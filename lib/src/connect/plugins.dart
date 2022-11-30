// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

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

  final List<IZegoUIKitPlugin> plugins;

  ZegoPrebuiltPlugins({
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.plugins,
  }) {
    _install();
  }

  PluginNetworkState networkState = PluginNetworkState.unknown;
  List<StreamSubscription<dynamic>?> subscriptions = [];
  PluginConnectionState pluginConnectionState =
      PluginConnectionState.disconnected;

  bool get isEnabled => plugins.isNotEmpty;

  void _install() {
    ZegoUIKit().installPlugins(plugins);
    for (var pluginType in ZegoUIKitPluginType.values) {
      ZegoUIKit().getPlugin(pluginType)?.getVersion().then((version) {
        debugPrint("plugin-$pluginType:$version");
      });
    }

    subscriptions.add(ZegoUIKit()
        .getSignalingPlugin()
        .getInvitationConnectionStateStream()
        .listen(onInvitationConnectionState));

    subscriptions
        .add(ZegoUIKit().getNetworkModeStream().listen(onNetworkModeChanged));
  }

  Future<void> init() async {
    await ZegoUIKit().getSignalingPlugin().init(appID, appSign: appSign);
    await ZegoUIKit().getSignalingPlugin().login(userID, userName);
  }

  Future<void> uninit() async {
    // TODO: Let's see if the life cycle here makes sense
    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().uninit();

    for (var streamSubscription in subscriptions) {
      streamSubscription?.cancel();
    }
  }

  Future<void> onUserInfoUpdate(String userID, String userName) async {
    var localUser = ZegoUIKit().getLocalUser();
    if (localUser.id == userID && localUser.name == userName) {
      debugPrint("same user, cancel this re-login");
      return;
    }

    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().login(userID, userName);
  }

  void onInvitationConnectionState(Map params) {
    debugPrint("[plugin] onInvitationConnectionState, param: $params");

    pluginConnectionState = PluginConnectionState.values[params['state']!];

    debugPrint(
        "[plugin] onInvitationConnectionState, state: $pluginConnectionState");
  }

  void onNetworkModeChanged(ZegoNetworkMode networkMode) {
    debugPrint("[plugin] onNetworkModeChanged $networkMode, "
        "network state: $networkState");

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
          reconnectIfDisconnected();
        }
        networkState = PluginNetworkState.online;
        break;
    }
  }

  void reconnectIfDisconnected() {
    debugPrint(
        "[plugin] reconnectIfDisconnected, state:$pluginConnectionState");
    if (pluginConnectionState == PluginConnectionState.disconnected) {
      debugPrint("[plugin] reconnect, id:$userID, name:$userName");
      ZegoUIKit().getSignalingPlugin().logout().then((value) {
        ZegoUIKit().getSignalingPlugin().login(userID, userName);
      });
    }
  }
}
