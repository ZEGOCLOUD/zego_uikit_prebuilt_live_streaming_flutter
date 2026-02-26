part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// Mixin that provides hall list control functionality for the live streaming controller.
///
/// Access via [ZegoUIKitPrebuiltLiveStreamingController.hall].
mixin ZegoLiveStreamingControllerHall {
  final ZegoLiveStreamingControllerHallImpl _hallImpl =
      ZegoLiveStreamingControllerHallImpl();

  /// Returns the hall list implementation instance.
  ZegoLiveStreamingControllerHallImpl get hall => _hallImpl;
}

/// media series API
class ZegoLiveStreamingControllerHallImpl
    with ZegoLiveStreamingControllerHallPrivate {}
