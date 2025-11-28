// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/defines.dart';

/// @nodoc
class ZegoLiveStreamingInRoomMessageEnableProperty {
  final _valueNotifier = ValueNotifier<bool>(true);
  final List<StreamSubscription<dynamic>?> _subscriptions = [];

  ZegoLiveStreamingInRoomMessageEnableProperty();

  void init({
    required String liveID,
  }) {
    _subscriptions.add(ZegoUIKit()
        .getRoomPropertiesStream(targetRoomID: liveID)
        .listen(onRoomPropertiesUpdated));
  }

  ValueNotifier<bool> get notifier => _valueNotifier;

  bool get value => _valueNotifier.value;

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    if (!updatedProperties.containsKey(disableChatRoomPropertyKey)) {
      return;
    }

    ZegoLoggerService.logInfo(
      'chat enabled property changed to '
      '${updatedProperties[disableChatRoomPropertyKey]!.value}',
      tag: 'live.streaming.message',
      subTag: 'message button',
    );
    _valueNotifier.value =
        toBoolean(updatedProperties[disableChatRoomPropertyKey]!.value);
  }

  bool toBoolean(String str) {
    return str != '0' && str != 'false' && str != '';
  }
}
