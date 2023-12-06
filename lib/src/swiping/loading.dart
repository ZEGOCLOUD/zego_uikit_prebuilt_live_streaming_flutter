// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/logout_notifier.dart';

/// @nodoc
class ZegoSwipingRoomLoadingBuilder extends StatefulWidget {
  const ZegoSwipingRoomLoadingBuilder({
    Key? key,
    required this.targetRoomID,
    required this.roomBuilder,
    required this.loadingBuilder,
  }) : super(key: key);

  final String targetRoomID;
  final Widget Function() roomBuilder;
  final Widget Function(String roomID)? loadingBuilder;

  @override
  State<ZegoSwipingRoomLoadingBuilder> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingScrollerElementState();
}

/// @nodoc
class _ZegoUIKitPrebuiltLiveStreamingScrollerElementState
    extends State<ZegoSwipingRoomLoadingBuilder> {
  final roomBuildNotifier = ValueNotifier<bool>(false);
  final roomLogoutNotifier = ZegoRoomLogoutNotifier();

  @override
  void initState() {
    super.initState();

    final isFromMinimizing = PrebuiltLiveStreamingMiniOverlayPageState.idle !=
        ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state;

    ///wait express room and zim room logout
    if (isFromMinimizing || roomLogoutNotifier.value) {
      ZegoLoggerService.logInfo(
        'room ${widget.targetRoomID} is logout or from minimizing($isFromMinimizing), can build',
        tag: 'live streaming',
        subTag: 'swiping-loading',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        roomBuildNotifier.value = true;
      });
    } else {
      ZegoLoggerService.logInfo(
        'room ${widget.targetRoomID} is not logout, wait room logout',
        tag: 'live streaming',
        subTag: 'swiping-loading',
      );

      roomLogoutNotifier.notifier.addListener(onRoomStateChanged);
    }
  }

  @override
  void dispose() {
    super.dispose();
    roomLogoutNotifier.notifier.removeListener(onRoomStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: roomBuildNotifier,
      builder: (context, canBuild, _) {
        return canBuild
            ? widget.roomBuilder()
            : Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: widget.loadingBuilder?.call(widget.targetRoomID) ??
                      const CircularProgressIndicator(),
                ),
              );
      },
    );
  }

  void onRoomStateChanged() {
    ZegoLoggerService.logInfo(
      'room ${widget.targetRoomID} state changed, logout:${roomLogoutNotifier.value}',
      tag: 'live streaming',
      subTag: 'swiping-loading',
    );

    if (roomLogoutNotifier.value) {
      ZegoLoggerService.logInfo(
        'room ${widget.targetRoomID} had logout, build..',
        tag: 'live streaming',
        subTag: 'swiping-loading',
      );

      roomBuildNotifier.value = true;
    }
  }
}
