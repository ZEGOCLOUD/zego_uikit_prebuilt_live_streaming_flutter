// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

/// @nodoc
class ZegoInRoomLiveMessageViewItem extends StatelessWidget {
  const ZegoInRoomLiveMessageViewItem({
    Key? key,
    required this.message,
    this.namePrefix,
    this.isHorizontal = true,
    this.showName = true,
    this.showAvatar = true,
    this.avatarBuilder,
    this.config,
  }) : super(key: key);

  final String? namePrefix;
  final ZegoInRoomMessage message;
  final bool isHorizontal;
  final bool showName;
  final bool showAvatar;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoInRoomMessageViewConfig? config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: config?.backgroundColor ??
              const Color(0xff2a2a2a).withOpacity(config?.opacity ?? 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: config?.borderRadius ??
                BorderRadius.all(Radius.circular(26.zR)),
          ),
          child: Padding(
            padding: config?.paddings ??
                EdgeInsets.fromLTRB(20.zR, 10.zR, 20.zR, 10.zR),
            child: Stack(
              children: [
                content(),
                Positioned(
                  top: 1.zR,
                  right: 1.zR,
                  child: state(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget content() {
    final padding =
        config?.paddings ?? EdgeInsets.fromLTRB(20.zR, 10.zR, 20.zR, 10.zR);
    return RichText(
      maxLines: config?.maxLines,
      overflow:
          null == config?.maxLines ? TextOverflow.clip : TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          ...showAvatar
              ? [
                  WidgetSpan(
                    child: SizedBox(
                      width: 26.zR + padding.vertical / 2 - 1,
                      height: 26.zR + padding.vertical / 2 - 1,
                      child: ZegoAvatar(
                        user: message.user,
                        avatarSize: Size(30.zR, 30.zR),
                        avatarBuilder: avatarBuilder,
                      ),
                    ),
                  ),
                  WidgetSpan(child: SizedBox(width: 1.zR))
                ]
              : [],
          ...showName
              ? [
                  if (namePrefix != null) prefixWidget(),
                  TextSpan(
                    text: message.user.name,
                    style: config?.nameTextStyle ??
                        TextStyle(
                          fontSize: 26.zR,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xffFFB763),
                        ),
                  ),
                  WidgetSpan(child: SizedBox(width: 10.zR)),
                ]
              : [],
          TextSpan(
            text: isHorizontal ? message.message : '\n${message.message}',
            style: config?.messageTextStyle ??
                TextStyle(
                  fontSize: 26.zR,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }

  TextSpan prefixWidget() {
    const messageHostColor = Color(0xff9f76ff);

    return TextSpan(
      children: [
        WidgetSpan(
          child: Transform.translate(
            offset: Offset(0, 0.zR),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 34.zR + namePrefix!.length * 12.zR,
                minWidth: 34.zR,
                minHeight: 36.zR,
                maxHeight: 36.zR,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: messageHostColor,
                  borderRadius: BorderRadius.all(Radius.circular(20.zR)),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.zR, 4.zR, 12.zR, 4.zR),
                  child: Center(
                    child: Text(
                      namePrefix!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.zR,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        WidgetSpan(child: SizedBox(width: 10.zR)),
      ],
    );
  }

  Widget state() {
    if (ZegoInRoomMessageState.idle == message.state.value ||
        ZegoInRoomMessageState.success == message.state.value) {
      return const SizedBox(width: 0, height: 0);
    }

    return ValueListenableBuilder<ZegoInRoomMessageState>(
      valueListenable: message.state,
      builder: (context, state, _) {
        if (ZegoInRoomMessageState.idle == state ||
            ZegoInRoomMessageState.success == state) {
          return const SizedBox(width: 0, height: 0);
        }

        var imageUrl = '';
        switch (state) {
          case ZegoInRoomMessageState.sending:
            imageUrl = StyleIconUrls.messageLoading;
            break;
          case ZegoInRoomMessageState.failed:
            imageUrl = StyleIconUrls.messageFail;
            break;
          default:
            break;
        }

        return GestureDetector(
          onTap: () {
            if (state == ZegoInRoomMessageState.failed) {
              ZegoUIKit().resendInRoomMessage(message);
            }
          },
          child: null != config?.resendIcon
              ? SizedBox(
                  width: 30.zR,
                  height: 30.zR,
                  child: config!.resendIcon,
                )
              : Container(
                  width: 30.zR,
                  height: 30.zR,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: UIKitImage.asset(imageUrl).image,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
