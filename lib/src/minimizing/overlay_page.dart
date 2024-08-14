// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/components/view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';

/// The page can be minimized within the app
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
    Key? key,
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
  }) : super(key: key);

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

  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final activeUserIDNotifier = ValueNotifier<String?>(null);
  final Map<String, List<double>> rangeSoundLevels = {};

  ZegoLiveStreamingMinimizeData? get prebuiltData =>
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

    activeUserTimer?.cancel();
    activeUserTimer = null;

    audioVideoListSubscription?.cancel();

    ZegoLiveStreamingMiniOverlayMachine()
        .unregisterStateChanged(onMiniOverlayMachineStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable:
            ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state,
        builder: (context, isInPK, _) {
          overlaySize = calculateItemSize();

          return PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) async {
              if (didPop) {
                return;
              }
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
                          MediaQuery.of(context).size.width -
                              overlaySize.width);
                      y = y.clamp(
                          0.0,
                          MediaQuery.of(context).size.height -
                              overlaySize.height);
                      topLeft = Offset(x, y);
                    });
                  },
                  child: LayoutBuilder(builder: (context, constraints) {
                    return SizedBox(
                      width: overlaySize.width,
                      height: overlaySize.height,
                      child: overlayItem(constraints),
                    );
                  }),
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
    final isInPK =
        ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state.value;
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

  Widget overlayItem(BoxConstraints constraints) {
    switch (currentState) {
      case ZegoLiveStreamingMiniOverlayPageState.idle:
      case ZegoLiveStreamingMiniOverlayPageState.living:
        return Container();
      case ZegoLiveStreamingMiniOverlayPageState.minimizing:
        return GestureDetector(
          onTap: () {
            ZegoUIKitPrebuiltLiveStreamingController().minimize.restore(
                  widget.contextQuery(),
                  rootNavigator: widget.rootNavigator,
                  withSafeArea: widget.navigatorWithSafeArea,
                );
          },
          child: circleBorder(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: ZegoLiveStreamingPKBattleStateCombineNotifier
                      .instance.state.value
                  ? minimizingPKUsersWidget(constraints)
                  : ValueListenableBuilder<String?>(
                      valueListenable: activeUserIDNotifier,
                      builder: (context, activeUserID, _) {
                        return minimizingUserWidget(
                          ZegoUIKit().getUser(activeUserID ?? ''),
                        );
                      },
                    ),
            ),
          ),
        );
    }
  }

  Widget minimizingPKUsersWidget(BoxConstraints constraints) {
    final spacing = 5.zR;

    Widget pkView = const SizedBox.shrink();

    final constraints = BoxConstraints(
      maxWidth: overlaySize.width - spacing,
      maxHeight: overlaySize.height - spacing,
    );
    final config =
        prebuiltData?.config ?? ZegoUIKitPrebuiltLiveStreamingConfig();
    final avatarConfig = ZegoAvatarConfig(
      builder: widget.avatarBuilder ?? prebuiltData?.config.avatarBuilder,
      soundWaveColor: widget.soundWaveColor,
    );

    /// new pk
    if (ZegoUIKitPrebuiltLiveStreamingPK.instance.isInPK) {
      pkView = ZegoLiveStreamingPKV2View(
        constraints: constraints,
        hostManager: ZegoLiveStreamingManagers().hostManager!,
        config: config,
        foregroundBuilder: widget.foregroundBuilder,
        backgroundBuilder: widget.backgroundBuilder,
        avatarConfig: avatarConfig,
      );
    }

    return Stack(
      children: [
        ...pkBackground(),
        Positioned(
          left: 0,
          right: 0,
          child: pkView,
        ),
        durationTimeBoard(),
        widget.foreground ?? Container(),
        widget.showLeaveButton ? leaveButton() : Container(),
      ],
    );
  }

  Widget minimizingUserWidget(ZegoUIKitUser? activeUser) {
    return widget.builder?.call(activeUser) ??
        Stack(
          children: [
            ZegoAudioVideoView(
              user: activeUser,
              foregroundBuilder: widget.foregroundBuilder,
              backgroundBuilder: widget.backgroundBuilder,
              avatarConfig: ZegoAvatarConfig(
                builder:
                    widget.avatarBuilder ?? prebuiltData?.config.avatarBuilder,
                soundWaveColor: widget.soundWaveColor,
              ),
            ),
            devices(activeUser),
            userName(activeUser),
            durationTimeBoard(),
            redPoint(),
            widget.foreground ?? Container(),
            widget.showLeaveButton ? leaveButton() : Container(),
          ],
        );
  }

  Widget userName(ZegoUIKitUser? activeUser) {
    return widget.showUserName
        ? Positioned(
            left: 2.zR,
            top: 25.zR,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.black.withOpacity(0.2),
              ),
              width: overlaySize.width / 3 * 2,
              child: Text(
                activeUser?.name ?? '',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: overlaySize.width * 0.08,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          )
        : Container();
  }

  Widget circleBorder({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(widget.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
      ),
      child: PhysicalModel(
        color: const Color(0xffA4A4A4),
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        shadowColor: Colors.black,
        child: child,
      ),
    );
  }

  Widget leaveButton() {
    return Positioned(
      top: 12.zR,
      right: 2.zR,
      child: ZegoTextIconButton(
        buttonSize: Size(50.zR, 50.zR),
        iconSize: Size(40.zR, 40.zR),
        icon: ButtonIcon(
          icon: widget.leaveButtonIcon ??
              Icon(
                Icons.close,
                color: Colors.white,
                size: 30.zR,
              ),
          backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
        ),
        onPressed: () async {
          await ZegoUIKitPrebuiltLiveStreamingController().leave(
            context,
            showConfirmation: false,
          );
        },
      ),
    );
  }

  Widget durationTimeBoard() {
    return Positioned(
      left: 0,
      right: 0,
      top: 2.zR,
      child: ZegoLiveStreamingDurationTimeBoard(
        config:
            prebuiltData?.config.duration ?? ZegoLiveStreamingDurationConfig(),
        events:
            prebuiltData?.events.duration ?? ZegoLiveStreamingDurationEvents(),
        manager: ZegoLiveStreamingManagers().liveDurationManager!,
        fontSize: 15.zR,
      ),
    );
  }

  Widget devices(ZegoUIKitUser? activeUser) {
    if (null == activeUser) {
      return Container();
    }

    if (!widget.showDevices) {
      return Container();
    }

    var localRole = ZegoLiveStreamingRole.audience;
    if (ZegoLiveStreamingManagers().hostManager!.isLocalHost) {
      localRole = ZegoLiveStreamingRole.host;
    } else if (ZegoLiveStreamingManagers()
        .connectManager!
        .isCoHost(ZegoUIKit().getLocalUser())) {
      localRole = ZegoLiveStreamingRole.coHost;
    }
    var bottomButtons = <ZegoLiveStreamingMenuBarButtonName>[];
    switch (localRole) {
      case ZegoLiveStreamingRole.host:
        bottomButtons = prebuiltData?.config.bottomMenuBar.hostButtons ?? [];
        break;
      case ZegoLiveStreamingRole.coHost:
        bottomButtons = prebuiltData?.config.bottomMenuBar.coHostButtons ?? [];
        break;
      case ZegoLiveStreamingRole.audience:
        bottomButtons =
            prebuiltData?.config.bottomMenuBar.audienceButtons ?? [];
        break;
    }
    final cameraEnabled = bottomButtons
        .contains(ZegoLiveStreamingMenuBarButtonName.toggleCameraButton);
    final microphoneEnabled = bottomButtons
        .contains(ZegoLiveStreamingMenuBarButtonName.toggleMicrophoneButton);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (cameraEnabled) cameraControl(activeUser),
          if (microphoneEnabled) microphoneControl(activeUser),
        ],
      ),
    );
  }

  Widget redPoint() {
    return Positioned(
      right: 3,
      top: 3,
      child: ValueListenableBuilder<bool>(
          valueListenable: ZegoLiveStreamingPKBattleStateCombineNotifier
              .instance.hasRequestEvent,
          builder: (context, hasPKRequestEvent, _) {
            final redPointWidget = Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              width: 15.zR,
              height: 15.zR,
            );
            return ZegoLiveStreamingManagers().hostManager!.isLocalHost
                ? ValueListenableBuilder<List<ZegoUIKitUser>>(
                    valueListenable: ZegoLiveStreamingManagers()
                        .connectManager!
                        .requestCoHostUsersNotifier,
                    builder: (context, requestCoHostUsers, _) {
                      if (requestCoHostUsers.isEmpty && !hasPKRequestEvent) {
                        return Container();
                      } else {
                        return redPointWidget;
                      }
                    },
                  )
                : ValueListenableBuilder<
                    ZegoLiveStreamingCoHostAudienceEventRequestReceivedData?>(
                    valueListenable: ZegoLiveStreamingManagers()
                        .connectManager!
                        .dataOfInvitedToJoinCoHostInMinimizingNotifier,
                    builder:
                        (context, dataOfInvitedToJoinCoHostInMinimizing, _) {
                      if (null == dataOfInvitedToJoinCoHostInMinimizing &&
                          !hasPKRequestEvent) {
                        return Container();
                      } else {
                        return redPointWidget;
                      }
                    },
                  );
          }),
    );
  }

  Widget cameraControl(ZegoUIKitUser activeUser) {
    const toolbarCameraNormal = 'assets/icons/s1_ctrl_bar_camera_normal.png';
    const toolbarCameraOff = 'assets/icons/s1_ctrl_bar_camera_off.png';

    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getCameraStateNotifier(activeUser.id),
      builder: (context, isCameraEnabled, _) {
        return GestureDetector(
          onTap: activeUser.id == ZegoUIKit().getLocalUser().id
              ? () {
                  ZegoUIKit()
                      .turnCameraOn(!isCameraEnabled, userID: activeUser.id);
                }
              : null,
          child: Container(
            width: overlaySize.width * 0.3,
            height: overlaySize.width * 0.3,
            decoration: BoxDecoration(
              color: isCameraEnabled
                  ? controlBarButtonCheckedBackgroundColor
                  : controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: overlaySize.width * 0.2,
                height: overlaySize.width * 0.2,
                child: uikitImage(
                  isCameraEnabled ? toolbarCameraNormal : toolbarCameraOff,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget microphoneControl(ZegoUIKitUser activeUser) {
    const toolbarMicNormal = 'assets/icons/s1_ctrl_bar_mic_normal.png';
    const toolbarMicOff = 'assets/icons/s1_ctrl_bar_mic_off.png';

    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getMicrophoneStateNotifier(activeUser.id),
      builder: (context, isMicrophoneEnabled, _) {
        return GestureDetector(
          onTap: activeUser.id == ZegoUIKit().getLocalUser().id
              ? () {
                  ZegoUIKit().turnMicrophoneOn(
                    !isMicrophoneEnabled,
                    userID: activeUser.id,
                    muteMode: !(prebuiltData
                            ?.config.coHost.stopCoHostingWhenMicCameraOff ??
                        true),
                  );
                }
              : null,
          child: Container(
            width: overlaySize.width * 0.3,
            height: overlaySize.width * 0.3,
            decoration: BoxDecoration(
              color: isMicrophoneEnabled
                  ? controlBarButtonCheckedBackgroundColor
                  : controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: overlaySize.width * 0.2,
                height: overlaySize.width * 0.2,
                child: uikitImage(
                  isMicrophoneEnabled ? toolbarMicNormal : toolbarMicOff,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void syncState() {
    setState(() {
      currentState = ZegoLiveStreamingMiniOverlayMachine().state;
      visibility =
          currentState == ZegoLiveStreamingMiniOverlayPageState.minimizing;

      if (visibility) {
        listenAudioVideoList();
        activeUserTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          updateActiveUserByTimer();
        });
      } else {
        audioVideoListSubscription?.cancel();
        activeUserTimer?.cancel();
        activeUserTimer = null;
      }
    });
  }

  void listenAudioVideoList() {
    audioVideoListSubscription =
        ZegoUIKit().getAudioVideoListStream().listen(onAudioVideoListUpdated);

    onAudioVideoListUpdated(ZegoUIKit().getAudioVideoList());
    activeUserIDNotifier.value = ZegoUIKit().getAudioVideoList().isEmpty
        ? ZegoUIKit().getLocalUser().id
        : ZegoUIKit().getAudioVideoList().first.id;
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    for (final subscription in soundLevelSubscriptions) {
      subscription?.cancel();
    }
    rangeSoundLevels.clear();

    for (final user in users) {
      soundLevelSubscriptions.add(user.soundLevel.listen((soundLevel) {
        if (rangeSoundLevels.containsKey(user.id)) {
          rangeSoundLevels[user.id]!.add(soundLevel);
        } else {
          rangeSoundLevels[user.id] = [soundLevel];
        }
      }));
    }
  }

  void updateActiveUserByTimer() {
    var maxAverageSoundLevel = 0.0;
    var activeUserID = '';
    rangeSoundLevels.forEach((userID, soundLevels) {
      final averageSoundLevel =
          soundLevels.reduce((a, b) => a + b) / soundLevels.length;

      if (averageSoundLevel > maxAverageSoundLevel) {
        activeUserID = userID;
        maxAverageSoundLevel = averageSoundLevel;
      }
    });
    activeUserIDNotifier.value = activeUserID;
    if (activeUserIDNotifier.value?.isEmpty ?? true) {
      activeUserIDNotifier.value = ZegoUIKit().getLocalUser().id;
    }

    rangeSoundLevels.clear();
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

  Image uikitImage(String name) {
    return Image.asset(name, package: 'zego_uikit');
  }

  List<Widget> pkBackground() {
    final background = prebuiltData?.config.background ??
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ZegoLiveStreamingImage.assetImage(
                ZegoLiveStreamingIconUrls.background,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );

    return [
      Positioned(top: 0, left: 0, right: 0, bottom: 0, child: background),
    ];
  }
}
