// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

/// @nodoc
class ZegoLeaveStreamingButton extends StatefulWidget {
  final ButtonIcon? icon;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoLiveHostManager hostManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;
  final ValueNotifier<bool>? isLeaveRequestingNotifier;

  const ZegoLeaveStreamingButton({
    Key? key,
    required this.config,
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

        final canLeave =
            await widget.config.onLeaveConfirmation?.call(context) ?? true;
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
        if (widget.hostManager.isLocalHost) {
          /// host end/leave live streaming
          if (widget.config.onLiveStreamingEnded != null) {
            widget.config.onLiveStreamingEnded!.call(false);
          } else {
            /// host will return to the previous page by default
            Navigator.of(
              context,
              rootNavigator: widget.hostManager.config.rootNavigator,
            ).pop();
          }
        } else {
          /// audience leave live streaming
          if (widget.config.onLeaveLiveStreaming != null) {
            widget.config.onLeaveLiveStreaming!.call(false);
          } else {
            Navigator.of(
              context,
              rootNavigator: widget.hostManager.config.rootNavigator,
            ).pop();
          }
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
    if (!widget.config.inRoomMessageConfig.notifyUserLeave) {
      return;
    }

    final messageAttributes =
        widget.config.inRoomMessageConfig.attributes?.call();
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
