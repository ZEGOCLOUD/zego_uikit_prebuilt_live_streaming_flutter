// Dart imports:
import 'dart:async';
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/audio_video_view_foreground.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/src/pk_impl.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/components/view.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/defines.dart';

/// @nodoc
class ZegoLivePageCentralAudioVideoView extends StatefulWidget {
  const ZegoLivePageCentralAudioVideoView({
    Key? key,
    required this.config,
    required this.hostManager,
    required this.liveStatusManager,
    required this.popUpManager,
    required this.controller,
    required this.constraints,
    this.plugins,
  }) : super(key: key);

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoLiveHostManager hostManager;
  final ZegoLiveStatusManager liveStatusManager;
  final ZegoPopUpManager popUpManager;
  final ZegoPrebuiltPlugins? plugins;

  final ZegoUIKitPrebuiltLiveStreamingController controller;
  final BoxConstraints constraints;

  @override
  State<ZegoLivePageCentralAudioVideoView> createState() =>
      ZegoLivePageCentralAudioVideoViewState();
}

/// @nodoc
class ZegoLivePageCentralAudioVideoViewState
    extends State<ZegoLivePageCentralAudioVideoView> {
  /// had sort the host be first
  bool audioVideoContainerHostHadSorted = false;
  List<StreamSubscription<dynamic>?> subscriptions = [];

  bool get isLivingWithHost =>
      LiveStatus.living == widget.liveStatusManager.notifier.value &&
      widget.hostManager.notifier.value != null;

  @override
  void initState() {
    super.initState();

    widget.liveStatusManager.notifier.addListener(onLiveStatusUpdated);
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    widget.liveStatusManager.notifier.removeListener(onLiveStatusUpdated);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state,
      builder: (context, isInPK, _) {
        if (isInPK) {
          /// old pk
          if (ZegoLiveStreamingPKBattleManager().isInPK) {
            return pkBattleView(
              constraints: widget.constraints,
            );
          }

          /// new pk
          if (ZegoUIKitPrebuiltLiveStreamingPKV2
                      .instance.pkStateNotifier.value ==
                  ZegoLiveStreamingPKBattleStateV2.inPK ||
              ZegoUIKitPrebuiltLiveStreamingPKV2
                      .instance.pkStateNotifier.value ==
                  ZegoLiveStreamingPKBattleStateV2.loading) {
            return pkBattleViewV2(
              constraints: widget.constraints,
            );
          }
        }

        return StreamBuilder<List<ZegoUIKitUser>>(
          stream: ZegoUIKit().getScreenSharingListStream(),
          builder: (context, snapshot) {
            final screenSharingUsers = ZegoUIKit().getScreenSharingList();
            return ValueListenableBuilder<ZegoUIKitUser?>(
              valueListenable: widget.hostManager.notifier,
              builder: (context, host, _) {
                return audioVideoContainer(
                  host,
                  widget.constraints.maxWidth,
                  widget.constraints.maxHeight,
                  screenSharingUsers.isNotEmpty,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget pkBattleView({
    required BoxConstraints constraints,
  }) {
    return Positioned(
      top: widget.config.pkBattleConfig.pKBattleViewTopPadding ?? 164.zR,
      child: ZegoLiveStreamingPKBattleView(
        constraints: constraints,
        config: widget.config,
        foregroundBuilder: widget.config.audioVideoViewConfig.foregroundBuilder,
        backgroundBuilder: widget.config.audioVideoViewConfig.backgroundBuilder,
        avatarConfig: ZegoAvatarConfig(
          showInAudioMode:
              widget.config.audioVideoViewConfig.showAvatarInAudioMode,
          showSoundWavesInAudioMode:
              widget.config.audioVideoViewConfig.showSoundWavesInAudioMode,
          builder: widget.config.avatarBuilder,
        ),
      ),
    );
  }

  Widget pkBattleViewV2({
    required BoxConstraints constraints,
  }) {
    return Positioned(
      top: widget.config.pkBattleV2Config.pKBattleViewTopPadding ?? 164.zR,
      child: ZegoLiveStreamingPKV2View(
        constraints: widget.constraints,
        hostManager: widget.hostManager,
        config: widget.config,
        foregroundBuilder: widget.config.audioVideoViewConfig.foregroundBuilder,
        backgroundBuilder: widget.config.audioVideoViewConfig.backgroundBuilder,
        avatarConfig: ZegoAvatarConfig(
          showInAudioMode:
              widget.config.audioVideoViewConfig.showAvatarInAudioMode,
          showSoundWavesInAudioMode:
              widget.config.audioVideoViewConfig.showSoundWavesInAudioMode,
          builder: widget.config.avatarBuilder,
        ),
      ),
    );
  }

  Widget audioVideoContainer(
    ZegoUIKitUser? host,
    double maxWidth,
    double maxHeight,
    bool withScreenSharing,
  ) {
    return host != null
        ? ValueListenableBuilder<bool>(
            valueListenable: ZegoUIKit()
                .getCameraStateNotifier(widget.hostManager.notifier.value!.id),
            builder: (context, isCameraEnabled, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: ZegoUIKit().getMicrophoneStateNotifier(
                    widget.hostManager.notifier.value!.id),
                builder: (context, isMicrophoneEnabled, _) {
                  if (!isCameraEnabled && !isMicrophoneEnabled) {
                    audioVideoContainerHostHadSorted = false;
                  }

                  return audioVideoWidget(
                    maxWidth,
                    maxHeight,
                    withScreenSharing,
                  );
                },
              );
            },
          )
        : audioVideoWidget(
            maxWidth,
            maxHeight,
            withScreenSharing,
          );
  }

  Widget audioVideoWidget(
    double width,
    double height,
    bool withScreenSharing,
  ) {
    return ValueListenableBuilder(
      valueListenable: widget.liveStatusManager.notifier,
      builder: (context, LiveStatus liveStatusValue, Widget? child) {
        final audioVideoContainerLayout = getAudioVideoContainerLayout(
          withScreenSharing,
        );

        Widget children = Container();

        if (LiveStatus.living == liveStatusValue) {
          children = ZegoAudioVideoContainer(
            layout: audioVideoContainerLayout,
            foregroundBuilder: audioVideoViewForeground,
            backgroundBuilder: audioVideoViewBackground,
            sortAudioVideo: audioVideoViewSorter,
            filterAudioVideo: audioVideoViewFilter,
            avatarConfig: ZegoAvatarConfig(
              showInAudioMode:
                  widget.config.audioVideoViewConfig.showAvatarInAudioMode,
              showSoundWavesInAudioMode:
                  widget.config.audioVideoViewConfig.showSoundWavesInAudioMode,
              builder: widget.config.avatarBuilder,
            ),
            screenSharingViewController:
                widget.controller.screen.screenSharingViewController,
          );
        } else if (LiveStatus.living != liveStatusValue &&
            null != widget.hostManager.notifier.value) {
          /// support local co-host view in host preparing
          return ValueListenableBuilder<bool>(
            valueListenable: ZegoUIKit()
                .getCameraStateNotifier(ZegoUIKit().getLocalUser().id),
            builder: (context, isCameraEnabled, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: ZegoUIKit()
                    .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id),
                builder: (context, isMicrophoneEnabled, _) {
                  if (!isCameraEnabled && !isMicrophoneEnabled) {
                    return Container();
                  }

                  /// local open camera or microphone
                  return ZegoAudioVideoContainer(
                    layout: audioVideoContainerLayout,
                    backgroundBuilder: audioVideoViewBackground,
                    foregroundBuilder: audioVideoViewForeground,
                    sortAudioVideo: audioVideoViewSorter,
                    filterAudioVideo: audioVideoViewFilter,
                    avatarConfig: ZegoAvatarConfig(
                      showInAudioMode: widget
                          .config.audioVideoViewConfig.showAvatarInAudioMode,
                      showSoundWavesInAudioMode: widget.config
                          .audioVideoViewConfig.showSoundWavesInAudioMode,
                      builder: widget.config.avatarBuilder,
                    ),
                    screenSharingViewController:
                        widget.controller.screen.screenSharingViewController,
                  );
                },
              );
            },
          );
        }

        return Positioned(
          top: 0,
          left: 0,
          child: SizedBox(
            width: width,
            height: height,
            child: children,
          ),
        );
      },
    );
  }

  ZegoLayout getAudioVideoContainerLayout(bool withScreenSharing) {
    if (withScreenSharing) {
      if (widget.config.layout != null &&
          widget.config.layout is ZegoLayoutGalleryConfig) {
        return widget.config.layout!;
      } else {
        return ZegoLayout.gallery(
          showNewScreenSharingViewInFullscreenMode: true,
          showScreenSharingFullscreenModeToggleButtonRules:
              ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,
        );
      }
    }

    return widget.config.layout ??
        ZegoLayout.pictureInPicture(
          smallViewPosition: ZegoViewPosition.bottomRight,
          isSmallViewDraggable: false,
          smallViewSize: Size(139.5.zW, 248.0.zH),
          smallViewMargin: EdgeInsets.only(
            left: 24.zR,
            top: 144.zR,
            right: 24.zR,
            bottom: 144.zR,
          ),
          showNewScreenSharingViewInFullscreenMode: true,
          showScreenSharingFullscreenModeToggleButtonRules:
              ZegoShowFullscreenModeToggleButtonRules.showWhenScreenPressed,
        );
  }

  Widget audioVideoViewForeground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    if (extraInfo[ZegoViewBuilderMapExtraInfoKey.isScreenSharingView.name]
            as bool? ??
        false) {
      /// live streaming not need microphone/camera/user name foreground
      return widget.config.audioVideoViewConfig.foregroundBuilder
              ?.call(context, size, user, extraInfo) ??
          Container(color: Colors.transparent);
    }

    return Stack(
      children: [
        widget.config.audioVideoViewConfig.foregroundBuilder
                ?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
        ValueListenableBuilder<bool>(
            valueListenable:
                ZegoUIKit().getMicrophoneStateNotifier(user?.id ?? ''),
            builder: (context, isMicrophoneEnabled, _) {
              return ZegoAudioVideoForeground(
                size: size,
                user: user,
                hostManager: widget.hostManager,
                connectManager: ZegoLiveStreamingManagers().connectManager!,
                popUpManager: widget.popUpManager,
                prebuiltController: widget.controller,
                translationText: widget.config.innerText,
                isPluginEnabled: widget.plugins?.isEnabled ?? false,
                //  only show if close
                showMicrophoneStateOnView: !isMicrophoneEnabled,
                showCameraStateOnView: false,
                showUserNameOnView:
                    widget.config.audioVideoViewConfig.showUserNameOnView,
              );
            }),
      ],
    );
  }

  Widget audioVideoViewBackground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallView = (screenSize.width - size.width).abs() > 1;
    return Stack(
      children: [
        Container(
            color: isSmallView
                ? const Color(0xff333437)
                : const Color(0xff4A4B4D)),
        widget.config.audioVideoViewConfig.backgroundBuilder?.call(
              context,
              size,
              user,
              extraInfo,
            ) ??
            Container(color: Colors.transparent),
      ],
    );
  }

  List<ZegoUIKitUser> audioVideoViewSorter(List<ZegoUIKitUser> users) {
    if (audioVideoContainerHostHadSorted) {
      return users;
    }

    if (isLivingWithHost &&
        (ZegoUIKit()
                .getCameraStateNotifier(
                    widget.hostManager.notifier.value?.id ?? '')
                .value ||
            ZegoUIKit()
                .getMicrophoneStateNotifier(
                    widget.hostManager.notifier.value?.id ?? '')
                .value)) {
      /// put host on first position
      users
        ..removeWhere(
            (user) => user.id == widget.hostManager.notifier.value!.id)
        ..insert(0, widget.hostManager.notifier.value!);

      /// not sort before next host changed
      audioVideoContainerHostHadSorted = true;
    }

    return users;
  }

  List<ZegoUIKitUser> audioVideoViewFilter(List<ZegoUIKitUser> users) {
    users.removeWhere((targetUser) {
      if (null != widget.config.audioVideoViewConfig.visible) {
        var targetUserRole = ZegoLiveStreamingRole.coHost;
        if (ZegoLiveStreamingManagers().hostManager?.isHost(targetUser) ??
            false) {
          targetUserRole = ZegoLiveStreamingRole.host;
        }
        if (!widget.config.audioVideoViewConfig.visible!.call(
          ZegoUIKit().getLocalUser(),
          ZegoLiveStreamingManagers().connectManager?.localRole ??
              ZegoLiveStreamingRole.audience,
          targetUser,
          targetUserRole,
        )) {
          /// only hide if invisible
          return true;
        }
      }

      return !targetUser.camera.value &&
          (!targetUser.microphone.value &&

              /// if mic is in mute mode, same as open state
              !targetUser.microphoneMuteMode.value);
    });

    return users;
  }

  void onLiveStatusUpdated() {
    ZegoLoggerService.logInfo(
      'live page, live status mgr updated, ${widget.liveStatusManager.notifier.value}',
      tag: 'live streaming',
      subTag: 'central audio video view',
    );

    if (LiveStatus.ended == widget.liveStatusManager.notifier.value) {
      /// host changed
      audioVideoContainerHostHadSorted = false;
    }
  }
}
