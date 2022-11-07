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

    subscriptions.add(ZegoUIKitInvitationService()
        .getInvitationConnectionStateStream()
        .listen(onInvitationConnectionState));

    subscriptions
        .add(ZegoUIKit().getNetworkModeStream().listen(onNetworkModeChanged));
  }

  Future<void> init() async {
    await ZegoUIKitInvitationService().init(appID, appSign: appSign);
    await ZegoUIKitInvitationService().login(userID, userName);
  }

  Future<void> uninit() async {
    // TODO: Let's see if the life cycle here makes sense
    await ZegoUIKitInvitationService().logout();
    await ZegoUIKitInvitationService().uninit();

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

    await ZegoUIKitInvitationService().logout();
    await ZegoUIKitInvitationService().login(userID, userName);
  }

  void onInvitationConnectionState(Map params) {
    debugPrint("[live invitation] onInvitationConnectionState, param: $params");

    pluginConnectionState = PluginConnectionState.values[params['state']!];

    debugPrint(
        "[live invitation] onInvitationConnectionState, state: $pluginConnectionState");
  }

  void onNetworkModeChanged(ZegoNetworkMode networkMode) {
    debugPrint("[live invitation] onNetworkModeChanged $networkMode, "
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
        "[live invitation] reconnectIfDisconnected, state:$pluginConnectionState");
    if (pluginConnectionState == PluginConnectionState.disconnected) {
      debugPrint("[live invitation] reconnect, id:$userID, name:$userName");
      ZegoUIKitInvitationService().logout().then((value) {
        ZegoUIKitInvitationService().login(userID, userName);
      });
    }
  }
}
