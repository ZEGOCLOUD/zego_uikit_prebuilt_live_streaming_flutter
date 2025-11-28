// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';

/// @nodoc
class ZegoLiveStreamingStatusManager {
  String liveID = '';
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  ZegoUIKitPrebuiltLiveStreamingEvents? events;

  bool _initialized = false;

  /// internal variables
  var notifier = ValueNotifier<LiveStatus>(LiveStatus.notStart);
  StreamSubscription<dynamic>? onRoomPropertiesUpdatedSubscription = null;

  Future<void> checkShouldStopPlayAllAudioVideo({
    required bool isPrebuiltFromHall,
  }) async {
    final needStop = !ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .hostManager
            .isLocalHost &&
        notifier.value != LiveStatus.living;
    ZegoLoggerService.logInfo(
      'need stop:$needStop',
      tag: 'live.streaming.live-status-mgr',
      subTag: 'checkShouldStopPlayAllAudioVideo',
    );

    if (isPrebuiltFromHall) {
      ZegoLoggerService.logInfo(
        'but is from hall, ignore',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'checkShouldStopPlayAllAudioVideo',
      );
    } else if (needStop) {
      /// audience, stop play first if not living, wait living to start play
      await ZegoUIKit().muteAllRemoteAudioVideo(targetRoomID: liveID);
    }
  }

  Future<void> init({
    required String liveID,
    ZegoUIKitPrebuiltLiveStreamingConfig? config,
    ZegoUIKitPrebuiltLiveStreamingEvents? events,
  }) async {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'init',
      );

      return;
    }

    _initialized = true;

    this.liveID = liveID;
    this.config = config;
    this.events = events;

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.live-status-mgr',
      subTag: 'init',
    );

    onLiveStatusUpdated();
    notifier.addListener(onLiveStatusUpdated);

    registerRoomEvents(liveID);

    if (ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .hostManager
            .isLocalHost &&
        (config?.preview.showPreviewForHost ?? true)) {
      ZegoUIKit().setRoomProperty(
        targetRoomID: liveID,
        RoomPropertyKey.liveStatus.text,
        LiveStatus.notStart.index.toString(),
      );
    }
  }

  Future<void> uninit() async {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'uninit',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.live-status-mgr',
      subTag: 'uninit',
    );

    unregisterRoomEvents(liveID);

    notifier.value = LiveStatus.notStart;
    notifier.removeListener(onLiveStatusUpdated);

    if (ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .isLocalHost) {
      ZegoLoggerService.logInfo(
        'host uninit live status property to end',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'uninit',
      );

      events?.onStateUpdated?.call(ZegoLiveStreamingState.ended);

      /// un-normal leave by leave button
      await ZegoUIKit().setRoomProperty(
        targetRoomID: liveID,
        RoomPropertyKey.liveStatus.text,
        LiveStatus.ended.index.toString(),
      );
    }

    liveID = '';
  }

  void registerRoomEvents(String liveID) {
    onRoomPropertiesUpdated(
      ZegoUIKit().getRoomProperties(targetRoomID: liveID),
    );
    onRoomPropertiesUpdatedSubscription = ZegoUIKit()
        .getRoomPropertiesStream(targetRoomID: liveID)
        .listen(onRoomPropertiesUpdated);

    onRoomStateUpdated();
    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .addListener(onRoomStateUpdated);
  }

  void unregisterRoomEvents(String liveID) {
    onRoomPropertiesUpdatedSubscription?.cancel();
    onRoomPropertiesUpdatedSubscription = null;

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .removeListener(onRoomStateUpdated);
  }

  void onRoomSwitched({
    required String liveID,
    ZegoUIKitPrebuiltLiveStreamingConfig? config,
    ZegoUIKitPrebuiltLiveStreamingEvents? events,
  }) {
    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.live-status-mgr',
      subTag: 'onRoomSwitched',
    );

    unregisterRoomEvents(this.liveID);

    this.liveID = liveID;

    registerRoomEvents(this.liveID);
  }

  void onRoomStateUpdated() {
    if (!ZegoUIKit().getRoom(targetRoomID: liveID).isLogin) {
      return;
    }

    if (ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .isLocalHost) {
      ZegoLoggerService.logInfo(
        'host init live status to end and start play all audio video',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'onRoomStateUpdated',
      );
      ZegoUIKit().unmuteAllRemoteAudioVideo(targetRoomID: liveID);

      ZegoUIKit().setRoomProperty(
        targetRoomID: liveID,
        RoomPropertyKey.liveStatus.text,
        LiveStatus.living.index.toString(),
      );
    }
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    if (!updatedProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      ZegoLoggerService.logInfo(
        'update properties not contain live status',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
      return;
    }

    final roomProperties = ZegoUIKit().getRoomProperties(targetRoomID: liveID);

    ZegoLoggerService.logInfo(
      'roomProperties:$roomProperties',
      tag: 'live.streaming.live-status-mgr',
      subTag: 'onRoomPropertiesUpdated',
    );

    if (!roomProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      /// live is not start if host not enter
      ZegoLoggerService.logInfo(
        'host key is not exist, set live status not start',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
      notifier.value = LiveStatus.notStart;
    } else if (roomProperties.containsKey(RoomPropertyKey.liveStatus.text)) {
      final oldNotifierValue = notifier.value;

      /// live is start or end
      final liveStatusValue = roomProperties[RoomPropertyKey.liveStatus.text]!;
      final targetNotifierValue = LiveStatus.values[
          int.tryParse(liveStatusValue.value) ?? LiveStatus.notStart.index];

      if (!_initialized &&
          oldNotifierValue == LiveStatus.notStart &&
          targetNotifierValue == LiveStatus.living) {
        /// The room attribute arrived early and has not been initialized yet, and the reissue event was thrown.
        onLiveStatusUpdated();
      }

      notifier.value = targetNotifierValue;

      ZegoLoggerService.logInfo(
        'update live status, value is $liveStatusValue, status is ${notifier.value}',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
    } else {
      /// live is not start
      ZegoLoggerService.logInfo(
        'live status key is not exist, live is not start',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
      notifier.value = LiveStatus.notStart;
    }

    if (!ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .isLocalHost) {
      /// audience, co-host
      if (notifier.value == LiveStatus.living) {
        /// living to start play
        ZegoUIKit().unmuteAllRemoteAudioVideo(targetRoomID: liveID);
      } else {
        ZegoUIKit().muteAllRemoteAudioVideo(targetRoomID: liveID);

        ZegoUIKit().turnCameraOn(targetRoomID: liveID, false);
        ZegoUIKit().turnMicrophoneOn(targetRoomID: liveID, false);
      }
    }

    if (LiveStatus.ended == notifier.value &&
        !ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .hostManager
            .isLocalHost) {
      ZegoLoggerService.logInfo(
        'live status is end, co-host switch to audience',
        tag: 'live.streaming.live-status-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .connectManager
          .updateAudienceConnectState(
            ZegoLiveStreamingAudienceConnectState.idle,
          );
    }
  }

  void onLiveStatusUpdated() {
    ZegoLoggerService.logInfo(
      'live status update to ${notifier.value}',
      tag: 'live.streaming.live-status-mgr',
      subTag: 'onLiveStatusUpdated',
    );

    switch (notifier.value) {
      case LiveStatus.ended:
        events?.onStateUpdated?.call(ZegoLiveStreamingState.ended);
        break;
      case LiveStatus.living:
        events?.onStateUpdated?.call(ZegoLiveStreamingState.living);
        break;
      case LiveStatus.notStart:
        events?.onStateUpdated?.call(ZegoLiveStreamingState.idle);
        break;
    }
  }
}
