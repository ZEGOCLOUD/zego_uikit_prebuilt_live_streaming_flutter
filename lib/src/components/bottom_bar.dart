// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/co_host_control_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_translation.dart';
import 'defines.dart';
import 'effects/beauty_effect_button.dart';
import 'effects/sound_effect_button.dart';
import 'leave_button.dart';
import 'message/disable_chat_button.dart';
import 'message/in_room_message_button.dart';

class ZegoBottomBar extends StatefulWidget {
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final Size buttonSize;

  final ZegoLiveHostManager hostManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;

  final ValueNotifier<LiveStatus> liveStatusNotifier;
  final ZegoLiveConnectManager connectManager;
  final ZegoTranslationText translationText;

  const ZegoBottomBar({
    Key? key,
    required this.config,
    required this.buttonSize,
    required this.hostManager,
    required this.hostUpdateEnabledNotifier,
    required this.liveStatusNotifier,
    required this.connectManager,
    required this.translationText,
  }) : super(key: key);

  @override
  State<ZegoBottomBar> createState() => _ZegoBottomBarState();
}

class _ZegoBottomBarState extends State<ZegoBottomBar> {
  List<ZegoMenuBarButtonName> buttons = [];
  List<Widget> extendButtons = [];

  @override
  void initState() {
    super.initState();

    updateButtonsByRole();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      height: 124.r,
      child: Stack(
        children: [
          widget.config.bottomMenuBarConfig.showInRoomMessageButton
              ? SizedBox(
                  height: 124.r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      zegoLiveButtonPadding,
                      ZegoInRoomMessageButton(hostManager: widget.hostManager),
                    ],
                  ),
                )
              : const SizedBox(),
          widget.hostManager.isHost
              ? rightToolbar(context)
              : ValueListenableBuilder(
                  valueListenable:
                      widget.connectManager.audienceLocalConnectStateNotifier,
                  builder: (context, connectState, _) {
                    if (widget.config.plugins.isEmpty) {
                      return rightToolbar(context);
                    }

                    if (ConnectState.connecting == connectState) {
                      return rightToolbar(context);
                    }

                    updateButtonsByRole();

                    return rightToolbar(context);
                  },
                ),
        ],
      ),
    );
  }

  void updateButtonsByRole() {
    if (widget.hostManager.isHost) {
      buttons = widget.config.bottomMenuBarConfig.hostButtons;
      extendButtons = widget.config.bottomMenuBarConfig.hostExtendButtons;
    } else {
      var connectState =
          widget.connectManager.audienceLocalConnectStateNotifier.value;
      var isCoHost = ConnectState.connected == connectState;

      buttons = isCoHost
          ? widget.config.bottomMenuBarConfig.coHostButtons
          : widget.config.bottomMenuBarConfig.audienceButtons;
      extendButtons = isCoHost
          ? widget.config.bottomMenuBarConfig.coHostExtendButtons
          : widget.config.bottomMenuBarConfig.audienceExtendButtons;
    }
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
    List<Widget> buttonList = [...getDefaultButtons(context), ...extendButtons];

    List<Widget> displayButtonList = [];
    if (buttonList.length > widget.config.bottomMenuBarConfig.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList =
          buttonList.sublist(0, widget.config.bottomMenuBarConfig.maxCount - 1);

      displayButtonList.add(
        buttonWrapper(
          child: ZegoMoreButton(
              menuButtonListFunc: () {
                List<Widget> buttonList = [
                  ...getDefaultButtons(context, cameraDefaultValueFunc: () {
                    return ZegoUIKit()
                        .getCameraStateNotifier(ZegoUIKit().getLocalUser().id)
                        .value;
                  }, microphoneDefaultValueFunc: () {
                    return ZegoUIKit()
                        .getMicrophoneStateNotifier(
                            ZegoUIKit().getLocalUser().id)
                        .value;
                  }),
                  ...extendButtons
                ];
                buttonList.removeRange(
                    0, widget.config.bottomMenuBarConfig.maxCount - 1);

                return buttonList;
              },
              icon: ButtonIcon(
                icon: PrebuiltLiveStreamingImage.asset(
                    PrebuiltLiveStreamingIconUrls.bottomBarMore),
                backgroundColor: Colors.transparent,
              )),
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

  Widget buttonWrapper({required Widget child, ZegoMenuBarButtonName? type}) {
    var buttonSize = widget.buttonSize;
    switch (type) {
      case ZegoMenuBarButtonName.coHostControlButton:
        switch (widget.connectManager.audienceLocalConnectStateNotifier.value) {
          case ConnectState.idle:
            buttonSize = Size(330.r, 72.r);
            break;
          case ConnectState.connecting:
            buttonSize = Size(330.r, 72.r);
            break;
          case ConnectState.connected:
            buttonSize = Size(168.r, 72.r);
            break;
        }
        break;
      default:
        break;
    }

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: child,
    );
  }

  List<Widget> getDefaultButtons(
    BuildContext context, {
    bool Function()? cameraDefaultValueFunc,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    if (buttons.isEmpty) {
      return [];
    }

    return buttons
        .map((type) => buttonWrapper(
              child: generateDefaultButtonsByEnum(
                context,
                type,
                cameraDefaultValueFunc: cameraDefaultValueFunc,
                microphoneDefaultValueFunc: microphoneDefaultValueFunc,
              ),
              type: type,
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
    BuildContext context,
    ZegoMenuBarButtonName type, {
    bool Function()? cameraDefaultValueFunc,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    var cameraDefaultOn = widget.config.turnOnCameraWhenJoining;
    var microphoneDefaultOn = widget.config.turnOnMicrophoneWhenJoining;
    if (widget.config.plugins.isNotEmpty &&
        ConnectState.connected ==
            widget.connectManager.audienceLocalConnectStateNotifier.value) {
      cameraDefaultOn = true;
      microphoneDefaultOn = true;
    }

    cameraDefaultOn = cameraDefaultValueFunc?.call() ?? cameraDefaultOn;
    microphoneDefaultOn =
        microphoneDefaultValueFunc?.call() ?? microphoneDefaultOn;

    var buttonSize = zegoLiveButtonSize;
    var iconSize = zegoLiveButtonIconSize;
    switch (type) {
      case ZegoMenuBarButtonName.toggleMicrophoneButton:
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
          defaultOn: microphoneDefaultOn,
        );
      case ZegoMenuBarButtonName.switchAudioOutputButton:
        return ZegoSwitchAudioOutputButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultUseSpeaker: widget.config.useSpeakerWhenJoining,
        );
      case ZegoMenuBarButtonName.toggleCameraButton:
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
          defaultOn: cameraDefaultOn,
        );
      case ZegoMenuBarButtonName.switchCameraButton:
        return ZegoSwitchCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.toolbarFlipCamera),
            backgroundColor: Colors.transparent,
          ),
          defaultUseFrontFacingCamera: ZegoUIKit()
              .getUseFrontFacingCameraStateNotifier(
                  ZegoUIKit().getLocalUser().id)
              .value,
        );
      case ZegoMenuBarButtonName.leaveButton:
        return ZegoLeaveStreamingButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: const Icon(Icons.close, color: Colors.white),
            backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
          ),
          config: widget.config,
          hostManager: widget.hostManager,
          hostUpdateEnabledNotifier: widget.hostUpdateEnabledNotifier,
        );
      case ZegoMenuBarButtonName.beautyEffectButton:
        return ZegoBeautyEffectButton(
          beautyEffects: widget.config.effectConfig.beautyEffects,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
      case ZegoMenuBarButtonName.soundEffectButton:
        return ZegoSoundEffectButton(
          voiceChangeEffect: widget.config.effectConfig.voiceChangeEffect,
          reverbEffect: widget.config.effectConfig.reverbEffect,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
      case ZegoMenuBarButtonName.coHostControlButton:
        return ZegoCoHostControlButton(
          hostManager: widget.hostManager,
          connectManager: widget.connectManager,
          translationText: widget.translationText,
        );
      case ZegoMenuBarButtonName.enableChatButton:
        return ZegoDisableChatButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
    }
  }
}
