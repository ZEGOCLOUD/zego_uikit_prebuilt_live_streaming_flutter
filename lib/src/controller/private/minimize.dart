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
  ZegoLiveStreamingMinimizeData? get minimizeData => _minimizeData;

  ZegoLiveStreamingMinimizeData? _minimizeData;

  ZegoLiveStreamingConnectManager? get _connectManager =>
      ZegoLiveStreamingManagers().connectManager;

  bool get isLiving =>
      _connectManager?.liveStatusNotifier.value == LiveStatus.living;
  final isMinimizingNotifier = ValueNotifier<bool>(false);

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void initByPrebuilt({
    required ZegoLiveStreamingMinimizeData minimizeData,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    _minimizeData = minimizeData;

    isMinimizingNotifier.value =
        ZegoLiveStreamingMiniOverlayMachine().isMinimizing;
    ZegoLiveStreamingMiniOverlayMachine()
        .registerStateChanged(onMiniOverlayMachineStateChanged);
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    _minimizeData = null;

    ZegoLiveStreamingMiniOverlayMachine()
        .unregisterStateChanged(onMiniOverlayMachineStateChanged);
  }

  void onMiniOverlayMachineStateChanged(
    ZegoLiveStreamingMiniOverlayPageState state,
  ) {
    isMinimizingNotifier.value =
        ZegoLiveStreamingMiniOverlayPageState.minimizing == state;
  }
}
