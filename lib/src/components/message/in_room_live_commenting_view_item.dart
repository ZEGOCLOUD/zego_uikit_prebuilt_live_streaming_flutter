// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

/// @nodoc
class ZegoInRoomLiveCommentingViewItem extends StatelessWidget {
  const ZegoInRoomLiveCommentingViewItem({
    Key? key,
    required this.user,
    required this.message,
    this.prefix,
    this.isHorizontal = true,
    this.config,
  }) : super(key: key);

  final String? prefix;
  final ZegoUIKitUser user;
  final String message;
  final bool isHorizontal;
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
            child: RichText(
              maxLines: config?.maxLines ?? 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  if (prefix != null) prefixWidget(),
                  TextSpan(
                    text: user.name,
                    style: config?.nameTextStyle ??
                        TextStyle(
                          fontSize: 26.zR,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xffFFB763),
                        ),
                  ),
                  WidgetSpan(child: SizedBox(width: 10.zR)),
                  TextSpan(
                    text: isHorizontal ? message : '\n$message',
                    style: config?.messageTextStyle ??
                        TextStyle(
                          fontSize: 26.zR,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextSpan prefixWidget() {
    const messageHostColor = Color(0xff9f76ff);

    return TextSpan(children: [
      WidgetSpan(
        child: Transform.translate(
          offset: Offset(0, 0.zR),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 34.zR + prefix!.length * 12.zR,
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
                    prefix!,
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
    ]);
  }
}
