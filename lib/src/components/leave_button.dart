// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/defines.dart';

/// @nodoc
class ZegoLeaveStreamingButton extends StatefulWidget {
  final ButtonIcon? icon;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingEvents events;
  final void Function(ZegoLiveStreamingEndEvent event) defaultEndAction;
  final Future<bool> Function(
    ZegoLiveStreamingLeaveConfirmationEvent event,
  ) defaultLeaveConfirmationAction;

  final ZegoLiveHostManager hostManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;
  final ValueNotifier<bool>? isLeaveRequestingNotifier;

  const ZegoLeaveStreamingButton({
    Key? key,
    required this.config,
    required this.events,
    required this.defaultEndAction,
    required this.defaultLeaveConfirmationAction,
    required this.hostManager,
    required this.hostUpdateEnabledNotifier,
    this.isLeaveRequestingNotifier,
    this.icon,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  @override
  State<ZegoLeaveStreamingButton> createState() =>
      ZegoLeaveStreamingButtonState();
}

/// @nodoc
class ZegoLeaveStreamingButtonState extends State<ZegoLeaveStreamingButton> {
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
      buttonSize: widget.buttonSize,
      iconSize: widget.iconSize,
      icon: ButtonIcon(
        icon: const Icon(Icons.close, color: Colors.white),
        backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
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

        final canLeave = await widget.events.onLeaveConfirmation?.call(
              endConfirmationEvent,
              defaultAction,
            ) ??
            true;
        if (canLeave) {
          await notifyUserLeaveByMessage();

          if (widget.hostManager.isLocalHost) {
            /// live is ready to end, host will update if receive property notify
            /// so need to keep current host value, DISABLE local host value UPDATE
            widget.hostUpdateEnabledNotifier.value = false;
            ZegoUIKit().updateRoomProperties({
              RoomPropertyKey.host.text: '',
              RoomPropertyKey.liveStatus.text: LiveStatus.ended.index.toString()
            });
          }
        } else {
          /// restore controller's leave status
          widget.isLeaveRequestingNotifier?.value = false;
        }

        return canLeave;
      },
      onPress: () async {
        final endEvent = ZegoLiveStreamingEndEvent(
          reason: ZegoLiveStreamingEndReason.localLeave,
          isFromMinimizing: ZegoLiveStreamingMiniOverlayPageState.minimizing ==
              ZegoUIKitPrebuiltLiveStreamingController().minimize.state,
        );
        defaultAction() {
          widget.defaultEndAction(endEvent);
        }

        if (widget.events.onEnded != null) {
          widget.events.onEnded!.call(endEvent, defaultAction);
        } else {
          defaultAction.call();
        }

        /// restore controller's leave status
        widget.isLeaveRequestingNotifier?.value = false;
      },
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
      await ZegoUIKit().sendInRoomMessage(widget.config.innerText.userLeave);
    } else {
      await ZegoUIKit().sendInRoomMessage(
        ZegoInRoomMessage.jsonBody(
          message: widget.config.innerText.userLeave,
          attributes: messageAttributes!,
        ),
      );
    }
  }
}
