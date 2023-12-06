// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_service.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/components/view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/core.dart';

/// @nodoc
/// @deprecated Use ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage
typedef ZegoMiniOverlayPage = ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage;

/// @nodoc
class ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage({
    Key? key,
    required this.contextQuery,
    this.size,
    this.topLeft = const Offset(100, 100),
    this.borderRadius = 6.0,
    this.borderColor = Colors.black12,
    this.soundWaveColor = const Color(0xff2254f6),
    this.padding = 0.0,
    this.showDevices = true,
    this.showUserName = true,
    this.builder,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.foreground,
    this.avatarBuilder,
  }) : super(key: key);

  final Size? size;
  final double padding;
  final double borderRadius;
  final Color borderColor;
  final Color soundWaveColor;
  final Offset topLeft;
  final bool showDevices;
  final bool showUserName;
  final BuildContext Function() contextQuery;

  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final Widget? foreground;
  final Widget Function(ZegoUIKitUser? activeUser)? builder;

  @override
  ZegoUIKitPrebuiltLiveStreamingMiniOverlayPageState createState() =>
      ZegoUIKitPrebuiltLiveStreamingMiniOverlayPageState();
}

/// @nodoc
class ZegoUIKitPrebuiltLiveStreamingMiniOverlayPageState
    extends State<ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage> {
  late Size overlaySize;

  PrebuiltLiveStreamingMiniOverlayPageState currentState =
      PrebuiltLiveStreamingMiniOverlayPageState.idle;

  bool visibility = true;
  late Offset topLeft;

  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final activeUserIDNotifier = ValueNotifier<String?>(null);
  final Map<String, List<double>> rangeSoundLevels = {};

  @override
  void initState() {
    super.initState();

    topLeft = widget.topLeft;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
          .listenStateChanged(onMiniOverlayMachineStateChanged);

      if (null !=
          ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().machine.current) {
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

    ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable:
            ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state,
        builder: (context, isInPK, _) {
          overlaySize = calculateItemSize();

          return WillPopScope(
            onWillPop: () async {
              return false;
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
      case PrebuiltLiveStreamingMiniOverlayPageState.idle:
      case PrebuiltLiveStreamingMiniOverlayPageState.living:
        return Container();
      case PrebuiltLiveStreamingMiniOverlayPageState.minimizing:
        return GestureDetector(
          onTap: () {
            final prebuiltData =
                ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().prebuiltData;
            assert(null != prebuiltData);

            /// re-enter prebuilt call
            ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
                .restoreFromMinimize();

            Navigator.of(widget.contextQuery(), rootNavigator: true).push(
              MaterialPageRoute(builder: (context) {
                final isSwiping = prebuiltData?.config.swipingConfig != null;
                return ZegoUIKitPrebuiltLiveStreaming(
                  appID: prebuiltData!.appID,
                  appSign: prebuiltData.appSign,
                  userID: prebuiltData.userID,
                  userName: prebuiltData.userName,
                  liveID: isSwiping
                      ? ZegoLiveStreamingManagers().swipingCurrentLiveID
                      : prebuiltData.liveID,
                  config: prebuiltData.config,
                  controller: prebuiltData.controller,
                  events: prebuiltData.events,
                );
              }),
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
    final config = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
            .prebuiltData
            ?.config ??
        ZegoUIKitPrebuiltLiveStreamingConfig();
    final avatarConfig = ZegoAvatarConfig(
      builder: widget.avatarBuilder ??
          ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
              .prebuiltData
              ?.config
              .avatarBuilder,
      soundWaveColor: widget.soundWaveColor,
    );

    /// old pk
    if (ZegoLiveStreamingPKBattleManager().isInPK) {
      pkView = ZegoLiveStreamingPKBattleView(
        withAspectRatio: false,
        constraints: constraints,
        config: config,
        foregroundBuilder: widget.foregroundBuilder,
        backgroundBuilder: widget.backgroundBuilder,
        avatarConfig: avatarConfig,
      );
    }

    /// new pk
    if (ZegoUIKitPrebuiltLiveStreamingPKV2.instance.isInPK) {
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
                builder: widget.avatarBuilder ??
                    ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
                        .prebuiltData
                        ?.config
                        .avatarBuilder,
                soundWaveColor: widget.soundWaveColor,
              ),
            ),
            devices(activeUser),
            userName(activeUser),
            durationTimeBoard(),
            redPoint(),
            widget.foreground ?? Container(),
          ],
        );
  }

  Widget userName(ZegoUIKitUser? activeUser) {
    return widget.showUserName
        ? Positioned(
            right: 5,
            top: 12,
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

  Widget durationTimeBoard() {
    return Positioned(
      left: 0,
      right: 0,
      top: 2,
      child: LiveDurationTimeBoard(
        config: ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
                .prebuiltData
                ?.config
                .durationConfig ??
            ZegoLiveDurationConfig(),
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
    var bottomButtons = <ZegoMenuBarButtonName>[];
    switch (localRole) {
      case ZegoLiveStreamingRole.host:
        bottomButtons = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
                .prebuiltData
                ?.config
                .bottomMenuBarConfig
                .hostButtons ??
            [];
        break;
      case ZegoLiveStreamingRole.coHost:
        bottomButtons = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
                .prebuiltData
                ?.config
                .bottomMenuBarConfig
                .coHostButtons ??
            [];
        break;
      case ZegoLiveStreamingRole.audience:
        bottomButtons = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
                .prebuiltData
                ?.config
                .bottomMenuBarConfig
                .audienceButtons ??
            [];
        break;
    }
    final cameraEnabled =
        bottomButtons.contains(ZegoMenuBarButtonName.toggleCameraButton);
    final microphoneEnabled =
        bottomButtons.contains(ZegoMenuBarButtonName.toggleMicrophoneButton);
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
          builder: (context, hasRequestEvent, _) {
            return ValueListenableBuilder<List<ZegoUIKitUser>>(
                valueListenable: ZegoLiveStreamingManagers()
                    .connectManager!
                    .requestCoHostUsersNotifier,
                builder: (context, requestCoHostUsers, _) {
                  if (requestCoHostUsers.isEmpty && !hasRequestEvent) {
                    return Container();
                  } else {
                    return Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 15.zR,
                      height: 15.zR,
                    );
                  }
                });
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
                    muteMode:
                        !(ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
                                .prebuiltData
                                ?.config
                                .stopCoHostingWhenMicCameraOff ??
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
      currentState = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state;
      visibility =
          currentState == PrebuiltLiveStreamingMiniOverlayPageState.minimizing;

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
      PrebuiltLiveStreamingMiniOverlayPageState state) {
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
    final background = ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine()
            .prebuiltData
            ?.config
            .background ??
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: PrebuiltLiveStreamingImage.assetImage(
                PrebuiltLiveStreamingIconUrls.background,
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
