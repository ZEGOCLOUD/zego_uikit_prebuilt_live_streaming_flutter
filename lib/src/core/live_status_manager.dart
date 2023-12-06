// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';

/// @nodoc
class ZegoLiveStatusManager {
  ZegoLiveConnectManager? connectManager;
  final ZegoLiveHostManager hostManager;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  bool _initialized = false;

  ZegoLiveStatusManager({
    required this.hostManager,
    required this.config,
  }) {
    subscriptions.add(
        ZegoUIKit().getRoomPropertiesStream().listen(onRoomPropertiesUpdated));
  }

  /// internal variables
  var notifier = ValueNotifier<LiveStatus>(LiveStatus.notStart);
  List<StreamSubscription<dynamic>?> subscriptions = [];

  Future<void> init() async {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live streaming',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'live status manager',
    );

    notifier.addListener(onLiveStatusUpdated);

    if (!hostManager.isLocalHost && notifier.value != LiveStatus.living) {
      /// audience, stop play first if not living, wait living to start play
      ZegoUIKit().stopPlayAllAudioVideo();
    }

    if (hostManager.isLocalHost) {
      ZegoLoggerService.logInfo(
        'host init live status to end and start play all audio video',
        tag: 'live streaming',
        subTag: 'live status manager',
      );
      ZegoUIKit().startPlayAllAudioVideo();

      if (config.previewConfig.showPreviewForHost) {
        await ZegoUIKit().setRoomProperty(
          RoomPropertyKey.liveStatus.text,
          LiveStatus.notStart.index.toString(),
        );
      } else {
        ZegoUIKit().setRoomProperty(
          RoomPropertyKey.liveStatus.text,
          LiveStatus.living.index.toString(),
        );
      }
    }
  }

  Future<void> uninit() async {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live streaming',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'live status manager',
    );

    notifier.removeListener(onLiveStatusUpdated);

    if (hostManager.isLocalHost) {
      ZegoLoggerService.logInfo(
        'host uninit live status property to end',
        tag: 'live streaming',
        subTag: 'live status manager',
      );

      config.onLiveStreamingStateUpdate?.call(ZegoLiveStreamingState.ended);

      /// un-normal leave by leave button
      await ZegoUIKit().setRoomProperty(
        RoomPropertyKey.liveStatus.text,
        LiveStatus.ended.index.toString(),
      );
    }

    notifier.value = LiveStatus.notStart;

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void setConnectManger(ZegoLiveConnectManager manager) {
    connectManager = manager;

    ZegoLoggerService.logInfo(
      'set connect manager',
      tag: 'live streaming',
      subTag: 'live status manager',
    );
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    if (!updatedProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      ZegoLoggerService.logInfo(
        'update properties not contain live status',
        tag: 'live streaming',
        subTag: 'live status manager',
      );
      return;
    }

    final roomProperties = ZegoUIKit().getRoomProperties();

    ZegoLoggerService.logInfo(
      'onRoomPropertiesUpdated roomProperties:$roomProperties',
      tag: 'live streaming',
      subTag: 'live status manager',
    );

    if (!roomProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      /// live is not start if host not enter
      ZegoLoggerService.logInfo(
        'host key is not exist, set live status not start',
        tag: 'live streaming',
        subTag: 'live status manager',
      );
      notifier.value = LiveStatus.notStart;
    } else if (roomProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      /// live is start or end
      final liveStatusValue = roomProperties[RoomPropertyKey.liveStatus.text]!;
      notifier.value = LiveStatus.values[
          int.tryParse(liveStatusValue.value) ?? LiveStatus.notStart.index];
      ZegoLoggerService.logInfo(
        'update live status, value is $liveStatusValue, status is ${notifier.value}',
        tag: 'live streaming',
        subTag: 'live status manager',
      );
    } else {
      /// live is not start
      ZegoLoggerService.logInfo(
        'live status key is not exist, live is not start',
        tag: 'live streaming',
        subTag: 'live status manager',
      );
      notifier.value = LiveStatus.notStart;
    }

    if (!hostManager.isLocalHost) {
      if (notifier.value == LiveStatus.living) {
        /// audience, living to start play
        ZegoUIKit().startPlayAllAudioVideo();
      } else {
        ZegoUIKit().stopPlayAllAudioVideo();

        ZegoUIKit().turnCameraOn(false);
        ZegoUIKit().turnMicrophoneOn(false);
      }
    }

    if (LiveStatus.ended == notifier.value && !hostManager.isLocalHost) {
      ZegoLoggerService.logInfo(
        'live status is end, co-host switch to audience',
        tag: 'live streaming',
        subTag: 'live status manager',
      );
      connectManager?.updateAudienceConnectState(
          ZegoLiveStreamingAudienceConnectState.idle);
    }
  }

  void onLiveStatusUpdated() {
    switch (notifier.value) {
      case LiveStatus.ended:
        config.onLiveStreamingStateUpdate?.call(ZegoLiveStreamingState.ended);
        break;
      case LiveStatus.living:
        config.onLiveStreamingStateUpdate?.call(ZegoLiveStreamingState.living);
        break;
      case LiveStatus.notStart:
        config.onLiveStreamingStateUpdate?.call(ZegoLiveStreamingState.idle);
        break;
    }
  }
}
