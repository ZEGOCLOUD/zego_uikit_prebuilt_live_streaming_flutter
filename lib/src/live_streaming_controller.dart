// Package imports:
import 'package:flutter/cupertino.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

part 'package:zego_uikit_prebuilt_live_streaming/src/internal/controller_p.dart';

class ZegoUIKitPrebuiltLiveStreamingController
    with ZegoUIKitPrebuiltLiveStreamingControllerPrivate {
  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screenSharingViewController.showScreenSharingViewInFullscreenMode(
        userID, isFullscreen);
  }

  /// actively leave the current live
  Future<bool> leave(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
    if (null == hostManager) {
      ZegoLoggerService.logInfo(
        'leave, param is invalid, hostManager:$hostManager',
        tag: 'live streaming',
        subTag: 'controller',
      );

      return false;
    }

    if (isLeaveRequestingNotifier.value) {
      ZegoLoggerService.logInfo(
        'leave, is leave requesting...',
        tag: 'live streaming',
        subTag: 'controller',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'leave, show confirmation:$showConfirmation',
      tag: 'live streaming',
      subTag: 'controller',
    );
    isLeaveRequestingNotifier.value = true;

    if (showConfirmation) {
      ///  if there is a user-defined event before the click,
      ///  wait the synchronize execution result
      final canLeave =
          await prebuiltConfig?.onLeaveConfirmation?.call(context) ?? true;
      if (!canLeave) {
        ZegoLoggerService.logInfo(
          'leave, refuse',
          tag: 'live streaming',
          subTag: 'controller',
        );

        isLeaveRequestingNotifier.value = false;

        return false;
      }
    }

    if (hostManager?.isHost ?? false) {
      /// live is ready to end, host will update if receive property notify
      /// so need to keep current host value, DISABLE local host value UPDATE
      hostManager?.hostUpdateEnabledNotifier.value = false;
      await ZegoUIKit().updateRoomProperties({
        RoomPropertyKey.host.text: '',
        RoomPropertyKey.liveStatus.text: LiveStatus.ended.index.toString()
      });
    }

    final result = await ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'leave, leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'live streaming',
        subTag: 'controller',
      );

      return 0 == result.errorCode;
    });

    if (hostManager?.isHost ?? false) {
      /// host end/leave live streaming
      if (prebuiltConfig?.onLiveStreamingEnded != null) {
        prebuiltConfig?.onLiveStreamingEnded?.call();
      } else {
        Navigator.of(
          context,
          rootNavigator: prebuiltConfig?.rootNavigator ?? true,
        ).pop();
      }
    } else {
      /// audience leave live streaming
      if (prebuiltConfig?.onLeaveLiveStreaming != null) {
        prebuiltConfig?.onLeaveLiveStreaming?.call();
      } else {
        Navigator.of(
          context,
          rootNavigator: prebuiltConfig?.rootNavigator ?? true,
        ).pop();
      }
    }

    ZegoLoggerService.logInfo(
      'leave, finished',
      tag: 'live streaming',
      subTag: 'controller',
    );

    return result;
  }
}
