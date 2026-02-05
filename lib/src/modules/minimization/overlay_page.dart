// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/mini_live.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';
import 'data.dart';
import 'defines.dart';
import 'overlay_machine.dart';

/// The page can be minimization within the app
///
/// To support the minimize functionality in the app:
///
/// 1. Add a minimize button.
/// ```dart
/// ZegoUIKitPrebuiltLiveStreamingConfig.topMenuBar.buttons.add(ZegoLiveStreamingMenuBarButtonName.minimizingButton)
/// ```
/// Alternatively, if you have defined your own button, you can call:
/// ```dart
/// ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize().
/// ```
///
/// 2. Nest the `ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage` within your MaterialApp widget. Make sure to return the correct context in the `contextQuery` parameter.
///
/// How to add in MaterialApp, example:
/// ```dart
///
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final navigatorKey = GlobalKey<NavigatorState>();
///   runApp(MyApp(
///     navigatorKey: navigatorKey,
///   ));
/// }
///
/// class MyApp extends StatefulWidget {
///   final GlobalKey<NavigatorState> navigatorKey;
///
///   const MyApp({
///     required this.navigatorKey,
///     Key? key,
///   }) : super(key: key);
///
///   @override
///   State<StatefulWidget> createState() => MyAppState();
/// }
///
/// class MyAppState extends State<MyApp> {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       title: 'Flutter Demo',
///       home: const ZegoUIKitPrebuiltLiveStreamingMiniPopScope(
///        child: HomePage(),
///      ),
///       navigatorKey: widget.navigatorKey,
///       builder: (BuildContext context, Widget? child) {
///         return Stack(
///           children: [
///             child!,
///
///             /// support minimizing
///             ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage(
///               contextQuery: () {
///                 return widget.navigatorKey.currentState!.context;
///               },
///             ),
///           ],
///         );
///       },
///     );
///   }
/// }
/// ```
class ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage({
    super.key,
    required this.contextQuery,
    this.rootNavigator = true,
    this.navigatorWithSafeArea = true,
    this.size,
    this.topLeft = const Offset(100, 100),
    this.borderRadius = 6.0,
    this.borderColor = Colors.black12,
    this.soundWaveColor = const Color(0xff2254f6),
    this.padding = 0.0,
    this.showDevices = true,
    this.showUserName = true,
    this.showLeaveButton = true,
    this.leaveButtonIcon,
    this.builder,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.foreground,
    this.avatarBuilder,
  });

  final BuildContext Function() contextQuery;
  final bool rootNavigator;
  final bool navigatorWithSafeArea;

  final Size? size;
  final double padding;
  final double borderRadius;
  final Color borderColor;
  final Color soundWaveColor;
  final Offset topLeft;
  final bool showDevices;
  final bool showUserName;

  final bool showLeaveButton;
  final Widget? leaveButtonIcon;

  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final Widget? foreground;
  final Widget Function(ZegoUIKitUser? activeUser)? builder;

  @override
  State<ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingMiniOverlayPageState();
}

/// @nodoc
class _ZegoUIKitPrebuiltLiveStreamingMiniOverlayPageState
    extends State<ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage> {
  late Size overlaySize;

  ZegoLiveStreamingMiniOverlayPageState currentState =
      ZegoLiveStreamingMiniOverlayPageState.idle;

  bool visibility = true;
  late Offset topLeft;

  ZegoLiveStreamingMinimizationData? get prebuiltData =>
      ZegoUIKitPrebuiltLiveStreamingController().minimize.private.minimizeData;

  @override
  void initState() {
    super.initState();

    topLeft = widget.topLeft;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZegoLiveStreamingMiniOverlayMachine()
          .registerStateChanged(onMiniOverlayMachineStateChanged);

      if (null != ZegoLiveStreamingMiniOverlayMachine().machine.current) {
        syncState();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    ZegoLiveStreamingMiniOverlayMachine()
        .unregisterStateChanged(onMiniOverlayMachineStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: ZegoLiveStreamingPageLifeCycle()
            .manager(ZegoUIKitPrebuiltLiveStreamingController().private.liveID)
            .pk
            .combineNotifier
            .state,
        builder: (context, isInPK, _) {
          overlaySize = calculateItemSize();

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (didPop) {
                return;
              }

              // Prevent the default pop-up behavior in the minimization state
              // Prevent popping by not calling Navigator.pop()
            },
            child: Visibility(
              visible: visibility,
              child: Positioned(
                left: topLeft.dx,
                top: topLeft.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      var x = topLeft.dx + details.delta.dx;
                      var y = topLeft.dy + details.delta.dy;
                      x = x.clamp(
                        0.0,
                        MediaQuery.of(context).size.width - overlaySize.width,
                      );
                      y = y.clamp(
                          0.0,
                          MediaQuery.of(context).size.height -
                              overlaySize.height);
                      topLeft = Offset(x, y);
                    });
                  },
                  child: SizedBox(
                    width: overlaySize.width,
                    height: overlaySize.height,
                    child: overlayItem(),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Size calculateItemSize() {
    if (null != widget.size) {
      return widget.size!;
    }

    final size = MediaQuery.of(context).size;
    final manager = ZegoLiveStreamingPageLifeCycle()
        .manager(ZegoUIKitPrebuiltLiveStreamingController().private.liveID);
    final isInPK = manager.pk.liveID ==
            ZegoUIKitPrebuiltLiveStreamingController().private.liveID &&
        manager.pk.combineNotifier.state.value;

    if (isInPK) {
      /// pk has two audio views
      final width = size.width / 2.0;
      final height = 16.0 / 18.0 * width;
      return Size(width, height);
    } else {
      final width = size.width / 4.0;
      final height = 16.0 / 9.0 * width;
      return Size(width, height);
    }
  }

  Widget overlayItem() {
    switch (currentState) {
      case ZegoLiveStreamingMiniOverlayPageState.idle:
      case ZegoLiveStreamingMiniOverlayPageState.living:
        return Container();
      case ZegoLiveStreamingMiniOverlayPageState.minimizing:
        ZegoLoggerService.logInfo(
          'live id:${ZegoUIKitPrebuiltLiveStreamingController().private.liveID}, ',
          tag: 'live.streaming.minimization.page',
          subTag: 'build page',
        );

        return GestureDetector(
          onTap: () {
            ZegoLoggerService.logInfo(
              'currentState:$currentState, '
              'visibility:$visibility, ',
              tag: 'live.streaming.minimization.page',
              subTag: 'onTap',
            );

            ZegoUIKitPrebuiltLiveStreamingController().minimize.restore(
                  widget.contextQuery(),
                  rootNavigator: widget.rootNavigator,
                  withSafeArea: widget.navigatorWithSafeArea,
                );
          },
          child: ZegoMinimizingStreamingPage(
            /// todo
            liveID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
            size: Size(
              overlaySize.width,
              overlaySize.height,
            ),
            config: prebuiltData?.config,
            borderRadius: widget.borderRadius,
            borderColor: widget.borderColor,
            padding: widget.padding,
            withCircleBorder: true,
            showDevices: widget.showDevices,
            showUserName: widget.showUserName,
            showLeaveButton: widget.showLeaveButton,
            soundWaveColor: widget.soundWaveColor,
            leaveButtonIcon: widget.leaveButtonIcon,
            foreground: widget.foreground,
            builder: widget.builder,
            foregroundBuilder: widget.foregroundBuilder,
            backgroundBuilder: widget.backgroundBuilder,
            avatarBuilder:
                widget.avatarBuilder ?? prebuiltData?.config.avatarBuilder,
            durationConfig: prebuiltData?.config.duration ??
                ZegoLiveStreamingDurationConfig(),
            durationEvents: prebuiltData?.events?.duration ??
                ZegoLiveStreamingDurationEvents(),
          ),
        );
    }
  }

  void syncState() {
    setState(() {
      currentState = ZegoLiveStreamingMiniOverlayMachine().state;
      visibility =
          currentState == ZegoLiveStreamingMiniOverlayPageState.minimizing;
      ZegoLoggerService.logInfo(
        'currentState:$currentState, '
        'visibility:$visibility, ',
        tag: 'live.streaming.minimization.page',
        subTag: 'syncState',
      );
    });
  }

  void onMiniOverlayMachineStateChanged(
      ZegoLiveStreamingMiniOverlayPageState state) {
    /// Overlay and setState may be in different contexts, causing the framework to be unable to update.
    ///
    /// The purpose of Future.delayed(Duration.zero, callback) is to execute the callback function in the next frame,
    /// which is equivalent to putting the callback function at the end of the queue,
    /// thus avoiding conflicts with the current frame and preventing the above-mentioned error from occurring.
    Future.delayed(Duration.zero, () {
      syncState();
    });
  }
}
