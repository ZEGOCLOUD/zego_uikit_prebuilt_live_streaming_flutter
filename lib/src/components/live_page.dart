// Dart imports:
import 'dart:async';
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'audio_video_view_foreground.dart';
import 'bottom_bar.dart';
import 'defines.dart';
import 'message/in_room_live_commenting_view.dart';
import 'top_bar.dart';

/// user and sdk should be login and init before page enter
class ZegoLivePage extends StatefulWidget {
  const ZegoLivePage({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    required this.hostManager,
    required this.liveStatusManager,
    this.plugins,
    this.tokenServerUrl = '',
  }) : super(key: key);

  final int appID;
  final String appSign;
  final String tokenServerUrl;

  final String userID;
  final String userName;

  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoLiveHostManager hostManager;
  final ZegoLiveStatusManager liveStatusManager;
  final ZegoPrebuiltPlugins? plugins;

  @override
  State<ZegoLivePage> createState() => ZegoLivePageState();
}

class ZegoLivePageState extends State<ZegoLivePage>
    with SingleTickerProviderStateMixin {
  /// had sort the host be first
  bool audioVideoContainerHostHadSorted = false;
  List<StreamSubscription<dynamic>?> subscriptions = [];

  late final ZegoLiveConnectManager connectManager;

  bool get isLiving =>
      LiveStatus.living == widget.liveStatusManager.notifier.value;

  bool get isLivingWithHost =>
      LiveStatus.living == widget.liveStatusManager.notifier.value &&
      widget.hostManager.notifier.value != null;

  @override
  void initState() {
    super.initState();

    connectManager = ZegoLiveConnectManager(
      config: widget.config,
      hostManager: widget.hostManager,
      liveStatusNotifier: widget.liveStatusManager.notifier,
      translationText: widget.config.translationText,
      contextQuery: () {
        return context;
      },
    );

    widget.hostManager.setConnectManger(connectManager);
    widget.liveStatusManager.setConnectManger(connectManager);

    widget.hostManager.notifier.addListener(onHostManagerUpdated);
    widget.liveStatusManager.notifier.addListener(onLiveStatusUpdated);

    subscriptions
      ..add(ZegoUIKit()
          .getTurnOnYourCameraRequestStream()
          .listen(onTurnOnYourCameraRequest))
      ..add(ZegoUIKit()
          .getTurnOnYourMicrophoneRequestStream()
          .listen(onTurnOnYourMicrophoneRequest));

    connectManager.init();
    if (widget.hostManager.isHost) {
      ZegoUIKit().setRoomProperty(
          RoomPropertyKey.liveStatus.text, LiveStatus.living.index.toString());
    }
    correctConfigValue();
  }

  @override
  void dispose() async {
    super.dispose();

    widget.liveStatusManager.notifier.removeListener(onLiveStatusUpdated);

    for (var subscription in subscriptions) {
      subscription?.cancel();
    }

    connectManager.uninit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () async {
          return await widget.config.onLeaveConfirmation!(context);
        },
        child: ScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return clickListener(
              child: LayoutBuilder(builder: (context, constraints) {
                return ValueListenableBuilder<ZegoUIKitUser?>(
                    valueListenable: widget.hostManager.notifier,
                    builder: (context, host, _) {
                      return ValueListenableBuilder<LiveStatus>(
                          valueListenable: widget.liveStatusManager.notifier,
                          builder: (context, liveStatus, _) {
                            return Stack(
                              children: [
                                background(constraints.maxHeight),
                                backgroundTips(),
                                StreamBuilder<List<ZegoUIKitUser>>(
                                  stream:
                                      ZegoUIKit().getScreenSharingListStream(),
                                  builder: (context, snapshot) {
                                    var screenSharingUsers =
                                        snapshot.data ?? [];
                                    return audioVideoContainer(
                                      host,
                                      constraints.maxHeight,
                                      screenSharingUsers.isNotEmpty,
                                    );
                                  },
                                ),
                                topBar(),
                                bottomBar(),
                                messageList(),
                              ],
                            );
                          });
                    });
              }),
            );
          },
        ),
      ),
    );
  }

  void correctConfigValue() {
    if (widget.config.bottomMenuBarConfig.maxCount > 5) {
      widget.config.bottomMenuBarConfig.maxCount = 5;
      ZegoLoggerService.logInfo(
        'menu bar buttons limited count\'s value  is exceeding the maximum limit',
        tag: "live streaming",
        subTag: "live page",
      );
    }
  }

  Widget clickListener({required Widget child}) {
    return GestureDetector(
      onTap: () {
        /// listen only click event in empty space
      },
      child: Listener(
        ///  listen for all click events in current view, include the click
        ///  receivers(such as button...), but only listen
        onPointerDown: (e) {},
        child: AbsorbPointer(
          absorbing: false,
          child: child,
        ),
      ),
    );
  }

  Widget backgroundTips() {
    return isLiving
        ? Container()
        : Center(
            child: Text(
              widget.config.translationText.noHostOnline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.r,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          );
  }

  Widget background(double height) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        width: 750.w,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: PrebuiltLiveStreamingImage.assetImage(
                PrebuiltLiveStreamingIconUrls.background),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget audioVideoContainer(
    ZegoUIKitUser? host,
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
                    return audioVideoWidget(maxHeight, withScreenSharing);
                  });
            })
        : audioVideoWidget(maxHeight, withScreenSharing);
  }

  Widget audioVideoWidget(
    double height,
    bool withScreenSharing,
  ) {
    var audioVideoContainerLayout = withScreenSharing
        ? ZegoLayout.gallery()
        : ZegoLayout.pictureInPicture(
            smallViewPosition: ZegoViewPosition.bottomRight,
            isSmallViewDraggable: false,
            smallViewSize: Size(139.5.w, 248.0.h),
            smallViewMargin: EdgeInsets.only(
              left: 24.r,
              top: 144.r,
              right: 24.r,
              bottom: 144.r,
            ),
          );

    Widget children = Container();

    if (isLiving) {
      children = ZegoAudioVideoContainer(
        layout: audioVideoContainerLayout,
        foregroundBuilder: audioVideoViewForeground,
        backgroundBuilder: audioVideoViewBackground,
        sortAudioVideo: audioVideoViewSorter,
        avatarConfig: ZegoAvatarConfig(
          showInAudioMode:
              widget.config.audioVideoViewConfig.showAvatarInAudioMode,
          showSoundWavesInAudioMode:
              widget.config.audioVideoViewConfig.showSoundWavesInAudioMode,
          builder: widget.config.avatarBuilder,
        ),
      );
    } else if (LiveStatus.living != widget.liveStatusManager.notifier.value &&
        null != widget.hostManager.notifier.value) {
      /// support local co-host view in host preparing
      return ValueListenableBuilder<bool>(
          valueListenable:
              ZegoUIKit().getCameraStateNotifier(ZegoUIKit().getLocalUser().id),
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
                    avatarConfig: ZegoAvatarConfig(
                      showInAudioMode: widget
                          .config.audioVideoViewConfig.showAvatarInAudioMode,
                      showSoundWavesInAudioMode: widget.config
                          .audioVideoViewConfig.showSoundWavesInAudioMode,
                      builder: widget.config.avatarBuilder,
                    ),
                  );
                });
          });
    }

    return Positioned(
      top: 0,
      left: 0,
      child: SizedBox(
        width: 750.w,
        height: height,
        child: children,
      ),
    );
  }

  List<ZegoUIKitUser> audioVideoViewSorter(List<ZegoUIKitUser> users) {
    if (audioVideoContainerHostHadSorted) {
      return users;
    }

    if (isLivingWithHost &&
        (ZegoUIKit()
                .getCameraStateNotifier(
                    widget.hostManager.notifier.value?.id ?? "")
                .value ||
            ZegoUIKit()
                .getMicrophoneStateNotifier(
                    widget.hostManager.notifier.value?.id ?? "")
                .value)) {
      /// put host on first position
      users.removeWhere(
          (user) => user.id == widget.hostManager.notifier.value!.id);
      users.insert(0, widget.hostManager.notifier.value!);

      /// not sort before next host changed
      audioVideoContainerHostHadSorted = true;
    }

    return users;
  }

  Widget audioVideoViewForeground(
      BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
    if (extraInfo[ZegoViewBuilderMapExtraInfoKey.isScreenSharingView.name]
            as bool? ??
        false) {
      return Container();
    }

    return Stack(
      children: [
        widget.config.audioVideoViewConfig.foregroundBuilder
                ?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
        ValueListenableBuilder<bool>(
            valueListenable:
                ZegoUIKit().getMicrophoneStateNotifier(user?.id ?? ""),
            builder: (context, isMicrophoneEnabled, _) {
              return ZegoAudioVideoForeground(
                size: size,
                user: user,
                hostManager: widget.hostManager,
                connectManager: connectManager,
                translationText: widget.config.translationText,
                isPluginEnabled: widget.plugins?.isEnabled ?? false,
                //  only show if close
                showMicrophoneStateOnView: !isMicrophoneEnabled,
                showCameraStateOnView: false,
                showUserNameOnView: true,
              );
            }),
      ],
    );
  }

  Widget audioVideoViewBackground(
      BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
    var screenSize = MediaQuery.of(context).size;
    var isSmallView = (screenSize.width - size.width).abs() > 1;
    return Stack(
      children: [
        Container(
            color: isSmallView
                ? const Color(0xff333437)
                : const Color(0xff4A4B4D)),
        widget.config.audioVideoViewConfig.backgroundBuilder
                ?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
      ],
    );
  }

  Widget topBar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 64.r,
      child: ZegoTopBar(
        config: widget.config,
        isPluginEnabled: widget.plugins?.isEnabled ?? false,
        hostManager: widget.hostManager,
        hostUpdateEnabledNotifier: widget.hostManager.hostUpdateEnabledNotifier,
        connectManager: connectManager,
        translationText: widget.config.translationText,
      ),
    );
  }

  Widget bottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ZegoBottomBar(
        buttonSize: zegoLiveButtonSize,
        config: widget.config,
        hostManager: widget.hostManager,
        hostUpdateEnabledNotifier: widget.hostManager.hostUpdateEnabledNotifier,
        liveStatusNotifier: widget.liveStatusManager.notifier,
        connectManager: connectManager,
        translationText: widget.config.translationText,
      ),
    );
  }

  Widget messageList() {
    return Positioned(
      left: 32.r,
      bottom: 124.r,
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(540.r, 400.r)),
        child: ZegoInRoomLiveCommentingView(
          itemBuilder: widget.config.inRoomMessageViewConfig.itemBuilder,
        ),
      ),
    );
  }

  void onHostManagerUpdated() {
    ZegoLoggerService.logInfo(
      "live page, host mgr updated, ${widget.hostManager.notifier.value}",
      tag: "live streaming",
      subTag: "live page",
    );
  }

  void onLiveStatusUpdated() {
    ZegoLoggerService.logInfo(
      "live page, live status mgr updated, ${widget.liveStatusManager.notifier.value}",
      tag: "live streaming",
      subTag: "live page",
    );

    if (LiveStatus.ended == widget.liveStatusManager.notifier.value) {
      /// host changed
      audioVideoContainerHostHadSorted = false;
    }

    if (!widget.hostManager.isHost) {
      ZegoLoggerService.logInfo(
        "audience, live streaming end by host, "
        "host: ${widget.hostManager.notifier.value}, "
        "live status: ${widget.liveStatusManager.notifier.value}",
        tag: "live streaming",
        subTag: "live page",
      );

      if (widget.hostManager.notifier.value != null &&
          LiveStatus.ended == widget.liveStatusManager.notifier.value) {
        if (widget.config.onLiveStreamingEnded != null) {
          widget.config.onLiveStreamingEnded!.call();
        }
      }
    }
  }

  void onTurnOnYourCameraRequest(String fromUserID) async {
    ZegoLoggerService.logInfo(
      "onTurnOnYourCameraRequest, fromUserID:$fromUserID",
      tag: "live streaming",
      subTag: "live page",
    );

    var canCameraTurnOnByOthers =
        await widget.config.onCameraTurnOnByOthersConfirmation?.call(context) ??
            false;
    ZegoLoggerService.logInfo(
      "canMicrophoneTurnOnByOthers:$canCameraTurnOnByOthers",
      tag: "live streaming",
      subTag: "live page",
    );
    if (canCameraTurnOnByOthers) {
      ZegoUIKit().turnCameraOn(true);
    }
  }

  void onTurnOnYourMicrophoneRequest(String fromUserID) async {
    ZegoLoggerService.logInfo(
      "onTurnOnYourMicrophoneRequest, fromUserID:$fromUserID",
      tag: "live streaming",
      subTag: "live page",
    );

    var canMicrophoneTurnOnByOthers = await widget
            .config.onMicrophoneTurnOnByOthersConfirmation
            ?.call(context) ??
        false;
    ZegoLoggerService.logInfo(
      "canMicrophoneTurnOnByOthers:$canMicrophoneTurnOnByOthers",
      tag: "live streaming",
      subTag: "live page",
    );
    if (canMicrophoneTurnOnByOthers) {
      ZegoUIKit().turnMicrophoneOn(true);
    }
  }
}
