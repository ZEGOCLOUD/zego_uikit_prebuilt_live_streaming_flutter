// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

class ZegoCoHostControlButton extends StatefulWidget {
  const ZegoCoHostControlButton({
    Key? key,
  }) : super(key: key);

  @override
  State<ZegoCoHostControlButton> createState() =>
      _ZegoCoHostControlButtonState();
}

class _ZegoCoHostControlButtonState extends State<ZegoCoHostControlButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  todo
    return Container();
    // 未申请连麦时显示ZegoRequestCoHostButton；
    // 申请连麦但未通过时显示ZegoCancelRequestCoHostButton；
    // 正在连麦显示ZegoEndCoHostButton。
  }

  Widget requestCoHostButton() {
    return ZegoTextIconButton(
      onPressed: () {
        //
      },
      buttonSize: Size(330.r, 72.r),
      iconSize: Size(48.r, 48.r),
      iconTextSpacing: 12.r,
      icon: ButtonIcon(
        icon: PrebuiltLiveStreamingImage.asset(
            PrebuiltLiveStreamingIconUrls.toolbarCoHost),
        backgroundColor: Colors.transparent,
      ),
      iconBorderColor: Colors.transparent,
      text: "Apply to connect",
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 26.r,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget cancelRequestCoHostButton() {
    //  todo
    return Container();
  }

  Widget endCoHostButton() {
    //  todo
    return Container();
  }
}
