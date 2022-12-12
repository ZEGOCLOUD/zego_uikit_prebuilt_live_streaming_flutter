// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// size
get zegoLiveButtonSize => Size(72.r, 72.r);

get zegoLiveButtonIconSize => Size(40.r, 40.r);

get zegoLiveButtonPadding => SizedBox.fromSize(size: Size.fromRadius(8.r));

Size getTextSize(String text, TextStyle textStyle) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

enum PopupItemValue {
  inviteConnect,
  kickCoHost,
  kickOutAttendance,
  cancel,
}

class PopupItem {
  final PopupItemValue value;
  final String text;

  const PopupItem(this.value, this.text);
}
