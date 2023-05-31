// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
class ZegoInRoomLiveCommentingViewItem extends StatelessWidget {
  const ZegoInRoomLiveCommentingViewItem({
    Key? key,
    required this.user,
    required this.message,
    this.prefix,
    this.maxLines = 3,
    this.isHorizontal = true,
    this.opacity = 0.5,
  }) : super(key: key);

  final String? prefix;
  final ZegoUIKitUser user;
  final String message;
  final int? maxLines;
  final bool isHorizontal;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final messageBackgroundColor = const Color(0xff2a2a2a).withOpacity(opacity);
    const messageNameColor = Color(0xffFFB763);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: messageBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(26.zR)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.zR, 10.zR, 20.zR, 10.zR),
            child: RichText(
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  if (prefix != null) prefixWidget(),
                  TextSpan(
                    text: user.name,
                    style: TextStyle(
                      fontSize: 26.zR,
                      color: messageNameColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  WidgetSpan(child: SizedBox(width: 10.zR)),
                  TextSpan(
                    text: isHorizontal ? message : '\n$message',
                    style: TextStyle(
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
