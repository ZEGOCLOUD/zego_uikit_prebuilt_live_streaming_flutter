part of 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_controller.dart';

/// @nodoc
mixin ZegoUIKitPrebuiltLiveStreamingControllerPrivate {
  final screenSharingViewController = ZegoScreenSharingViewController();

  ZegoUIKitPrebuiltLiveStreamingConfig? _prebuiltConfig;
  ZegoLiveHostManager? _hostManager;
  ZegoLiveConnectManager? _connectManager;

  final ValueNotifier<bool> isLeaveRequestingNotifier =
      ValueNotifier<bool>(false);

  /// DO NOT CALL
  /// Call Inside By Prebuilt
  /// prebuilt assign value to internal variables
  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig prebuiltConfig,
    required ZegoLiveHostManager hostManager,
    required ZegoLiveConnectManager connectManager,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live streaming',
      subTag: 'controller_p',
    );

    _prebuiltConfig = prebuiltConfig;
    _hostManager = hostManager;
    _connectManager = connectManager;
  }

  /// DO NOT CALL
  /// Call Inside By Prebuilt
  /// prebuilt assign value to internal variables
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live streaming',
      subTag: 'controller_p',
    );

    isLeaveRequestingNotifier.value = false;

    _prebuiltConfig = null;
    _hostManager = null;
    _connectManager = null;
  }
}
