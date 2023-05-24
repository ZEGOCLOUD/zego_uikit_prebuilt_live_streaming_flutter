// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

part 'package:zego_uikit_prebuilt_live_streaming/src/internal/controller_p.dart';

/// Used to control the live streaming functionality.
/// If the default live streaming UI and interactions do not meet your requirements, you can use this [ZegoUIKitPrebuiltLiveStreamingController] to actively control the business logic.
/// This class is used by setting the [controller] parameter in the constructor of [ZegoUIKitPrebuiltLiveStreaming].
class ZegoUIKitPrebuiltLiveStreamingController
    with ZegoUIKitPrebuiltLiveStreamingControllerPrivate {
  /// This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
  /// You need to provide the user's ID [userID] to determine which user to perform the operation on.
  /// By using a boolean value [isFullscreen], you can specify whether the user enters or exits full-screen mode.
  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screenSharingViewController.showScreenSharingViewInFullscreenMode(
        userID, isFullscreen);
  }

  /// This function is used to end the Live Streaming.
  /// You can pass the context [context] for any necessary pop-ups or page transitions.
  /// By using the [showConfirmation] parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming.
  /// This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the [onLeaveConfirmation], [onLiveStreamingEnded] and [onLeaveLiveStreaming] settings in the config.
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

    if (hostManager?.isLocalHost ?? false) {
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

    if (hostManager?.isLocalHost ?? false) {
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
