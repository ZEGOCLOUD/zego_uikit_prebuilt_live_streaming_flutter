// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/prebuilt_data.dart';

/// @nodoc
class ZegoUIKitPrebuiltLiveStreamingMinimizingButton extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreamingMinimizingButton({
    Key? key,
    required this.prebuiltData,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final ZegoUIKitPrebuiltLiveStreamingData prebuiltData;

  @override
  State<ZegoUIKitPrebuiltLiveStreamingMinimizingButton> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingMinimizingButtonState();
}

/// @nodoc
class _ZegoUIKitPrebuiltLiveStreamingMinimizingButtonState
    extends State<ZegoUIKitPrebuiltLiveStreamingMinimizingButton> {
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
        if (PrebuiltLiveStreamingMiniOverlayPageState.minimizing ==
            ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().state()) {
          ZegoLoggerService.logInfo(
            'is minimizing, ignore',
            tag: 'call',
            subTag: 'overlay button',
          );

          return;
        }

        ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().changeState(
          PrebuiltLiveStreamingMiniOverlayPageState.minimizing,
          prebuiltData: widget.prebuiltData,
        );

        Navigator.of(context).pop();

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
              PrebuiltLiveStreamingImage.asset(
                PrebuiltLiveStreamingIconUrls.minimizing,
              ),
        ),
      ),
    );
  }
}
