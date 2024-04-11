part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMessagePrivate {
  final _impl = ZegoLiveStreamingControllerMessagePrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerMessagePrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerMessagePrivateImpl {
  StreamController<ZegoInRoomMessage>? streamControllerPseudoMessage;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveStreaming.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt() {
    streamControllerPseudoMessage ??=
        StreamController<ZegoInRoomMessage>.broadcast();
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveStreaming.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    streamControllerPseudoMessage?.close();
    streamControllerPseudoMessage = null;
  }
}
