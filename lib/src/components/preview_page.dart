// Dart imports:
import 'dart:core';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/beauty_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart'; // import this

/// @nodoc
/// user should be login before page enter
class ZegoLiveStreamingPreviewPage extends StatefulWidget {
  const ZegoLiveStreamingPreviewPage({
    super.key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    required this.popUpManager,
  });

  final int appID;
  final String appSign;

  final String userID;
  final String userName;

  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoLiveStreamingPopUpManager popUpManager;

  @override
  State<ZegoLiveStreamingPreviewPage> createState() =>
      _ZegoLiveStreamingPreviewPageState();
}

/// @nodoc
class _ZegoLiveStreamingPreviewPageState
    extends State<ZegoLiveStreamingPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ZegoScreenUtilInit(
        designSize: const Size(750, 1334),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final page = LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  background(constraints.maxHeight),
                  ZegoAudioVideoView(
                    roomID: widget.liveID,
                    user: ZegoUIKit().getLocalUser(),
                    foregroundBuilder: audioVideoViewForeground,
                    backgroundBuilder: audioVideoViewBackground,
                    avatarConfig: ZegoAvatarConfig(
                      showInAudioMode:
                          widget.config.audioVideoView.showAvatarInAudioMode,
                      showSoundWavesInAudioMode: widget
                          .config.audioVideoView.showSoundWavesInAudioMode,
                      builder: widget.config.avatarBuilder,
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

          return widget.config.turnOnCameraWhenJoining
              ? FutureBuilder<List<bool>>(
                  future: Future.wait([
                    requestPermission(Permission.camera),
                    ZegoUIKit().turnCameraOn(
                      targetRoomID: widget.liveID,
                      ZegoLiveStreamingPageLifeCycle()
                          .currentManagers
                          .hostManager
                          .isLocalHost,
                    ),
                  ]),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      return page;
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                )
              : page;
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
            image: ZegoLiveStreamingImage.assetImage(
                ZegoLiveStreamingIconUrls.background),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget topBar() {
    if (!widget.config.preview.topBar.isVisible) {
      return Container();
    }

    final buttonSize = Size(88.zR, 88.zR);
    final iconSize = Size(56.zR, 56.zR);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: 10.zR,
          top: 10,
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
                  rootNavigator: widget.config.rootNavigator,
                ).pop();
              },
              icon: ButtonIcon(
                icon: widget.config.preview.pageBackIcon ??
                    (isRTL(context)
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: ZegoLiveStreamingImage.asset(
                              ZegoLiveStreamingIconUrls.pageBack,
                            ),
                          )
                        : ZegoLiveStreamingImage.asset(
                            ZegoLiveStreamingIconUrls.pageBack,
                          )),
              ),
              iconSize: iconSize,
              buttonSize: buttonSize,
              clickableBackgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
            const Expanded(child: SizedBox()),
            ZegoSwitchCameraButton(
              roomID: widget.liveID,
              buttonSize: buttonSize,
              iconSize: iconSize,
              icon: ButtonIcon(
                icon: widget.config.preview.switchCameraIcon ??
                    ZegoLiveStreamingImage.asset(
                        ZegoLiveStreamingIconUrls.previewFlipCamera),
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
              defaultUseFrontFacingCamera: ZegoUIKit()
                  .getUseFrontFacingCameraStateNotifier(
                    targetRoomID: widget.liveID,
                    ZegoUIKit().getLocalUser().id,
                  )
                  .value,
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    if (!widget.config.preview.bottomBar.isVisible) {
      return Container();
    }

    final buttonSize = Size(88.zR, 88.zR);
    final iconSize = Size(56.zR, 56.zR);

    final beautyButtonPlaceHolder =
        SizedBox(width: buttonSize.width, height: buttonSize.height);

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
            widget.config.preview.bottomBar.showBeautyEffectButton
                ? ZegoLiveStreamingBeautyEffectButton(
                    translationText: widget.config.innerText,
                    rootNavigator: widget.config.rootNavigator,
                    effectConfig: widget.config.effect,
                    buttonSize: buttonSize,
                    iconSize: iconSize,
                    icon: widget.config.preview.beautyEffectIcon != null
                        ? ButtonIcon(
                            icon: widget.config.preview.beautyEffectIcon,
                          )
                        : null,
                  )
                : beautyButtonPlaceHolder,
            SizedBox(width: 48.zR),
            startButton(),
            SizedBox(width: 48.zR),
            beautyButtonPlaceHolder,
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

    defaultAction() async {
      await checkPermissions(
        context: context,
        permissions: permissions,
        isShowDialog: true,
        translationText: widget.config.innerText,
        rootNavigator: widget.config.rootNavigator,
        popUpManager: widget.popUpManager,
        kickOutNotifier:
            ZegoLiveStreamingPageLifeCycle().currentManagers.kickOutNotifier,
      ).then(
        (value) {
          ZegoLoggerService.logInfo(
            'started',
            tag: 'live.streaming.preview-page',
            subTag: 'preview page',
          );

          ZegoLiveStreamingPageLifeCycle().updatePreviewPageVisibility(false);
        },
      );
    }

    return widget.config.preview.startLiveButtonBuilder?.call(context,
            () async {
          defaultAction.call();
        }) ??
        GestureDetector(
          onTap: defaultAction,
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
                widget.config.innerText.startLiveStreamingButton,
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
        widget.config.audioVideoView.foregroundBuilder?.call(
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
        widget.config.audioVideoView.backgroundBuilder?.call(
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
