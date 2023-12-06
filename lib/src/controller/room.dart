part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
class ZegoLiveStreamingRoomController {
  final ValueNotifier<bool> isLeaveRequestingNotifier =
      ValueNotifier<bool>(false);

  ZegoUIKitPrebuiltLiveStreamingConfig? get _prebuiltConfig =>
      ZegoLiveStreamingManagers().hostManager?.config;

  ZegoLiveHostManager? get _hostManager =>
      ZegoLiveStreamingManagers().hostManager;

  Future<bool> leave(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
    if (null == _hostManager) {
      ZegoLoggerService.logInfo(
        'leave, param is invalid, hostManager:$_hostManager',
        tag: 'live streaming',
        subTag: 'controller.room',
      );

      return false;
    }

    if (isLeaveRequestingNotifier.value) {
      ZegoLoggerService.logInfo(
        'leave, is leave requesting...',
        tag: 'live streaming',
        subTag: 'controller.room',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'leave, show confirmation:$showConfirmation',
      tag: 'live streaming',
      subTag: 'controller.room',
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
          subTag: 'controller.room',
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
        subTag: 'controller.room',
      );

      return 0 == result.errorCode;
    });

    final isFromMinimizing =
        ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().isMinimizing;
    if (isFromMinimizing) {
      /// leave in minimizing
      if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) !=
          null) {
        await ZegoUIKit().getSignalingPlugin().leaveRoom();

        /// not need logout
        // await ZegoUIKit().getSignalingPlugin().logout();
        /// not need destroy signaling sdk
        await ZegoUIKit().getSignalingPlugin().uninit(forceDestroy: false);
      }

      await ZegoLiveStreamingManagers().uninitPluginAndManagers();

      ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().resetInLiving();

      if (_hostManager?.isLocalHost ?? false) {
        /// host end/leave live streaming
        _prebuiltConfig?.onLiveStreamingEnded?.call(isFromMinimizing);
      } else {
        /// audience leave live streaming
        _prebuiltConfig?.onLeaveLiveStreaming?.call(isFromMinimizing);
      }

      /// from minimizing, not need to return to the previous page by default
    } else {
      if (_hostManager?.isLocalHost ?? false) {
        /// host end/leave live streaming
        if (_prebuiltConfig?.onLiveStreamingEnded != null) {
          _prebuiltConfig?.onLiveStreamingEnded?.call(isFromMinimizing);
        } else {
          /// return to the previous page by default
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
          /// return to the previous page by default
          Navigator.of(
            context,
            rootNavigator: _prebuiltConfig?.rootNavigator ?? true,
          ).pop();
        }
      }
    }

    ZegoLoggerService.logInfo(
      'leave, finished',
      tag: 'live streaming',
      subTag: 'controller.room',
    );

    return result;
  }
}
