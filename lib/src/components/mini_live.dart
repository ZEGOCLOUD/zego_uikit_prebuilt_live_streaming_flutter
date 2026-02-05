// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/pip/pip_ios.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/components/view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';

class ZegoMinimizingStreamingPage extends StatefulWidget {
  const ZegoMinimizingStreamingPage({
    super.key,
    required this.liveID,
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
    this.showLocalUserView = true,
    this.showCameraButton = true,
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
  });

  final String liveID;
  final Size size;
  final double padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool withCircleBorder;
  final bool showDevices;
  final bool showUserName;
  final bool showLeaveButton;
  final bool showLocalUserView;
  final bool showCameraButton;
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
  final pipLayoutUserListNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  Size get buttonArea => Size(widget.size.width * 0.2, widget.size.width * 0.2);

  Size get buttonSize => Size(widget.size.width * 0.1, widget.size.width * 0.1);

  bool get playingStreamInPIPUnderIOS {
    bool isPlaying = false;
    if (Platform.isIOS) {
      isPlaying = (ZegoUIKitPrebuiltLiveStreamingController()
              .pip
              .private
              .pipImpl() as ZegoLiveStreamingControllerIOSPIP)
          .isSupportInConfig;
    }

    return isPlaying;
  }

  @override
  void initState() {
    super.initState();

    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .activeUser
        .start(
          showLocalUserView: widget.showLocalUserView,
        );
  }

  @override
  void dispose() {
    super.dispose();

    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .activeUser
        .stop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final page = Scaffold(
          resizeToAvoidBottomInset: false,
          body: ZegoLiveStreamingPageLifeCycle()
                  .manager(widget.liveID)
                  .pk
                  .combineNotifier
                  .state
                  .value
              ? minimizingPKUsersWidget(constraints)
              : ValueListenableBuilder<String?>(
                  valueListenable: ZegoUIKitPrebuiltLiveStreamingController()
                      .minimize
                      .private
                      .activeUser
                      .activeUserIDNotifier,
                  builder: (context, activeUserID, _) {
                    return audioVideoContainer(
                      activeUserID ?? ZegoUIKit().getLocalUser().id,
                    );
                  },
                ),
        );

        return widget.withCircleBorder ? circleBorder(child: page) : page;
      },
    );
  }

  Widget audioVideoContainer(String activeUserID) {
    final avList = ZegoUIKit().getAudioVideoList(targetRoomID: widget.liveID);
    if (!widget.showLocalUserView) {
      avList.removeWhere((user) => user.id == ZegoUIKit().getLocalUser().id);
    }
    var displayWidthFactor = avList.length.toDouble();
    if (avList.length >= 3) {
      displayWidthFactor = 4.0;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final smallViewWidth = constraints.maxWidth / displayWidthFactor;
        final smallViewHeight = 16.0 / 9.0 * smallViewWidth;

        return Stack(
          children: [
            widget.background ?? Container(),
            IgnorePointer(
              ignoring: true,
              child: ZegoAudioVideoContainer(
                roomID: widget.liveID,
                layout: ZegoLayout.pictureInPicture(
                  smallViewPosition: ZegoViewPosition.bottomLeft,
                  smallViewMargin: EdgeInsets.only(
                    left: 10.zR,
                    top: 10.zR,
                    right: 10.zR,
                    bottom: 15.zR,
                  ),
                  smallViewSize: Size(smallViewWidth, smallViewHeight),
                  isSmallViewDraggable: false,
                  switchLargeOrSmallViewByClick: true,
                  isSmallViewsScrollable: false,
                  bigViewUserID: activeUserID,
                ),
                filterAudioVideo: (List<ZegoUIKitUser> users) {
                  if (!widget.showLocalUserView) {
                    users.removeWhere(
                        (user) => user.id == ZegoUIKit().getLocalUser().id);
                  }

                  return users;
                },
                avatarConfig: ZegoAvatarConfig(
                  builder: widget.avatarBuilder,
                  soundWaveColor: widget.soundWaveColor,
                ),
                foregroundBuilder: (
                  BuildContext context,
                  Size size,
                  ZegoUIKitUser? user,

                  /// {ZegoViewBuilderMapExtraInfoKey:value}
                  /// final value = extraInfo[ZegoViewBuilderMapExtraInfoKey.key.name]
                  Map<String, dynamic> extraInfo,
                ) {
                  if (playingStreamInPIPUnderIOS) {
                    /// not support if ios pip, platform view will be render wrong user
                    /// after changed
                    return Container();
                  }

                  final isActiveUser = activeUserID == user?.id;
                  return Stack(
                    children: [
                      if (isActiveUser) devices(user),
                      userName(user, alignCenter: !isActiveUser),
                    ],
                  );
                },
                backgroundBuilder: widget.backgroundBuilder,
                onUserListUpdated: (List<ZegoUIKitUser> userList) {
                  pipLayoutUserListNotifier.value = userList;
                },
              ),
            ),
            durationTimeBoard(),
            widget.foreground ?? Container(),
            widget.showLeaveButton ? leaveButton() : Container(),
          ],
        );
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
    final isInPK = ZegoLiveStreamingPageLifeCycle()
        .manager(widget.liveID)
        .pk
        .combineNotifier
        .state
        .value;
    if (isInPK) {
      pkView = ZegoLiveStreamingPKV2View(
        liveID: widget.liveID,
        constraints: constraints,
        hostManager:
            ZegoLiveStreamingPageLifeCycle().currentManagers.hostManager,
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
              roomID: widget.liveID,
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

  Widget userName(
    ZegoUIKitUser? activeUser, {
    bool alignCenter = false,
  }) {
    return widget.showUserName
        ? Positioned(
            left: alignCenter ? 0 : null,
            right: alignCenter ? 0 : 2.zW,
            bottom: 2.zH,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.black.withValues(alpha: 0.2),
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
      right: 10.zR,
      child: ZegoTextIconButton(
        buttonSize: Size(widget.size.width * 0.4, widget.size.width * 0.4),
        iconSize: Size(widget.size.width * 0.2, widget.size.width * 0.2),
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
        liveID: widget.liveID,
        config: widget.durationConfig ?? ZegoLiveStreamingDurationConfig(),
        events: widget.durationEvents ?? ZegoLiveStreamingDurationEvents(),
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
    if (ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .isLocalHost) {
      localRole = ZegoLiveStreamingRole.host;
    } else if (ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .connectManager
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
      bottom: buttonArea.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (cameraEnabled && widget.showCameraButton) ...[
            cameraControl(activeUser),
            SizedBox(width: 10.zR),
          ],
          if (microphoneEnabled && widget.showMicrophoneButton) ...[
            microphoneControl(activeUser),
            SizedBox(width: 10.zR),
          ]
        ],
      ),
    );
  }

  Widget redPoint() {
    return Positioned(
      right: 3,
      top: 3,
      child: ValueListenableBuilder<bool>(
          valueListenable: ZegoLiveStreamingPageLifeCycle()
              .manager(widget.liveID)
              .pk
              .combineNotifier
              .hasRequestEvent,
          builder: (context, hasPKRequestEvent, _) {
            final redPointWidget = Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              width: 15.zR,
              height: 15.zR,
            );
            return ZegoLiveStreamingPageLifeCycle()
                    .currentManagers
                    .hostManager
                    .isLocalHost
                ? ValueListenableBuilder<List<ZegoUIKitUser>>(
                    valueListenable: ZegoLiveStreamingPageLifeCycle()
                        .currentManagers
                        .connectManager
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
                    valueListenable: ZegoLiveStreamingPageLifeCycle()
                        .currentManagers
                        .connectManager
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
      valueListenable: ZegoUIKit().getCameraStateNotifier(
        targetRoomID: widget.liveID,
        activeUser.id,
      ),
      builder: (context, isCameraEnabled, _) {
        return GestureDetector(
          onTap: activeUser.id == ZegoUIKit().getLocalUser().id
              ? () {
                  ZegoUIKit().turnCameraOn(
                    targetRoomID: widget.liveID,
                    !isCameraEnabled,
                    userID: activeUser.id,
                  );
                }
              : null,
          child: Container(
            width: buttonArea.width,
            height: buttonArea.height,
            decoration: BoxDecoration(
              color: isCameraEnabled
                  ? controlBarButtonCheckedBackgroundColor
                  : controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: buttonSize.width,
                height: buttonSize.height,
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
      valueListenable: ZegoUIKit().getMicrophoneStateNotifier(
        targetRoomID: widget.liveID,
        activeUser.id,
      ),
      builder: (context, isMicrophoneEnabled, _) {
        return GestureDetector(
          onTap: activeUser.id == ZegoUIKit().getLocalUser().id
              ? () {
                  ZegoUIKit().turnMicrophoneOn(
                    targetRoomID: widget.liveID,
                    !isMicrophoneEnabled,
                    userID: activeUser.id,
                    muteMode:
                        !(widget.config?.coHost.stopCoHostingWhenMicCameraOff ??
                            true),
                  );
                }
              : null,
          child: Container(
            width: buttonArea.width,
            height: buttonArea.height,
            decoration: BoxDecoration(
              color: isMicrophoneEnabled
                  ? controlBarButtonCheckedBackgroundColor
                  : controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: buttonSize.width,
                height: buttonSize.height,
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

  Image uikitImage(String name) {
    return Image.asset(name, package: 'zego_uikit');
  }
}
