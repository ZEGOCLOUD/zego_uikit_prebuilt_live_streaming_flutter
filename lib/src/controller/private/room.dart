part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerRoomPrivate {
  final _impl = ZegoLiveStreamingControllerRoomPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerRoomPrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerRoomPrivateImpl {
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  ZegoUIKitPrebuiltLiveStreamingEvents? events;

  final ValueNotifier<bool> isLeaveRequestingNotifier =
      ValueNotifier<bool>(false);

  ZegoLiveStreamingHostManager? get hostManager =>
      ZegoLiveStreamingManagers().hostManager;

  Future<void> defaultEndAction(
    ZegoLiveStreamingEndEvent event,
    BuildContext context,
    bool rootNavigator,
  ) async {
    ZegoLoggerService.logInfo(
      'default call end event, event:$event',
      tag: 'live-streaming',
      subTag: 'controller.room.p',
    );

    if (ZegoLiveStreamingMiniOverlayPageState.minimizing ==
        ZegoUIKitPrebuiltLiveStreamingController().minimize.state) {
      /// now is minimizing state, not need to navigate, just switch to idle
      ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
    } else {
      try {
        if (context.mounted) {
          Navigator.of(
            context,
            rootNavigator: rootNavigator,
          ).pop(true);
        } else {
          ZegoLoggerService.logInfo(
            'live streaming end, context is not mounted',
            tag: 'live-streaming',
            subTag: 'controller.room.p',
          );
        }
      } catch (e) {
        ZegoLoggerService.logError(
          'live streaming end, navigator exception:$e, event:$event',
          tag: 'live-streaming',
          subTag: 'controller.room.p',
        );
      }
    }
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt({
    ZegoUIKitPrebuiltLiveStreamingConfig? config,
    ZegoUIKitPrebuiltLiveStreamingEvents? events,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.room.p',
    );

    this.config = config;
    this.events = events;

    isLeaveRequestingNotifier.value = false;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.room.p',
    );

    config = null;
    events = null;

    isLeaveRequestingNotifier.value = false;
  }

  Future<bool> defaultLeaveConfirmationAction(
    ZegoLiveStreamingLeaveConfirmationEvent event,
  ) async {
    if (config?.confirmDialogInfo == null) {
      return true;
    }

    final confirmDialogInfo = config?.confirmDialogInfo ??
        ZegoLiveStreamingDialogInfo(
          title: 'Stop the live',
          message: 'Are you sure to stop the live?',
          cancelButtonName: 'Cancel',
          confirmButtonName: 'Stop it',
        );

    return showLiveDialog(
      context: event.context,
      rootNavigator: config?.rootNavigator ?? false,
      title: confirmDialogInfo.title,
      content: confirmDialogInfo.message,
      leftButtonText: confirmDialogInfo.cancelButtonName,
      leftButtonCallback: () {
        //  pop this dialog
        try {
          Navigator.of(
            event.context,
            rootNavigator: config?.rootNavigator ?? false,
          ).pop(false);
        } catch (e) {
          ZegoLoggerService.logError(
            'call hangup confirmation, '
            'navigator exception:$e, '
            'event:$event',
            tag: 'live-streaming',
            subTag: 'controller.p',
          );
        }
      },
      rightButtonText: confirmDialogInfo.confirmButtonName,
      rightButtonCallback: () {
        //  pop this dialog
        try {
          Navigator.of(
            event.context,
            rootNavigator: config?.rootNavigator ?? false,
          ).pop(true);
        } catch (e) {
          ZegoLoggerService.logError(
            'call hangup confirmation, '
            'navigator exception:$e, '
            'event:$event',
            tag: 'live-streaming',
            subTag: 'controller.p',
          );
        }
      },
    );
  }
}
