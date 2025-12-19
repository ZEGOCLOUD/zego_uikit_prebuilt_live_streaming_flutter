// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/beauty_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/sound_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/leave_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/disable_chat_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/input_board_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pip_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/co_host_control_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/mini_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';

/// @nodoc
class ZegoLiveStreamingBottomBar extends StatefulWidget {
  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;
  final void Function(ZegoLiveStreamingEndEvent event) defaultEndAction;
  final Future<bool> Function(
    ZegoLiveStreamingLeaveConfirmationEvent event,
  ) defaultLeaveConfirmationAction;

  final Size buttonSize;

  final ZegoLiveStreamingPopUpManager popUpManager;

  final ValueNotifier<bool>? isLeaveRequestingNotifier;

  const ZegoLiveStreamingBottomBar({
    super.key,
    required this.liveID,
    required this.config,
    required this.events,
    required this.defaultEndAction,
    required this.defaultLeaveConfirmationAction,
    required this.buttonSize,
    required this.popUpManager,
    this.isLeaveRequestingNotifier,
  });

  @override
  State<ZegoLiveStreamingBottomBar> createState() =>
      _ZegoLiveStreamingBottomBarState();
}

/// @nodoc
class _ZegoLiveStreamingBottomBarState
    extends State<ZegoLiveStreamingBottomBar> {
  List<ZegoLiveStreamingMenuBarButtonName> buttons = [];
  List<ZegoLiveStreamingMenuBarExtendButton> extendButtons = [];

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
      margin: widget.config.bottomMenuBar.margin,
      padding: widget.config.bottomMenuBar.padding,
      decoration: BoxDecoration(
        color:
            widget.config.bottomMenuBar.backgroundColor ?? Colors.transparent,
      ),
      height: widget.config.bottomMenuBar.height ?? 124.zR,
      child: Stack(
        children: [
          if (ZegoLiveStreamingPageLifeCycle()
              .currentManagers
              .hostManager
              .isLocalHost)
            rightToolbar(context)
          else
            ValueListenableBuilder(
              valueListenable: ZegoLiveStreamingPageLifeCycle()
                  .currentManagers
                  .connectManager
                  .audienceLocalConnectStateNotifier,
              builder: (context, connectState, _) {
                if (widget.config.plugins.isEmpty) {
                  return rightToolbar(context);
                }

                if (ZegoLiveStreamingAudienceConnectState.connecting ==
                    connectState) {
                  return rightToolbar(context);
                }

                updateButtonsByRole();

                return rightToolbar(context);
              },
            ),
          leftChatButton(),
        ],
      ),
    );
  }

  void updateButtonsByRole() {
    if (ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .isLocalHost) {
      buttons = widget.config.bottomMenuBar.hostButtons;
      extendButtons = widget.config.bottomMenuBar.hostExtendButtons;
    } else {
      final connectState = ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .connectManager
          .audienceLocalConnectStateNotifier
          .value;
      final isCoHost =
          ZegoLiveStreamingAudienceConnectState.connected == connectState;

      buttons = isCoHost
          ? widget.config.bottomMenuBar.coHostButtons
          : widget.config.bottomMenuBar.audienceButtons;
      extendButtons = isCoHost
          ? widget.config.bottomMenuBar.coHostExtendButtons
          : widget.config.bottomMenuBar.audienceExtendButtons;
    }

    if (buttons.contains(ZegoLiveStreamingMenuBarButtonName.chatButton) &&
        !widget.config.bottomMenuBar.showInRoomMessageButton) {
      buttons.removeWhere(
          (button) => button == ZegoLiveStreamingMenuBarButtonName.chatButton);
    }
  }

  Widget leftChatButton() {
    if (buttons.contains(ZegoLiveStreamingMenuBarButtonName.chatButton)) {
      /// hide chat button is show on right bar
      return const SizedBox();
    }

    if (widget.config.bottomMenuBar.showInRoomMessageButton) {
      return SizedBox(
        height: 124.zR,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            zegoLiveButtonPadding,
            ZegoLiveStreamingInRoomMessageInputBoardButton(
              liveID: widget.liveID,
              translationText: widget.config.innerText,
              hostManager:
                  ZegoLiveStreamingPageLifeCycle().currentManagers.hostManager,
              onSheetPopUp: (int key) {
                widget.popUpManager.addAPopUpSheet(key);
              },
              onSheetPop: (int key) {
                widget.popUpManager.removeAPopUpSheet(key);
              },
              enabledIcon: ButtonIcon(
                icon: widget
                    .config.bottomMenuBar.buttonStyle?.chatEnabledButtonIcon,
              ),
              disabledIcon: ButtonIcon(
                icon: widget
                    .config.bottomMenuBar.buttonStyle?.chatDisabledButtonIcon,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget rightToolbar(BuildContext context) {
    var leftPaddings = <Widget>[];
    if (!widget.config.bottomMenuBar.showInRoomMessageButton) {
      leftPaddings = [
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
      ];
    } else if (buttons
        .contains(ZegoLiveStreamingMenuBarButtonName.chatButton)) {
      leftPaddings = [
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
      ];
    } else if (buttons.contains(ZegoLiveStreamingMenuBarButtonName.expanding)) {
      leftPaddings = [
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
        SizedBox.fromSize(size: zegoLiveButtonSize),
      ];
    }

    return CustomScrollView(
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...leftPaddings,
              ...getDisplayButtons(context),
              zegoLiveButtonPadding,
              zegoLiveButtonPadding,
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> sortDisplayButtons(
    List<Widget> builtInButton,
    List<ZegoLiveStreamingMenuBarExtendButton> tempExtendButtons,
  ) {
    /// classify
    final unsortedExtendIndexesWithButton = <int, Widget>{};
    final notNeedSortedExtendButtons = <Widget>[];
    final totalButtonCount = builtInButton.length + tempExtendButtons.length;
    for (var i = 0; i < tempExtendButtons.length; i++) {
      final extendButton = tempExtendButtons[i];
      if (extendButton.index >= 0 && extendButton.index < totalButtonCount) {
        unsortedExtendIndexesWithButton[extendButton.index] = extendButton;
      } else {
        // button which index is -1 mean not need to sort
        notNeedSortedExtendButtons.add(extendButton);
      }
    }

    /// sort
    final entries = unsortedExtendIndexesWithButton.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final sortedExtendIndexesWithButton = Map<int, Widget>.fromEntries(entries);

    /// insert
    final sortButtons = <Widget>[
      ...builtInButton,
      ...notNeedSortedExtendButtons
    ];
    sortedExtendIndexesWithButton.forEach((index, button) {
      sortButtons.insert(index, button);
    });

    return sortButtons;
  }

  List<Widget> getDisplayButtons(BuildContext context) {
    final buttonList = sortDisplayButtons(
      getDefaultButtons(context),
      extendButtons,
    );

    var displayButtonList = <Widget>[];
    if (buttonList.length > widget.config.bottomMenuBar.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList = buttonList.sublist(
        0,
        widget.config.bottomMenuBar.maxCount - 1,
      )..add(
          buttonWrapper(
            child: ZegoMoreButton(
              menuButtonListFunc: () {
                final buttonList = sortDisplayButtons(
                  getDefaultButtons(context),
                  extendButtons,
                )..removeRange(
                    0,
                    widget.config.bottomMenuBar.maxCount - 1,
                  );

                return buttonList;
              },
              icon: ButtonIcon(
                icon: ZegoLiveStreamingImage.asset(
                    ZegoLiveStreamingIconUrls.bottomBarMore),
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

  Widget buttonWrapper(
      {required Widget child, ZegoLiveStreamingMenuBarButtonName? type}) {
    if (ZegoLiveStreamingMenuBarButtonName.expanding == type) {
      return child;
    }

    var buttonSize = widget.buttonSize;

    /// co-host button
    final coHostButtonTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 26.zR,
      fontWeight: FontWeight.w500,
    );
    final iconTextSpacing = 20.zR;
    switch (type) {
      case ZegoLiveStreamingMenuBarButtonName.coHostControlButton:
        switch (ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .connectManager
            .audienceLocalConnectStateNotifier
            .value) {
          case ZegoLiveStreamingAudienceConnectState.idle:
            final textSize = getTextSize(
              widget.config.bottomMenuBar.buttonStyle
                      ?.requestCoHostButtonText ??
                  widget.config.innerText.requestCoHostButton,
              coHostButtonTextStyle,
            );
            buttonSize = Size(
              textSize.width +
                  (textSize.width > 1 ? iconTextSpacing : 0) +
                  zegoLiveButtonSize.width,
              zegoLiveButtonSize.height,
            );
            break;
          case ZegoLiveStreamingAudienceConnectState.connecting:
            final textSize = getTextSize(
              widget.config.bottomMenuBar.buttonStyle
                      ?.cancelRequestCoHostButtonText ??
                  widget.config.innerText.cancelRequestCoHostButton,
              coHostButtonTextStyle,
            );
            buttonSize = Size(
              textSize.width +
                  (textSize.width > 1 ? iconTextSpacing : 0) +
                  zegoLiveButtonSize.width,
              zegoLiveButtonSize.height,
            );
            break;
          case ZegoLiveStreamingAudienceConnectState.connected:
            final textSize = getTextSize(
              widget.config.bottomMenuBar.buttonStyle?.endCoHostButtonText ??
                  widget.config.innerText.endCoHostButton,
              coHostButtonTextStyle,
            );
            buttonSize = Size(
              textSize.width +
                  (textSize.width > 1 ? iconTextSpacing : 0) +
                  zegoLiveButtonSize.width,
              zegoLiveButtonSize.height,
            );
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

  List<Widget> getDefaultButtons(BuildContext context) {
    if (buttons.isEmpty) {
      return [];
    }

    return buttons
        .map((type) => buttonWrapper(
              child: generateDefaultButtonsByEnum(context, type),
              type: type,
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
    BuildContext context,
    ZegoLiveStreamingMenuBarButtonName type,
  ) {
    final needRestoreDeviceState = (ZegoUIKitPrebuiltLiveStreamingController()
                .minimize
                .private
                .minimizeData
                ?.isPrebuiltFromMinimizing ??
            false) ||
        ZegoUIKitPrebuiltLiveStreamingController()
            .pip
            .private
            .pipImpl()
            .isRestoredFromPIP;

    final cameraDefaultOnFunc = needRestoreDeviceState
        ? () {
            /// if is minimizing, take the local device state
            return ZegoUIKit()
                .getCameraStateNotifier(
                  targetRoomID: widget.liveID,
                  ZegoUIKit().getLocalUser().id,
                )
                .value;
          }
        : () {
            final isConnected =
                ZegoLiveStreamingAudienceConnectState.connected ==
                    ZegoLiveStreamingPageLifeCycle()
                        .currentManagers
                        .connectManager
                        .audienceLocalConnectStateNotifier
                        .value;
            var cameraDefaultOn = widget.config.turnOnCameraWhenJoining;
            if (widget.config.plugins.isNotEmpty && isConnected) {
              cameraDefaultOn =
                  widget.config.coHost.turnOnCameraWhenCohosted?.call() ?? true;
            }
            return cameraDefaultOn;
          };
    final microphoneDefaultOnFunc = needRestoreDeviceState
        ? () {
            /// if is minimizing, take the local device state
            return ZegoUIKit()
                .getMicrophoneStateNotifier(
                  targetRoomID: widget.liveID,
                  ZegoUIKit().getLocalUser().id,
                )
                .value;
          }
        : () {
            final isConnected =
                ZegoLiveStreamingAudienceConnectState.connected ==
                    ZegoLiveStreamingPageLifeCycle()
                        .currentManagers
                        .connectManager
                        .audienceLocalConnectStateNotifier
                        .value;
            var microphoneDefaultOn = widget.config.turnOnMicrophoneWhenJoining;
            if (widget.config.plugins.isNotEmpty && isConnected) {
              microphoneDefaultOn = true;
            }

            return microphoneDefaultOn;
          };

    final buttonSize = zegoLiveButtonSize;
    final iconSize = zegoLiveButtonIconSize;
    switch (type) {
      case ZegoLiveStreamingMenuBarButtonName.toggleMicrophoneButton:
        return ValueListenableBuilder<bool>(
          valueListenable:
              ZegoUIKitPrebuiltLiveStreamingPK.instance.combineNotifier.state,
          builder: (context, _isInPK, _) {
            final isInPK = ZegoUIKitPrebuiltLiveStreamingPK.instance.liveID ==
                    widget.liveID &&
                _isInPK;
            final needUserMuteMode =
                (!widget.config.coHost.stopCoHostingWhenMicCameraOff) || isInPK;

            return ZegoToggleMicrophoneButton(
              roomID: widget.liveID,
              buttonSize: buttonSize,
              iconSize: iconSize,
              normalIcon: ButtonIcon(
                icon: widget.config.bottomMenuBar.buttonStyle
                        ?.toggleMicrophoneOnButtonIcon ??
                    ZegoLiveStreamingImage.asset(
                      ZegoLiveStreamingIconUrls.toolbarMicNormal,
                    ),
                backgroundColor: Colors.transparent,
              ),
              offIcon: ButtonIcon(
                icon: widget.config.bottomMenuBar.buttonStyle
                        ?.toggleMicrophoneOffButtonIcon ??
                    ZegoLiveStreamingImage.asset(
                      ZegoLiveStreamingIconUrls.toolbarMicOff,
                    ),
                backgroundColor: Colors.transparent,
              ),
              defaultOn: microphoneDefaultOnFunc(),
              muteMode: needUserMuteMode,
            );
          },
        );

      case ZegoLiveStreamingMenuBarButtonName.switchAudioOutputButton:
        return ZegoSwitchAudioOutputButton(
          roomID: widget.liveID,
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultUseSpeaker: widget.config.useSpeakerWhenJoining,
          speakerIcon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle
                ?.switchAudioOutputToSpeakerButtonIcon,
          ),
          headphoneIcon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle
                ?.switchAudioOutputToHeadphoneButtonIcon,
          ),
          bluetoothIcon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle
                ?.switchAudioOutputToBluetoothButtonIcon,
          ),
        );
      case ZegoLiveStreamingMenuBarButtonName.toggleCameraButton:
        return ZegoToggleCameraButton(
          roomID: widget.liveID,
          buttonSize: buttonSize,
          iconSize: iconSize,
          normalIcon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle
                    ?.toggleCameraOnButtonIcon ??
                ZegoLiveStreamingImage.asset(
                  ZegoLiveStreamingIconUrls.toolbarCameraNormal,
                ),
            backgroundColor: Colors.transparent,
          ),
          offIcon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle
                    ?.toggleCameraOffButtonIcon ??
                ZegoLiveStreamingImage.asset(
                  ZegoLiveStreamingIconUrls.toolbarCameraOff,
                ),
            backgroundColor: Colors.transparent,
          ),
          defaultOn: cameraDefaultOnFunc(),
        );
      case ZegoLiveStreamingMenuBarButtonName.switchCameraButton:
        return ZegoSwitchCameraButton(
          roomID: widget.liveID,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: widget
                    .config.bottomMenuBar.buttonStyle?.switchCameraButtonIcon ??
                ZegoLiveStreamingImage.asset(
                  ZegoLiveStreamingIconUrls.toolbarFlipCamera,
                ),
            backgroundColor: Colors.transparent,
          ),
          defaultUseFrontFacingCamera: ZegoUIKit()
              .getUseFrontFacingCameraStateNotifier(
                targetRoomID: widget.liveID,
                ZegoUIKit().getLocalUser().id,
              )
              .value,
        );
      case ZegoLiveStreamingMenuBarButtonName.leaveButton:
        return ZegoLiveStreamingLeaveButton(
          liveID: widget.liveID,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle?.leaveButtonIcon ??
                const Icon(Icons.close, color: Colors.white),
            backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
          ),
          config: widget.config,
          events: widget.events,
          defaultEndAction: widget.defaultEndAction,
          defaultLeaveConfirmationAction: widget.defaultLeaveConfirmationAction,
          isLeaveRequestingNotifier: widget.isLeaveRequestingNotifier,
        );
      case ZegoLiveStreamingMenuBarButtonName.beautyEffectButton:
        return ZegoLiveStreamingBeautyEffectButton(
          translationText: widget.config.innerText,
          rootNavigator: widget.config.rootNavigator,
          effectConfig: widget.config.effect,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon:
                widget.config.bottomMenuBar.buttonStyle?.beautyEffectButtonIcon,
          ),
        );
      case ZegoLiveStreamingMenuBarButtonName.soundEffectButton:
        return ZegoLiveStreamingSoundEffectButton(
          translationText: widget.config.innerText,
          rootNavigator: widget.config.rootNavigator,
          voiceChangeEffect: widget.config.effect.voiceChangeEffect,
          reverbEffect: widget.config.effect.reverbEffect,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon:
                widget.config.bottomMenuBar.buttonStyle?.soundEffectButtonIcon,
          ),
          effectConfig: widget.config.effect,
        );
      case ZegoLiveStreamingMenuBarButtonName.coHostControlButton:
        return ZegoLiveStreamingCoHostControlButton(
          liveID: widget.liveID,
          translationText: widget.config.innerText,
          requestCoHostButtonIcon: ButtonIcon(
            icon: widget
                .config.bottomMenuBar.buttonStyle?.requestCoHostButtonIcon,
          ),
          cancelRequestCoHostButtonIcon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle
                ?.cancelRequestCoHostButtonIcon,
          ),
          endCoHostButtonIcon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle?.endCoHostButtonIcon,
          ),
          requestCoHostButtonText:
              widget.config.bottomMenuBar.buttonStyle?.requestCoHostButtonText,
          cancelRequestCoHostButtonText: widget
              .config.bottomMenuBar.buttonStyle?.cancelRequestCoHostButtonText,
          endCoHostButtonText:
              widget.config.bottomMenuBar.buttonStyle?.endCoHostButtonText,
        );
      case ZegoLiveStreamingMenuBarButtonName.enableChatButton:
        return ZegoLiveStreamingDisableChatButton(
          liveID: widget.liveID,
          buttonSize: buttonSize,
          iconSize: iconSize,
          enableIcon: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle?.enableChatButtonIcon,
          ),
          disableIcon: ButtonIcon(
            icon:
                widget.config.bottomMenuBar.buttonStyle?.disableChatButtonIcon,
          ),
        );
      case ZegoLiveStreamingMenuBarButtonName.toggleScreenSharingButton:
        return ZegoScreenSharingToggleButton(
          roomID: widget.liveID,
          buttonSize: buttonSize,
          iconSize: iconSize,
          onPressed: (isScreenSharing) {},
          iconStartSharing: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle
                ?.toggleScreenSharingOnButtonIcon,
          ),
          iconStopSharing: ButtonIcon(
            icon: widget.config.bottomMenuBar.buttonStyle
                ?.toggleScreenSharingOffButtonIcon,
          ),
        );
      case ZegoLiveStreamingMenuBarButtonName.chatButton:
        if (widget.config.bottomMenuBar.showInRoomMessageButton) {
          return ZegoLiveStreamingInRoomMessageInputBoardButton(
            liveID: widget.liveID,
            translationText: widget.config.innerText,
            hostManager:
                ZegoLiveStreamingPageLifeCycle().currentManagers.hostManager,
            onSheetPopUp: (int key) {
              widget.popUpManager.addAPopUpSheet(key);
            },
            onSheetPop: (int key) {
              widget.popUpManager.removeAPopUpSheet(key);
            },
            enabledIcon: ButtonIcon(
              icon: widget
                  .config.bottomMenuBar.buttonStyle?.chatEnabledButtonIcon,
            ),
            disabledIcon: ButtonIcon(
              icon: widget
                  .config.bottomMenuBar.buttonStyle?.chatDisabledButtonIcon,
            ),
          );
        } else {
          return const SizedBox();
        }
      case ZegoLiveStreamingMenuBarButtonName.expanding:
        return Expanded(child: Container());
      case ZegoLiveStreamingMenuBarButtonName.minimizingButton:
        return const ZegoLiveStreamingMinimizationButton();
      case ZegoLiveStreamingMenuBarButtonName.pipButton:
        return ZegoLiveStreamingPIPButton(
          liveID: widget.liveID,
          aspectWidth: widget.config.pip.aspectWidth,
          aspectHeight: widget.config.pip.aspectHeight,
        );
    }
  }
}
