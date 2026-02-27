// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'dispose.dart';
import 'init_state.dart';

/// @nodoc
class ZegoLiveStreamingNormalLifeCycle {
  final initStateDelegate = ZegoLiveStreamingPageLifeCycleInitState();
  final disposeDelegate = ZegoLiveStreamingPageLifeCycleDispose();

  final _listeners = <String, VoidCallback>{};

  void initFromPreview({
    required String liveID,
  }) {
    if (_listeners.containsKey(liveID)) {
      return;
    }

    _listeners[liveID] = () {
      _onRoomsStateUpdated(liveID);
    };

    ZegoUIKit().getRoomsStateStream().addListener(_listeners[liveID]!);
  }

  void uninitFromPreview({
    required String liveID,
  }) {
    if (!_listeners.containsKey(liveID)) {
      return;
    }

    ZegoUIKit().getRoomsStateStream().removeListener(_listeners[liveID]!);
    _listeners.remove(liveID);
  }

  /// Plugins wait for RTC room entry
  /// todo This should not be placed here
  void _onRoomsStateUpdated(String liveID) {
    if (liveID.isEmpty) {
      ZegoLoggerService.logInfo(
        'live id is empty, ignore',
        tag: 'live.streaming.lifecyle',
        subTag: 'onRoomsStateUpdated',
      );

      return;
    }

    final roomsState = ZegoUIKit().getRoomsStateStream().value;
    if (!roomsState.containsKey(liveID)) {
      ZegoLoggerService.logInfo(
        'not contain live id, ignore'
        'liveID:$liveID, '
        'roomsState:$roomsState, ',
        tag: 'live.streaming.lifecyle',
        subTag: 'onRoomsStateUpdated',
      );

      return;
    }

    final roomState = roomsState[liveID]!;
    if (!roomState.isLogin2) {
      ZegoLoggerService.logInfo(
        'room not login, ignore'
        'liveID:$liveID, '
        'roomState:$roomState, ',
        tag: 'live.streaming.lifecyle',
        subTag: 'onRoomsStateUpdated',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'room login, '
      'liveID:$liveID, '
      'roomState:$roomState, ',
      tag: 'live.streaming.lifecyle',
      subTag: 'onRoomsStateUpdated',
    );

    ZegoLiveStreamingPageLifeCycle().plugins.joinRoom(
          targetLiveID: liveID,
        );
  }
}
