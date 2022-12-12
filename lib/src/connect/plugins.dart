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
        debugPrint("[plugin] plugin-$pluginType:$version");
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
    debugPrint("[plugin] plugins init");
    initialized = true;

    await ZegoUIKit()
        .getSignalingPlugin()
        .init(appID, appSign: appSign)
        .then((value) {
      debugPrint("[plugin] plugins init done");
    });

    debugPrint("[plugin] plugins init, login...");
    await ZegoUIKit()
        .getSignalingPlugin()
        .login(userID, userName)
        .then((value) async {
      debugPrint("[plugin] plugins login done, join room...");
      return joinRoom().then((value) {
        debugPrint("[plugin] plugins room joined");
        roomHasInitLogin = true;
      });
    });

    debugPrint("[plugin] plugins init done");
  }

  Future<bool> joinRoom() async {
    debugPrint("[plugin] plugins joinRoom");

    return await ZegoUIKit()
        .getSignalingPlugin()
        .joinRoom(roomID)
        .then((result) {
      debugPrint(
          "[plugin] plugins login result: ${result.code} ${result.message}");
      if (result.code.isNotEmpty) {
        showDebugToast("login room failed, ${result.code} ${result.message}");
      }

      return result.code.isEmpty;
    });
  }

  Future<void> uninit() async {
    debugPrint("[plugin] uninit");
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
      debugPrint("[plugin] same user, cancel this re-login");
      return;
    }

    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().login(userID, userName);
  }

  void onUserConnectionState(Map params) {
    debugPrint("[plugin] onUserConnectionState, param: $params");

    pluginUserStateNotifier.value =
        PluginConnectionState.values[params['state']!];

    debugPrint(
        "[plugin] onUserConnectionState, user state: ${pluginUserStateNotifier.value}");

    if (tryReLogging &&
        pluginUserStateNotifier.value == PluginConnectionState.connected) {
      tryReLogging = false;
      onPluginReLogin?.call();
    }

    tryReEnterRoom();
  }

  void onRoomState(Map params) {
    debugPrint("[plugin] onRoomState, param: $params");

    roomStateNotifier.value = PluginRoomState.values[params['state']!];

    debugPrint(
        "[plugin] onRoomState, state: ${roomStateNotifier.value}, networkState:$networkState");

    tryReEnterRoom();
  }

  void onNetworkModeChanged(ZegoNetworkMode networkMode) {
    debugPrint(
        "[plugin] onNetworkModeChanged $networkMode, previous network state: $networkState");

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
    debugPrint("[plugin] tryReLogin, state:${pluginUserStateNotifier.value}");

    if (!initialized) {
      debugPrint("[plugin] tryReLogin, plugin is not init");
      return;
    }

    if (pluginUserStateNotifier.value != PluginConnectionState.disconnected) {
      debugPrint("[plugin] tryReLogin, user state is not disconnected");
      return;
    }

    debugPrint("[plugin] re-login, id:$userID, name:$userName");
    tryReLogging = true;
    return await ZegoUIKit().getSignalingPlugin().logout().then((value) async {
      await ZegoUIKit().getSignalingPlugin().login(userID, userName);
    });
  }

  Future<bool> tryReEnterRoom() async {
    debugPrint(
        "[plugin] tryReEnterRoom, room state: ${roomStateNotifier.value}, networkState:$networkState");

    if (!initialized) {
      debugPrint("[plugin] tryReEnterRoom, plugin is not init");
      return false;
    }
    if (!roomHasInitLogin) {
      debugPrint("[plugin] tryReEnterRoom, first login room has not finished");
      return false;
    }

    if (PluginRoomState.disconnected != roomStateNotifier.value) {
      debugPrint("[plugin] tryReEnterRoom, room state is not disconnected");
      return false;
    }

    if (networkState != PluginNetworkState.online) {
      debugPrint("[plugin] tryReEnterRoom, network is not connected");
      return false;
    }

    if (pluginUserStateNotifier.value != PluginConnectionState.connected) {
      debugPrint("[plugin] tryReEnterRoom, user state is not connected");
      return false;
    }

    debugPrint("[plugin] try re-enter room");
    return await joinRoom().then((result) {
      debugPrint("[plugin] re-enter room result:$result");

      if (!result) {
        return false;
      }

      onPluginReLogin?.call();

      return true;
    });
  }
}
