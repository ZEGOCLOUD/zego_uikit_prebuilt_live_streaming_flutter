// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_streaming.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/loading.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/login_notifier.dart';

/// The encapsulation layer of the "Live Streaming Widget" includes the
/// functionality of swiping up and down to switch between live streams.
class ZegoUIKitPrebuiltLiveStreamingSwiping extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreamingSwiping({
    Key? key,
    required this.initialLiveID,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.config,
    required this.swipingConfig,
    this.controller,
    this.events,
  }) : super(key: key);
  final String initialLiveID;

  /// swiping config
  final ZegoLiveStreamingSwipingConfig swipingConfig;

  /// same as [ZegoUIKitPrebuiltLiveStreamingPage.appID]
  final int appID;

  /// same as [ZegoUIKitPrebuiltLiveStreamingPage.appSign]
  final String appSign;

  /// same as [ZegoUIKitPrebuiltLiveStreamingPage.userID]
  final String userID;

  /// same as [ZegoUIKitPrebuiltLiveStreamingPage.userName]
  final String userName;

  /// same as [ZegoUIKitPrebuiltLiveStreamingPage.config]
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  /// same as [ZegoUIKitPrebuiltLiveStreamingPage.controller]
  final ZegoUIKitPrebuiltLiveStreamingController? controller;

  /// same as [ZegoUIKitPrebuiltLiveStreamingPage.events]
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;

  /// @nodoc
  @override
  State<ZegoUIKitPrebuiltLiveStreamingSwiping> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingSwipingState();
}

/// @nodoc
class _ZegoUIKitPrebuiltLiveStreamingSwipingState
    extends State<ZegoUIKitPrebuiltLiveStreamingSwiping> {
  ZegoRoomLoginNotifier? roomLoginNotifier;
  late final PageController _pageController;

  String _targetRoomID = '';
  bool _targetRoomDone = false;

  int get currentPageIndex => _pageController.page?.round() ?? 0;

  int get pageCount => 2;

  Duration get pageDuration => const Duration(milliseconds: 500);

  Curve get pageCurve => Curves.easeInOut;

  @override
  void initState() {
    super.initState();

    roomLoginNotifier = ZegoRoomLoginNotifier(
      configPlugins: widget.config.plugins,
    );
    roomLoginNotifier?.notifier.addListener(onRoomStateChanged);

    _pageController = PageController(initialPage: 0);

    _targetRoomID = widget.initialLiveID;
    if (_targetRoomID.isEmpty) {
      _targetRoomID = widget.swipingConfig.requireNextLiveID();
    }
    ZegoLiveStreamingManagers().swipingCurrentLiveID = _targetRoomID;
    _targetRoomDone = false;
    roomLoginNotifier?.resetCheckingData(_targetRoomID);
  }

  @override
  void dispose() {
    super.dispose();

    _pageController.dispose();
    roomLoginNotifier?.notifier.removeListener(onRoomStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (!_targetRoomDone) {
          return;
        }

        var targetRoomID = '';
        if (details.velocity.pixelsPerSecond.dy > 0) {
          targetRoomID = widget.swipingConfig.requirePreviousLiveID();
        } else if (details.velocity.pixelsPerSecond.dy < 0) {
          targetRoomID = widget.swipingConfig.requireNextLiveID();
        }
        if (targetRoomID == _targetRoomID) {
          ZegoLoggerService.logInfo(
            'PageView.onVerticalDragEnd target room id($targetRoomID) is same as before($_targetRoomID)',
            tag: 'live streaming',
            subTag: 'swiping',
          );
          return;
        }
        if (targetRoomID.isEmpty) {
          ZegoLoggerService.logInfo(
            'PageView.onVerticalDragEnd target room id is empty',
            tag: 'live streaming',
            subTag: 'swiping',
          );
          return;
        }

        _targetRoomID = targetRoomID;
        ZegoLiveStreamingManagers().swipingCurrentLiveID = _targetRoomID;
        _targetRoomDone = false;

        _pageController.jumpToPage(0 == currentPageIndex ? 1 : 0);
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (pageIndex) {
          ZegoLoggerService.logInfo(
            'PageView.onPageChanged $pageIndex',
            tag: 'live streaming',
            subTag: 'swiping',
          );
        },
        itemCount: pageCount,
        itemBuilder: (context, pageIndex) {
          ZegoLoggerService.logInfo(
            'PageView.itemBuilder $pageIndex, room id:$_targetRoomID',
            tag: 'live streaming',
            subTag: 'swiping',
          );

          return ZegoSwipingRoomLoadingBuilder(
            targetRoomID: _targetRoomID,
            loadingBuilder: widget.swipingConfig.loadingBuilder,
            roomBuilder: () {
              ZegoLoggerService.logInfo(
                'PageView.itemBuilder.builder, page index:$pageIndex live id:$_targetRoomID',
                tag: 'live streaming',
                subTag: 'swiping',
              );

              ///wait express room and signaling room login result
              roomLoginNotifier?.resetCheckingData(_targetRoomID);

              return ZegoUIKitPrebuiltLiveStreamingPage(
                liveID: _targetRoomID,
                appID: widget.appID,
                appSign: widget.appSign,
                userID: widget.userID,
                userName: widget.userName,
                controller: widget.controller,
                events: widget.events,
                config: widget.config,
              );
            },
          );
        },
      ),
    );
  }

  void onRoomStateChanged() {
    final expressDone = ZegoUIKit().getRoom().id == _targetRoomID &&
        ZegoRoomStateChangedReason.Logined ==
            ZegoUIKit().getRoomStateStream().value.reason;

    ZegoLoggerService.logInfo(
      'on room state changed, '
      'target room id:$_targetRoomID, '
      'express room id:${ZegoUIKit().getRoom().id}, '
      'express room state:${ZegoUIKit().getRoomStateStream().value.reason}, ',
      tag: 'live streaming',
      subTag: 'swiping',
    );

    var signalingDone = true;
    if (null != ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      signalingDone =
          ZegoUIKit().getSignalingPlugin().getRoomID() == _targetRoomID &&
              ZegoSignalingPluginRoomState.connected ==
                  ZegoUIKit().getSignalingPlugin().getRoomState();

      ZegoLoggerService.logInfo(
        'on room state changed, '
        'signaling room id:${ZegoUIKit().getSignalingPlugin().getRoomID()}, '
        'signaling room state:${ZegoUIKit().getSignalingPlugin().getRoomState()},',
        tag: 'live streaming',
        subTag: 'swiping',
      );
    }

    ZegoLoggerService.logInfo(
      'on room state changed, express done:$expressDone, signaling done:$signalingDone',
      tag: 'live streaming',
      subTag: 'swiping',
    );
    if (expressDone && signalingDone) {
      _targetRoomDone = true;
    }
  }
}
