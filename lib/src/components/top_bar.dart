// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/components.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

class ZegoTopBar extends StatefulWidget {
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  const ZegoTopBar({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  State<ZegoTopBar> createState() => _ZegoTopBarState();
}

class _ZegoTopBarState extends State<ZegoTopBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      height: 80.r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          avatar(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const ZegoMemberButton(),
              SizedBox(width: 33.r),
              closeButton(),
              SizedBox(width: 34.r),
            ],
          )
        ],
      ),
    );
  }

  Widget closeButton() {
    var buttonSize = Size(52.r, 52.r);
    var iconSize = Size(24.r, 24.r);
    var defaultIcon = ButtonIcon(
      icon: const Icon(Icons.close, color: Colors.white),
      backgroundColor: zegoLiveButtonBackgroundColor,
    );
    return widget.config.useEndLiveStreamingButton
        ? ZegoEndButton(
            buttonSize: buttonSize,
            iconSize: iconSize,
            icon: defaultIcon,
            onEndConfirmation: onCloseConfirming,
            onPress: onClosePress,
          )
        : ZegoLeaveButton(
            buttonSize: buttonSize,
            iconSize: iconSize,
            icon: defaultIcon,
            onLeaveConfirmation: onCloseConfirming,
            onPress: onClosePress,
          );
  }

  Future<bool> onCloseConfirming(context) async {
    return await widget.config.onEndOrLeaveLiveStreamingConfirming!(context);
  }

  void onClosePress() {
    if (widget.config.onEndOrLeaveLiveStreaming != null) {
      widget.config.onEndOrLeaveLiveStreaming!.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget avatar() {
    return Row(
      children: [
        SizedBox(width: 32.r),
        SizedBox(
          height: 68.r,
          child: Container(
            child: Row(
              children: [
                SizedBox(width: 6.r),
                ZegoAvatar(
                  user: ZegoUIKit().getLocalUser(),
                  avatarSize: Size(56.r, 56.r),
                  showSoundLevel: false,
                  avatarBuilder:
                      widget.config.audioVideoViewConfig.avatarBuilder,
                ),
                SizedBox(width: 12.r),
                Text(
                  ZegoUIKit().getLocalUser().name,
                  style: TextStyle(
                    fontSize: 24.r,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 24.r),
              ],
            ),
            decoration: BoxDecoration(
              color: zegoLiveButtonBackgroundColor,
              borderRadius: BorderRadius.circular(68.r),
            ),
          ),
        ),
      ],
    );
  }
}
