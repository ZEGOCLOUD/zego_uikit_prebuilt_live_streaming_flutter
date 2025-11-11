// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/instance.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimizing/defines.dart';

/// @nodoc
class ZegoLiveStreamingLeaveButton extends StatefulWidget {
  final String liveID;

  final ButtonIcon? icon;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;
  final void Function(ZegoLiveStreamingEndEvent event) defaultEndAction;
  final Future<bool> Function(
    ZegoLiveStreamingLeaveConfirmationEvent event,
  ) defaultLeaveConfirmationAction;

  final ValueNotifier<bool>? isLeaveRequestingNotifier;

  const ZegoLiveStreamingLeaveButton({
    super.key,
    required this.liveID,
    required this.config,
    required this.events,
    required this.defaultEndAction,
    required this.defaultLeaveConfirmationAction,
    this.isLeaveRequestingNotifier,
    this.icon,
    this.iconSize,
    this.buttonSize,
  });

  @override
  State<ZegoLiveStreamingLeaveButton> createState() =>
      _ZegoLiveStreamingLeaveButtonState();
}

class _ZegoLiveStreamingLeaveButtonState
    extends State<ZegoLiveStreamingLeaveButton> {
  final hangupButtonClickableNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    widget.isLeaveRequestingNotifier?.addListener(oHangUpRequestingChanged);
  }

  @override
  void dispose() {
    widget.isLeaveRequestingNotifier?.removeListener(oHangUpRequestingChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZegoLeaveButton(
      roomID: widget.liveID,
      buttonSize: widget.buttonSize,
      iconSize: widget.iconSize,
      icon: ButtonIcon(
        icon: widget.icon?.icon ?? const Icon(Icons.close, color: Colors.white),
        backgroundColor: widget.icon?.backgroundColor ??
            ZegoUIKitDefaultTheme.buttonBackgroundColor,
      ),
      clickableNotifier: hangupButtonClickableNotifier,
      onLeaveConfirmation: (context) async {
        /// prevent controller's leave function call after leave button click
        widget.isLeaveRequestingNotifier?.value = true;

        final endConfirmationEvent = ZegoLiveStreamingLeaveConfirmationEvent(
          context: context,
        );
        defaultAction() async {
          return widget.defaultLeaveConfirmationAction(endConfirmationEvent);
        }

        final canLeave = await widget.events?.onLeaveConfirmation?.call(
              endConfirmationEvent,
              defaultAction,
            ) ??
            true;
        if (canLeave) {
          await notifyUserLeaveByMessage();

          if (ZegoLiveStreamingPageLifeCycle()
              .currentManagers
              .hostManager
              .isLocalHost) {
            /// live is ready to end, host will update if receive property notify
            /// so need to keep current host value, DISABLE local host value UPDATE
            ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .hostUpdateEnabledNotifier
                .value = false;
            ZegoUIKit().updateRoomProperties(
              targetRoomID: widget.liveID,
              {
                RoomPropertyKey.host.text: '',
                RoomPropertyKey.liveStatus.text:
                    LiveStatus.ended.index.toString()
              },
            );
          }
        } else {
          /// restore controller's leave status
          widget.isLeaveRequestingNotifier?.value = false;
        }

        if (canLeave) {
          /// If entered from live hall, need special handling
        }

        return canLeave;
      },
      onPress: () async {
        await ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();

        final endEvent = ZegoLiveStreamingEndEvent(
          reason: ZegoLiveStreamingEndReason.localLeave,
          isFromMinimizing: ZegoLiveStreamingMiniOverlayPageState.minimizing ==
              ZegoUIKitPrebuiltLiveStreamingController().minimize.state,
        );
        defaultAction() {
          widget.defaultEndAction(endEvent);
        }

        if (widget.events?.onEnded != null) {
          widget.events?.onEnded!.call(endEvent, defaultAction);
        } else {
          defaultAction.call();
        }

        /// restore controller's leave status
        widget.isLeaveRequestingNotifier?.value = false;
      },

      /// Using live streaming swiping, has additional logic
      quitDelegate: ZegoLiveStreamingPageLifeCycle().swiping.usingRoomSwiping
          ? (String roomID) {
              /// If using live hall to enter, need to switch room instead, otherwise
              /// [ZegoLiveStreamingSwipingLifeCycle]'s uninitFromPreview has already handled it
              /// So no additional handling needed here, and cannot leave room
            }
          : null,
    );
  }

  void oHangUpRequestingChanged() {
    hangupButtonClickableNotifier.value =
        !(widget.isLeaveRequestingNotifier?.value ?? true);
  }

  Future<void> notifyUserLeaveByMessage() async {
    if (!widget.config.inRoomMessage.notifyUserLeave) {
      return;
    }

    final messageAttributes = widget.config.inRoomMessage.attributes?.call();
    if (messageAttributes?.isEmpty ?? true) {
      await ZegoUIKit().sendInRoomMessage(
        targetRoomID: widget.liveID,
        widget.config.innerText.userLeave,
      );
    } else {
      await ZegoUIKit().sendInRoomMessage(
        targetRoomID: widget.liveID,
        ZegoInRoomMessage.jsonBody(
          message: widget.config.innerText.userLeave,
          attributes: messageAttributes!,
        ),
      );
    }
  }
}
