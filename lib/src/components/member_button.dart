// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'defines.dart';

class ZegoMemberButton extends StatefulWidget {
  const ZegoMemberButton({Key? key}) : super(key: key);

  @override
  State<ZegoMemberButton> createState() => _ZegoMemberButtonState();
}

class _ZegoMemberButtonState extends State<ZegoMemberButton> {
  var memberCountNotifier = ValueNotifier<int>(0);
  StreamSubscription<dynamic>? userListSubscription;

  @override
  void initState() {
    super.initState();

    memberCountNotifier.value = ZegoUIKit().getAllUsers().length;
    userListSubscription =
        ZegoUIKit().getUserListStream().listen(onUserListUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    userListSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 106.r,
        maxHeight: 56.r,
        minHeight: 56.r,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: zegoLiveButtonBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(28.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48.r,
              height: 48.r,
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6.r),
            SizedBox(
              height: 56.r,
              child: Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: memberCountNotifier,
                  builder: (context, memberCount, child) {
                    return Text(
                      memberCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.r,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    memberCountNotifier.value = users.length;
  }
}
