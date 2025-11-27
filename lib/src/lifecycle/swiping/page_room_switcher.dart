// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';

import 'room_login_checker.dart';

/// Room information (room ID and token)
class ZegoLiveStreamingSwipingRoomInfo {
  ZegoLiveStreamingSwipingRoomInfo({
    required this.liveID,
    required this.token,
  });

  final String liveID;
  final String token;

  @override
  String toString() {
    return 'room id:$liveID';
  }
}

/// Room switcher manager
/// Only handles page builder's switch room, **does not handle leaving room**
/// Uses stack (LIFO) to manage room switching flow
class ZegoLiveStreamingSwipingPageRoomSwitcher {
  ZegoLiveStreamingSwipingPageRoomSwitcher({
    required List<IZegoUIKitPlugin> configPlugins,
  }) : _configPlugins = configPlugins;

  final List<IZegoUIKitPlugin> _configPlugins;

  /// Room information stack (LIFO - Last In First Out)
  final List<ZegoLiveStreamingSwipingRoomInfo> _roomStack = [];

  /// Currently processing room ID
  String? _processingRoomID;

  /// Login listener
  ZegoLiveStreamingRoomLoginChecker? _loginNotifier;

  /// Login listener subscription
  StreamSubscription<dynamic>? _loginSubscription;

  /// Push room ID and token to stack and start processing flow
  /// [liveID] Room ID to push to stack
  /// [token] Token to push to stack
  /// [shouldCheckCurrentRoom] Whether to check if the popped element is the current room, default is true. If false, skip check and switch directly
  Future<void> updateRoomID(
    String liveID,
    String token, {
    bool shouldCheckCurrentRoom = true,
  }) async {
    ZegoLoggerService.logInfo(
      'push room id to stack, '
      'room id:$liveID, '
      'token:$token, '
      'shouldCheckCurrentRoom:$shouldCheckCurrentRoom, '
      'processingRoomID:$_processingRoomID, '
      'stack(${_roomStack.length}):$_roomStack, ',
      tag: 'live-streaming-room-switch',
      subTag: 'pushRoomID',
    );

    /// 更新最新的直播间
    ZegoUIKitPrebuiltLiveStreamingController().private.liveID = liveID;

    ///
    _roomStack.add(ZegoLiveStreamingSwipingRoomInfo(
      liveID: liveID,
      token: token,
    ));

    /// If it is the first switch, switch directly;
    /// otherwise, wait for the room status to change, then obtain the latest LIVE room for processing
    if (_processingRoomID == null) {
      await _processStack(shouldCheckCurrentRoom: shouldCheckCurrentRoom);
    }
  }

  /// Process room switching flow in stack
  /// [shouldCheckCurrentRoom] Whether to check if the popped element is the current room, default is true
  Future<void> _processStack({bool shouldCheckCurrentRoom = true}) async {
    /// If stack is empty, end and report error (should not be empty)
    if (_roomStack.isEmpty) {
      ZegoLoggerService.logError(
        'room stack is empty, this should not happen',
        tag: 'live-streaming-room-switch',
        subTag: 'processStack',
      );
      return;
    }

    /// If already processing, wait for current processing to complete
    if (_processingRoomID != null) {
      ZegoLoggerService.logInfo(
        'already processing room id:$_processingRoomID, wait...',
        tag: 'live-streaming-room-switch',
        subTag: 'processStack',
      );
      return;
    }

    /// Pop from stack top and clear stack
    final targetRoomInfo = _roomStack.removeLast();
    final targetRoomID = targetRoomInfo.liveID;
    final targetToken = targetRoomInfo.token;
    _roomStack.clear();

    /// If need to check if popped element is current room
    if (shouldCheckCurrentRoom) {
      /// Get latest current room ID (using callback function, because currentHost may change during room joining process)
      final currentRoomID = ZegoUIKit().getCurrentRoom().id;
      if (currentRoomID.isEmpty) {
        ZegoLoggerService.logError(
          'current room id is null or empty, cannot process stack',
          tag: 'live-streaming-room-switch',
          subTag: 'processStack',
        );
        _processingRoomID = null;
        return;
      }

      ZegoLoggerService.logInfo(
        'process stack, target room id:$targetRoomID, '
        'current room id:$currentRoomID',
        tag: 'live-streaming-room-switch',
        subTag: 'processStack',
      );

      /// Check if popped element is current room (using _ZegoLiveStreamingSwipingPageState's currentHost.roomID)
      if (targetRoomID == currentRoomID) {
        /// If yes, clear stack and finish
        ZegoLoggerService.logInfo(
          'target room id is same as current room id, clear stack and finish',
          tag: 'live-streaming-room-switch',
          subTag: 'processStack',
        );
        _processingRoomID = null;
        return;
      }
    } else {
      ZegoLoggerService.logInfo(
        'process stack, target room id:$targetRoomID, skip check current room',
        tag: 'live-streaming-room-switch',
        subTag: 'processStack',
      );
    }

    /// If not, then switchRoom
    _processingRoomID = targetRoomID;
    await _switchRoom(targetRoomID, targetToken);
  }

  /// Switch room
  Future<void> _switchRoom(String targetRoomID, String token) async {
    if (!ZegoLiveStreamingPageLifeCycle().swiping.usingRoomSwiping) {
      ZegoLoggerService.logError(
        'room delegate is null, cannot switch room',
        tag: 'live-streaming-room-switch',
        subTag: 'switchRoom',
      );
      _processingRoomID = null;
      return;
    }

    ZegoLoggerService.logInfo(
      'switch room, from:${ZegoUIKit().getCurrentRoom().id}, to:$targetRoomID',
      tag: 'live-streaming-room-switch',
      subTag: 'switchRoom',
    );

    try {
      await ZegoUIKit().switchRoom(
        toRoomID: targetRoomID,
        token: token,
      );
      await ZegoLiveStreamingPageLifeCycle().currentManagers.plugins.switchRoom(
            targetLiveID: targetRoomID,
          );

      /// Wait for room joining to complete
      await _waitForRoomLogin(targetRoomID);
    } catch (e) {
      ZegoLoggerService.logError(
        'switch room failed, error:$e',
        tag: 'live-streaming-room-switch',
        subTag: 'switchRoom',
      );
      _processingRoomID = null;
    }
  }

  /// Wait for room login to complete
  Future<void> _waitForRoomLogin(String targetRoomID) async {
    ZegoLoggerService.logInfo(
      'wait for room login, target room id:$targetRoomID',
      tag: 'live-streaming-room-switch',
      subTag: 'waitForRoomLogin',
    );

    /// Clean up previous listeners
    _loginNotifier?.notifier.removeListener(_onRoomLoginChanged);
    _loginSubscription?.cancel();

    /// Create new login listener
    _loginNotifier = ZegoLiveStreamingRoomLoginChecker(
      configPlugins: _configPlugins,
    );
    _loginNotifier!.resetCheckingData(targetRoomID);

    /// Check if already logged in
    if (_loginNotifier!.value) {
      ZegoLoggerService.logInfo(
        'room already logged in, target room id:$targetRoomID',
        tag: 'live-streaming-room-switch',
        subTag: 'waitForRoomLogin',
      );
      _onRoomLoginCompleted();
      return;
    }

    /// Listen to login status changes
    _loginNotifier!.notifier.addListener(_onRoomLoginChanged);
  }

  /// Room login status change callback
  void _onRoomLoginChanged() {
    if (_loginNotifier?.value == true) {
      _onRoomLoginCompleted();
    }
  }

  /// Room login completion handling
  void _onRoomLoginCompleted() {
    ZegoLoggerService.logInfo(
      'room login completed, processing room id:$_processingRoomID',
      tag: 'live-streaming-room-switch',
      subTag: 'onRoomLoginCompleted',
    );

    /// todo runSwiping && ...
    /// Room management is messy, need to organize;

    /// Clean up listeners
    _loginNotifier?.notifier.removeListener(_onRoomLoginChanged);
    _loginSubscription?.cancel();
    _loginNotifier = null;

    final completedRoomID = _processingRoomID;
    _processingRoomID = null;

    /// After room joining completes, if stack is not empty, continue the process
    if (_roomStack.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'room stack is not empty after login, continue process, '
        'completed room id:$completedRoomID, stack:$_roomStack',
        tag: 'live-streaming-room-switch',
        subTag: 'onRoomLoginCompleted',
      );
      _processStack(shouldCheckCurrentRoom: true);
    } else {
      ZegoLoggerService.logInfo(
        'room stack is empty after login, finish process, '
        'completed room id:$completedRoomID',
        tag: 'live-streaming-room-switch',
        subTag: 'onRoomLoginCompleted',
      );
    }
  }

  /// Clean up resources
  void dispose() {
    ZegoLoggerService.logInfo(
      'dispose room switch manager',
      tag: 'live-streaming-room-switch',
      subTag: 'dispose',
    );

    _loginNotifier?.notifier.removeListener(_onRoomLoginChanged);
    _loginSubscription?.cancel();
    _loginNotifier = null;
    _roomStack.clear();
    _processingRoomID = null;
  }
}
