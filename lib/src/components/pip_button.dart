// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';

/// @nodoc
class ZegoLiveStreamingPIPButton extends StatefulWidget {
  const ZegoLiveStreamingPIPButton({
    Key? key,
    required this.liveID,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.aspectWidth = 9,
    this.aspectHeight = 16,
  }) : super(key: key);

  final String liveID;

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final int aspectWidth;
  final int aspectHeight;

  @override
  State<ZegoLiveStreamingPIPButton> createState() =>
      _ZegoLiveStreamingPIPButtonState();
}

/// @nodoc
class _ZegoLiveStreamingPIPButtonState
    extends State<ZegoLiveStreamingPIPButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZegoUIKitRoomState>(
      valueListenable: ZegoUIKit().getRoomStateStream(
        targetRoomID: widget.liveID,
      ),
      builder: (context, roomState, _) {
        return roomState.isLogin2 ? button() : Container();
      },
    );
  }

  Widget button() {
    final containerSize = widget.buttonSize ?? zegoLiveButtonSize;
    final sizeBoxSize = widget.iconSize ?? zegoLiveButtonIconSize;

    return GestureDetector(
      onTap: () async {
        final pipStatus =
            await ZegoUIKitPrebuiltLiveStreamingController().pip.enable(
                  aspectWidth: widget.aspectWidth,
                  aspectHeight: widget.aspectHeight,
                );
        if (ZegoPiPStatus.enabled != pipStatus) {
          return;
        }

        if (widget.afterClicked != null) {
          widget.afterClicked!();
        }
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        padding: EdgeInsets.all(containerSize.width / 5),
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              ZegoUIKitDefaultTheme.buttonBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              ZegoLiveStreamingImage.asset(
                ZegoLiveStreamingIconUrls.pip,
              ),
        ),
      ),
    );
  }
}
