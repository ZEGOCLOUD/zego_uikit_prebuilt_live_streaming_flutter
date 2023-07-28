// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

/// @nodoc
class ZegoDisableChatButton extends StatefulWidget {
  final Size? iconSize;
  final Size? buttonSize;
  final ButtonIcon? enableIcon;
  final ButtonIcon? disableIcon;

  const ZegoDisableChatButton({
    Key? key,
    this.enableIcon,
    this.disableIcon,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  @override
  State<ZegoDisableChatButton> createState() => _ZegoDisableChatButtonState();
}

/// @nodoc
class _ZegoDisableChatButtonState extends State<ZegoDisableChatButton> {
  bool isChatEnabled = true;
  bool isUpdatingRoomProperty = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    isChatEnabled = toBoolean(
        ZegoUIKit().getRoomProperties()[disableChatRoomPropertyKey]?.value ??
            'true');

    final icon = isChatEnabled ? widget.enableIcon : widget.disableIcon;
    icon?.icon ??= isChatEnabled
        ? PrebuiltLiveStreamingImage.asset(
            PrebuiltLiveStreamingIconUrls.enableIM,
          )
        : PrebuiltLiveStreamingImage.asset(
            PrebuiltLiveStreamingIconUrls.disableIM,
          );

    return GestureDetector(
      onTap: () async {
        if (isUpdatingRoomProperty) {
          ZegoLoggerService.logInfo(
            'room property update is not finish',
            tag: 'live streaming',
            subTag: 'disable chat button',
          );
          return;
        }

        isChatEnabled = !isChatEnabled;
        isUpdatingRoomProperty = true;
        ZegoUIKit()
            .setRoomProperty(
          disableChatRoomPropertyKey,
          isChatEnabled.toString(),
        )
            .then((value) {
          ZegoLoggerService.logInfo(
            'chat enable property update to $isChatEnabled',
            tag: 'live streaming',
            subTag: 'disable chat button',
          );

          isUpdatingRoomProperty = false;
        });

        setState(() {});
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: icon?.backgroundColor ?? Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: icon?.icon,
        ),
      ),
    );
  }

  bool toBoolean(String str) {
    return str != '0' && str != 'false' && str != '';
  }
}
