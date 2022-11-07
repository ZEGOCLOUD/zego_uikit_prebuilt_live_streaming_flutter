// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'defines.dart';

class ZegoLiveHostManager {
  ZegoLiveConnectManager? connectManager;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  ZegoLiveHostManager({required this.config}) {
    configIsHost = config.isHost;

    subscriptions
      ..add(
          ZegoUIKit().getRoomPropertiesStream().listen(onRoomPropertiesUpdated))
      ..add(ZegoUIKit().getUserListStream().listen(onUserListUpdated));
  }

  /// internal variables
  final hostUpdateEnabledNotifier = ValueNotifier<bool>(true);
  final notifier = ValueNotifier<ZegoUIKitUser?>(null);
  String pendingUserID = "";
  List<StreamSubscription<dynamic>?> subscriptions = [];
  int localHostPropertyUpdateTime = 0;
  bool configIsHost = false;

  bool get isHost =>
      // if not receive room 'host' property yet, then checkout config
      (notifier.value == null && configIsHost) ||
      // if room 'host' property received, checkout notifier value
      (notifier.value != null &&
          ZegoUIKit().getLocalUser().id == notifier.value!.id);

  Future<void> init() async {
    debugPrint("[host mgr] init");

    if (configIsHost) {
      debugPrint(
          "[host mgr] local user ${ZegoUIKit().getLocalUser().toString()} is host in config");
      if (notifier.value != null &&
          notifier.value!.id != ZegoUIKit().getLocalUser().id) {
        /// host is exist
        debugPrint(
            "[host mgr] host is exist:${notifier.value!.id} ${notifier.value!.name}");
      } else {
        localHostPropertyUpdateTime = DateTime.now().millisecondsSinceEpoch;
        debugPrint(
            "[host mgr] set room property to notify, timestamp:$localHostPropertyUpdateTime");
        updateHostValue(ZegoUIKit().getLocalUser());
        await ZegoUIKit().updateRoomProperty(
            RoomPropertyKey.host.text, ZegoUIKit().getLocalUser().id);
      }
    }
  }

  void uninit() {
    debugPrint("[host mgr] uninit");

    if (isHost) {
      debugPrint("[host mgr] host uninit host property");
      ZegoUIKit().updateRoomProperty(RoomPropertyKey.host.text, "");
    }

    hostUpdateEnabledNotifier.value = true;
    notifier.value = null;
    pendingUserID = "";

    for (var subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    if (pendingUserID.isNotEmpty) {
      debugPrint("[host mgr] exist pending host $pendingUserID");

      var host = ZegoUIKit().getUser(pendingUserID);
      if (host != null && !host.isEmpty()) {
        debugPrint("[host mgr] host updated, ${host.toString()}");
        updateHostValue(host);
        pendingUserID = "";
      }
    }
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    if (!updatedProperties.containsKey(RoomPropertyKey.host.text)) {
      debugPrint("[host mgr] update properties not contain host");
      return;
    }

    var roomProperties = ZegoUIKit().getRoomProperties();
    debugPrint(
        "[host mgr] onRoomPropertiesUpdated roomProperties:$roomProperties");

    /// host exist
    var hostIDProperty = roomProperties[RoomPropertyKey.host.text]!;
    if (hostIDProperty.updateUserID == ZegoUIKit().getLocalUser().id) {
      return;
    }

    if (hostIDProperty.updateTime < localHostPropertyUpdateTime) {
      /// local property(config set in init) is newer than current room property (sdk)
      debugPrint(
          "[host mgr] host property update time is older than local setting time, "
          "property timestamp:${hostIDProperty.updateTime}, "
          "local timestamp:$localHostPropertyUpdateTime");
      return;
    }

    if (hostIDProperty.value.isEmpty) {
      /// host gone or null
      var localHostReceived = notifier.value != null &&
          ZegoUIKit().getLocalUser().id == notifier.value!.id;
      debugPrint("[host mgr] host key is not exist, host is gone or null, "
          "local host had received: $localHostReceived");
      if (localHostReceived) {
        debugPrint("[host mgr] sync host property");
        ZegoUIKit().updateRoomProperty(
            RoomPropertyKey.host.text, ZegoUIKit().getLocalUser().id);
      } else {
        updateHostValue(null);
      }
    } else if (notifier.value?.id != hostIDProperty.value) {
      debugPrint("[host mgr] update host to be: ${hostIDProperty.toString()}");
      var host = ZegoUIKit().getUser(hostIDProperty.value);
      if ((host == null || host.isEmpty()) && hostIDProperty.value.isNotEmpty) {
        debugPrint(
            "[host mgr] $hostIDProperty user is not exist, host will be wait update util user list update");
        pendingUserID = hostIDProperty.value;
      } else {
        if (host?.id != notifier.value?.id &&
            notifier.value?.id == ZegoUIKit().getLocalUser().id) {
          /// local host, change by new host, switch to audience
          connectManager?.updateAudienceConnectState(ConnectState.connecting);
          connectManager?.updateAudienceConnectState(ConnectState.idle);
        }

        updateHostValue(host);
      }
    }
  }

  void setConnectManger(ZegoLiveConnectManager manager) {
    connectManager = manager;
  }

  void updateHostValue(ZegoUIKitUser? host) {
    if (hostUpdateEnabledNotifier.value) {
      debugPrint("[host mgr] host updated, ${host?.toString()}");
      if (notifier.value?.id != host?.id) {
        if (config.isHost && host?.id != ZegoUIKit().getLocalUser().id) {
          configIsHost = false;
        }

        notifier.value = host;
      }
    } else {
      /// in host ready to end, host should not update, otherwise host condition will failed
      debugPrint("[host mgr] host update disabled, ${host?.toString()}");
    }
  }
}
