// Dart imports:
import 'dart:core';
import 'dart:math' as math; // import this

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/beauty_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

/// @nodoc
/// user should be login before page enter
class ZegoPreviewPage extends StatefulWidget {
  const ZegoPreviewPage({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.liveStreamingConfig,
    required this.hostManager,
    required this.startedNotifier,
    required this.liveStreamingPageReady,
    required this.config,
    required this.popUpManager,
    required this.kickOutNotifier,
  }) : super(key: key);

  final int appID;
  final String appSign;

  final String userID;
  final String userName;

  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig liveStreamingConfig;

  final ZegoLiveHostManager hostManager;
  final ValueNotifier<bool> startedNotifier;

  final ValueNotifier<bool> liveStreamingPageReady;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoPopUpManager popUpManager;
  final ValueNotifier<bool> kickOutNotifier;

  @override
  State<ZegoPreviewPage> createState() => _ZegoPreviewPageState();
}

/// @nodoc
class _ZegoPreviewPageState extends State<ZegoPreviewPage> {
  @override
  void initState() {
    super.initState();

    if (widget.config.turnOnCameraWhenJoining) {
      ZegoUIKit().turnCameraOn(widget.hostManager.isLocalHost);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ZegoScreenUtilInit(
        designSize: const Size(750, 1334),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  background(constraints.maxHeight),
                  ZegoAudioVideoContainer(
                    layout: ZegoLayout.pictureInPicture(
                      smallViewPosition: ZegoViewPosition.bottomRight,
                      smallViewSize: Size(139.5.zW, 248.0.zH),
                      smallViewMargin: EdgeInsets.only(
                        left: 24.zR,
                        top: 144.zR,
                        right: 24.zR,
                        bottom: 144.zR,
                      ),
                    ),
                    foregroundBuilder: audioVideoViewForeground,
                    backgroundBuilder: audioVideoViewBackground,
                    avatarConfig: ZegoAvatarConfig(
                      showInAudioMode: widget.liveStreamingConfig
                          .audioVideoViewConfig.showAvatarInAudioMode,
                      showSoundWavesInAudioMode: widget.liveStreamingConfig
                          .audioVideoViewConfig.showSoundWavesInAudioMode,
                      builder: widget.liveStreamingConfig.avatarBuilder,
                    ),
                  ),
                  topBar(),
                  bottomBar(),
                  foreground(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget foreground(double width, double height) {
    return widget.config.foreground ?? Container();
  }

  Widget background(double height) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        width: 750.zW,
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

  Widget topBar() {
    final buttonSize = Size(88.zR, 88.zR);
    final iconSize = Size(56.zR, 56.zR);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: 0.zR,
          top: 0,
          right: 10.zR,
          bottom: 0.zR,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ZegoTextIconButton(
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: widget.liveStreamingConfig.rootNavigator,
                ).pop();
              },
              icon: ButtonIcon(
                icon: widget.config.previewConfig.pageBackIcon ??
                    (isRTL(context)
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: PrebuiltLiveStreamingImage.asset(
                              PrebuiltLiveStreamingIconUrls.pageBack,
                            ),
                          )
                        : PrebuiltLiveStreamingImage.asset(
                            PrebuiltLiveStreamingIconUrls.pageBack,
                          )),
              ),
              iconSize: iconSize,
              buttonSize: buttonSize,
            ),
            const Expanded(child: SizedBox()),
            ZegoSwitchCameraButton(
              buttonSize: buttonSize,
              iconSize: iconSize,
              icon: ButtonIcon(
                icon: widget.config.previewConfig.switchCameraIcon ??
                    PrebuiltLiveStreamingImage.asset(
                        PrebuiltLiveStreamingIconUrls.previewFlipCamera),
                backgroundColor: Colors.transparent,
              ),
              defaultUseFrontFacingCamera: ZegoUIKit()
                  .getUseFrontFacingCameraStateNotifier(
                      ZegoUIKit().getLocalUser().id)
                  .value,
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    final buttonSize = Size(88.zR, 88.zR);
    final iconSize = Size(56.zR, 56.zR);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: 89.zR,
          top: 0,
          right: 89.zR,
          bottom: 97.zR,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZegoBeautyEffectButton(
              translationText: widget.liveStreamingConfig.innerText,
              rootNavigator: widget.liveStreamingConfig.rootNavigator,
              effectConfig: widget.liveStreamingConfig.effectConfig,
              buttonSize: buttonSize,
              iconSize: iconSize,
              icon: widget.config.previewConfig.beautyEffectIcon != null
                  ? ButtonIcon(
                      icon: widget.config.previewConfig.beautyEffectIcon,
                    )
                  : null,
            ),
            SizedBox(width: 48.zR),
            startButton(),
            SizedBox(width: 48.zR),
            SizedBox(width: 88.zR, height: 88.zR),
          ],
        ),
      ),
    );
  }

  Widget startButton() {
    final permissions = <Permission>[];
    if (widget.config.turnOnCameraWhenJoining) {
      permissions.add(Permission.camera);
    }
    if (widget.config.turnOnMicrophoneWhenJoining) {
      permissions.add(Permission.microphone);
    }

    return widget.liveStreamingConfig.startLiveButtonBuilder?.call(context,
            () async {
          checkPermissions(
            context: context,
            permissions: permissions,
            isShowDialog: true,
            translationText: widget.liveStreamingConfig.innerText,
            rootNavigator: widget.liveStreamingConfig.rootNavigator,
            popUpManager: widget.popUpManager,
            kickOutNotifier: widget.kickOutNotifier,
          ).then(
            (value) {
              if (!widget.liveStreamingPageReady.value) {
                ZegoLoggerService.logInfo(
                  'live streaming page is waiting room login',
                  tag: 'live streaming',
                  subTag: 'preview page',
                );
                return;
              }

              widget.startedNotifier.value = true;
            },
          );
        }) ??
        GestureDetector(
          onTap: () async {
            checkPermissions(
              context: context,
              permissions: permissions,
              isShowDialog: true,
              translationText: widget.liveStreamingConfig.innerText,
              rootNavigator: widget.liveStreamingConfig.rootNavigator,
              popUpManager: widget.popUpManager,
              kickOutNotifier: widget.kickOutNotifier,
            ).then((value) {
              if (!widget.liveStreamingPageReady.value) {
                ZegoLoggerService.logInfo(
                  'live streaming page is waiting room login',
                  tag: 'live streaming',
                  subTag: 'preview page',
                );
                return;
              }

              widget.startedNotifier.value = true;
            });
          },
          child: Container(
            width: 300.zR,
            height: 88.zR,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44.zR),
                gradient: const LinearGradient(
                  colors: [Color(0xffA754FF), Color(0xff510DF1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.liveStreamingConfig.innerText.startLiveStreamingButton,
                style: TextStyle(
                  fontSize: 32.zR,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
  }

  Widget audioVideoViewForeground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    return Stack(
      children: [
        widget.liveStreamingConfig.audioVideoViewConfig.foregroundBuilder?.call(
              context,
              size,
              user,
              extraInfo,
            ) ??
            Container(color: Colors.transparent),
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
        widget.liveStreamingConfig.audioVideoViewConfig.backgroundBuilder?.call(
              context,
              size,
              user,
              extraInfo,
            ) ??
            Container(color: Colors.transparent),
      ],
    );
  }
}
