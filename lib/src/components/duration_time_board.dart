// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';

/// @nodoc
class ZegoLiveStreamingDurationTimeBoard extends StatefulWidget {
  final String liveID;
  final ZegoLiveStreamingDurationConfig config;
  final ZegoLiveStreamingDurationEvents? events;

  final double? fontSize;

  const ZegoLiveStreamingDurationTimeBoard({
    super.key,
    required this.liveID,
    required this.config,
    required this.events,
    this.fontSize,
  });

  @override
  State<StatefulWidget> createState() =>
      _ZegoLiveStreamingDurationTimeBoardState();
}

class _ZegoLiveStreamingDurationTimeBoardState
    extends State<ZegoLiveStreamingDurationTimeBoard> {
  Timer? durationTimer;
  Duration? beginDuration;
  var durationNotifier = ValueNotifier<Duration>(Duration.zero);

  ZegoLiveStreamingDurationManager get manager =>
      ZegoLiveStreamingPageLifeCycle().currentManagers.liveDurationManager;

  @override
  void initState() {
    super.initState();

    if (widget.config.isVisible) {
      ZegoLoggerService.logInfo(
        'init duration',
        tag: 'live.streaming.duration-board',
        subTag: 'prebuilt',
      );

      if (manager.liveID == widget.liveID && manager.isValid) {
        startDurationTimerByNetworkTime();
      } else {
        ZegoLoggerService.logInfo(
          'manager notifier value is null, wait...',
          tag: 'live.streaming.duration-board',
          subTag: 'duration time board',
        );

        manager.notifier.addListener(startDurationTimerByNetworkTime);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    durationTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.isVisible) {
      return Container();
    }

    return ValueListenableBuilder<Duration>(
      valueListenable: durationNotifier,
      builder: (context, elapsedTime, _) {
        if (manager.liveID != widget.liveID || !manager.isValid) {
          return Container();
        }

        return elapsedTime.inSeconds <= 0
            ? Container()
            : Text(
                durationFormatString(elapsedTime),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: widget.fontSize ?? 25.zR,
                ),
              );
      },
    );
  }

  String durationFormatString(Duration elapsedTime) {
    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes.remainder(60);
    final seconds = elapsedTime.inSeconds.remainder(60);

    final minutesFormatString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:$minutesFormatString'
        : minutesFormatString;
  }

  void startDurationTimerByNetworkTime() {
    if (manager.liveID == widget.liveID && manager.isValid) {
      manager.notifier.removeListener(startDurationTimerByNetworkTime);

      final networkTimeNow = ZegoUIKit().getNetworkTime();
      if (null == networkTimeNow.value) {
        ZegoLoggerService.logInfo(
          'network time is null, wait...',
          tag: 'live.streaming.duration-board',
          subTag: 'duration time board',
        );

        ZegoUIKit()
            .getNetworkTime()
            .addListener(waitNetworkTimeUpdateForStartDurationTimer);
      } else {
        startDurationTimer(networkTimeNow.value!);
      }
    }
  }

  void waitNetworkTimeUpdateForStartDurationTimer() {
    ZegoUIKit()
        .getNetworkTime()
        .removeListener(waitNetworkTimeUpdateForStartDurationTimer);

    final networkTimeNow = ZegoUIKit().getNetworkTime();
    ZegoLoggerService.logInfo(
      'network time update:$networkTimeNow',
      tag: 'live.streaming.duration-board',
      subTag: 'duration time board',
    );

    startDurationTimer(networkTimeNow.value!);
  }

  void startDurationTimer(DateTime networkTimeNow) {
    ZegoLoggerService.logInfo(
      'start duration timer, network time is $networkTimeNow, live begin time is ${ZegoLiveStreamingPageLifeCycle().currentManagers.liveDurationManager.notifier.value}',
      tag: 'live.streaming.duration-board',
      subTag: 'duration time board',
    );

    beginDuration = networkTimeNow.difference(manager.notifier.value);

    durationTimer?.cancel();
    durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationNotifier.value = beginDuration! + Duration(seconds: timer.tick);
      widget.events?.onUpdated?.call(durationNotifier.value);
    });
  }
}
