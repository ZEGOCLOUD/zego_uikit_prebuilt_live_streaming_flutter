part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

extension ZegoLiveStreamingPipStatus on PiPStatus {
  ZegoPiPStatus toZego() {
    switch (this) {
      case PiPStatus.enabled:
        return ZegoPiPStatus.enabled;
      case PiPStatus.disabled:
        return ZegoPiPStatus.disabled;
      case PiPStatus.automatic:
        return ZegoPiPStatus.automatic;
      case PiPStatus.unavailable:
        return ZegoPiPStatus.unavailable;
    }
  }
}

/// @nodoc

mixin ZegoLiveStreamingControllerPIPImplPrivate {
  final _private = ZegoLiveStreamingControllerPIPImplPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerPIPImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoLiveStreamingControllerPIPImplPrivateImpl {
  ZegoLiveStreamingControllerPIPInterface? _pipImpl;

  ZegoLiveStreamingControllerPIPInterface pipImpl() {
    if (null == _pipImpl) {
      if (Platform.isAndroid) {
        _pipImpl = ZegoLiveStreamingControllerPIPAndroid();
      } else if (Platform.isIOS) {
        _pipImpl = ZegoLiveStreamingControllerIOSPIP();
      } else {
        assert(false, 'platform not support');
      }
    }

    return _pipImpl!;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) async {
    await pipImpl().initByPrebuilt(config: config);
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    pipImpl().uninitByPrebuilt();
  }
}
