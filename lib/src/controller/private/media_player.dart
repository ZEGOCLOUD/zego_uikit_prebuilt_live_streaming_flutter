// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';

class ZegoLiveStreamingControllerMediaDefaultPlayer
    with ZegoLiveStreamingControllerMediaDefaultPlayerPrivate {
  ValueNotifier<bool> get visibleNotifier => private.visibleNotifier;

  void sharing(String filePathOrURL) {
    ZegoLoggerService.logInfo(
      'sharing, '
      'path:$filePathOrURL',
      tag: 'live-streaming',
      subTag: 'controller.media.player',
    );

    if (!(private.config?.mediaPlayer.defaultPlayer.support ?? false)) {
      ZegoLoggerService.logInfo(
        'sharing, but {config.mediaPlayer.defaultPlayer.support} is not support',
        tag: 'live-streaming',
        subTag: 'controller.media.player',
      );

      return;
    }

    String fileExtension = '';
    if (filePathOrURL.contains('.')) {
      fileExtension = filePathOrURL.split('.').last.toLowerCase();
    }
    final supportExtensions = [
      ...zegoMediaVideoExtensions,
      ...zegoMediaAudioExtensions,
    ];
    if (!supportExtensions.contains(fileExtension)) {
      ZegoLoggerService.logInfo(
        'extension($fileExtension) is not valid, only support:$supportExtensions',
        tag: 'live-streaming',
        subTag: 'controller.media.player',
      );

      return;
    }

    show();
    private.sharingPathNotifier.value = filePathOrURL;
  }

  void show() {
    ZegoLoggerService.logInfo(
      'showPlayer, ',
      tag: 'live-streaming',
      subTag: 'controller.media.player',
    );

    private.visibleNotifier.value = true;
  }

  void hide({
    bool needStop = true,
  }) {
    ZegoLoggerService.logInfo(
      'hidePlayer, '
      'needStop:$needStop, ',
      tag: 'live-streaming',
      subTag: 'controller.media.player',
    );

    if (needStop) {
      ZegoUIKit().stopMedia();
    }

    private.visibleNotifier.value = false;
  }
}

mixin ZegoLiveStreamingControllerMediaDefaultPlayerPrivate {
  final _impl = ZegoLiveStreamingControllerMediaDefaultPlayerPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerMediaDefaultPlayerPrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerMediaDefaultPlayerPrivateImpl {
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  final sharingPathNotifier = ValueNotifier<String?>(null);
  final visibleNotifier = ValueNotifier<bool>(false);

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveStreaming.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.media.p',
    );

    this.config = config;

    ZegoUIKit().getMediaPlayStateNotifier().addListener(onPlayStateChanged);
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveStreaming.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.media.p',
    );

    ZegoUIKit().getMediaPlayStateNotifier().removeListener(onPlayStateChanged);

    config = null;
    visibleNotifier.value = false;
    sharingPathNotifier.value = null;
  }

  void onPlayStateChanged() {
    final playState = ZegoUIKit().getMediaPlayStateNotifier().value;

    ZegoLoggerService.logInfo(
      'onPlayStateChanged, state:$playState',
      tag: 'live-streaming',
      subTag: 'controller.media.p',
    );

    if (ZegoUIKitMediaPlayState.noPlay == playState) {
      sharingPathNotifier.value = null;
    }
  }
}
