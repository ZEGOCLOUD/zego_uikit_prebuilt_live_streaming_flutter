// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/bottom_bar.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/in_room_live_commenting_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/top_bar.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/live_duration_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/minimizing/prebuilt_data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_controller.dart';

/// @nodoc
class ZegoLivePageSurface extends StatefulWidget {
  const ZegoLivePageSurface({
    Key? key,
    required this.config,
    required this.prebuiltData,
    required this.hostManager,
    required this.liveStatusManager,
    required this.liveDurationManager,
    required this.popUpManager,
    required this.connectManager,
    this.plugins,
    this.controller,
  }) : super(key: key);

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingData prebuiltData;

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
  }

  @override
  void dispose() {
    _animationController.dispose();

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
        prebuiltData: widget.prebuiltData,
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
        prebuiltData: widget.prebuiltData,
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
      child: LiveDurationTimeBoard(
        config: widget.config.durationConfig,
        manager: widget.liveDurationManager,
      ),
    );
  }
}
