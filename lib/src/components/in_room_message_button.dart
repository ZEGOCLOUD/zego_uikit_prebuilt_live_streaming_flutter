// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'defines.dart';
import 'in_room_message_input_board.dart';

class ZegoInRoomMessageButton extends StatefulWidget {
  const ZegoInRoomMessageButton({
    Key? key,
  }) : super(key: key);

  @override
  State<ZegoInRoomMessageButton> createState() => _ZegoInRoomMessageButtonState();
}

class _ZegoInRoomMessageButtonState extends State<ZegoInRoomMessageButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(
      onPressed: () {
        Navigator.of(context).push(ZegoInRoomMessageInputBoard());
      },
      icon: ButtonIcon(
        icon: PrebuiltLiveStreamingImage.asset(PrebuiltLiveStreamingIconUrls.iconMessage),
        backgroundColor: zegoLiveButtonBackgroundColor,
      ),
      iconSize: zegoLiveButtonIconSize,
      buttonSize: zegoLiveButtonSize,
    );
  }
}
