part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerAudioVideoImplPrivate {
  final _private = ZegoLiveStreamingControllerAudioVideoImplPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerAudioVideoImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoLiveStreamingControllerAudioVideoImplPrivateImpl {
  ZegoUIKitPrebuiltLiveStreamingConfig? config;

  final _microphone = ZegoLiveStreamingControllerAudioVideoMicrophoneImpl();
  final _camera = ZegoLiveStreamingControllerAudioVideoCameraImpl();

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveAudioRoom.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live streaming',
      subTag: 'controller.audioVideo.p',
    );

    this.config = config;

    _microphone.private.initByPrebuilt(config: config);
    _camera.private.initByPrebuilt(config: config);
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveAudioRoom.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'live streaming',
      subTag: 'controller.audioVideo.p',
    );

    config = null;

    _microphone.private.uninitByPrebuilt();
    _camera.private.uninitByPrebuilt();
  }
}

/// @nodoc
mixin ZegoLiveStreamingControllerAudioVideoDeviceImplPrivate {
  final _private = ZegoLiveStreamingControllerAudioVideoImplDevicePrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerAudioVideoImplDevicePrivateImpl get private =>
      _private;
}

/// @nodoc
class ZegoLiveStreamingControllerAudioVideoImplDevicePrivateImpl {
  ZegoUIKitPrebuiltLiveStreamingConfig? config;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveAudioRoom.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live streaming',
      subTag: 'controller.audioVideo.p',
    );

    this.config = config;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveAudioRoom.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'live streaming',
      subTag: 'controller.audioVideo.p',
    );

    config = null;
  }
}
