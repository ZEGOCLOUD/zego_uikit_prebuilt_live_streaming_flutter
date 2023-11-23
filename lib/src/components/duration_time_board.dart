// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_duration_manager.dart';

/// @nodoc
class LiveDurationTimeBoard extends StatefulWidget {
  final ZegoLiveDurationConfig config;
  final ZegoLiveDurationManager manager;

  final double? fontSize;

  const LiveDurationTimeBoard({
    Key? key,
    required this.config,
    required this.manager,
    this.fontSize,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CallDurationTimeBoardState();
}

/// @nodoc
class CallDurationTimeBoardState extends State<LiveDurationTimeBoard> {
  Timer? durationTimer;
  Duration? beginDuration;
  var durationNotifier = ValueNotifier<Duration>(Duration.zero);

  @override
  void initState() {
    super.initState();

    if (widget.config.isVisible) {
      ZegoLoggerService.logInfo(
        'init duration',
        tag: 'live',
        subTag: 'prebuilt',
      );

      if (widget.manager.isValid) {
        startDurationTimerByNetworkTime();
      } else {
        ZegoLoggerService.logInfo(
          'manager notifier value is null, wait...',
          tag: 'live streaming',
          subTag: 'duration time board',
        );

        widget.manager.notifier.addListener(startDurationTimerByNetworkTime);
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
        if (!widget.manager.isValid) {
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
    if (widget.manager.isValid) {
      final networkTimeNow = ZegoUIKit().getNetworkTime();
      if (null == networkTimeNow.value) {
        ZegoLoggerService.logInfo(
          'network time is null, wait...',
          tag: 'live streaming',
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
      tag: 'live streaming',
      subTag: 'duration time board',
    );

    startDurationTimer(networkTimeNow.value!);
  }

  void startDurationTimer(DateTime networkTimeNow) {
    ZegoLoggerService.logInfo(
      'start duration timer, network time is $networkTimeNow, live begin time is ${widget.manager.notifier.value}',
      tag: 'live streaming',
      subTag: 'duration time board',
    );

    beginDuration = networkTimeNow.difference(widget.manager.notifier.value);

    durationTimer?.cancel();
    durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationNotifier.value = beginDuration! + Duration(seconds: timer.tick);
      widget.config.onDurationUpdate?.call(durationNotifier.value);
    });
  }
}
