// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil_zego/flutter_screenutil_zego.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/beauty_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/sound_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/leave_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/disable_chat_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/in_room_message_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/co_host_control_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class ZegoBottomBar extends StatefulWidget {
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final Size buttonSize;

  final ZegoLiveHostManager hostManager;
  final ZegoPopUpManager popUpManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;

  final ValueNotifier<LiveStatus> liveStatusNotifier;
  final ZegoLiveConnectManager connectManager;

  const ZegoBottomBar({
    Key? key,
    required this.config,
    required this.buttonSize,
    required this.hostManager,
    required this.hostUpdateEnabledNotifier,
    required this.liveStatusNotifier,
    required this.connectManager,
    required this.popUpManager,
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
          if (widget.hostManager.isHost)
            rightToolbar(context)
          else
            ValueListenableBuilder(
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
          if (widget.config.bottomMenuBarConfig.showInRoomMessageButton)
            SizedBox(
              height: 124.r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  zegoLiveButtonPadding,
                  ZegoInRoomMessageButton(
                    translationText: widget.config.translationText,
                    hostManager: widget.hostManager,
                    onSheetPopUp: (int key) {
                      widget.popUpManager.addAPopUpSheet(key);
                    },
                    onSheetPop: (int key) {
                      widget.popUpManager.removeAPopUpSheet(key);
                    },
                  ),
                ],
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }

  void updateButtonsByRole() {
    if (widget.hostManager.isHost) {
      buttons = widget.config.bottomMenuBarConfig.hostButtons;
      extendButtons = widget.config.bottomMenuBarConfig.hostExtendButtons;
    } else {
      final connectState =
          widget.connectManager.audienceLocalConnectStateNotifier.value;
      final isCoHost = ConnectState.connected == connectState;

      buttons = isCoHost
          ? widget.config.bottomMenuBarConfig.coHostButtons
          : widget.config.bottomMenuBarConfig.audienceButtons;
      extendButtons = isCoHost
          ? widget.config.bottomMenuBarConfig.coHostExtendButtons
          : widget.config.bottomMenuBarConfig.audienceExtendButtons;
    }
  }

  Widget rightToolbar(BuildContext context) {
    return CustomScrollView(
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
    );
  }

  List<Widget> getDisplayButtons(BuildContext context) {
    final buttonList = <Widget>[
      ...getDefaultButtons(context),
      ...extendButtons
    ];

    var displayButtonList = <Widget>[];
    if (buttonList.length > widget.config.bottomMenuBarConfig.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList = buttonList.sublist(
        0,
        widget.config.bottomMenuBarConfig.maxCount - 1,
      )..add(
          buttonWrapper(
            child: ZegoMoreButton(
              menuButtonListFunc: () {
                final buttonList = <Widget>[
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
                ]..removeRange(
                    0,
                    widget.config.bottomMenuBarConfig.maxCount - 1,
                  );

                return buttonList;
              },
              icon: ButtonIcon(
                icon: PrebuiltLiveStreamingImage.asset(
                    PrebuiltLiveStreamingIconUrls.bottomBarMore),
                backgroundColor: Colors.transparent,
              ),
              onSheetPopUp: (int key) {
                widget.popUpManager.addAPopUpSheet(key);
              },
              onSheetPop: (int key) {
                widget.popUpManager.removeAPopUpSheet(key);
              },
            ),
          ),
        );
    } else {
      displayButtonList = buttonList;
    }

    final displayButtonsWithSpacing = <Widget>[];
    for (final button in displayButtonList) {
      displayButtonsWithSpacing
        ..add(button)
        ..add(zegoLiveButtonPadding);
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

    final buttonSize = zegoLiveButtonSize;
    final iconSize = zegoLiveButtonIconSize;
    switch (type) {
      case ZegoMenuBarButtonName.toggleMicrophoneButton:
        return ValueListenableBuilder(
          valueListenable: ZegoLiveStreamingPKBattleManager().state,
          builder: (context, pkBattleState, _) {
            final needUserMuteMode =
                pkBattleState == ZegoLiveStreamingPKBattleState.inPKBattle ||
                    pkBattleState == ZegoLiveStreamingPKBattleState.loading;
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
              muteMode: needUserMuteMode,
            );
          },
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
          translationText: widget.config.translationText,
          rootNavigator: widget.config.rootNavigator,
          beautyEffects: widget.config.effectConfig.beautyEffects,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
      case ZegoMenuBarButtonName.soundEffectButton:
        return ZegoSoundEffectButton(
          translationText: widget.config.translationText,
          rootNavigator: widget.config.rootNavigator,
          voiceChangeEffect: widget.config.effectConfig.voiceChangeEffect,
          reverbEffect: widget.config.effectConfig.reverbEffect,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
      case ZegoMenuBarButtonName.coHostControlButton:
        return ZegoCoHostControlButton(
          hostManager: widget.hostManager,
          connectManager: widget.connectManager,
          translationText: widget.config.translationText,
        );
      case ZegoMenuBarButtonName.enableChatButton:
        return ZegoDisableChatButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
      case ZegoMenuBarButtonName.toggleScreenSharingButton:
        return ZegoScreenSharingToggleButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          onPressed: (isScreenSharing) {},
        );
    }
  }
}
