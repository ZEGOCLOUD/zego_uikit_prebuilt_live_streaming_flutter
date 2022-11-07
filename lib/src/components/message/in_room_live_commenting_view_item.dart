// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoInRoomLiveCommentingViewItem extends StatelessWidget {
  const ZegoInRoomLiveCommentingViewItem({
    Key? key,
    required this.user,
    required this.message,
    this.prefix,
    this.maxLines = 3,
    this.isHorizontal = true,
  }) : super(key: key);

  final String? prefix;
  final ZegoUIKitUser user;
  final String message;
  final int? maxLines;
  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    var messageBackgroundColor = const Color(0xff2a2a2a).withOpacity(0.5);
    var messageNameColor = const Color(0xffFFB763);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: messageBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(26.r)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.r, 10.r, 20.r, 10.r),
            child: RichText(
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  if (prefix != null) prefixWidget(),
                  TextSpan(
                    text: user.name,
                    style: TextStyle(
                      fontSize: 26.r,
                      color: messageNameColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  WidgetSpan(child: SizedBox(width: 10.r)),
                  TextSpan(
                    text: isHorizontal ? message : "\n$message",
                    style: TextStyle(
                      fontSize: 26.r,
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
    var messageHostColor = const Color(0xff9f76ff);

    return TextSpan(children: [
      WidgetSpan(
        child: Transform.translate(
          offset: Offset(0, 0.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 34.r + prefix!.length * 12.r,
              minWidth: 34.r,
              minHeight: 36.r,
              maxHeight: 36.r,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: messageHostColor,
                borderRadius: BorderRadius.all(Radius.circular(20.r)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.r, 4.r, 12.r, 4.r),
                child: Center(
                  child: Text(
                    prefix!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.r,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      WidgetSpan(child: SizedBox(width: 10.r)),
    ]);
  }
}
