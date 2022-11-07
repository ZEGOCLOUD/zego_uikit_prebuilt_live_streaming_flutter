// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

class ZegoLeaveStreamingButton extends StatelessWidget {
  final ButtonIcon? icon;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  final ZegoLiveHostManager hostManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;

  const ZegoLeaveStreamingButton({
    Key? key,
    required this.config,
    required this.hostManager,
    required this.hostUpdateEnabledNotifier,
    this.icon,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZegoLeaveButton(
      buttonSize: buttonSize,
      iconSize: iconSize,
      icon: ButtonIcon(
        icon: const Icon(Icons.close, color: Colors.white),
        backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
      ),
      onLeaveConfirmation: (context) async {
        var canLeave = await config.onLeaveConfirmation?.call(context) ?? true;
        if (canLeave) {
          if (hostManager.isHost) {
            /// live is ready to end, host will update if receive property notify
            /// so need to keep current host value, DISABLE local host value UPDATE
            hostUpdateEnabledNotifier.value = false;
            ZegoUIKit().updateRoomProperties({
              RoomPropertyKey.host.text: "",
              RoomPropertyKey.liveStatus.text: LiveStatus.ended.index.toString()
            });
          }
        }

        return canLeave;
      },
      onPress: () async {
        if (hostManager.isHost) {
          /// host end/leave live streaming
          if (config.onLiveStreamingEnded != null) {
            config.onLiveStreamingEnded!.call();
          } else {
            Navigator.of(context).pop();
          }
        } else {
          /// audience leave live streaming
          if (config.onLeaveLiveStreaming != null) {
            config.onLeaveLiveStreaming!.call();
          } else {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}
