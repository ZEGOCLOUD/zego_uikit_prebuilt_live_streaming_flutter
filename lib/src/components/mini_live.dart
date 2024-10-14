// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/components/view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';

class ZegoMinimizingStreamingPage extends StatefulWidget {
  const ZegoMinimizingStreamingPage({
    Key? key,
    required this.size,
    this.config,
    this.borderRadius = 6.0,
    this.borderColor,
    this.backgroundColor,
    this.padding = 0.0,
    this.withCircleBorder = true,
    this.showDevices = true,
    this.showUserName = true,
    this.showLeaveButton = true,
    this.showMicrophoneButton = true,
    this.soundWaveColor = const Color(0xff2254f6),
    this.leaveButtonIcon,
    this.foreground,
    this.builder,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarBuilder,
    this.durationConfig,
    this.durationEvents,
    this.background,
  }) : super(key: key);

  final Size size;
  final double padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool withCircleBorder;
  final bool showDevices;
  final bool showUserName;
  final bool showLeaveButton;
  final bool showMicrophoneButton;
  final Widget? leaveButtonIcon;

  final Color soundWaveColor;
  final Widget? background;
  final Widget? foreground;
  final Widget Function(ZegoUIKitUser? activeUser)? builder;

  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarBuilder? avatarBuilder;

  final ZegoLiveStreamingDurationConfig? durationConfig;
  final ZegoLiveStreamingDurationEvents? durationEvents;

  final ZegoUIKitPrebuiltLiveStreamingConfig? config;

  @override
  State<ZegoMinimizingStreamingPage> createState() =>
      ZegoMinimizingStreamingPageState();
}

class ZegoMinimizingStreamingPageState
    extends State<ZegoMinimizingStreamingPage> {
  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final activeUserIDNotifier = ValueNotifier<String?>(null);
  final Map<String, List<double>> rangeSoundLevels = {};

  @override
  void initState() {
    super.initState();

    listenAudioVideoList();
    activeUserTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateActiveUserByTimer();
    });
  }

  @override
  void dispose() {
    super.dispose();

    activeUserTimer?.cancel();
    activeUserTimer = null;

    audioVideoListSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final page = Scaffold(
          resizeToAvoidBottomInset: false,
          body:
              ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state.value
                  ? minimizingPKUsersWidget(constraints)
                  : ValueListenableBuilder<String?>(
                      valueListenable: activeUserIDNotifier,
                      builder: (context, activeUserID, _) {
                        return minimizingUserWidget(
                          ZegoUIKit().getUser(activeUserID ?? ''),
                        );
                      },
                    ),
        );
        return widget.withCircleBorder
            ? circleBorder(
                child: page,
              )
            : page;
      },
    );
  }

  Widget minimizingPKUsersWidget(BoxConstraints constraints) {
    final spacing = 5.zR;

    Widget pkView = const SizedBox.shrink();

    final constraints = BoxConstraints(
      maxWidth: widget.size.width - spacing,
      maxHeight: widget.size.height - spacing,
    );
    final avatarConfig = ZegoAvatarConfig(
      builder: widget.avatarBuilder,
      soundWaveColor: widget.soundWaveColor,
    );

    /// new pk
    if (ZegoUIKitPrebuiltLiveStreamingPK.instance.isInPK) {
      pkView = ZegoLiveStreamingPKV2View(
        constraints: constraints,
        hostManager: ZegoLiveStreamingManagers().hostManager!,
        config: widget.config ?? ZegoUIKitPrebuiltLiveStreamingConfig(),
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
            widget.background ?? Container(),
            ZegoAudioVideoView(
              user: activeUser,
              foregroundBuilder: widget.foregroundBuilder,
              backgroundBuilder: widget.backgroundBuilder,
              avatarConfig: ZegoAvatarConfig(
                builder: widget.avatarBuilder,
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
              width: widget.size.width / 3 * 2,
              child: Text(
                activeUser?.name ?? '',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.size.width * 0.08,
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
        config: widget.durationConfig ?? ZegoLiveStreamingDurationConfig(),
        events: widget.durationEvents ?? ZegoLiveStreamingDurationEvents(),
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
        bottomButtons = widget.config?.bottomMenuBar.hostButtons ?? [];
        break;
      case ZegoLiveStreamingRole.coHost:
        bottomButtons = widget.config?.bottomMenuBar.coHostButtons ?? [];
        break;
      case ZegoLiveStreamingRole.audience:
        bottomButtons = widget.config?.bottomMenuBar.audienceButtons ?? [];
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
          if (cameraEnabled && widget.showMicrophoneButton)
            cameraControl(activeUser),
          if (microphoneEnabled && widget.showMicrophoneButton)
            microphoneControl(activeUser),
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
            width: widget.size.width * 0.3,
            height: widget.size.width * 0.3,
            decoration: BoxDecoration(
              color: isCameraEnabled
                  ? controlBarButtonCheckedBackgroundColor
                  : controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: widget.size.width * 0.2,
                height: widget.size.width * 0.2,
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
                        !(widget.config?.coHost.stopCoHostingWhenMicCameraOff ??
                            true),
                  );
                }
              : null,
          child: Container(
            width: widget.size.width * 0.3,
            height: widget.size.width * 0.3,
            decoration: BoxDecoration(
              color: isMicrophoneEnabled
                  ? controlBarButtonCheckedBackgroundColor
                  : controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: widget.size.width * 0.2,
                height: widget.size.width * 0.2,
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

  List<Widget> pkBackground() {
    final background = widget.config?.background ??
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

  Image uikitImage(String name) {
    return Image.asset(name, package: 'zego_uikit');
  }
}
