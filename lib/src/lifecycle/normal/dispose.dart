// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/overlay_machine.dart';

/// @nodoc
class ZegoLiveStreamingPageLifeCycleDispose {
  Future<void> run({
    required String targetLiveID,
    required ZegoLiveStreamingManagers? currentManagers,
    required ZegoLiveStreamingPageLifeCycleContextData data,
    required bool canLeaveRoom,
    required bool isFromMinimize,
  }) async {
    ZegoLoggerService.logInfo(
      'room id:$targetLiveID, '
      'canLeaveRoom:$canLeaveRoom, ',
      tag: 'live.streaming.lifecyle-dispose',
      subTag: 'run',
    );

    /// not return if cause by minimized close
    if (!isFromMinimize && ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logInfo(
        'isMinimizing, ignore',
        tag: 'live.streaming.lifecyle-dispose',
        subTag: 'run',
      );

      return;
    }

    if (ZegoUIKit().getScreenSharingStateNotifier().value) {
      ZegoUIKit().stopSharingScreen(targetRoomID: targetLiveID);
    }

    await currentManagers?.uninitPluginAndManagers(
      isFromMinimize: isFromMinimize,
    );

    if (data.config.role == ZegoLiveStreamingRole.audience) {
      /// audience, should be start play when leave
      ZegoUIKit().unmuteAllRemoteAudioVideo(targetRoomID: targetLiveID);
    }
    if (null != data.config.audienceAudioVideoResourceMode) {
      ZegoUIKit().setPlayerResourceMode(
        targetRoomID: targetLiveID,
        ZegoUIKitStreamResourceMode.Default,
      );
    }

    ZegoUIKit().turnCameraOn(targetRoomID: targetLiveID, false);
    ZegoUIKit().turnMicrophoneOn(targetRoomID: targetLiveID, false);

    await _uninitBaseBeautyConfig();

    if (canLeaveRoom) {
      await ZegoUIKit().leaveRoom(targetRoomID: targetLiveID).then(
        (_) {
          _onRoomLogout(data: data);
        },
      );
    }

    ZegoUIKitPrebuiltLiveStreamingController().private.uninitByPrebuilt();
    ZegoLiveStreamingPageLifeCycle()
        .normal
        .initStateDelegate
        .clear(targetLiveID);
  }

  Future<void> _uninitBaseBeautyConfig() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.lifecyle-dispose',
      subTag: 'uninitBaseBeautyConfig',
    );

    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();
    await ZegoUIKit().stopEffectsEnv();
    await ZegoUIKit().enableBeauty(false);
  }

  void _onRoomLogout({
    required ZegoLiveStreamingPageLifeCycleContextData data,
  }) {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.lifecyle-dispose',
      subTag: 'onRoomLogout',
    );

    /// only effect call after leave room
    ZegoUIKit().enableCustomVideoProcessing(false);
  }
}
