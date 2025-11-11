// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/instance.dart';

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
        tag: 'live-streaming',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live-streaming',
      subTag: 'live duration manager',
    );

    this.liveID = liveID;

    roomPropertySubscription = ZegoUIKit()
        .getRoomPropertiesStream(targetRoomID: liveID)
        .listen(onRoomPropertiesUpdated);

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .addListener(onRoomStateUpdated);
  }

  Future<void> uninit() async {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live-streaming',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live-streaming',
      subTag: 'live duration manager',
    );
    roomPropertySubscription?.cancel();

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .removeListener(onRoomStateUpdated);
  }

  void onRoomStateUpdated() {
    setRoomPropertyByHost();
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    final roomProperties = ZegoUIKit().getRoomProperties(targetRoomID: liveID);
    ZegoLoggerService.logInfo(
      'onRoomPropertiesUpdated roomProperties:$roomProperties, updatedProperties:$updatedProperties',
      tag: 'live-streaming',
      subTag: 'live duration manager',
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
    if (currentDateTime != serverDateTime) {
      if (ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .hostManager
          .isLocalHost) {
        ZegoLoggerService.logInfo(
          'live duration value is not equal, host sync value:${notifier.value}',
          tag: 'live-streaming',
          subTag: 'live duration manager',
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
        tag: 'live-streaming',
        subTag: 'live duration manager',
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
        tag: 'live-streaming',
        subTag: 'live duration manager',
      );
      return;
    }

    /// ignore room property update event, because had updated from local
    roomPropertySubscription?.cancel();

    final networkTimeNow = ZegoUIKit().getNetworkTime();
    if (null == networkTimeNow.value) {
      ZegoLoggerService.logInfo(
        'network time is null, wait..',
        tag: 'live-streaming',
        subTag: 'live duration manager',
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
      tag: 'live-streaming',
      subTag: 'live duration manager',
    );

    setPropertyByNetworkTime(networkTimeNow.value!);
  }

  void setPropertyByNetworkTime(DateTime networkTimeNow) {
    notifier.value = networkTimeNow;

    ZegoLoggerService.logInfo(
      'live duration value is not exist, host set value:${notifier.value}',
      tag: 'live-streaming',
      subTag: 'live duration manager',
    );

    ZegoUIKit().setRoomProperty(
      targetRoomID: liveID,
      RoomPropertyKey.liveDuration.text,
      networkTimeNow.millisecondsSinceEpoch.toString(),
    );
  }
}
