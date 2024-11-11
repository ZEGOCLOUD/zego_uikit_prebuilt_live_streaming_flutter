part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerPrivate {
  final _impl = ZegoLiveStreamingControllerPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerPrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerPrivateImpl {
  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt() {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.p',
    );
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.p',
    );
  }
}
