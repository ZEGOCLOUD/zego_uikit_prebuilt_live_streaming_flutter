// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
class ZegoRoomLogoutNotifier {
  ZegoRoomLogoutNotifier() {
    _checkExpressRoom();
    _checkSignalingRoom();
  }

  final notifier = ValueNotifier<bool>(false);

  String? get checkingRoomID => _checkingRoomID;

  bool get value => notifier.value;

  String? _checkingRoomID;

  final List<bool> _result = [false, false];
  final _expressResultIndex = 0;
  final _signalingResultIndex = 1;

  StreamSubscription<dynamic>? _signalingSubscription;

  void resetCheckingData() {
    ZegoLoggerService.logInfo(
      'reset checking room',
      tag: 'live streaming',
      subTag: 'logout-notifier',
    );

    _checkingRoomID = null;

    ZegoUIKit().getRoomStateStream().removeListener(_onExpressRoomStateChanged);
    _signalingSubscription?.cancel();

    _checkExpressRoom();
    _checkSignalingRoom();
  }

  void _syncResult() {
    notifier.value =
        _result[_expressResultIndex] && _result[_signalingResultIndex];

    ZegoLoggerService.logInfo(
      'sync result, result:$_result, value:${notifier.value}',
      tag: 'live streaming',
      subTag: 'logout-notifier',
    );
  }

  void _checkExpressRoom() {
    ZegoLoggerService.logInfo(
      'check express room, '
      'room id:${ZegoUIKit().getRoom().id}, '
      'room state:${ZegoUIKit().getRoomStateStream().value.reason}',
      tag: 'live streaming',
      subTag: 'logout-notifier',
    );

    _result[_expressResultIndex] = ZegoUIKit().getRoom().id.isEmpty;
    _syncResult();

    if (ZegoUIKit().getRoom().id.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'check express room, express room ${ZegoUIKit().getRoom().id} is exist, listen...',
        tag: 'live streaming',
        subTag: 'logout-notifier',
      );

      _checkingRoomID = ZegoUIKit().getRoom().id;

      ZegoUIKit()
          .getRoomStateStream()
          .removeListener(_onExpressRoomStateChanged);
      ZegoUIKit().getRoomStateStream().addListener(_onExpressRoomStateChanged);
    }
  }

  void _onExpressRoomStateChanged() {
    ZegoLoggerService.logInfo(
      'express room state changed, target room id:$_checkingRoomID, '
      'room id:${ZegoUIKit().getRoom().id}, '
      'room state:${ZegoUIKit().getRoomStateStream().value.reason}',
      tag: 'live streaming',
      subTag: 'logout-notifier',
    );

    _result[_expressResultIndex] = ZegoUIKit().getRoom().id.isEmpty;

    if (_result[_expressResultIndex]) {
      ZegoLoggerService.logInfo(
        'express room state changed, room already logout, remove listener',
        tag: 'live streaming',
        subTag: 'logout-notifier',
      );

      ZegoUIKit()
          .getRoomStateStream()
          .removeListener(_onExpressRoomStateChanged);
    }

    _syncResult();
  }

  void _checkSignalingRoom() {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'check signaling room, signaling is null, not need check',
        tag: 'live streaming',
        subTag: 'logout-notifier',
      );

      _result[_signalingResultIndex] = true;
      _syncResult();

      return;
    }

    ZegoLoggerService.logInfo(
      'check signaling room, target room id:$_checkingRoomID, '
      'room id:${ZegoUIKit().getSignalingPlugin().getRoomID()}, '
      'room state:${ZegoUIKit().getSignalingPlugin().getRoomState()}',
      tag: 'live streaming',
      subTag: 'logout-notifier',
    );

    _result[_signalingResultIndex] =
        ZegoSignalingPluginRoomState.disconnected ==
            ZegoUIKit().getSignalingPlugin().getRoomState();
    _syncResult();

    if (ZegoSignalingPluginRoomState.disconnected !=
        ZegoUIKit().getSignalingPlugin().getRoomState()) {
      ZegoLoggerService.logInfo(
        'check signaling room, room is not disconnected, listen...',
        tag: 'live streaming',
        subTag: 'logout-notifier',
      );

      _signalingSubscription?.cancel();
      _signalingSubscription = ZegoUIKit()
          .getSignalingPlugin()
          .getRoomStateStream()
          .listen(_onSignalingRoomStateChanged);
    }
  }

  void _onSignalingRoomStateChanged(
    ZegoSignalingPluginRoomStateChangedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'signaling room state changed, target room id:$_checkingRoomID, '
      'room id:${ZegoUIKit().getSignalingPlugin().getRoomID()}, '
      'room state:${ZegoUIKit().getSignalingPlugin().getRoomState()}',
      tag: 'live streaming',
      subTag: 'logout-notifier',
    );

    _result[_signalingResultIndex] =
        ZegoSignalingPluginRoomState.disconnected == event.state;

    if (_result[_signalingResultIndex]) {
      ZegoLoggerService.logInfo(
        'signaling room state changed, room already disconnected, remove listener',
        tag: 'live streaming',
        subTag: 'logout-notifier',
      );

      _signalingSubscription?.cancel();
    }

    _syncResult();
  }
}
