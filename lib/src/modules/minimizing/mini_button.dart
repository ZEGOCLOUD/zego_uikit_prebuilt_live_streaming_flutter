// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';

/// @nodoc
class ZegoLiveStreamingMinimizingButton extends StatefulWidget {
  const ZegoLiveStreamingMinimizingButton({
    super.key,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
  });

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoLiveStreamingMinimizingButton> createState() =>
      _ZegoLiveStreamingMinimizingButtonState();
}

/// @nodoc
class _ZegoLiveStreamingMinimizingButtonState
    extends State<ZegoLiveStreamingMinimizingButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.buttonSize ?? zegoLiveButtonSize;
    final iconSize = widget.iconSize ?? zegoLiveButtonIconSize;

    return GestureDetector(
      onTap: () {
        if (ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing) {
          ZegoLoggerService.logInfo(
            'is minimizing, ignore',
            tag: 'live-streaming',
            subTag: 'overlay button',
          );

          return;
        }

        ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize(context);

        if (widget.afterClicked != null) {
          widget.afterClicked!();
        }
      },
      child: Container(
        width: buttonSize.width,
        height: buttonSize.height,
        padding: EdgeInsets.all(buttonSize.width / 5),
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              ZegoUIKitDefaultTheme.buttonBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: iconSize,
          child: widget.icon?.icon ??
              ZegoLiveStreamingImage.asset(
                ZegoLiveStreamingIconUrls.minimizing,
              ),
        ),
      ),
    );
  }
}
