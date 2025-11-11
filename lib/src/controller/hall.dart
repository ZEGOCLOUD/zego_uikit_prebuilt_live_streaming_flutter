part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerHall {
  final ZegoLiveStreamingControllerHallImpl _hallImpl =
      ZegoLiveStreamingControllerHallImpl();

  ZegoLiveStreamingControllerHallImpl get hall => _hallImpl;
}

/// media series API
class ZegoLiveStreamingControllerHallImpl
    with ZegoLiveStreamingControllerHallPrivate {}
