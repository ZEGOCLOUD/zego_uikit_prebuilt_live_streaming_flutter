// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';

/// @nodoc
class ZegoLiveDurationManager {
  final ZegoLiveHostManager hostManager;

  bool _initialized = false;

  bool get isValid => notifier.value.millisecondsSinceEpoch > 0;

  ZegoLiveDurationManager({
    required this.hostManager,
  }) {
    roomPropertySubscription =
        ZegoUIKit().getRoomPropertiesStream().listen(onRoomPropertiesUpdated);
  }

  /// internal variables
  var notifier = ValueNotifier<DateTime>(DateTime(0));
  StreamSubscription<dynamic>? roomPropertySubscription;

  bool isPropertyInited = false;

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
      subTag: 'live duration manager',
    );
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
      subTag: 'live duration manager',
    );
    roomPropertySubscription?.cancel();
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    final roomProperties = ZegoUIKit().getRoomProperties();
    ZegoLoggerService.logInfo(
      'onRoomPropertiesUpdated roomProperties:$roomProperties, updatedProperties:$updatedProperties',
      tag: 'live streaming',
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
      if (hostManager.isLocalHost) {
        ZegoLoggerService.logInfo(
          'live duration value is not equal, host sync value:${notifier.value}',
          tag: 'live streaming',
          subTag: 'live duration manager',
        );

        ZegoUIKit().setRoomProperty(
            RoomPropertyKey.liveDuration.text, propertyTimestamp);
      }
    } else {
      ZegoLoggerService.logInfo(
        'live duration value is exist:${notifier.value}',
        tag: 'live streaming',
        subTag: 'live duration manager',
      );
    }
  }

  void setRoomPropertyByHost() {
    final roomProperties = ZegoUIKit().getRoomProperties();

    if (!hostManager.isLocalHost) {
      ZegoLoggerService.logInfo(
        'try set value, but is not a host',
        tag: 'live streaming',
        subTag: 'live duration manager',
      );
      return;
    }

    if (roomProperties.keys.length < 2) {
      /// should contain 'host' and 'live_status'
      ZegoLoggerService.logInfo(
        'try set value, but room properties length is small than 2',
        tag: 'live streaming',
        subTag: 'live duration manager',
      );
      return;
    }

    /// todo
    // var updateFromRemote = true;
    // roomProperties.forEach((key, value) {
    //   if (!value.updateFromRemote) {
    //     updateFromRemote = false;
    //   }
    // });
    // if (!updateFromRemote) {
    //   ZegoLoggerService.logInfo(
    //     'try set value, but room properties is not all update from remote',
    //     tag: 'live streaming',
    //     subTag: 'live duration manager',
    //   );
    //   return;
    // }

    /// ignore room property update event, because had updated from local
    roomPropertySubscription?.cancel();

    final networkTimeNow = ZegoUIKit().getNetworkTime();
    if (null == networkTimeNow.value) {
      ZegoLoggerService.logInfo(
        'network time is null, wait..',
        tag: 'live streaming',
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
      tag: 'live streaming',
      subTag: 'live duration manager',
    );

    setPropertyByNetworkTime(networkTimeNow.value!);
  }

  void setPropertyByNetworkTime(DateTime networkTimeNow) {
    notifier.value = networkTimeNow;

    ZegoLoggerService.logInfo(
      'live duration value is not exist, host set value:${notifier.value}',
      tag: 'live streaming',
      subTag: 'live duration manager',
    );

    ZegoUIKit().setRoomProperty(
      RoomPropertyKey.liveDuration.text,
      networkTimeNow.millisecondsSinceEpoch.toString(),
    );
  }
}
