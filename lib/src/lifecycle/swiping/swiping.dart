// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/defines.dart';

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
      tag: 'live.streaming.lifecyle-swiping',
      subTag: 'initFromPreview',
    );

    config = swipingConfig;
    currentLiveID = liveID;
    this.hallConfig = hallConfig;

    if (!usingRoomSwiping) {
      ZegoLoggerService.logInfo(
        'not using swiping, ignore',
        tag: 'live.streaming.lifecyle-swiping',
        subTag: 'initFromPreview',
      );

      return;
    }

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

    await ZegoUIKit().enableSwitchRoomNotStopPlay(true);

    if (isPrebuiltFromHall) {
      hallRoomID = ZegoUIKit().getCurrentRoom().id;

      /// here's no need to stop the push and pull streams here,
      /// because hall pulls the host stream, and swiping to navigate to the live stream page requires this.
      await ZegoUIKit().switchRoom(
        toRoomID: liveID,
        stopPublishAllStream: false,
        stopPlayAllStream: false,
        clearStreamData: false,
        clearUserData: false,
      );
    }
  }

  Future<void> uninitFromPreview({
    required bool isPrebuiltFromHall,
  }) async {
    streamContext.uninit();

    config = null;
    hallRoomID = '';
    hallConfig = null;
  }
}
