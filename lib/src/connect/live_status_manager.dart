// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'defines.dart';

class ZegoLiveStatusManager {
  ZegoLiveConnectManager? connectManager;
  final ZegoLiveHostManager hostManager;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  ZegoLiveStatusManager({
    required this.hostManager,
    required this.config,
  }) {
    subscriptions.add(
        ZegoUIKit().getRoomPropertiesStream().listen(onRoomPropertiesUpdated));
  }

  /// internal variables
  var notifier = ValueNotifier<LiveStatus>(LiveStatus.notStart);
  List<StreamSubscription<dynamic>?> subscriptions = [];

  bool get isAudience =>
      !hostManager.isHost && !isCoHost(ZegoUIKit().getLocalUser());

  Future<void> init() async {
    debugPrint("[live status mgr] init");

    if (!hostManager.isHost) {
      ZegoUIKit().stopPlayAllAudioVideo();
    }

    if (hostManager.isHost) {
      debugPrint(
          "[live status mgr] host init live status to end and start play all audio video");
      ZegoUIKit().startPlayAllAudioVideo();
      await ZegoUIKit().updateRoomProperty(
          RoomPropertyKey.liveStatus.text, LiveStatus.ended.index.toString());
    }
  }

  void uninit() {
    debugPrint("[live status mgr] uninit");

    if (hostManager.isHost) {
      debugPrint("[live status mgr] host uninit live status property to end");

      /// un-normal leave by leave button
      ZegoUIKit().updateRoomProperty(
          RoomPropertyKey.liveStatus.text, LiveStatus.ended.index.toString());
    }

    notifier.value = LiveStatus.notStart;

    for (var subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void setConnectManger(ZegoLiveConnectManager manager) {
    connectManager = manager;
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    if (!updatedProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      debugPrint("[live status mgr] update properties not contain live status");
      return;
    }

    var roomProperties = ZegoUIKit().getRoomProperties();

    debugPrint(
        "[live status mgr] onRoomPropertiesUpdated roomProperties:$roomProperties");

    if (!roomProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      /// live is not start if host not enter
      debugPrint(
          "[live status mgr] host key is not exist, set live status not start");
      notifier.value = LiveStatus.notStart;
    } else if (roomProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      /// live is start or end
      var liveStatusValue = roomProperties[RoomPropertyKey.liveStatus.text]!;
      notifier.value = 1 == int.parse(liveStatusValue.value)
          ? LiveStatus.living //  start: 1
          : LiveStatus.ended; //  end: 0, empty, null or others
      debugPrint(
          "[live status mgr] update live status, value is $liveStatusValue, status is ${notifier.value}");
    } else {
      /// live is not start
      debugPrint(
          "[live status mgr] live status key is not exist, live is not start");
      notifier.value = LiveStatus.notStart;
    }

    if (!hostManager.isHost) {
      if (notifier.value == LiveStatus.living) {
        ZegoUIKit().startPlayAllAudioVideo();
      } else {
        ZegoUIKit().stopPlayAllAudioVideo();

        ZegoUIKit().turnCameraOn(false);
        ZegoUIKit().turnMicrophoneOn(false);
      }
    }

    if (LiveStatus.ended == notifier.value && !hostManager.isHost) {
      debugPrint("live status is end, co-host switch to audience");
      connectManager?.updateAudienceConnectState(ConnectState.idle);
    }
  }
}
