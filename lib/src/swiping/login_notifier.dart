// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
class ZegoRoomLoginNotifier {
  ZegoRoomLoginNotifier({
    required List<IZegoUIKitPlugin> configPlugins,
  }) : _configPlugins = configPlugins {
    ZegoLoggerService.logInfo(
      'constructor, config plugins:$_configPlugins',
      tag: 'live streaming',
      subTag: 'login-notifier',
    );

    _checkExpressRoom();
    _checkSignalingRoom();
  }

  final notifier = ValueNotifier<bool>(false);

  bool get value => notifier.value;

  String _targetRoomID = '';
  final List<IZegoUIKitPlugin> _configPlugins;

  final List<bool> _result = [false, false];
  final _expressResultIndex = 0;
  final _signalingResultIndex = 1;

  StreamSubscription<dynamic>? _signalingSubscription;

  void resetCheckingData(String roomID) {
    ZegoLoggerService.logInfo(
      'reset checking room to $roomID',
      tag: 'live streaming',
      subTag: 'login-notifier',
    );

    _targetRoomID = roomID;

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
      subTag: 'login-notifier',
    );
  }

  void _checkExpressRoom() {
    ZegoLoggerService.logInfo(
      'check express room, target room id:$_targetRoomID, '
      'room id:${ZegoUIKit().getRoom().id}, '
      'room state:${ZegoUIKit().getRoomStateStream().value.reason}',
      tag: 'live streaming',
      subTag: 'login-notifier',
    );

    _result[_expressResultIndex] = ZegoUIKit().getRoom().id == _targetRoomID &&
        ZegoRoomStateChangedReason.Logined ==
            ZegoUIKit().getRoomStateStream().value.reason;
    _syncResult();

    if (ZegoUIKit().getRoom().id != _targetRoomID ||
        ZegoRoomStateChangedReason.Logined !=
            ZegoUIKit().getRoomStateStream().value.reason) {
      ZegoLoggerService.logInfo(
        'check express room, express room is not ready, listen...',
        tag: 'live streaming',
        subTag: 'login-notifier',
      );

      ZegoUIKit()
          .getRoomStateStream()
          .removeListener(_onExpressRoomStateChanged);
      ZegoUIKit().getRoomStateStream().addListener(_onExpressRoomStateChanged);
    }
  }

  void _onExpressRoomStateChanged() {
    ZegoLoggerService.logInfo(
      'express room state changed, target room id:$_targetRoomID, '
      'room id:${ZegoUIKit().getRoom().id}, '
      'room state:${ZegoUIKit().getRoomStateStream().value.reason}',
      tag: 'live streaming',
      subTag: 'login-notifier',
    );

    _result[_expressResultIndex] = ZegoUIKit().getRoom().id == _targetRoomID &&
        ZegoRoomStateChangedReason.Logined ==
            ZegoUIKit().getRoomStateStream().value.reason;

    if (_result[_expressResultIndex]) {
      ZegoLoggerService.logInfo(
        'express room state changed, room already login, remove listener',
        tag: 'live streaming',
        subTag: 'login-notifier',
      );

      ZegoUIKit()
          .getRoomStateStream()
          .removeListener(_onExpressRoomStateChanged);
    }

    _syncResult();
  }

  void _checkSignalingRoom() {
    if (_configPlugins
        .where(
            (plugin) => plugin.getPluginType() == ZegoUIKitPluginType.signaling)
        .isEmpty) {
      ZegoLoggerService.logInfo(
        'check signaling room, signaling is not in config, not need to check',
        tag: 'live streaming',
        subTag: 'login-notifier',
      );

      _result[_signalingResultIndex] = true;
      _syncResult();

      return;
    }

    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'check signaling room, signaling is null, wait install...',
        tag: 'live streaming',
        subTag: 'login-notifier',
      );

      ZegoUIKit()
          .pluginsInstallNotifier()
          .addListener(_onPluginsInstallNotifier);

      return;
    }

    ZegoLoggerService.logInfo(
      'check signaling room, target room id:$_targetRoomID, '
      'room id:${ZegoUIKit().getSignalingPlugin().getRoomID()}, '
      'room state:${ZegoUIKit().getSignalingPlugin().getRoomState()}',
      tag: 'live streaming',
      subTag: 'login-notifier',
    );

    _result[_signalingResultIndex] =
        _targetRoomID == ZegoUIKit().getSignalingPlugin().getRoomID() &&
            ZegoSignalingPluginRoomState.connected ==
                ZegoUIKit().getSignalingPlugin().getRoomState();
    _syncResult();

    if (_targetRoomID != ZegoUIKit().getSignalingPlugin().getRoomID() ||
        ZegoSignalingPluginRoomState.connected !=
            ZegoUIKit().getSignalingPlugin().getRoomState()) {
      ZegoLoggerService.logInfo(
        'check signaling room, room is not connected, listen...',
        tag: 'live streaming',
        subTag: 'login-notifier',
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
        tag: 'live streaming',
        subTag: 'login-notifier',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'on plugins install, signaling installed, remove listen and recheck signaling room',
      tag: 'live streaming',
      subTag: 'login-notifier',
    );
    ZegoUIKit()
        .pluginsInstallNotifier()
        .removeListener(_onPluginsInstallNotifier);
    _checkSignalingRoom();
  }

  void _onSignalingRoomStateChanged(
    ZegoSignalingPluginRoomStateChangedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'signaling room state changed, target room id:$_targetRoomID, '
      'room id:${ZegoUIKit().getSignalingPlugin().getRoomID()}, '
      'room state:${ZegoUIKit().getSignalingPlugin().getRoomState()}',
      tag: 'live streaming',
      subTag: 'login-notifier',
    );

    _result[_signalingResultIndex] =
        _targetRoomID == ZegoUIKit().getSignalingPlugin().getRoomID() &&
            ZegoSignalingPluginRoomState.connected ==
                ZegoUIKit().getSignalingPlugin().getRoomState();

    if (_result[_signalingResultIndex]) {
      ZegoLoggerService.logInfo(
        'signaling room state changed, room already connected, remove listener',
        tag: 'live streaming',
        subTag: 'login-notifier',
      );

      _signalingSubscription?.cancel();
    }

    _syncResult();
  }
}
