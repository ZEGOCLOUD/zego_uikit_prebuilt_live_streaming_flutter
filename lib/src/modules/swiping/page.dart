// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:loop_page_view/loop_page_view.dart';
import 'package:zego_uikit/zego_uikit.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_streaming_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
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
  bool get userDebugMode => true && kDebugMode;

  /// todo token expiration update

  int currentPageIndex = 0;
  final _canScrollNotifier = ValueNotifier<bool>(false);
  late ZegoLiveStreamingRoomLoginChecker initialRoomLoginChecker;
  late final LoopPageController pageController;
  late final ZegoLiveStreamingSwipingPageRoomSwitcher roomSwitchManager;

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

  @override
  void initState() {
    super.initState();

    currentPageIndex = startIndex;
    pageController = LoopPageController(initialPage: startIndex);
    roomSwitchManager = ZegoLiveStreamingSwipingPageRoomSwitcher(
      configPlugins: widget.config.plugins,
    );

    ZegoLoggerService.logInfo(
      'previous host:$previousHost, '
      'current host:$currentHost, '
      'next host:$nextHost, ',
      tag: 'live-streaming-swiping-page',
      subTag: 'initState',
    );

    /// Listen to initial room login status, once successful allow swiping, then stop listening
    initialRoomLoginChecker = ZegoLiveStreamingRoomLoginChecker(
      configPlugins: widget.config.plugins,
    );
    initialRoomLoginChecker.resetCheckingData(currentHost!.roomID);
    _onInitialRoomLoginChanged();
    initialRoomLoginChecker.notifier.addListener(_onInitialRoomLoginChanged);

    ZegoLiveStreamingPageLifeCycle().swiping.streamContext.updateContext(
          previousHost: previousHost ?? ZegoLiveStreamingSwipingHost.empty(),
          currentHost: currentHost ?? ZegoLiveStreamingSwipingHost.empty(),
          nextHost: nextHost ?? ZegoLiveStreamingSwipingHost.empty(),
        );
  }

  void _onInitialRoomLoginChanged() {
    ZegoLoggerService.logInfo(
      'checker room id:${initialRoomLoginChecker.targetRoomID}, '
      'checker value:${initialRoomLoginChecker.notifier.value}, '
      'current host:$currentHost, ',
      tag: 'live-streaming-swiping-page',
      subTag: 'onInitialRoomLoginChanged',
    );

    if (initialRoomLoginChecker.notifier.value) {
      /// Initial room login successful, allow swiping, and remove listener
      _canScrollNotifier.value = true;
      initialRoomLoginChecker.notifier
          .removeListener(_onInitialRoomLoginChanged);
    }
  }

  @override
  void dispose() {
    initialRoomLoginChecker.notifier.removeListener(_onInitialRoomLoginChanged);
    _canScrollNotifier.dispose();
    roomSwitchManager.dispose();
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _canScrollNotifier,
      builder: (context, canScroll, _) {
        return LoopPageView.builder(
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
              tag: 'live-streaming-swiping-page',
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
                if (userDebugMode)
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
        );
      },
    );
  }

  Future<void> onPageChanged(int pageIndex) async {
    ZegoLoggerService.logInfo(
      'pageIndex:$pageIndex, '
      'currentPageIndex:$currentPageIndex, ',
      tag: 'live-streaming-swiping-page',
      subTag: 'onPageChanged',
    );

    if (currentPageIndex == pageIndex) {
      ZegoLoggerService.logInfo(
        'same, ignore',
        tag: 'live-streaming-swiping-page',
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
      tag: 'live-streaming-swiping-page',
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
      roomSwitchManager.updateRoomID(
        currentHost!.roomID,
        widget.token,
        shouldCheckCurrentRoom: false,
      );
    }
  }
}
