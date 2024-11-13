// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_streaming.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/loading_builder.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/login_notifier.dart';

/// The encapsulation layer of the "Live Streaming Widget" includes the
/// functionality of swiping up and down to switch between live streams.
class ZegoLiveStreamingSwipingPage extends StatefulWidget {
  const ZegoLiveStreamingSwipingPage({
    Key? key,
    required this.initialLiveID,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.config,
    required this.swipingConfig,
    this.token = '',
    this.events,
  }) : super(key: key);
  final String initialLiveID;

  /// swiping config
  final ZegoLiveStreamingSwipingConfig swipingConfig;

  /// same as [ZegoLiveStreamingPage.appID]
  final int appID;

  /// same as [ZegoLiveStreamingPage.appSign]
  final String appSign;

  /// same as [ZegoLiveStreamingPage.token]
  final String token;

  /// same as [ZegoLiveStreamingPage.userID]
  final String userID;

  /// same as [ZegoLiveStreamingPage.userName]
  final String userName;

  /// same as [ZegoLiveStreamingPage.config]
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  /// same as [ZegoLiveStreamingPage.events]
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;

  /// @nodoc
  @override
  State<ZegoLiveStreamingSwipingPage> createState() =>
      _ZegoLiveStreamingSwipingPageState();
}

/// @nodoc
class _ZegoLiveStreamingSwipingPageState
    extends State<ZegoLiveStreamingSwipingPage> {
  ZegoLiveStreamingSwipingRoomLoginNotifier? roomLoginNotifier;
  late final PageController _pageController;

  String _targetRoomID = '';

  List<StreamSubscription<dynamic>?> subscriptions = [];

  int get currentPageIndex => _pageController.page?.round() ?? 0;

  int get pageCount => 2;

  Duration get pageDuration => const Duration(milliseconds: 500);

  Curve get pageCurve => Curves.easeInOut;

  @override
  void initState() {
    super.initState();

    /// when swiping, cannot cancel event listening, otherwise there will be timing problems, resulting in no more event callbacks
    ZegoUIKit().enableEventUninitOnRoomLeaved(false);

    roomLoginNotifier = ZegoLiveStreamingSwipingRoomLoginNotifier(
      configPlugins: widget.config.plugins,
    );
    roomLoginNotifier?.notifier.addListener(onRoomStateChanged);

    _pageController = PageController(initialPage: 0);

    _targetRoomID = widget.initialLiveID;
    if (_targetRoomID.isEmpty) {
      _targetRoomID = widget.swipingConfig.requireNextLiveID();
    }
    ZegoUIKitPrebuiltLiveStreamingController()
        .swiping
        .private
        .currentSwipingID = _targetRoomID;
    ZegoUIKitPrebuiltLiveStreamingController()
        .swiping
        .private
        .currentRoomSwipingDone = false;
    roomLoginNotifier?.resetCheckingData(_targetRoomID);

    ZegoUIKitPrebuiltLiveStreamingController().swiping.private.initByPrebuilt(
          swipingConfig: widget.config.swiping,
        );
    subscriptions.add(ZegoUIKitPrebuiltLiveStreamingController()
        .swiping
        .private
        .stream
        ?.stream
        .listen(onSwipingRequest));
  }

  @override
  void dispose() {
    super.dispose();

    ZegoUIKit().enableEventUninitOnRoomLeaved(true);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    _pageController.dispose();
    roomLoginNotifier?.notifier.removeListener(onRoomStateChanged);

    ZegoUIKitPrebuiltLiveStreamingController()
        .swiping
        .private
        .uninitByPrebuilt();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (!ZegoUIKitPrebuiltLiveStreamingController()
            .swiping
            .private
            .currentRoomSwipingDone) {
          ZegoLoggerService.logInfo(
            'onVerticalDragEnd, but current room not finish',
            tag: 'live-streaming',
            subTag: 'swiping',
          );

          return;
        }

        var targetRoomID = '';
        if (details.velocity.pixelsPerSecond.dy > 0) {
          targetRoomID = widget.swipingConfig.requirePreviousLiveID();
        } else if (details.velocity.pixelsPerSecond.dy < 0) {
          targetRoomID = widget.swipingConfig.requireNextLiveID();
        }
        swipingTo(targetRoomID);
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (pageIndex) {
          ZegoLoggerService.logInfo(
            'PageView.onPageChanged $pageIndex',
            tag: 'live-streaming',
            subTag: 'swiping',
          );
        },
        itemCount: pageCount,
        itemBuilder: (context, pageIndex) {
          ZegoLoggerService.logInfo(
            'PageView.itemBuilder $pageIndex, room id:$_targetRoomID',
            tag: 'live-streaming',
            subTag: 'swiping',
          );

          return ZegoLiveStreamingSwipingRoomLoadingBuilder(
            targetRoomID: _targetRoomID,
            loadingBuilder: widget.swipingConfig.loadingBuilder,
            roomBuilder: () {
              ZegoLoggerService.logInfo(
                'PageView.itemBuilder.builder, page index:$pageIndex live id:$_targetRoomID',
                tag: 'live-streaming',
                subTag: 'swiping',
              );

              ///wait express room and signaling room login result
              roomLoginNotifier?.resetCheckingData(_targetRoomID);

              return ZegoLiveStreamingPage(
                liveID: _targetRoomID,
                appID: widget.appID,
                appSign: widget.appSign,
                token: widget.token,
                userID: widget.userID,
                userName: widget.userName,
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
      tag: 'live-streaming',
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
        tag: 'live-streaming',
        subTag: 'swiping',
      );
    }

    ZegoLoggerService.logInfo(
      'on room state changed, express done:$expressDone, signaling done:$signalingDone',
      tag: 'live-streaming',
      subTag: 'swiping',
    );
    if (expressDone && signalingDone) {
      ZegoUIKitPrebuiltLiveStreamingController()
          .swiping
          .private
          .currentRoomSwipingDone = true;
    }
  }

  void swipingTo(String targetRoomID) {
    if (targetRoomID == _targetRoomID) {
      ZegoLoggerService.logInfo(
        'swipingTo, '
        'target room id($targetRoomID) is same as before ($_targetRoomID)',
        tag: 'live-streaming',
        subTag: 'swiping',
      );
      return;
    }

    if (targetRoomID.isEmpty) {
      ZegoLoggerService.logInfo(
        'swipingTo, target room id is empty',
        tag: 'live-streaming',
        subTag: 'swiping',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'swipingTo, $targetRoomID',
      tag: 'live-streaming',
      subTag: 'swiping',
    );

    _targetRoomID = targetRoomID;
    ZegoUIKitPrebuiltLiveStreamingController()
        .swiping
        .private
        .currentSwipingID = _targetRoomID;
    ZegoUIKitPrebuiltLiveStreamingController()
        .swiping
        .private
        .currentRoomSwipingDone = false;

    _pageController.jumpToPage(0 == currentPageIndex ? 1 : 0);
  }

  void onSwipingRequest(String targetRoomID) {
    if (!ZegoUIKitPrebuiltLiveStreamingController()
        .swiping
        .private
        .currentRoomSwipingDone) {
      ZegoLoggerService.logInfo(
        'onSwipingRequest $targetRoomID, but current room not finish',
        tag: 'live-streaming',
        subTag: 'swiping',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'onSwipingRequest $targetRoomID',
      tag: 'live-streaming',
      subTag: 'swiping',
    );

    swipingTo(targetRoomID);
  }
}
