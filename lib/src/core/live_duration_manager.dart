// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';

/// @nodoc
class ZegoLiveStreamingDurationManager {
  String liveID = '';

  bool _initialized = false;

  bool get isValid => notifier.value.millisecondsSinceEpoch > 0;

  /// internal variables
  var notifier = ValueNotifier<DateTime>(DateTime(0));
  StreamSubscription<dynamic>? roomPropertySubscription;

  bool isPropertyInited = false;

  Future<void> init({
    required String liveID,
  }) async {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live.streaming.live-duration-mgr',
        subTag: 'init',
      );

      return;
    }

    _initialized = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live.streaming.live-duration-mgr',
      subTag: 'init',
    );

    this.liveID = liveID;

    registerRoomEvents(liveID);
  }

  Future<void> uninit() async {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live.streaming.live-duration-mgr',
        subTag: 'uninit',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.live-duration-mgr',
      subTag: 'uninit',
    );

    unregisterRoomEvents(liveID);

    liveID = '';
  }

  void registerRoomEvents(String liveID) {
    onRoomPropertiesUpdated(
      ZegoUIKit().getRoomProperties(targetRoomID: liveID),
    );
    roomPropertySubscription = ZegoUIKit()
        .getRoomPropertiesStream(targetRoomID: liveID)
        .listen(onRoomPropertiesUpdated);

    onRoomStateUpdated();
    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .addListener(onRoomStateUpdated);
  }

  void unregisterRoomEvents(String liveID) {
    roomPropertySubscription?.cancel();
    roomPropertySubscription = null;

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .removeListener(onRoomStateUpdated);
  }

  void onRoomSwitched({
    required String liveID,
  }) {
    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.live-duration-mgr',
      subTag: 'onRoomSwitched',
    );

    /// Cancel the event listener for the previous LIVE broadcast room
    unregisterRoomEvents(this.liveID);

    this.liveID = liveID;

    registerRoomEvents(this.liveID);
  }

  void onRoomStateUpdated() {
    setRoomPropertyByHost();
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    final roomProperties = ZegoUIKit().getRoomProperties(targetRoomID: liveID);
    ZegoLoggerService.logInfo(
      'roomProperties:$roomProperties, '
      'updatedProperties:$updatedProperties',
      tag: 'live.streaming.live-duration-mgr',
      subTag: 'onRoomPropertiesUpdated',
    );

    if (roomProperties.containsKey(RoomPropertyKey.liveDuration.text)) {
      trySyncValueByRoomProperties(roomProperties);
    }
  }

  void trySyncValueByRoomProperties(Map<String, RoomProperty> roomProperties) {
    final propertyTimestamp =
        roomProperties[RoomPropertyKey.liveDuration.text]!.value;

    final currentDateTime = notifier.value;
    final serverDateTime = DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(propertyTimestamp) ?? 0);
    notifier.value = serverDateTime;
    ZegoLoggerService.logInfo(
      'previous value:$currentDateTime, '
      'now value:${notifier.value}, ',
      tag: 'live.streaming.live-duration-mgr',
      subTag: 'trySyncValueByRoomProperties',
    );

    if (currentDateTime != serverDateTime) {
      if (ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .hostManager
          .isLocalHost) {
        ZegoLoggerService.logInfo(
          'live duration value is not equal, host sync value:${notifier.value}',
          tag: 'live.streaming.live-duration-mgr',
          subTag: 'trySyncValueByRoomProperties',
        );

        ZegoUIKit().setRoomProperty(
          targetRoomID: liveID,
          RoomPropertyKey.liveDuration.text,
          propertyTimestamp,
        );
      }
    } else {
      ZegoLoggerService.logInfo(
        'live duration value is exist:${notifier.value}',
        tag: 'live.streaming.live-duration-mgr',
        subTag: 'trySyncValueByRoomProperties',
      );
    }
  }

  void setRoomPropertyByHost() {
    if (!ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .isLocalHost) {
      ZegoLoggerService.logInfo(
        'try set value, but is not a host',
        tag: 'live.streaming.live-duration-mgr',
        subTag: 'setRoomPropertyByHost',
      );
      return;
    }

    /// ignore room property update event, because had updated from local
    roomPropertySubscription?.cancel();

    final networkTimeNow = ZegoUIKit().getNetworkTime();
    if (null == networkTimeNow.value) {
      ZegoLoggerService.logInfo(
        'network time is null, wait..',
        tag: 'live.streaming.live-duration-mgr',
        subTag: 'setRoomPropertyByHost',
      );

      ZegoUIKit()
          .getNetworkTime()
          .addListener(waitNetworkTimeUpdatedForSetProperty);
    } else {
      setPropertyByNetworkTime(networkTimeNow.value!);
    }
  }

  void waitNetworkTimeUpdatedForSetProperty() {
    ZegoUIKit()
        .getNetworkTime()
        .removeListener(waitNetworkTimeUpdatedForSetProperty);

    final networkTimeNow = ZegoUIKit().getNetworkTime();
    ZegoLoggerService.logInfo(
      'network time update:$networkTimeNow',
      tag: 'live.streaming.live-duration-mgr',
      subTag: 'waitNetworkTimeUpdatedForSetProperty',
    );

    setPropertyByNetworkTime(networkTimeNow.value!);
  }

  void setPropertyByNetworkTime(DateTime networkTimeNow) {
    notifier.value = networkTimeNow;

    ZegoLoggerService.logInfo(
      'live duration value is not exist, host set value:${notifier.value}',
      tag: 'live.streaming.live-duration-mgr',
      subTag: 'setPropertyByNetworkTime',
    );

    ZegoUIKit().setRoomProperty(
      targetRoomID: liveID,
      RoomPropertyKey.liveDuration.text,
      networkTimeNow.millisecondsSinceEpoch.toString(),
    );
  }
}
