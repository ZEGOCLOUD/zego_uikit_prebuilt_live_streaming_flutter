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
    Size containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    Size sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);

    isChatEnabled = ZegoUIKit()
            .getRoomProperties()
            .containsKey(disableChatRoomPropertyKey)
        ? toBoolean(
            ZegoUIKit().getRoomProperties()[disableChatRoomPropertyKey]!.value)
        : true;

    var icon = ButtonIcon(
      icon: PrebuiltLiveStreamingImage.asset(isChatEnabled
          ? PrebuiltLiveStreamingIconUrls.enableIM
          : PrebuiltLiveStreamingIconUrls.disableIM),
    );

    return GestureDetector(
      onTap: () async {
        if (isUpdatingRoomProperty) {
          ZegoLoggerService.logInfo(
            "room property update is not finish",
            tag: "live streaming",
            subTag: "disable chat button",
          );
          return;
        }

        isChatEnabled = !isChatEnabled;
        isUpdatingRoomProperty = true;
        ZegoUIKit()
            .setRoomProperty(
                disableChatRoomPropertyKey, isChatEnabled.toString())
            .then((value) {
          isUpdatingRoomProperty = false;
        });

        setState(() {});
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: icon.backgroundColor ?? Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: icon.icon,
        ),
      ),
    );
  }

  bool toBoolean(String str) {
    return str != '0' && str != 'false' && str != '';
  }
}
