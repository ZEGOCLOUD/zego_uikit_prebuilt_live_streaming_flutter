// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';

class ZegoMemberListSheet extends StatefulWidget {
  const ZegoMemberListSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<ZegoMemberListSheet> createState() => _ZegoMemberListSheetState();
}

class _ZegoMemberListSheetState extends State<ZegoMemberListSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      return Column(
        children: [
          header(98.h),
          Container(height: 1.r, color: Colors.white.withOpacity(0.15)),
          SizedBox(
            height: constraints.maxHeight - 1.r - 98.h,
            child: const ZegoMemberList(
              showCameraState: false,
              showMicrophoneState: false,
            ),
          ),
        ],
      );
    }));
  }

  Widget header(double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 70.r,
              height: 70.r,
              child: PrebuiltLiveStreamingImage.asset(
                  PrebuiltLiveStreamingIconUrls.back),
            ),
          ),
          SizedBox(width: 10.r),
          Text(
            "Member",
            style: TextStyle(
              fontSize: 36.0.r,
              color: const Color(0xffffffff),
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }
}

void showMemberListSheet(BuildContext context) {
  showModalBottomSheet(
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: ZegoUIKitDefaultTheme.viewBackgroundColor,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.85,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: const ZegoMemberListSheet(),
          ),
        ),
      );
    },
  );
}
