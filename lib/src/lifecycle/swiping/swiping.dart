// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/instance.dart';
import 'stream_context.dart';

class ZegoLiveStreamingSwipingLifeCycle {
  bool isPrebuiltFromHall = false;
  String currentLiveID = '';
  String hallRoomID = '';
  ZegoLiveStreamingSwipingConfig? config;
  ZegoLiveStreamingHallConfig? hallConfig;

  bool get usingRoomSwiping => config != null;

  /// Live streaming context data after each swipe onPageChanged
  final streamContext = LiveStreamingSwipingStreamContext();

  Future<void> initFromPreview({
    required String token,
    required String liveID,
    required ZegoLiveStreamingSwipingConfig? swipingConfig,
    required ZegoLiveStreamingHallConfig? hallConfig,
    required bool isPrebuiltFromHall,
    required ZegoLiveStreamingPageLifeCycleContextData contextData,
  }) async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live-streaming-lifecyle-swiping',
      subTag: 'initFromPreview',
    );

    config = swipingConfig;
    currentLiveID = liveID;
    this.hallConfig = hallConfig;
    this.isPrebuiltFromHall = isPrebuiltFromHall;

    /// If entered from live hall, use live hall's enter live flow, which has optimizations
    await ZegoUIKitPrebuiltLiveStreamingController()
        .hall
        .private
        .controller
        .private
        .moveStreamToTheirRoom();

    if (usingRoomSwiping) {
      /// Initialize initial live streaming swiping context data
      await streamContext.init(token: token, swipingConfig: swipingConfig);
    }

    await ZegoUIKit().turnCameraOn(
      targetRoomID: liveID,
      contextData.config.turnOnCameraWhenJoining,
    );
    await ZegoUIKit().turnMicrophoneOn(
      targetRoomID: liveID,
      contextData.config.turnOnMicrophoneWhenJoining,
    );

    await ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .liveStatusManager
        .checkShouldStopPlayAllAudioVideo(
          isPrebuiltFromHall: isPrebuiltFromHall,
        );

    await ZegoUIKit().enableSwitchRoomNotStopPlay(true);

    if (isPrebuiltFromHall) {
      hallRoomID = ZegoUIKit().getCurrentRoom().id;
      await ZegoUIKit().switchRoom(toRoomID: liveID);
    }
  }

  Future<void> uninitFromPreview() async {
    /// If entered from live hall, use live hall's exit live flow, which has optimizations
    /// todo: ignoreFilter only copy host's main
    await ZegoUIKitPrebuiltLiveStreamingController()
        .hall
        .private
        .controller
        .private
        .moveStreamToHall();

    if (ZegoUIKit().getScreenSharingStateNotifier().value) {
      ZegoUIKit().stopSharingScreen(targetRoomID: currentLiveID);
    }

    streamContext.uninit();

    isPrebuiltFromHall = false;
    config = null;

    if (hallRoomID.isNotEmpty) {
      /// Switch back to live hall
      await ZegoUIKit().switchRoom(toRoomID: hallRoomID);
    }
    hallRoomID = '';

    ZegoUIKitPrebuiltLiveStreamingController()
        .hall
        .private
        .controller
        .private
        .private
        .forceUpdate();
    hallConfig = null;
  }
}
