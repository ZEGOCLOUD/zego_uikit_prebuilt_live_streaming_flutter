// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';

import 'stream_context.dart';

class ZegoLiveStreamingSwipingLifeCycle {
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

    /// If entered from live hall, use live hall's enter live flow, which has optimizations
    await ZegoUIKitPrebuiltLiveStreamingController()
        .hall
        .private
        .controller
        .private
        .moveStreamToTheirRoom();
    ZegoUIKitPrebuiltLiveStreamingController()
        .hall
        .private
        .controller
        .private
        .private
      ..clearData()
      ..uninit(
        /// 都不需要销毁，只是
        needEnableSwitchRoomNotStopPlay: false,
        needStopPlayAll: false,
        needLeaveRoom: false,
        needUninitSDK: false,
      );

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

  Future<void> uninitFromPreview({
    required bool isPrebuiltFromHall,
  }) async {
    if (ZegoUIKit().getScreenSharingStateNotifier().value) {
      ZegoUIKit().stopSharingScreen(targetRoomID: currentLiveID);
    }

    streamContext.uninit();

    config = null;
    hallRoomID = '';
    hallConfig = null;
  }
}
