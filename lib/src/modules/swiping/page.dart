// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:loop_page_view/loop_page_view.dart';
import 'package:zego_uikit/zego_uikit.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_streaming_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/swiping/page_room_switcher.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/swiping/room_login_checker.dart';

import 'defines.dart';

/// The encapsulation layer of the "Live Streaming Widget" includes the
/// functionality of swiping up and down to switch between live streams.
///
/// Internally driven by whether **ZegoUIKitPrebuiltLiveStreamingConfig.swiping** is set to determine whether to display the interface
class ZegoLiveStreamingSwipingPage extends StatefulWidget {
  const ZegoLiveStreamingSwipingPage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.config,
    required this.popUpManager,
    required this.isPrebuiltFromMinimizing,
    required this.isPrebuiltFromHall,
    this.swipingModel,
    this.swipingModelDelegate,
    this.token = '',
    this.events,
  });

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

  final ZegoLiveStreamingPopUpManager popUpManager;
  final bool isPrebuiltFromMinimizing;
  final bool isPrebuiltFromHall;

  /// swiping model
  /// list of [live id]
  /// When swiping up or down, the corresponding LIVE ID will be returned via this [model]
  final ZegoLiveStreamingSwipingModel? swipingModel;

  /// If you want to manage data yourself, please refer to [ZegoLiveStreamingSwipingModel],
  /// then cancel the setting of [model], and then set [modelDelegate]
  final ZegoLiveStreamingSwipingModelDelegate? swipingModelDelegate;

  /// @nodoc
  @override
  State<ZegoLiveStreamingSwipingPage> createState() =>
      _ZegoLiveStreamingSwipingPageState();
}

/// @nodoc
class _ZegoLiveStreamingSwipingPageState
    extends State<ZegoLiveStreamingSwipingPage> {
  /// todo token expiration update

  int currentPageIndex = 0;
  final _canScrollNotifier = ValueNotifier<bool>(false);
  late ZegoLiveStreamingRoomLoginChecker roomLoginChecker;
  late final LoopPageController pageController;
  late final ZegoLiveStreamingSwipingPageRoomSwitcher roomSwitchManager;

  // Track mute state for previous/next pages during scrolling
  bool _isPreviousUnmuted = false;
  bool _isNextUnmuted = false;

  // Track last pixels value to calculate scroll direction
  double? _lastPixels;

  // Accumulated offset from current page
  double _accumulatedOffset = 0.0;

  // Track if page has changed via onPageChanged to filter stale scroll updates
  bool _pageChangedFlag = false;

  int get startIndex => 0;

  int get endIndex => 2;

  int get pageCount => (endIndex - startIndex) + 1;

  ZegoLiveStreamingSwipingHost? get previousHost =>
      widget.swipingModel?.activeContext?.previous ??
      widget.swipingModelDelegate?.activeContext.previous;

  ZegoLiveStreamingSwipingHost? get currentHost =>
      widget.swipingModel?.activeRoom ??
      widget.swipingModelDelegate?.activeRoom;

  ZegoLiveStreamingSwipingHost? get nextHost =>
      widget.swipingModel?.activeContext?.next ??
      widget.swipingModelDelegate?.activeContext.next;

  ZegoLiveStreamingStreamMode get streamMode =>
      widget.config.swiping?.streamMode ??
      ZegoLiveStreamingStreamMode.preloaded;

  @override
  void initState() {
    super.initState();

    ZegoLoggerService.logInfo(
      'initState, _canScrollNotifier.value:${_canScrollNotifier.value}, ',
      tag: 'live.streaming.swiping.page',
      subTag: 'initState',
    );

    currentPageIndex = startIndex;
    pageController = LoopPageController(initialPage: startIndex);
    roomSwitchManager = ZegoLiveStreamingSwipingPageRoomSwitcher(
      configPlugins: widget.config.plugins,
      onRoomWillSwitch: (String liveID) {
        ZegoLiveStreamingPageLifeCycle().onRoomWillSwitch(
          liveID: liveID,
        );
      },
      onRoomSwitched: (String liveID) {
        syncRoomLoginChecker(currentHost!.roomID);

        ZegoLiveStreamingPageLifeCycle().onRoomSwitched(
          liveID: liveID,
          config: widget.config,
          events: widget.events,
        );
      },
    );

    ZegoLoggerService.logInfo(
      'previous host:$previousHost, '
      'current host:$currentHost, '
      'next host:$nextHost, ',
      tag: 'live.streaming.swiping.page',
      subTag: 'initState',
    );

    /// Listen to initial room login status, once successful allow swiping, then stop listening
    roomLoginChecker = ZegoLiveStreamingRoomLoginChecker(
      configPlugins: widget.config.plugins,
    );
    roomLoginChecker.notifier.addListener(onPageRoomLoginChanged);
    syncRoomLoginChecker(currentHost!.roomID);

    ZegoLiveStreamingPageLifeCycle().swiping.streamContext.updateContext(
          previousHost: previousHost ?? ZegoLiveStreamingSwipingHost.empty(),
          currentHost: currentHost ?? ZegoLiveStreamingSwipingHost.empty(),
          nextHost: nextHost ?? ZegoLiveStreamingSwipingHost.empty(),
        );

    ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .connectManager
        .audienceLocalConnectStateNotifier
        .addListener(onAudienceLocalConnectStateUpdated);
  }

  @override
  void dispose() {
    roomLoginChecker.notifier.removeListener(onPageRoomLoginChanged);
    _canScrollNotifier.dispose();
    roomSwitchManager.dispose();
    pageController.dispose();

    ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .connectManager
        .audienceLocalConnectStateNotifier
        .removeListener(onAudienceLocalConnectStateUpdated);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _canScrollNotifier,
      builder: (context, canScroll, _) {
        return NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: LoopPageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,

            /// Must wait for first room to join before scrolling, otherwise switch will fail
            physics: canScroll ? null : NeverScrollableScrollPhysics(),

            // allowImplicitScrolling: true,
            onPageChanged: onPageChanged,
            itemCount: pageCount,
            itemBuilder: (context, pageIndex) {
              ZegoLiveStreamingSwipingHost? itemHost;

              if (pageIndex == currentPageIndex) {
                itemHost = currentHost;
              } else {
                bool toNext = false;
                if (currentPageIndex == startIndex && pageIndex == endIndex) {
                  toNext = false;
                } else if (currentPageIndex == endIndex &&
                    pageIndex == startIndex) {
                  toNext = true;
                } else {
                  toNext = pageIndex > currentPageIndex;
                }

                itemHost = toNext ? nextHost : previousHost;
              }

              itemHost ??= ZegoLiveStreamingSwipingHost.empty();

              ZegoLoggerService.logInfo(
                'pageIndex:$pageIndex, '
                'item host:$itemHost, ',
                tag: 'live.streaming.swiping.page',
                subTag: 'itemBuilder',
              );

              return Stack(
                children: [
                  ZegoLiveStreamingPage(
                    liveID: itemHost.roomID,
                    appID: widget.appID,
                    appSign: widget.appSign,
                    token: widget.token,
                    userID: widget.userID,
                    userName: widget.userName,
                    events: widget.events,
                    config: widget.config,
                    popUpManager: widget.popUpManager,
                    isPrebuiltFromMinimizing: widget.isPrebuiltFromMinimizing,
                    isPrebuiltFromHall: widget.isPrebuiltFromHall,
                  ),
                  if (ZegoUIKit().useDebugMode)
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Page '
                        '$pageIndex, '
                        'live id:${itemHost.roomID}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      _handleScrollUpdate(notification);
    } else if (notification is ScrollEndNotification) {
      _handleScrollEnd();
    }
    return false;
  }

  void _handleScrollUpdate(ScrollNotification notification) {
    final metrics = notification.metrics;
    // Check if metrics has pixels and viewport dimension
    if (!metrics.hasPixels || !metrics.hasContentDimensions) {
      return;
    }

    final currentPixels = metrics.pixels;

    // Initialize lastPixels if not set
    if (_lastPixels == null) {
      _lastPixels = currentPixels;
      return;
    }

    // Calculate offset based on pixels change relative to viewport
    // For LoopPageView, pixels can be very large, so we calculate relative offset
    final pixelsDelta = currentPixels - _lastPixels!;
    final incrementalOffset = pixelsDelta / metrics.viewportDimension;

    // Check if page has changed via onPageChanged to filter stale scroll updates
    // If onPageChanged has already triggered, skip this stale update
    if (_pageChangedFlag) {
      // Reset tracking variables and clear the flag
      _lastPixels = null;
      _pageChangedFlag = false;
      return;
    }

    // Accumulate offset to track total scroll distance from current page
    // >0.5 next page&onPageChanged happened
    // <-0.5 previous page&onPageChanged happened
    _accumulatedOffset += incrementalOffset;

    // Update lastPixels for next calculation
    _lastPixels = currentPixels;

    // Calculate if previous/next page is visible
    // When accumulatedOffset > 0, scrolling down (next page visible)
    // When accumulatedOffset < 0, scrolling up (previous page visible)
    // Threshold: if accumulatedOffset > 0.01, next page is visible; if accumulatedOffset < -0.01, previous page is visible
    const threshold = 0.01;

    final isNextVisible = _accumulatedOffset > threshold;
    final isPreviousVisible = _accumulatedOffset < -threshold;

    // Unmute next page if visible and not already unmuted
    if (isNextVisible && !_isNextUnmuted && nextHost != null) {
      _unmuteHost(nextHost!);
      _isNextUnmuted = true;
      ZegoLoggerService.logInfo(
        'unmute next page during scroll, accumulatedOffset:$_accumulatedOffset',
        tag: 'live.streaming.swiping.page',
        subTag: 'scroll',
      );
    } else if (!isNextVisible && _isNextUnmuted && nextHost != null) {
      // Mute next page if not visible and currently unmuted
      _muteHost(nextHost!);
      _isNextUnmuted = false;
      ZegoLoggerService.logInfo(
        'mute next page during scroll, accumulatedOffset:$_accumulatedOffset',
        tag: 'live.streaming.swiping.page',
        subTag: 'scroll',
      );
    }

    // Unmute previous page if visible and not already unmuted
    if (isPreviousVisible && !_isPreviousUnmuted && previousHost != null) {
      _unmuteHost(previousHost!);
      _isPreviousUnmuted = true;
      ZegoLoggerService.logInfo(
        'unmute previous page during scroll, accumulatedOffset:$_accumulatedOffset',
        tag: 'live.streaming.swiping.page',
        subTag: 'scroll',
      );
    } else if (!isPreviousVisible &&
        _isPreviousUnmuted &&
        previousHost != null) {
      // Mute previous page if not visible and currently unmuted
      _muteHost(previousHost!);
      _isPreviousUnmuted = false;
      ZegoLoggerService.logInfo(
        'mute previous page during scroll, accumulatedOffset:$_accumulatedOffset',
        tag: 'live.streaming.swiping.page',
        subTag: 'scroll',
      );
    }
  }

  void _handleScrollEnd() {
    // Reset tracking variables when scroll ends
    _lastPixels = null;
    _accumulatedOffset = 0.0;

    // When scroll ends (user releases finger), re-mute any unmuted pages
    // that are not the current page
    if (_isNextUnmuted && nextHost != null) {
      _muteHost(nextHost!);
      _isNextUnmuted = false;
      ZegoLoggerService.logInfo(
        'mute next page on scroll end',
        tag: 'live.streaming.swiping.page',
        subTag: 'scroll',
      );
    }
    if (_isPreviousUnmuted && previousHost != null) {
      _muteHost(previousHost!);
      _isPreviousUnmuted = false;
      ZegoLoggerService.logInfo(
        'mute previous page on scroll end',
        tag: 'live.streaming.swiping.page',
        subTag: 'scroll',
      );
    }
  }

  Future<void> _muteHost(ZegoLiveStreamingSwipingHost host) async {
    if (streamMode == ZegoLiveStreamingStreamMode.preloaded) {
      /// Quick mode: use mute/unmute
      await ZegoUIKit().muteUserAudioVideo(
        host.user.id,
        true, // mute
        targetRoomID: host.roomID,
      );
    } else {
      /// Normal mode: stop playing stream to avoid extra costs
      await ZegoUIKit().stopPlayingStream(
        host.streamID,
        targetRoomID: host.roomID,
      );
    }
  }

  Future<void> _unmuteHost(ZegoLiveStreamingSwipingHost host) async {
    if (streamMode == ZegoLiveStreamingStreamMode.preloaded) {
      /// Quick mode: only enable video;
      /// audio should only be enabled when the page is actually switched to onPageChanged.
      await ZegoUIKit().muteUserVideo(
        host.user.id,
        false, // unmute
        targetRoomID: host.roomID,
      );
    } else {
      /// Normal mode: start playing stream
      await ZegoUIKit().startPlayingStream(
        host.streamID,
        host.user.id,
        targetRoomID: host.roomID,
      );
    }
  }

  void syncRoomLoginChecker(String liveID) {
    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.swiping.page',
      subTag: 'syncRoomLoginChecker',
    );

    roomLoginChecker.resetCheckingData(liveID);
    onPageRoomLoginChanged();
  }

  void onPageRoomLoginChanged() {
    final checkerValue = roomLoginChecker.notifier.value;
    final oldCanScroll = _canScrollNotifier.value;

    ZegoLoggerService.logInfo(
      'checker room id:${roomLoginChecker.targetRoomID}, '
      'checker value:$checkerValue, '
      'current host:$currentHost, '
      'old _canScrollNotifier.value:$oldCanScroll, ',
      tag: 'live.streaming.swiping.page',
      subTag: 'onPageRoomLoginChanged',
    );

    if (checkerValue) {
      /// Initial room login successful, allow swiping, and remove listener
      _canScrollNotifier.value = true;
      ZegoLoggerService.logInfo(
        '_canScrollNotifier.value changed from $oldCanScroll to true, ',
        tag: 'live.streaming.swiping.page',
        subTag: 'onPageRoomLoginChanged',
      );
      roomLoginChecker.notifier.removeListener(onPageRoomLoginChanged);
    }
  }

  Future<void> onPageChanged(int pageIndex) async {
    ZegoLoggerService.logInfo(
      'pageIndex:$pageIndex, '
      'currentPageIndex:$currentPageIndex, ',
      tag: 'live.streaming.swiping.page',
      subTag: 'onPageChanged',
    );

    if (currentPageIndex == pageIndex) {
      ZegoLoggerService.logInfo(
        'same, ignore',
        tag: 'live.streaming.swiping.page',
        subTag: 'onPageChanged',
      );
      return;
    }

    bool toNext = false;
    if (currentPageIndex == startIndex && pageIndex == endIndex) {
      /// Boundary point swipe up
      toNext = false;
    } else if (currentPageIndex == endIndex && pageIndex == startIndex) {
      /// Boundary point swipe down
      toNext = true;
    } else {
      toNext = pageIndex > currentPageIndex;
    }

    final oldCurrentPageIndex = currentPageIndex;
    currentPageIndex = pageIndex;

    // Reset scroll mute state when page actually changes
    _lastPixels = null;

    // Set flag to filter stale scroll updates that may arrive after onPageChanged
    _pageChangedFlag = true;

    if (toNext) {
      widget.swipingModel?.next();
    } else {
      widget.swipingModel?.previous();
    }
    widget.swipingModelDelegate?.delegate?.call(toNext);

    ZegoLoggerService.logInfo(
      'page index:{now:$pageIndex, previous:$oldCurrentPageIndex},'
      'previous host:$previousHost, '
      'current host:$currentHost, '
      'next host:$nextHost, ',
      tag: 'live.streaming.swiping.page',
      subTag: 'onPageChanged',
    );

    await ZegoLiveStreamingPageLifeCycle().swiping.streamContext.updateContext(
          previousHost: previousHost ?? ZegoLiveStreamingSwipingHost.empty(),
          currentHost: currentHost ?? ZegoLiveStreamingSwipingHost.empty(),
          nextHost: nextHost ?? ZegoLiveStreamingSwipingHost.empty(),
        );
    ZegoUIKitPrebuiltLiveStreamingController()
        .hall
        .private
        .controller
        .private
        .private
        .forceUpdate();

    /// Push to stack, start room switching flow
    /// What's pushed to stack is the new room ID (currentHost.roomID) and token
    /// shouldCheckCurrentRoom is set to false, because currentHost was just updated in onPageChanged, no need to check
    if (currentHost?.roomID.isNotEmpty ?? false) {
      /// Swiping is not allowed until successful login in the current room
      final oldCanScroll = _canScrollNotifier.value;
      _canScrollNotifier.value = false;
      ZegoLoggerService.logInfo(
        '_canScrollNotifier.value changed from $oldCanScroll to false, '
        'currentHost.roomID:${currentHost!.roomID}, ',
        tag: 'live.streaming.swiping.page',
        subTag: 'onPageChanged',
      );
      syncRoomLoginChecker(currentHost!.roomID);

      roomSwitchManager.updateRoomID(
        currentHost!.roomID,
        widget.token,
        shouldCheckCurrentRoom: false,
      );
    }
  }

  void onAudienceLocalConnectStateUpdated() {
    final audienceLocalConnectState = ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .connectManager
        .audienceLocalConnectStateNotifier
        .value;

    _canScrollNotifier.value = roomLoginChecker.notifier.value &&

        /// During co-hosting, swiping to switch LIVE rooms is not allowed
        ///
        /// todo: How to do event throwing and default pop-up prompt??
        ZegoLiveStreamingAudienceConnectState.connected !=
            audienceLocalConnectState;

    ZegoLoggerService.logInfo(
      'audienceLocalConnectState:$audienceLocalConnectState, '
      'roomLoginChecker value:${roomLoginChecker.notifier.value}, '
      'canScroll:${_canScrollNotifier.value}, ',
      tag: 'live.streaming.swiping.page',
      subTag: 'onAudienceLocalConnectStateUpdated',
    );
  }
}
