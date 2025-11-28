// Dart imports:
import 'dart:async';

// Package imports:
import 'package:floating/floating.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/pip/pip_interface.dart';

class ZegoLiveStreamingControllerPIPAndroid
    implements ZegoLiveStreamingControllerPIPInterface {
  final _private = ZegoCallControllerPIPImplPrivateAndroid();

  Floating get floating => _private.floating;

  @override
  bool get isRestoredFromPIP => _private.isRestoredFromPIP;

  @override
  Future<ZegoPiPStatus> get status async =>
      (await _private.floating.pipStatus).toZego();

  @override
  Future<bool> get available async => await _private.floating.isPipAvailable;

  @override
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    final isPipAvailable = await _private.floating.isPipAvailable;
    if (!isPipAvailable) {
      ZegoLoggerService.logError(
        'but pip is not available, ',
        tag: 'live.streaming.controller.pip',
        subTag: 'enable',
      );

      return ZegoPiPStatus.unavailable;
    }

    var status = ZegoPiPStatus.unavailable;
    try {
      status = (await _private.floating.enable(
        ImmediatePiP(
          aspectRatio: Rational(aspectWidth, aspectHeight),
        ),
      ))
          .toZego();
    } catch (e) {
      ZegoLoggerService.logInfo(
        'exception:${e.toString()}',
        tag: 'live.streaming.controller.pip',
        subTag: 'enable',
      );
    }
    return status;
  }

  @override
  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    var status = ZegoPiPStatus.unavailable;
    try {
      status = await _private.enableWhenBackground(
        aspectWidth: aspectWidth,
        aspectHeight: aspectHeight,
      );
    } catch (e) {
      ZegoLoggerService.logInfo(
        'exception:${e.toString()}',
        tag: 'live.streaming.controller.pip',
        subTag: 'enableWhenBackground',
      );
    }
    return status;
  }

  @override
  Future<void> cancelBackground() async {
    /// back to app
    await ZegoUIKit().activeAppToForeground();

    try {
      await _private.floating.cancelOnLeavePiP();
    } catch (e) {
      ZegoLoggerService.logInfo(
        'exception:${e.toString()}',
        tag: 'live.streaming.controller.pip',
        subTag: 'cancelOnLeavePiP',
      );
    }
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  @override
  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) async {
    await _private.initByPrebuilt(config: config);
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  @override
  void uninitByPrebuilt() {
    _private.uninitByPrebuilt();
  }
}

class ZegoCallControllerPIPImplPrivateAndroid {
  final floating = Floating();
  ZegoUIKitPrebuiltLiveStreamingConfig? config;

  bool isInPIP = false;
  bool isRestoredFromPIP = false;

  StreamSubscription<dynamic>? subscription;

  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.controller.pip',
      subTag: 'initByPrebuilt',
    );

    this.config = config;

    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .isMinimizingNotifier
        .addListener(onMinimizeStateChanged);

    subscription = floating.pipStatusStream.listen(onPIPStatusUpdated);

    if (config?.pip.enableWhenBackground ?? true) {
      await enableWhenBackground(
        aspectWidth: config?.pip.aspectWidth ?? 9,
        aspectHeight: config?.pip.aspectHeight ?? 16,
      );
    }
  }

  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.controller.pip',
      subTag: 'uninitByPrebuilt',
    );

    config = null;

    subscription?.cancel();

    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .isMinimizingNotifier
        .removeListener(onMinimizeStateChanged);
  }

  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    final isPipAvailable = await floating.isPipAvailable;
    if (!isPipAvailable) {
      ZegoLoggerService.logError(
        'but pip is not available, ',
        tag: 'live.streaming.controller.pip',
        subTag: 'enableWhenBackground',
      );

      return ZegoPiPStatus.unavailable;
    }

    try {
      return (await floating.enable(
        OnLeavePiP(
          aspectRatio: Rational(aspectWidth, aspectHeight),
        ),
      ))
          .toZego();
    } catch (e) {
      ZegoLoggerService.logWarn(
        'exception:$e, ',
        tag: 'live.streaming.controller.pip',
        subTag: 'enableWhenBackground',
      );

      return ZegoPiPStatus.disabled;
    }
  }

  void onMinimizeStateChanged() async {
    if (!ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing) {
      if (config?.pip.enableWhenBackground ?? true) {
        await enableWhenBackground(
          aspectWidth: config?.pip.aspectWidth ?? 9,
          aspectHeight: config?.pip.aspectHeight ?? 16,
        );
      }
    }
  }

  void onPIPStatusUpdated(PiPStatus status) {
    ZegoLoggerService.logInfo(
      'status:$status, ',
      tag: 'live.streaming.controller.pip',
      subTag: 'onPIPStatusUpdated',
    );

    switch (status) {
      case PiPStatus.enabled:
        isInPIP = true;
        break;
      case PiPStatus.disabled:
        if (isInPIP) {
          isRestoredFromPIP = true;
          isInPIP = false;

          /// can't know when the rendering will end after restoration.
          /// get default value of camera/microphone in bottom bar
          Future.delayed(const Duration(seconds: 1), () {
            isRestoredFromPIP = false;
          });
        }

        if (config?.pip.enableWhenBackground ?? true) {
          enableWhenBackground(
            aspectWidth: config?.pip.aspectWidth ?? 9,
            aspectHeight: config?.pip.aspectHeight ?? 16,
          );
        }
        break;
      case PiPStatus.automatic:
        break;
      case PiPStatus.unavailable:
        break;
    }
  }
}
