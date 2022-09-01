// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'defines.dart';
import 'in_room_message_button.dart';

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
      height: widget.buttonSize.height,
      child: Stack(
        children: [
          widget.config.showInRoomMessageButton
              ? Row(
                  children: [
                    zegoLiveButtonPadding,
                    const ZegoInRoomMessageButton(),
                  ],
                )
              : const SizedBox(),
          rightToolbar(context),
        ],
      ),
    );
  }

  Widget rightToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 100.0.r),
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
      ...widget.config.menuBarExtendButtons
    ];

    List<Widget> displayButtonList = [];
    if (buttonList.length > widget.config.menuBarButtonsMaxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList =
          buttonList.sublist(0, widget.config.menuBarButtonsMaxCount - 1);

      buttonList.removeRange(0, widget.config.menuBarButtonsMaxCount - 1);
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
    if (widget.config.menuBarButtons.isEmpty) {
      return [];
    }

    return widget.config.menuBarButtons
        .map((type) => buttonWrapper(
              child: generateDefaultButtonsByEnum(context, type),
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
      BuildContext context, ZegoLiveMenuBarButtonName type) {
    switch (type) {
      case ZegoLiveMenuBarButtonName.toggleMicrophoneButton:
        return ZegoToggleMicrophoneButton(
          defaultOn: widget.config.turnOnMicrophoneWhenJoining,
        );
      case ZegoLiveMenuBarButtonName.switchAudioOutputButton:
        return ZegoSwitchAudioOutputButton(
          defaultUseSpeaker: widget.config.useSpeakerWhenJoining,
        );
      case ZegoLiveMenuBarButtonName.toggleCameraButton:
        return ZegoToggleCameraButton(
          defaultOn: widget.config.turnOnCameraWhenJoining,
        );
      case ZegoLiveMenuBarButtonName.switchCameraFacingButton:
        return const ZegoSwitchCameraFacingButton();
      case ZegoLiveMenuBarButtonName.leaveButton:
      case ZegoLiveMenuBarButtonName.endButton:
        Future<bool> onCloseConfirming(context) async {
          return await widget.config.onEndOrLiveStreamingConfirming!(context);
        }

        void onClosePress() {
          if (widget.config.onEndOrLiveStreaming != null) {
            widget.config.onEndOrLiveStreaming!.call();
          } else {
            Navigator.of(context).pop();
          }
        }

        var buttonSize = Size(96.r, 96.r);
        var iconSize = Size(56.r, 56.r);
        var defaultIcon = ButtonIcon(
          icon: const Icon(Icons.close, color: Colors.white),
          backgroundColor: zegoLiveButtonBackgroundColor,
        );
        return type == ZegoLiveMenuBarButtonName.endButton
            ? ZegoEndButton(
                buttonSize: buttonSize,
                iconSize: iconSize,
                icon: defaultIcon,
                onEndConfirmation: onCloseConfirming,
                onPress: onClosePress,
              )
            : ZegoLeaveButton(
                buttonSize: buttonSize,
                iconSize: iconSize,
                icon: defaultIcon,
                onLeaveConfirmation: onCloseConfirming,
                onPress: onClosePress,
              );
    }
  }
}
