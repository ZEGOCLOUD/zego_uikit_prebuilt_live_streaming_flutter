// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'defines.dart';
import 'effects/beauty_effect_button.dart';
import 'effects/sound_effect_button.dart';
import 'message/in_room_message_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

class ZegoBottomBar extends StatefulWidget {
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final Size buttonSize;

  const ZegoBottomBar({
    Key? key,
    required this.config,
    required this.buttonSize,
  }) : super(key: key);

  @override
  State<ZegoBottomBar> createState() => _ZegoBottomBarState();
}

class _ZegoBottomBarState extends State<ZegoBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      height: 124.r,
      child: Stack(
        children: [
          widget.config.showInRoomMessageButton
              ? SizedBox(
                  height: 124.r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      zegoLiveButtonPadding,
                      const ZegoInRoomMessageButton(),
                    ],
                  ),
                )
              : const SizedBox(),
          rightToolbar(context),
        ],
      ),
    );
  }

  Widget rightToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 120.0.r),
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ...getDisplayButtons(context),
                zegoLiveButtonPadding,
                zegoLiveButtonPadding,
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getDisplayButtons(BuildContext context) {
    List<Widget> buttonList = [
      ...getDefaultButtons(context),
      ...widget.config.bottomMenuBarConfig.extendButtons
    ];

    List<Widget> displayButtonList = [];
    if (buttonList.length > widget.config.bottomMenuBarConfig.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList =
          buttonList.sublist(0, widget.config.bottomMenuBarConfig.maxCount - 1);

      buttonList.removeRange(0, widget.config.bottomMenuBarConfig.maxCount - 1);
      displayButtonList.add(
        buttonWrapper(
          child: ZegoMoreButton(menuButtonList: buttonList),
        ),
      );
    } else {
      displayButtonList = buttonList;
    }

    List<Widget> displayButtonsWithSpacing = [];
    for (var button in displayButtonList) {
      displayButtonsWithSpacing.add(button);
      displayButtonsWithSpacing.add(zegoLiveButtonPadding);
    }

    return displayButtonsWithSpacing;
  }

  Widget buttonWrapper({required Widget child}) {
    return SizedBox(
      width: widget.buttonSize.width,
      height: widget.buttonSize.height,
      child: child,
    );
  }

  List<Widget> getDefaultButtons(BuildContext context) {
    if (widget.config.bottomMenuBarConfig.buttons.isEmpty) {
      return [];
    }

    return widget.config.bottomMenuBarConfig.buttons
        .map((type) => buttonWrapper(
              child: generateDefaultButtonsByEnum(context, type),
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
      BuildContext context, ZegoLiveMenuBarButtonName type) {
    var buttonSize = Size(96.r, 96.r);
    var iconSize = Size(56.r, 56.r);
    switch (type) {
      case ZegoLiveMenuBarButtonName.toggleMicrophoneButton:
        return ZegoToggleMicrophoneButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          normalIcon: ButtonIcon(
            icon: PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.toolbarMicNormal),
            backgroundColor: Colors.transparent,
          ),
          offIcon: ButtonIcon(
            icon: PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.toolbarMicOff),
            backgroundColor: Colors.transparent,
          ),
          defaultOn: widget.config.turnOnMicrophoneWhenJoining,
        );
      case ZegoLiveMenuBarButtonName.switchAudioOutputButton:
        return ZegoSwitchAudioOutputButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultUseSpeaker: widget.config.useSpeakerWhenJoining,
        );
      case ZegoLiveMenuBarButtonName.toggleCameraButton:
        return ZegoToggleCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          normalIcon: ButtonIcon(
            icon: PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.toolbarCameraNormal),
            backgroundColor: Colors.transparent,
          ),
          offIcon: ButtonIcon(
            icon: PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.toolbarCameraOff),
            backgroundColor: Colors.transparent,
          ),
          defaultOn: widget.config.turnOnCameraWhenJoining,
        );
      case ZegoLiveMenuBarButtonName.switchCameraButton:
        return ZegoSwitchCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.toolbarFlipCamera),
            backgroundColor: Colors.transparent,
          ),
        );
      case ZegoLiveMenuBarButtonName.leaveButton:
        return ZegoLeaveButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: const Icon(Icons.close, color: Colors.white),
            backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
          ),
          onLeaveConfirmation: (context) async {
            return await widget
                .config.onLeaveLiveStreamingConfirmation!(context);
          },
          onPress: () async {
            if (widget.config.onLeaveLiveStreaming != null) {
              widget.config.onLeaveLiveStreaming!.call();
            } else {
              Navigator.of(context).pop();
            }
          },
        );
      case ZegoLiveMenuBarButtonName.beautyEffectButton:
        return ZegoBeautyEffectButton(
          beautyEffects: widget.config.effectConfig.beautyEffects,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
      case ZegoLiveMenuBarButtonName.soundEffectButton:
        return ZegoSoundEffectButton(
          voiceChangeEffect: widget.config.effectConfig.voiceChangeEffect,
          reverbEffect: widget.config.effectConfig.reverbEffect,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
    }
  }
}
