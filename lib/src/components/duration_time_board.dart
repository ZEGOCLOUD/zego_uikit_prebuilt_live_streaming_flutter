import 'dart:async';

// Package imports:
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

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
        startDurationTimer();
      } else {
        widget.manager.notifier.addListener(onLiveDurationManagerValueChanged);
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
                  fontSize: widget.fontSize ?? 25.r,
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

  void onLiveDurationManagerValueChanged() {
    if (widget.manager.isValid) {
      startDurationTimer();
    }
  }

  void startDurationTimer() {
    final networkTimestamp = ZegoUIKit().getNetworkTimeStamp();
    beginDuration = DateTime.fromMillisecondsSinceEpoch(networkTimestamp)
        .difference(widget.manager.notifier.value);

    durationTimer?.cancel();
    durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationNotifier.value = beginDuration! + Duration(seconds: timer.tick);
      widget.config.onDurationUpdate?.call(durationNotifier.value);
    });
  }
}
