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
  final int appID;
  final String appSign;

  final String userID;
  final String userName;

  final String roomID;

  final List<IZegoUIKitPlugin> plugins;

  final VoidCallback? onPluginReLogin;

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

  PluginNetworkState networkState = PluginNetworkState.unknown;
  List<StreamSubscription<dynamic>?> subscriptions = [];
  var pluginUserStateNotifier =
      ValueNotifier<PluginConnectionState>(PluginConnectionState.disconnected);
  var roomStateNotifier =
      ValueNotifier<PluginRoomState>(PluginRoomState.disconnected);
  bool tryReLogging = false;
  bool initialized = false;
  bool roomHasInitLogin = false;

  bool get isEnabled => plugins.isNotEmpty;

  void _install() {
    ZegoUIKit().installPlugins(plugins);
    for (var pluginType in ZegoUIKitPluginType.values) {
      ZegoUIKit().getPlugin(pluginType)?.getVersion().then((version) {
        ZegoLoggerService.logInfo(
          "plugin-$pluginType:$version",
          tag: "live streaming",
          subTag: "plugin",
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
      "plugins init",
      tag: "live streaming",
      subTag: "plugin",
    );
    initialized = true;

    await ZegoUIKit()
        .getSignalingPlugin()
        .init(appID, appSign: appSign)
        .then((value) {
      ZegoLoggerService.logInfo(
        "plugins init done",
        tag: "live streaming",
        subTag: "plugin",
      );
    });

    ZegoLoggerService.logInfo(
      "plugins init, login...",
      tag: "live streaming",
      subTag: "plugin",
    );
    await ZegoUIKit()
        .getSignalingPlugin()
        .login(userID, userName)
        .then((value) async {
      ZegoLoggerService.logInfo(
        "plugins login done, join room...",
        tag: "live streaming",
        subTag: "plugin",
      );
      return joinRoom().then((value) {
        ZegoLoggerService.logInfo(
          "plugins room joined",
          tag: "live streaming",
          subTag: "plugin",
        );
        roomHasInitLogin = true;
      });
    });

    ZegoLoggerService.logInfo(
      "plugins init done",
      tag: "live streaming",
      subTag: "plugin",
    );
  }

  Future<bool> joinRoom() async {
    ZegoLoggerService.logInfo(
      "plugins joinRoom",
      tag: "live streaming",
      subTag: "plugin",
    );

    return await ZegoUIKit()
        .getSignalingPlugin()
        .joinRoom(roomID)
        .then((result) {
      ZegoLoggerService.logInfo(
        "plugins login result: ${result.code} ${result.message}",
        tag: "live streaming",
        subTag: "plugin",
      );
      if (result.code.isNotEmpty) {
        showDebugToast("login room failed, ${result.code} ${result.message}");
      }

      return result.code.isEmpty;
    });
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      "uninit",
      tag: "live streaming",
      subTag: "plugin",
    );
    initialized = false;

    roomHasInitLogin = false;
    tryReLogging = false;

    await ZegoUIKit().getSignalingPlugin().leaveRoom();
    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().uninit();

    for (var streamSubscription in subscriptions) {
      streamSubscription?.cancel();
    }
  }

  Future<void> onUserInfoUpdate(String userID, String userName) async {
    var localUser = ZegoUIKit().getLocalUser();
    if (localUser.id == userID && localUser.name == userName) {
      ZegoLoggerService.logInfo(
        "same user, cancel this re-login",
        tag: "live streaming",
        subTag: "plugin",
      );
      return;
    }

    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().login(userID, userName);
  }

  void onUserConnectionState(Map params) {
    ZegoLoggerService.logInfo(
      "onUserConnectionState, param: $params",
      tag: "live streaming",
      subTag: "plugin",
    );

    pluginUserStateNotifier.value =
        PluginConnectionState.values[params['state']!];

    ZegoLoggerService.logInfo(
      "onUserConnectionState, user state: ${pluginUserStateNotifier.value}",
      tag: "live streaming",
      subTag: "plugin",
    );

    if (tryReLogging &&
        pluginUserStateNotifier.value == PluginConnectionState.connected) {
      tryReLogging = false;
      onPluginReLogin?.call();
    }

    tryReEnterRoom();
  }

  void onRoomState(Map params) {
    ZegoLoggerService.logInfo(
      "onRoomState, param: $params",
      tag: "live streaming",
      subTag: "plugin",
    );

    roomStateNotifier.value = PluginRoomState.values[params['state']!];

    ZegoLoggerService.logInfo(
      "onRoomState, state: ${roomStateNotifier.value}, networkState:$networkState",
      tag: "live streaming",
      subTag: "plugin",
    );

    tryReEnterRoom();
  }

  void onNetworkModeChanged(ZegoNetworkMode networkMode) {
    ZegoLoggerService.logInfo(
      "onNetworkModeChanged $networkMode, previous network state: $networkState",
      tag: "live streaming",
      subTag: "plugin",
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
    ZegoLoggerService.logInfo(
      "tryReLogin, state:${pluginUserStateNotifier.value}",
      tag: "live streaming",
      subTag: "plugin",
    );

    if (!initialized) {
      ZegoLoggerService.logInfo(
        "tryReLogin, plugin is not init",
        tag: "live streaming",
        subTag: "plugin",
      );
      return;
    }

    if (pluginUserStateNotifier.value != PluginConnectionState.disconnected) {
      ZegoLoggerService.logInfo(
        "tryReLogin, user state is not disconnected",
        tag: "live streaming",
        subTag: "plugin",
      );
      return;
    }

    ZegoLoggerService.logInfo(
      "re-login, id:$userID, name:$userName",
      tag: "live streaming",
      subTag: "plugin",
    );
    tryReLogging = true;
    return await ZegoUIKit().getSignalingPlugin().logout().then((value) async {
      await ZegoUIKit().getSignalingPlugin().login(userID, userName);
    });
  }

  Future<bool> tryReEnterRoom() async {
    ZegoLoggerService.logInfo(
      "tryReEnterRoom, room state: ${roomStateNotifier.value}, networkState:$networkState",
      tag: "live streaming",
      subTag: "plugin",
    );

    if (!initialized) {
      ZegoLoggerService.logInfo(
        "tryReEnterRoom, plugin is not init",
        tag: "live streaming",
        subTag: "plugin",
      );
      return false;
    }
    if (!roomHasInitLogin) {
      ZegoLoggerService.logInfo(
        "tryReEnterRoom, first login room has not finished",
        tag: "live streaming",
        subTag: "plugin",
      );
      return false;
    }

    if (PluginRoomState.disconnected != roomStateNotifier.value) {
      ZegoLoggerService.logInfo(
        "tryReEnterRoom, room state is not disconnected",
        tag: "live streaming",
        subTag: "plugin",
      );
      return false;
    }

    if (networkState != PluginNetworkState.online) {
      ZegoLoggerService.logInfo(
        "tryReEnterRoom, network is not connected",
        tag: "live streaming",
        subTag: "plugin",
      );
      return false;
    }

    if (pluginUserStateNotifier.value != PluginConnectionState.connected) {
      ZegoLoggerService.logInfo(
        "tryReEnterRoom, user state is not connected",
        tag: "live streaming",
        subTag: "plugin",
      );
      return false;
    }

    ZegoLoggerService.logInfo(
      "try re-enter room",
      tag: "live streaming",
      subTag: "plugin",
    );
    return await joinRoom().then((result) {
      ZegoLoggerService.logInfo(
        "re-enter room result:$result",
        tag: "live streaming",
        subTag: "plugin",
      );

      if (!result) {
        return false;
      }

      onPluginReLogin?.call();

      return true;
    });
  }
}
