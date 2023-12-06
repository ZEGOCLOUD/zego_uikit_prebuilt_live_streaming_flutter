part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMinimizing {
  final _minimizingController = ZegoLiveStreamingMinimizingController();

  ZegoLiveStreamingMinimizingController get minimize => _minimizingController;
}

/// Here are the APIs related to screen sharing.
class ZegoLiveStreamingMinimizingController {
  ZegoLiveConnectManager? get _connectManager =>
      ZegoLiveStreamingManagers().connectManager;

  bool get _isLiving =>
      _connectManager?.liveStatusNotifier.value == LiveStatus.living;

  void toMinimize() {
    if (ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logInfo(
        'is minimizing, ignore',
        tag: 'live streaming',
        subTag: 'controller.mini',
      );

      return;
    }

    if (!_isLiving) {
      ZegoLoggerService.logInfo(
        'is not living, ignore',
        tag: 'live streaming',
        subTag: 'controller.mini',
      );

      return;
    }

    ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().toMinimize();

    final context = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().context;
    if (context?.mounted ?? false) {
      Navigator.of(context!).pop();
    } else {
      ZegoLoggerService.logInfo(
        'context is not valid, could not pop',
        tag: 'live streaming',
        subTag: 'controller.mini',
      );
    }
  }
}
