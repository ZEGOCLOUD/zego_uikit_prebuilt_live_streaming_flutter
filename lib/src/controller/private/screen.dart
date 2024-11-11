part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerScreenImplPrivate {
  final _private = ZegoLiveStreamingControllerScreenImplPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerScreenImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoLiveStreamingControllerScreenImplPrivateImpl {
  final viewController = ZegoScreenSharingViewController();

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) async {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.screenSharing.p',
    );

    if (null != config?.screenSharing.autoStop) {
      viewController.private.autoStopSettings.invalidCount =
          config!.screenSharing.autoStop.invalidCount;
      viewController.private.autoStopSettings.canEnd =
          config.screenSharing.autoStop.canEnd;
    }
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.pip.p',
    );
  }
}
