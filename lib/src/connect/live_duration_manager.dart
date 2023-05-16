// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

/// @nodoc
class ZegoLiveDurationManager {
  final ZegoLiveHostManager hostManager;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  bool get isValid => notifier.value.millisecondsSinceEpoch > 0;

  ZegoLiveDurationManager({
    required this.hostManager,
    required this.config,
  }) {
    subscription =
        ZegoUIKit().getRoomPropertiesStream().listen(onRoomPropertiesUpdated);
  }

  /// internal variables
  var notifier = ValueNotifier<DateTime>(DateTime(0));
  StreamSubscription<dynamic>? subscription;

  bool isPropertyInited = false;

  Future<void> init() async {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'live duration manager',
    );
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'live duration manager',
    );
    subscription?.cancel();
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    final roomProperties = ZegoUIKit().getRoomProperties();
    ZegoLoggerService.logInfo(
      'onRoomPropertiesUpdated roomProperties:$roomProperties, updatedProperties:$updatedProperties',
      tag: 'live streaming',
      subTag: 'live duration manager',
    );

    if (roomProperties.containsKey(RoomPropertyKey.liveDuration.text)) {
      trySyncValue(roomProperties);
    }
  }

  void trySyncValue(Map<String, RoomProperty> roomProperties) {
    final timestamp = roomProperties[RoomPropertyKey.liveDuration.text]!.value;

    final currentValue = notifier.value;
    final serverValue =
        DateTime.fromMillisecondsSinceEpoch(int.tryParse(timestamp) ?? 0);
    notifier.value = serverValue;
    if (currentValue != serverValue) {
      if (hostManager.isHost) {
        ZegoLoggerService.logInfo(
          'live duration value is not equal, host sync value:${notifier.value}',
          tag: 'live streaming',
          subTag: 'live duration manager',
        );

        ZegoUIKit()
            .setRoomProperty(RoomPropertyKey.liveDuration.text, timestamp);
      }
    } else {
      ZegoLoggerService.logInfo(
        'live duration value is exist:${notifier.value}',
        tag: 'live streaming',
        subTag: 'live duration manager',
      );
    }
  }

  void setValueByHost() {
    final roomProperties = ZegoUIKit().getRoomProperties();

    if (!hostManager.isHost) {
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

    var updateFromRemote = true;
    roomProperties.forEach((key, value) {
      if (!value.updateFromRemote) {
        updateFromRemote = false;
      }
    });
    if (!updateFromRemote) {
      ZegoLoggerService.logInfo(
        'try set value, but room properties is not all update from remote',
        tag: 'live streaming',
        subTag: 'live duration manager',
      );
      return;
    }

    subscription?.cancel();

    ZegoUIKit().getNetworkTimeStamp().then((timestamp) {
      notifier.value = DateTime.fromMillisecondsSinceEpoch(timestamp);

      ZegoLoggerService.logInfo(
        'live duration value is not exist, host set value:${notifier.value}',
        tag: 'live streaming',
        subTag: 'live duration manager',
      );

      ZegoUIKit().setRoomProperty(
        RoomPropertyKey.liveDuration.text,
        timestamp.toString(),
      );
    });
  }
}
