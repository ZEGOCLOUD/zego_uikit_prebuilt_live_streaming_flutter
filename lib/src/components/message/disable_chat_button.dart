// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'defines.dart';

class ZegoDisableChatButton extends StatefulWidget {
  final Size? iconSize;
  final Size? buttonSize;

  const ZegoDisableChatButton({
    Key? key,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  @override
  State<ZegoDisableChatButton> createState() => _ZegoDisableChatButtonState();
}

class _ZegoDisableChatButtonState extends State<ZegoDisableChatButton> {
  bool isChatEnabled = true;
  bool isUpdatingRoomProperty = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isChatEnabled = ZegoUIKit()
            .getRoomProperties()
            .containsKey(disableChatRoomPropertyKey)
        ? toBoolean(
            ZegoUIKit().getRoomProperties()[disableChatRoomPropertyKey]!.value)
        : false;

    return ZegoTextIconButton(
      onPressed: () {
        if (isUpdatingRoomProperty) {
          debugPrint(
              "[disable chat button] room property update is not finish");
          return;
        }

        setState(() {
          isChatEnabled = !isChatEnabled;
        });

        isUpdatingRoomProperty = true;
        ZegoUIKit()
            .updateRoomProperty(
                disableChatRoomPropertyKey, isChatEnabled.toString())
            .then((value) {
          isUpdatingRoomProperty = false;
        });
      },
      icon: ButtonIcon(
        icon: PrebuiltLiveStreamingImage.asset(isChatEnabled
            ? PrebuiltLiveStreamingIconUrls.disableIM
            : PrebuiltLiveStreamingIconUrls.enableIM),
      ),
      iconSize: widget.iconSize ?? Size(72.r, 72.r),
      buttonSize: widget.buttonSize ?? Size(96.r, 96.r),
    );
  }

  bool toBoolean(String str) {
    return str != '0' && str != 'false' && str != '';
  }
}
