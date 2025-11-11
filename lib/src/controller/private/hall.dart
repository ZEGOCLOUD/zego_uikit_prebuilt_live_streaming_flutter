part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerHallPrivate {
  final _impl = ZegoLiveStreamingControllerHallPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerHallPrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerHallPrivateImpl {
  ZegoLiveStreamingHallListController? _hallController;

  final ZegoLiveStreamingHallListController _defaultHallListController =
      ZegoLiveStreamingHallListController();

  ZegoLiveStreamingHallListController get controller =>
      _hallController ?? _defaultHallListController;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveStreaming.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt({
    required ZegoLiveStreamingHallListController? hallController,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.hall.p',
    );

    _hallController = hallController;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveStreaming.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.hall.p',
    );

    _hallController = null;
  }
}
