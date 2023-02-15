// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';

enum PluginNetworkState {
  unknown,
  offline,
  online,
}

class ZegoPrebuiltPlugins {
  ZegoPrebuiltPlugins(
      {required this.appID,
      required this.appSign,
      required this.userID,
      required this.userName,
      required this.roomID,
      required this.plugins,
      this.onPluginReLogin}) {
    _install();
  }
  final int appID;
  final String appSign;

  final String userID;
  final String userName;

  final String roomID;

  final List<IZegoUIKitPlugin> plugins;

  final VoidCallback? onPluginReLogin;

  PluginNetworkState networkState = PluginNetworkState.unknown;
  List<StreamSubscription<dynamic>?> subscriptions = [];
  ValueNotifier<ZegoSignalingPluginConnectionState> pluginUserStateNotifier =
      ValueNotifier<ZegoSignalingPluginConnectionState>(
          ZegoSignalingPluginConnectionState.disconnected);
  ValueNotifier<ZegoSignalingPluginRoomState> roomStateNotifier =
      ValueNotifier<ZegoSignalingPluginRoomState>(
          ZegoSignalingPluginRoomState.disconnected);
  bool tryReLogging = false;
  bool initialized = false;
  bool roomHasInitLogin = false;

  bool get isEnabled => plugins.isNotEmpty;

  void _install() {
    ZegoUIKit().installPlugins(plugins);
    for (final pluginType in ZegoUIKitPluginType.values) {
      ZegoUIKit().getPlugin(pluginType)?.getVersion().then((version) {
        ZegoLoggerService.logInfo(
          'plugin-$pluginType:$version',
          tag: 'live streaming',
          subTag: 'plugin',
        );
      });
    }

    subscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getConnectionStateStream()
          .listen(onUserConnectionState))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getRoomStateStream()
          .listen(onRoomState))
      ..add(ZegoUIKit().getNetworkModeStream().listen(onNetworkModeChanged));
  }

  Future<void> init() async {
    ZegoLoggerService.logInfo(
      'plugins init',
      tag: 'live streaming',
      subTag: 'plugin',
    );
    initialized = true;

    await ZegoUIKit()
        .getSignalingPlugin()
        .init(appID, appSign: appSign)
        .then((value) {
      ZegoLoggerService.logInfo(
        'plugins init done',
        tag: 'live streaming',
        subTag: 'plugin',
      );
    });

    ZegoLoggerService.logInfo(
      'plugins init, login...',
      tag: 'live streaming',
      subTag: 'plugin',
    );
    await ZegoUIKit()
        .getSignalingPlugin()
        .login(id: userID, name: userName)
        .then((value) async {
      ZegoLoggerService.logInfo(
        'plugins login done, join room...',
        tag: 'live streaming',
        subTag: 'plugin',
      );
      return joinRoom().then((value) {
        ZegoLoggerService.logInfo(
          'plugins room joined',
          tag: 'live streaming',
          subTag: 'plugin',
        );
        roomHasInitLogin = true;
      });
    });

    ZegoLoggerService.logInfo(
      'plugins init done',
      tag: 'live streaming',
      subTag: 'plugin',
    );
  }

  Future<bool> joinRoom() async {
    ZegoLoggerService.logInfo(
      'plugins joinRoom',
      tag: 'live streaming',
      subTag: 'plugin',
    );

    return ZegoUIKit().getSignalingPlugin().joinRoom(roomID).then((result) {
      if (result.error != null) {
        ZegoLoggerService.logInfo('[plugin] plugins login failed: ${result.error}',
        tag: 'live streaming',
        subTag: 'plugin',
      );
        showDebugToast('login room failed, ${result.error}');
      } else {
        ZegoLoggerService.logInfo('[plugin] plugins login success',
        tag: 'live streaming',
        subTag: 'plugin',
      );
      }

      return result.error == null;
    });
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'plugin',
    );
    initialized = false;

    roomHasInitLogin = false;
    tryReLogging = false;

    await ZegoUIKit().getSignalingPlugin().leaveRoom();
    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().uninit();

    for (final streamSubscription in subscriptions) {
      streamSubscription?.cancel();
    }
  }

  Future<void> onUserInfoUpdate(String userID, String userName) async {
    final localUser = ZegoUIKit().getLocalUser();
    if (localUser.id == userID && localUser.name == userName) {
      ZegoLoggerService.logInfo(
        'same user, cancel this re-login',
        tag: 'live streaming',
        subTag: 'plugin',
      );
      return;
    }

    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().login(id: userID, name: userName);
  }

  void onUserConnectionState(
      ZegoSignalingPluginConnectionStateChangedEvent event) {
    ZegoLoggerService.logInfo('[plugin] onUserConnectionState, param: $event',
      tag: 'live streaming',
      subTag: 'plugin',
    );

    pluginUserStateNotifier.value = event.state;

    ZegoLoggerService.logInfo(
      'onUserConnectionState, user state: ${pluginUserStateNotifier.value}',
      tag: 'live streaming',
      subTag: 'plugin',
    );

    if (tryReLogging &&
        pluginUserStateNotifier.value ==
            ZegoSignalingPluginConnectionState.connected) {
      tryReLogging = false;
      onPluginReLogin?.call();
    }

    tryReEnterRoom();
  }

  void onRoomState(ZegoSignalingPluginRoomStateChangedEvent event) {
    ZegoLoggerService.logInfo(
      'onRoomState, event: $event',
      tag: 'live streaming',
      subTag: 'plugin',
    );

    roomStateNotifier.value = event.state;

    ZegoLoggerService.logInfo(
        '[plugin] onRoomState, state: ${roomStateNotifier.value}, networkState:$networkState',      
      tag: 'live streaming',
      subTag: 'plugin',
    );

    tryReEnterRoom();
  }

  void onNetworkModeChanged(ZegoNetworkMode networkMode) {
    ZegoLoggerService.logInfo(
      'onNetworkModeChanged $networkMode, previous network state: $networkState',
      tag: 'live streaming',
      subTag: 'plugin',
    );

    switch (networkMode) {
      case ZegoNetworkMode.Offline:
      case ZegoNetworkMode.Unknown:
        networkState = PluginNetworkState.offline;
        break;
      case ZegoNetworkMode.Ethernet:
      case ZegoNetworkMode.WiFi:
      case ZegoNetworkMode.Mode2G:
      case ZegoNetworkMode.Mode3G:
      case ZegoNetworkMode.Mode4G:
      case ZegoNetworkMode.Mode5G:
        if (PluginNetworkState.offline == networkState) {
          tryReLogin();
        }

        networkState = PluginNetworkState.online;
        break;
    }
  }

  Future<void> tryReLogin() async {
    ZegoLoggerService.logInfo('[plugin] tryReLogin, state:${pluginUserStateNotifier.value}',      
      tag: 'live streaming',
      subTag: 'plugin',
    );

    if (!initialized) {
      ZegoLoggerService.logInfo('[plugin] tryReLogin, plugin is not init',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
      return;
    }

    if (pluginUserStateNotifier.value !=
        ZegoSignalingPluginConnectionState.disconnected) {
      ZegoLoggerService.logInfo('[plugin] tryReLogin, user state is not disconnected',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
      return;
    }

    ZegoLoggerService.logInfo('[plugin] re-login, id:$userID, name:$userName',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
    tryReLogging = true;
    return await ZegoUIKit().getSignalingPlugin().logout().then((value) async {
      await ZegoUIKit().getSignalingPlugin().login(id: userID, name: userName);
    });
  }

  Future<bool> tryReEnterRoom() async {
    ZegoLoggerService.logInfo(
        '[plugin] tryReEnterRoom, room state: ${roomStateNotifier.value}, networkState:$networkState');

    if (!initialized) {
      ZegoLoggerService.logInfo('[plugin] tryReEnterRoom, plugin is not init',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
      return false;
    }
    if (!roomHasInitLogin) {
      ZegoLoggerService.logInfo('[plugin] tryReEnterRoom, first login room has not finished',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
      return false;
    }

    if (ZegoSignalingPluginRoomState.disconnected != roomStateNotifier.value) {
      ZegoLoggerService.logInfo('[plugin] tryReEnterRoom, room state is not disconnected',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
      return false;
    }

    if (networkState != PluginNetworkState.online) {
      ZegoLoggerService.logInfo('[plugin] tryReEnterRoom, network is not connected',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
      return false;
    }

    if (pluginUserStateNotifier.value !=
        ZegoSignalingPluginConnectionState.connected) {
      ZegoLoggerService.logInfo('[plugin] tryReEnterRoom, user state is not connected',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
      return false;
    }

    ZegoLoggerService.logInfo('[plugin] try re-enter room',      
      tag: 'live streaming',
      subTag: 'plugin',
    );
    return await joinRoom().then((result) {
      ZegoLoggerService.logInfo('[plugin] re-enter room result:$result',      
      tag: 'live streaming',
      subTag: 'plugin',
    );

      if (!result) {
        return false;
      }

      onPluginReLogin?.call();

      return true;
    });
  }
}
