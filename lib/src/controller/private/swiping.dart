part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerSwipingPrivate {
  final _private = ZegoLiveStreamingControllerSwipingPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerSwipingPrivateImpl get private => _private;
}

/// @nodoc
/// Here are the APIs related to invitation.
class ZegoLiveStreamingControllerSwipingPrivateImpl {
  ZegoLiveStreamingSwipingConfig? config;

  StreamController<String>? stream;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void initByPrebuilt({
    required ZegoLiveStreamingSwipingConfig? swipingConfig,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live.swiping',
      subTag: 'controller.swiping.p',
    );

    stream ??= StreamController<String>.broadcast();
    config = swipingConfig;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'live.swiping',
      subTag: 'controller.swiping.p',
    );

    config = null;

    stream?.close();
    stream = null;
  }
}
