// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

enum _RoomLoginIndex {
  express,
  signaling,
}

/// @nodoc
class ZegoLiveStreamingRoomLoginChecker {
  ZegoLiveStreamingRoomLoginChecker({
    required List<IZegoUIKitPlugin> configPlugins,
  }) : _configPlugins = configPlugins {
    ZegoLoggerService.logInfo(
      'config plugins:$_configPlugins',
      tag: 'live.streaming.room-login-checker',
      subTag: 'constructor',
    );

    _targetRoomID = ZegoUIKit().getCurrentRoom().id;
    _checkExpressRoom();
    _checkSignalingRoom();
  }

  final notifier = ValueNotifier<bool>(false);

  bool get value => notifier.value;

  String _targetRoomID = '';

  String get targetRoomID => _targetRoomID;

  final List<IZegoUIKitPlugin> _configPlugins;

  final List<bool> _result = [false, false];

  StreamSubscription<dynamic>? _signalingSubscription;

  void resetCheckingData(String roomID) {
    ZegoLoggerService.logInfo(
      'room id:$roomID, ',
      tag: 'live.streaming.room-login-checker',
      subTag: 'reset',
    );

    _targetRoomID = roomID;

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: _targetRoomID)
        .removeListener(_onExpressRoomStateChanged);
    _signalingSubscription?.cancel();

    _checkExpressRoom();
    _checkSignalingRoom();
  }

  void _syncResult() {
    notifier.value = _result[_RoomLoginIndex.express.index] &&
        _result[_RoomLoginIndex.signaling.index];

    ZegoLoggerService.logInfo(
      'result:$_result, '
      'value:${notifier.value}',
      tag: 'live.streaming.room-login-checker',
      subTag: 'sync',
    );
  }

  void _checkExpressRoom() {
    final targetRoomState =
        ZegoUIKit().getRoomStateStream(targetRoomID: _targetRoomID);
    ZegoLoggerService.logInfo(
      'target room id:$_targetRoomID, '
      'room id:${ZegoUIKit().getRoom(targetRoomID: _targetRoomID).id}, '
      'room state:${targetRoomState.value.reason}',
      tag: 'live.streaming.room-login-checker',
      subTag: 'express',
    );

    if (targetRoomState.value.isLogin2) {
      _result[_RoomLoginIndex.express.index] = true;
      _syncResult();
    } else {
      ZegoLoggerService.logInfo(
        'express room is not ready, listen...',
        tag: 'live.streaming.room-login-checker',
        subTag: 'express',
      );

      targetRoomState.removeListener(_onExpressRoomStateChanged);
      targetRoomState.addListener(_onExpressRoomStateChanged);
    }
  }

  void _onExpressRoomStateChanged() {
    final targetRoomState =
        ZegoUIKit().getRoomStateStream(targetRoomID: _targetRoomID);
    ZegoLoggerService.logInfo(
      'room state changed, '
      'target room id:$_targetRoomID, '
      'room state:${targetRoomState.value.reason}',
      tag: 'live.streaming.room-login-checker',
      subTag: 'express',
    );

    _result[_RoomLoginIndex.express.index] = targetRoomState.value.isLogin2;

    if (_result[_RoomLoginIndex.express.index]) {
      ZegoLoggerService.logInfo(
        'room state changed, room already login, remove listener',
        tag: 'live.streaming.room-login-checker',
        subTag: 'express',
      );

      targetRoomState.removeListener(_onExpressRoomStateChanged);
    }

    _syncResult();
  }

  void _checkSignalingRoom() {
    if (_configPlugins
        .where(
            (plugin) => plugin.getPluginType() == ZegoUIKitPluginType.signaling)
        .isEmpty) {
      ZegoLoggerService.logInfo(
        'check room, '
        'signaling is not in config, not need to check',
        tag: 'live.streaming.room-login-checker',
        subTag: 'signaling',
      );

      _result[_RoomLoginIndex.signaling.index] = true;
      _syncResult();

      return;
    }

    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'check room, '
        'signaling is null, wait install...',
        tag: 'live.streaming.room-login-checker',
        subTag: 'signaling',
      );

      ZegoUIKit()
          .pluginsInstallNotifier()
          .addListener(_onPluginsInstallNotifier);

      return;
    }

    final currentRoomID = ZegoUIKit().getSignalingPlugin().getRoomID();
    final currentRoomState = ZegoUIKit().getSignalingPlugin().getRoomState();
    ZegoLoggerService.logInfo(
      'check room, '
      'target room id:$_targetRoomID, '
      'current room id:$currentRoomID, '
      'current room state:$currentRoomState, ',
      tag: 'live.streaming.room-login-checker',
      subTag: 'signaling',
    );

    _result[_RoomLoginIndex.signaling.index] = _targetRoomID == currentRoomID &&
        ZegoSignalingPluginRoomState.connected == currentRoomState;
    _syncResult();

    if (_targetRoomID != currentRoomID ||
        ZegoSignalingPluginRoomState.connected != currentRoomState) {
      ZegoLoggerService.logInfo(
        'room is not connected, listen...',
        tag: 'live.streaming.room-login-checker',
        subTag: 'signaling',
      );

      _signalingSubscription?.cancel();
      _signalingSubscription = ZegoUIKit()
          .getSignalingPlugin()
          .getRoomStateStream()
          .listen(_onSignalingRoomStateChanged);
    }
  }

  void _onPluginsInstallNotifier() {
    final pluginsInstalled = ZegoUIKit().pluginsInstallNotifier().value;

    if (!pluginsInstalled.contains(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'on plugins install, but signaling still null, wait install...',
        tag: 'live.streaming.room-login-checker',
        subTag: 'signaling',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'on plugins install, signaling installed, remove listen and recheck signaling room',
      tag: 'live.streaming.room-login-checker',
      subTag: 'signaling',
    );
    ZegoUIKit()
        .pluginsInstallNotifier()
        .removeListener(_onPluginsInstallNotifier);
    _checkSignalingRoom();
  }

  void _onSignalingRoomStateChanged(
    ZegoSignalingPluginRoomStateChangedEvent event,
  ) {
    final currentRoomID = ZegoUIKit().getSignalingPlugin().getRoomID();
    final currentRoomState = ZegoUIKit().getSignalingPlugin().getRoomState();

    ZegoLoggerService.logInfo(
      'room state changed, target room id:$_targetRoomID, '
      'current room id:$currentRoomID, '
      'current room state:$currentRoomState, ',
      tag: 'live.streaming.room-login-checker',
      subTag: 'signaling',
    );

    _result[_RoomLoginIndex.signaling.index] = _targetRoomID == currentRoomID &&
        ZegoSignalingPluginRoomState.connected == currentRoomState;
    if (_result[_RoomLoginIndex.signaling.index]) {
      ZegoLoggerService.logInfo(
        'room state changed, room already connected, remove listener',
        tag: 'live.streaming.room-login-checker',
        subTag: 'signaling',
      );

      _signalingSubscription?.cancel();
    }

    _syncResult();
  }
}
