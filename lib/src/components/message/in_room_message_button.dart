// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'in_room_message_input_board.dart';

class ZegoInRoomMessageButton extends StatefulWidget {
  final Size? iconSize;
  final Size? buttonSize;

  const ZegoInRoomMessageButton({
    Key? key,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  @override
  State<ZegoInRoomMessageButton> createState() =>
      _ZegoInRoomMessageButtonState();
}

class _ZegoInRoomMessageButtonState extends State<ZegoInRoomMessageButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(
      onPressed: () {
        Navigator.of(context).push(ZegoInRoomMessageInputBoard());
      },
      icon: ButtonIcon(
        icon:
            PrebuiltLiveStreamingImage.asset(PrebuiltLiveStreamingIconUrls.im),
      ),
      iconSize: widget.iconSize ?? Size(72.r, 72.r),
      buttonSize: widget.buttonSize ?? Size(96.r, 96.r),
    );
  }
}
