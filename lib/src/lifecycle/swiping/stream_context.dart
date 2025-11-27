// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/swiping/defines.dart';

/// Swiping live streaming context
/// - Current live room
/// - Previous and next live rooms
class LiveStreamingSwipingStreamContext {
  ZegoLiveStreamingSwipingConfig? config;

  ZegoLiveStreamingSwipingHost currentSwipingHost =
      ZegoLiveStreamingSwipingHost.empty();
  ZegoLiveStreamingSwipingHost previousSwipingHost =
      ZegoLiveStreamingSwipingHost.empty();
  ZegoLiveStreamingSwipingHost nextSwipingHost =
      ZegoLiveStreamingSwipingHost.empty();
  List<ZegoLiveStreamingSwipingHost> pendingPlayHosts = [];
  List<StreamSubscription<dynamic>?> audioVideoStreamSubscriptions = [];

  Future<void> init({
    required String token,
    required ZegoLiveStreamingSwipingConfig? swipingConfig,
  }) async {
    ZegoLoggerService.logInfo(
      ','
      'swipingConfig:$swipingConfig, ',
      tag: 'live.swiping.stream-context',
      subTag: 'init',
    );

    config = swipingConfig;

    /// After setting this, switching room (switchRoom) will not stop pulling streams (both RTC and CDN streams will not stop)
    await ZegoUIKit().enableSwitchRoomNotStopPlay(true);
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.swiping.stream-context',
      subTag: 'uninit',
    );

    pendingPlayHosts = [];
    config = null;
    currentSwipingHost = ZegoLiveStreamingSwipingHost.empty();
  }

  /// Update live streaming context when switching live rooms
  Future<void> updateContext({
    required ZegoLiveStreamingSwipingHost currentHost,
    required ZegoLiveStreamingSwipingHost previousHost,
    required ZegoLiveStreamingSwipingHost nextHost,
  }) async {
    ZegoLoggerService.logInfo(
      'update, '
      'current:{ '
      'previous:$previousSwipingHost, '
      'current:$currentSwipingHost, '
      'next:$nextSwipingHost, '
      '}, '
      'target:{ '
      'previous:$previousHost, '
      'current:$currentHost, '
      'next:$nextHost, '
      '}, ',
      tag: 'live.swiping.stream-context',
      subTag: 'updateContext',
    );

    if (currentHost.isEqual(currentSwipingHost)) {
      ZegoLoggerService.logInfo(
        'target host is equal as current host, ignore',
        tag: 'live.swiping.stream-context',
        subTag: 'updateContext',
      );

      return;
    }

    previousHost.syncPlayingState();
    currentHost.syncPlayingState();
    nextHost.syncPlayingState();

    for (var e in audioVideoStreamSubscriptions) {
      e?.cancel();
    }

    /// Streams to pull
    List<ZegoLiveStreamingSwipingHost> startPlayingHosts = [
      currentHost,
      previousHost,
      nextHost
    ];
    startPlayingHosts.removeWhere((e) {
      return
          // Current host
          e.isEqual(currentSwipingHost) ||
              e.isEqual(previousSwipingHost) ||
              e.isEqual(nextSwipingHost);
    });

    List<ZegoLiveStreamingSwipingHost> stopPlayingHosts = [];
    for (var playingHost in
        // Previously pulled host streams
        [currentSwipingHost, previousHost, nextHost]) {
      if (
          // Not target host
          !currentHost.isEqual(playingHost) &&
              !previousHost.isEqual(playingHost) &&
              !nextHost.isEqual(playingHost)) {
        /// Not in pull stream queue now, need to stop
        stopPlayingHosts.add(playingHost);
      }
      // else {
      //   /// Still in pull stream queue, copy over
      //   ZegoUIKit().copyToAnotherRoom(
      //     fromRoomID: playingHost.roomID,
      //     fromStreamID: playingHost.streamID,
      //     toRoomID: currentHost.roomID,
      //     isFromAnotherRoom: currentHost.roomID != playingHost.roomID,
      //
      //     /// Only copy, current live streaming still needs it
      //     deleteAfterCopy: false,
      //   );
      // }
    }

    /// Stop streams that are not in current context
    for (var host in stopPlayingHosts) {
      await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
        targetRoomID: currentSwipingHost.roomID,
        host.user.id,
      );
    }

    currentSwipingHost = currentHost;
    previousSwipingHost = previousHost;
    nextSwipingHost = nextHost;

    pendingPlayHosts = List.from(startPlayingHosts);
    pendingPlayHosts.removeWhere((e) {
      e.syncPlayingState();
      return e.isPlaying;
    });

    tryPlayPendingHost();
  }

  Future<void> tryPlayPendingHost() async {
    ZegoUIKit().getRoomsStateStream().removeListener(onRoomsStateUpdated);

    final roomsState = ZegoUIKit().getRoomsStateStream().value;
    if (!roomsState.containsKey(currentSwipingHost.roomID)) {
      ZegoUIKit().getRoomsStateStream().addListener(onRoomsStateUpdated);
      return;
    }

    final roomState = roomsState[currentSwipingHost.roomID]!;
    if (!roomState.isLogin2) {
      ZegoUIKit().getRoomsStateStream().addListener(onRoomsStateUpdated);
      return;
    }

    pendingPlayHosts.removeWhere((e) {
      e.syncPlayingState();
      return e.isPlaying;
    });

    /// After entering target live room, pull streams from other live rooms and mute them
    for (var host in pendingPlayHosts) {
      await ZegoUIKit().startPlayAnotherRoomAudioVideo(
        targetRoomID: currentSwipingHost.roomID,
        host.roomID,
        host.user.id,
        userName: host.user.name,

        /// Render in other live page
        playOnAnotherRoom: true,
      );

      await ZegoUIKit().muteUserAudio(
        host.user.id,
        true,
        targetRoomID: host.roomID,
      );
    }

    pendingPlayHosts = [];
  }

  void onRoomsStateUpdated() async {
    final roomsState = ZegoUIKit().getRoomsStateStream().value;
    if (!roomsState.containsKey(currentSwipingHost.roomID)) {
      return;
    }

    final roomState = roomsState[currentSwipingHost.roomID]!;
    if (!roomState.isLogin2) {
      return;
    }

    tryPlayPendingHost();
  }
}
