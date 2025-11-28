// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';

import 'enter_wave_animation.dart';

class ZegoLiveStreamingHallForeground extends StatefulWidget {
  final String liveID;
  final ZegoUIKitUser? user;

  /// Enter live streaming button event
  final void Function(String liveID) onEnterLivePressed;

  /// Inner text configuration
  final ZegoUIKitPrebuiltLiveStreamingInnerText innerText;

  final bool showUserInfo;
  final bool showLivingFlag;

  const ZegoLiveStreamingHallForeground({
    super.key,
    required this.user,
    required this.liveID,
    required this.onEnterLivePressed,
    required this.innerText,
    this.showUserInfo = true,
    this.showLivingFlag = true,
  });

  @override
  State<ZegoLiveStreamingHallForeground> createState() {
    return _ZegoLiveStreamingHallPageState();
  }
}

class _ZegoLiveStreamingHallPageState
    extends State<ZegoLiveStreamingHallForeground> {
  bool get useDebugMode => false && kDebugMode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (useDebugMode)
          Positioned(
            right: 20.zR,
            top: 120.zR,
            child: Text('live id:${widget.liveID}, host:${widget.user?.id}'),
          ),
        Positioned(
          left: 20.zR,
          right: 20.zR,
          bottom: 120.zR,
          child: joinButton(),
        ),
        if (widget.showLivingFlag)
          Positioned(left: 10.zR, bottom: 80.zR, child: livingFlag()),
        if (widget.showUserInfo)
          Positioned(left: 10.zR, bottom: 20.zR, child: userName()),
      ],
    );
  }

  Widget userName() {
    return Text(
      '@${(widget.user?.name.isEmpty ?? true) ? 'user_${widget.user?.id}' : widget.user?.name}',
      style: TextStyle(
        fontSize: 25.zR,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget livingFlag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.zR, vertical: 4.zR),
      decoration: BoxDecoration(
        color: const Color(0xFFFF69B4), // Pink
        borderRadius: BorderRadius.circular(4.zR),
      ),
      child: Text(
        widget.innerText.livingFlagText,
        style: TextStyle(
          fontSize: 25.zR,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget joinButton() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.zR),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withAlpha(70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.zR),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.zR, horizontal: 24.zR),
          ),
          onPressed: () {
            widget.onEnterLivePressed.call(widget.liveID);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZegoLiveStreamingLiveHallEnterWaveAnimation(
                size: 20.zR,
                color: Colors.white,
              ),
              SizedBox(width: 15.zR),
              Text(
                widget.innerText.enterLiveButtonText,
                style: TextStyle(
                  fontSize: 30.zR,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
