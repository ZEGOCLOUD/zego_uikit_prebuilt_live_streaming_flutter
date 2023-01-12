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
    ZegoLoggerService.logInfo(
      "init",
      tag: "live streaming",
      subTag: "live status manager",
    );

    if (!hostManager.isHost) {
      ZegoUIKit().stopPlayAllAudioVideo();
    }

    if (hostManager.isHost) {
      ZegoLoggerService.logInfo(
        "host init live status to end and start play all audio video",
        tag: "live streaming",
        subTag: "live status manager",
      );
      ZegoUIKit().startPlayAllAudioVideo();
      await ZegoUIKit().setRoomProperty(
          RoomPropertyKey.liveStatus.text, LiveStatus.ended.index.toString());
    }
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      "uninit",
      tag: "live streaming",
      subTag: "live status manager",
    );

    if (hostManager.isHost) {
      ZegoLoggerService.logInfo(
        "host uninit live status property to end",
        tag: "live streaming",
        subTag: "live status manager",
      );

      /// un-normal leave by leave button
      ZegoUIKit().setRoomProperty(
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
      ZegoLoggerService.logInfo(
        "update properties not contain live status",
        tag: "live streaming",
        subTag: "live status manager",
      );
      return;
    }

    var roomProperties = ZegoUIKit().getRoomProperties();

    ZegoLoggerService.logInfo(
      "onRoomPropertiesUpdated roomProperties:$roomProperties",
      tag: "live streaming",
      subTag: "live status manager",
    );

    if (!roomProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      /// live is not start if host not enter
      ZegoLoggerService.logInfo(
        "host key is not exist, set live status not start",
        tag: "live streaming",
        subTag: "live status manager",
      );
      notifier.value = LiveStatus.notStart;
    } else if (roomProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      /// live is start or end
      var liveStatusValue = roomProperties[RoomPropertyKey.liveStatus.text]!;
      notifier.value = 1 == int.parse(liveStatusValue.value)
          ? LiveStatus.living //  start: 1
          : LiveStatus.ended; //  end: 0, empty, null or others
      ZegoLoggerService.logInfo(
        "update live status, value is $liveStatusValue, status is ${notifier.value}",
        tag: "live streaming",
        subTag: "live status manager",
      );
    } else {
      /// live is not start
      ZegoLoggerService.logInfo(
        "live status key is not exist, live is not start",
        tag: "live streaming",
        subTag: "live status manager",
      );
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
      ZegoLoggerService.logInfo(
        "live status is end, co-host switch to audience",
        tag: "live streaming",
        subTag: "live status manager",
      );
      connectManager?.updateAudienceConnectState(ConnectState.idle);
    }
  }
}
