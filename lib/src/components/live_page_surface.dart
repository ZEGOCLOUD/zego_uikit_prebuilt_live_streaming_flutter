// Dart imports:
import 'dart:async';
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/bottom_bar.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/in_room_live_commenting_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/top_bar.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_controller.dart';

/// @nodoc
class ZegoLivePageSurface extends StatefulWidget {
  const ZegoLivePageSurface({
    Key? key,
    required this.config,
    required this.hostManager,
    required this.liveStatusManager,
    required this.liveDurationManager,
    required this.popUpManager,
    required this.connectManager,
    this.plugins,
    this.controller,
  }) : super(key: key);

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoLiveHostManager hostManager;
  final ZegoLiveStatusManager liveStatusManager;
  final ZegoLiveDurationManager liveDurationManager;
  final ZegoPopUpManager popUpManager;
  final ZegoPrebuiltPlugins? plugins;
  final ZegoLiveConnectManager connectManager;

  final ZegoUIKitPrebuiltLiveStreamingController? controller;

  @override
  State<ZegoLivePageSurface> createState() => ZegoLivePageSurfaceState();
}

/// @nodoc
class ZegoLivePageSurfaceState extends State<ZegoLivePageSurface>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  Timer? durationTimer;
  Duration? beginDuration;
  var durationNotifier = ValueNotifier<Duration>(Duration.zero);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(_animationController);

    if (widget.config.durationConfig.isVisible) {
      ZegoLoggerService.logInfo(
        'init duration',
        tag: 'live',
        subTag: 'prebuilt',
      );

      if (widget.liveDurationManager.isValid) {
        startDurationTimer();
      } else {
        widget.liveDurationManager.notifier
            .addListener(onLiveDurationManagerValueChanged);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    durationTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // 添加此行

      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _animationController.value +=
            details.primaryDelta! / context.size!.width;
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_animationController.value >= 0.5) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: SlideTransition(
        position: _animation,
        child: Stack(
          children: [
            topBar(),
            bottomBar(),
            messageList(),
            durationTimeBoard(),
          ],
        ),
      ),
    );
  }

  Widget topBar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 64.r,
      child: ZegoTopBar(
        config: widget.config,
        isPluginEnabled: widget.plugins?.isEnabled ?? false,
        hostManager: widget.hostManager,
        hostUpdateEnabledNotifier: widget.hostManager.hostUpdateEnabledNotifier,
        connectManager: widget.connectManager,
        popUpManager: widget.popUpManager,
        isLeaveRequestingNotifier: widget.controller?.isLeaveRequestingNotifier,
        translationText: widget.config.innerText,
      ),
    );
  }

  Widget bottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ZegoBottomBar(
        buttonSize: zegoLiveButtonSize,
        config: widget.config,
        hostManager: widget.hostManager,
        hostUpdateEnabledNotifier: widget.hostManager.hostUpdateEnabledNotifier,
        liveStatusNotifier: widget.liveStatusManager.notifier,
        connectManager: widget.connectManager,
        isLeaveRequestingNotifier: widget.controller?.isLeaveRequestingNotifier,
        popUpManager: widget.popUpManager,
      ),
    );
  }

  Widget messageList() {
    return Positioned(
      left: 32.r,
      bottom: 124.r,
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(540.r, 400.r)),
        child: ZegoInRoomLiveCommentingView(
          itemBuilder: widget.config.inRoomMessageViewConfig.itemBuilder,
          opacity: widget.config.inRoomMessageViewConfig.opacity,
        ),
      ),
    );
  }

  Widget durationTimeBoard() {
    if (!widget.config.durationConfig.isVisible) {
      return Container();
    }

    return Positioned(
      left: 0,
      right: 0,
      top: 10,
      child: ValueListenableBuilder<Duration>(
        valueListenable: durationNotifier,
        builder: (context, elapsedTime, _) {
          if (!widget.liveDurationManager.isValid) {
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
                    fontSize: 25.r,
                  ),
                );
        },
      ),
    );
  }

  String durationFormatString(Duration elapsedTime) {
    final hours = elapsedTime.inHours;
    final minutes = elapsedTime.inMinutes.remainder(60);
    final seconds = elapsedTime.inSeconds.remainder(60);

    final minutesFormatString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:'
        : minutesFormatString;
  }

  void onLiveDurationManagerValueChanged() {
    if (widget.liveDurationManager.isValid) {
      startDurationTimer();
    }
  }

  void startDurationTimer() {
    ZegoUIKit().getNetworkTimeStamp().then((timestamp) {
      beginDuration = DateTime.fromMillisecondsSinceEpoch(timestamp)
          .difference(widget.liveDurationManager.notifier.value);

      durationTimer?.cancel();
      durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        durationNotifier.value = beginDuration! + Duration(seconds: timer.tick);
        widget.config.durationConfig.onDurationUpdate
            ?.call(durationNotifier.value);
      });
    });
  }
}
