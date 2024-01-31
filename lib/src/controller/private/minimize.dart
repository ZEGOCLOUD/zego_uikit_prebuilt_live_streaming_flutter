part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMinimizingPrivate {
  final _private = ZegoLiveStreamingControllerMinimizingPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerMinimizingPrivateImpl get private => _private;
}

/// @nodoc
/// Here are the APIs related to invitation.
class ZegoLiveStreamingControllerMinimizingPrivateImpl {
  ZegoUIKitPrebuiltLiveStreamingData? get minimizeData => _minimizeData;

  ZegoUIKitPrebuiltLiveStreamingData? _minimizeData;

  ZegoLiveConnectManager? get _connectManager =>
      ZegoLiveStreamingManagers().connectManager;

  bool get isLiving =>
      _connectManager?.liveStatusNotifier.value == LiveStatus.living;

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingData minimizeData,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    _minimizeData = minimizeData;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    _minimizeData = null;
  }
}
