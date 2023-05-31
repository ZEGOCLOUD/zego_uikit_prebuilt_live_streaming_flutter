// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
Size get zegoLiveButtonSize => Size(72.zR, 72.zR);

/// @nodoc
Size get zegoLiveButtonIconSize => Size(40.zR, 40.zR);

/// @nodoc
SizedBox get zegoLiveButtonPadding =>
    SizedBox.fromSize(size: Size.fromRadius(8.zR));

/// @nodoc
enum PopupItemValue {
  inviteConnect,
  kickCoHost,
  kickOutAttendance,
  cancel,
}

/// @nodoc
class PopupItem {
  final PopupItemValue value;
  final String text;

  const PopupItem(this.value, this.text);
}

/// @nodoc
bool isRTL(BuildContext context) {
  return Directionality.of(context) == TextDirection.rtl;
}
