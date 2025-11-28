// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/pip/pip_interface.dart';

class ZegoLiveStreamingControllerIOSPIP
    extends ZegoLiveStreamingControllerPIPInterface {
  final _private = ZegoCallControllerPIPImplPrivateIOS();

  bool get isSupportInConfig => _private.isSupportInConfig;

  @override
  bool get isRestoredFromPIP => false;

  @override
  Future<bool> get available async {
    return _private.available;
  }

  @override
  Future<void> cancelBackground() async {}

  @override
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'live.streaming.controller.pip',
        subTag: 'enable',
      );

      return ZegoPiPStatus.unavailable;
    }

    if (!_private.isSupportInConfig) {
      ZegoLoggerService.logInfo(
        'not enable PIP in config',
        tag: 'live.streaming.controller.pip',
        subTag: 'enable',
      );

      return ZegoPiPStatus.unavailable;
    }

    ZegoUIKit().backToDesktop();
    return ZegoPiPStatus.enabled;
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
  Future<ZegoPiPStatus> get status async => ZegoPiPStatus.unavailable;

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

class ZegoCallControllerPIPImplPrivateIOS {
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  StreamSubscription<dynamic>? subscription;
  bool? _isSupportInConfig;
  bool? _isAvailable;

  bool get available {
    if (null != _isAvailable) {
      return _isAvailable!;
    }

    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    _isAvailable == systemVersion.major >= 15;
    return _isAvailable!;
  }

  bool get isSupportInConfig {
    if (null == _isSupportInConfig) {
      _isSupportInConfig = config?.pip.iOS.support ?? true;
      if (_isSupportInConfig!) {
        final systemVersion = ZegoUIKit().getMobileSystemVersion();
        if (systemVersion.major < 15) {
          ZegoLoggerService.logInfo(
            'not support pip smaller than 15',
            tag: 'live.streaming.controller.pip',
            subTag: 'isSupportInConfig',
          );

          _isSupportInConfig = false;
        }
      }
    }

    return _isSupportInConfig!;
  }

  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.controller.pip',
      subTag: 'initByPrebuilt',
    );

    this.config = config;

    if (!Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'only support iOS',
        tag: 'live.streaming.controller.pip',
        subTag: 'initByPrebuilt',
      );

      return;
    }

    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .activeUser
        .activeUserIDNotifier
        .addListener(onMinimizeActiveUserChanged);
    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .isMinimizingNotifier
        .addListener(onMinimizeStateChanged);

    ZegoUIKit()
        .adapterService()
        .registerMessageHandler(_onAppLifecycleStateChanged);

    if (isSupportInConfig) {
      if (config?.pip.enableWhenBackground ?? true) {
        await enableWhenBackground(
          aspectWidth: config?.pip.aspectWidth ?? 9,
          aspectHeight: config?.pip.aspectHeight ?? 16,
        );
      }
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
        .activeUser
        .activeUserIDNotifier
        .removeListener(onMinimizeActiveUserChanged);
    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .isMinimizingNotifier
        .removeListener(onMinimizeStateChanged);

    ZegoUIKit()
        .adapterService()
        .unregisterMessageHandler(_onAppLifecycleStateChanged);
  }

  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'live.streaming.controller.pip',
        subTag: 'enableWhenBackground',
      );

      return ZegoPiPStatus.unavailable;
    }

    if (isSupportInConfig) {
      await ZegoUIKit().enableIOSPIPAuto(
        true,
        aspectWidth: aspectWidth,
        aspectHeight: aspectHeight,
      );
      return ZegoPiPStatus.enabled;
    }

    return ZegoPiPStatus.unavailable;
  }

  void onMinimizeActiveUserChanged() {
    /// not support if ios pip, platform view will be render wrong user
    /// after changed
    // final targetUserID = ZegoUIKitPrebuiltLiveStreamingController()
    //         .minimize
    //         .private
    //         .activeUser
    //         .activeUserIDNotifier
    //         .value ??
    //     '';
    //
    // ZegoLoggerService.logInfo(
    //   'onMinimizeActiveUserChanged, $targetUserID',
    //   tag: 'live.streaming.controller.pip',
    //   subTag: 'controller.pip.p ios',
    // );
    //
    // if (ZegoUIKit().getLocalUser().id != targetUserID) {
    //   ZegoUIKit().updateIOSPIPSource(
    //     ZegoUIKit().getUser(targetUserID).streamID,
    //   );
    // }
  }

  void onMinimizeStateChanged() async {
    await forceUpdatePIPVC();
  }

  Future<void> forceUpdatePIPVC() async {
    if (ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing) {
      final currentActiveUserID = ZegoUIKitPrebuiltLiveStreamingController()
              .minimize
              .private
              .activeUser
              .activeUserIDNotifier
              .value ??
          '';

      /// new pip vc
      if (ZegoUIKit().getLocalUser().id != currentActiveUserID) {
        await ZegoUIKit().enableIOSPIP(
          ZegoUIKit()
              .getUser(
                targetRoomID:
                    ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
                currentActiveUserID,
              )
              .streamID,
          aspectWidth: config?.pip.aspectWidth ?? 9,
          aspectHeight: config?.pip.aspectHeight ?? 16,
        );
      }
    }
  }

  /// sync app background state
  void _onAppLifecycleStateChanged(AppLifecycleState appLifecycleState) async {
    ZegoLoggerService.logInfo(
      'state:$appLifecycleState',
      tag: 'live.streaming.controller.pip',
      subTag: 'onAppLifecycleStateChanged',
    );

    if (!isSupportInConfig) {
      return;
    }

    if (AppLifecycleState.resumed == appLifecycleState) {
      await ZegoUIKit().stopIOSPIP();
      await forceUpdatePIPVC();
    } else if (AppLifecycleState.inactive == appLifecycleState) {
      /// pip need render remote user's stream, local can not render
      if (ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing) {
        ZegoUIKitPrebuiltLiveStreamingController()
            .minimize
            .private
            .activeUser
            .switchActiveUserToRemoteUser();
      }
    }
  }
}
