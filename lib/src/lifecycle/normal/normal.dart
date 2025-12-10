// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

import 'dispose.dart';
import 'init_state.dart';

class ZegoLiveStreamingNormalLifeCycle {
  String currentLiveID = '';

  final initStateDelegate = ZegoLiveStreamingPageLifeCycleInitState();
  final disposeDelegate = ZegoLiveStreamingPageLifeCycleDispose();

  void initFromPreview({
    required String liveID,
  }) {
    currentLiveID = liveID;

    ZegoUIKit().getRoomsStateStream().addListener(_onRoomsStateUpdated);
  }

  void uninitFromPreview() {
    ZegoUIKit().getRoomsStateStream().removeListener(_onRoomsStateUpdated);

    currentLiveID = '';
  }

  /// Plugins wait for RTC room entry
  /// todo This should not be placed here
  void _onRoomsStateUpdated() {
    if (currentLiveID.isEmpty) {
      ZegoLoggerService.logInfo(
        'current live id is empty, ignore',
        tag: 'live.streaming.lifecyle',
        subTag: 'onRoomsStateUpdated',
      );

      return;
    }

    final roomsState = ZegoUIKit().getRoomsStateStream().value;
    if (!roomsState.containsKey(currentLiveID)) {
      ZegoLoggerService.logInfo(
        'not contain current live id, ignore'
        'currentLiveID:$currentLiveID, '
        'roomsState:$roomsState, ',
        tag: 'live.streaming.lifecyle',
        subTag: 'onRoomsStateUpdated',
      );

      return;
    }

    final roomState = roomsState[currentLiveID]!;
    if (!roomState.isLogin2) {
      ZegoLoggerService.logInfo(
        'room not login, ignore'
        'currentLiveID:$currentLiveID, '
        'roomState:$roomState, ',
        tag: 'live.streaming.lifecyle',
        subTag: 'onRoomsStateUpdated',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'room login'
      'currentLiveID:$currentLiveID, '
      'roomState:$roomState, ',
      tag: 'live.streaming.lifecyle',
      subTag: 'onRoomsStateUpdated',
    );
  }
}
