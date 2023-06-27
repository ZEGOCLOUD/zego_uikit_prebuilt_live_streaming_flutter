// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';

part 'package:zego_uikit_prebuilt_live_streaming/src/internal/controller_p.dart';

/// Used to control the live streaming functionality.
///
/// If the default live streaming UI and interactions do not meet your requirements, you can use this [ZegoUIKitPrebuiltLiveStreamingController] to actively control the business logic.
/// This class is used by setting the [ZegoUIKitPrebuiltLiveStreaming.controller] parameter in the constructor of [ZegoUIKitPrebuiltLiveStreaming].
class ZegoUIKitPrebuiltLiveStreamingController
    with ZegoUIKitPrebuiltLiveStreamingControllerPrivate {
  /// This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
  ///
  /// You need to provide the user's ID [userID] to determine which user to perform the operation on.
  /// By using a boolean value [isFullscreen], you can specify whether the user enters or exits full-screen mode.
  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screenSharingViewController.showScreenSharingViewInFullscreenMode(
        userID, isFullscreen);
  }

  /// This function is used to end the Live Streaming.
  ///
  /// You can pass the context [context] for any necessary pop-ups or page transitions.
  /// By using the [showConfirmation] parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming.
  ///
  /// This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the [ZegoUIKitPrebuiltLiveStreamingConfig.onLeaveConfirmation], [ZegoUIKitPrebuiltLiveStreamingConfig.onLiveStreamingEnded] and [ZegoUIKitPrebuiltLiveStreamingConfig.onLeaveLiveStreaming] settings in the config.
  Future<bool> leave(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
    if (null == _hostManager) {
      ZegoLoggerService.logInfo(
        'leave, param is invalid, hostManager:$_hostManager',
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
          await _prebuiltConfig?.onLeaveConfirmation?.call(context) ?? true;
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

    if (_hostManager?.isLocalHost ?? false) {
      /// live is ready to end, host will update if receive property notify
      /// so need to keep current host value, DISABLE local host value UPDATE
      _hostManager?.hostUpdateEnabledNotifier.value = false;
      await ZegoUIKit().updateRoomProperties({
        RoomPropertyKey.host.text: '',
        RoomPropertyKey.liveStatus.text: LiveStatus.ended.index.toString()
      });
    }

    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();

    final result = await ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'leave, leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'live streaming',
        subTag: 'controller',
      );

      return 0 == result.errorCode;
    });

    final isFromMinimizing =
        PrebuiltLiveStreamingMiniOverlayPageState.minimizing ==
            ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state();
    if (isFromMinimizing) {
      /// leave in minimizing
      if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) !=
          null) {
        await ZegoUIKit().getSignalingPlugin().leaveRoom();
        await ZegoUIKit().getSignalingPlugin().logout();
        await ZegoUIKit().getSignalingPlugin().uninit();
      }

      await ZegoLiveStreamingManagers().unintPluginAndManagers();

      ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().changeState(
        PrebuiltLiveStreamingMiniOverlayPageState.idle,
      );

      if (_hostManager?.isLocalHost ?? false) {
        /// host end/leave live streaming
        _prebuiltConfig?.onLiveStreamingEnded?.call(isFromMinimizing);
      } else {
        /// audience leave live streaming
        _prebuiltConfig?.onLeaveLiveStreaming?.call(isFromMinimizing);
      }
    } else {
      if (_hostManager?.isLocalHost ?? false) {
        /// host end/leave live streaming
        if (_prebuiltConfig?.onLiveStreamingEnded != null) {
          _prebuiltConfig?.onLiveStreamingEnded?.call(isFromMinimizing);
        } else {
          Navigator.of(
            context,
            rootNavigator: _prebuiltConfig?.rootNavigator ?? true,
          ).pop();
        }
      } else {
        /// audience leave live streaming
        if (_prebuiltConfig?.onLeaveLiveStreaming != null) {
          _prebuiltConfig?.onLeaveLiveStreaming?.call(isFromMinimizing);
        } else {
          Navigator.of(
            context,
            rootNavigator: _prebuiltConfig?.rootNavigator ?? true,
          ).pop();
        }
      }
    }

    uninitByPrebuilt();

    ZegoLoggerService.logInfo(
      'leave, finished',
      tag: 'live streaming',
      subTag: 'controller',
    );

    return result;
  }

  /// remove co-host, make co-host to be a audience
  Future<bool> removeCoHost(ZegoUIKitUser coHost) async {
    if (null == _hostManager || null == _connectManager) {
      ZegoLoggerService.logInfo(
        'kick co-host, param is invalid, hostManager:$_hostManager, connectManager:$_connectManager',
        tag: 'live streaming',
        subTag: 'controller',
      );

      return false;
    }

    if (!_hostManager!.isLocalHost) {
      ZegoLoggerService.logInfo(
        'kick co-host, local is not a host',
        tag: 'live streaming',
        subTag: 'controller',
      );

      return false;
    }

    return _connectManager!.kickCoHost(coHost);
  }

  /// invite audience to be a co-host
  Future<void> makeAudienceCoHost(ZegoUIKitUser invitee) async {
    if (null == _hostManager || null == _connectManager) {
      ZegoLoggerService.logInfo(
        'kick co-host, param is invalid, hostManager:$_hostManager, connectManager:$_connectManager',
        tag: 'live streaming',
        subTag: 'controller',
      );

      return;
    }

    if (!_hostManager!.isLocalHost) {
      ZegoLoggerService.logInfo(
        'kick co-host, local is not a host',
        tag: 'live streaming',
        subTag: 'controller',
      );

      return;
    }

    return _connectManager!.inviteAudienceConnect(invitee);
  }
}
