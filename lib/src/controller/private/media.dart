part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMediaPrivate {
  final _impl = ZegoLiveStreamingControllerMediaPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerMediaPrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerMediaPrivateImpl {
  final defaultPlayer = ZegoLiveStreamingControllerMediaDefaultPlayer();

  ZegoUIKitPrebuiltLiveStreamingConfig? config;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveStreaming.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.media.p',
    );

    this.config = config;

    defaultPlayer.private.initByPrebuilt(config: config);
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveStreaming.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.media.p',
    );

    config = null;
    defaultPlayer.private.uninitByPrebuilt();
  }
}
