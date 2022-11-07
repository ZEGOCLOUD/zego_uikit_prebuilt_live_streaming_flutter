// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/components.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_translation.dart';
import 'leave_button.dart';

class ZegoTopBar extends StatefulWidget {
  final bool isPluginEnabled;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoLiveHostManager hostManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;
  final ZegoLiveConnectManager connectManager;
  final ZegoTranslationText translationText;

  const ZegoTopBar({
    Key? key,
    required this.isPluginEnabled,
    required this.config,
    required this.hostManager,
    required this.hostUpdateEnabledNotifier,
    required this.connectManager,
    required this.translationText,
  }) : super(key: key);

  @override
  State<ZegoTopBar> createState() => _ZegoTopBarState();
}

class _ZegoTopBarState extends State<ZegoTopBar> {
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
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      height: 80.r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          avatar(),
          const Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ZegoMemberButton(
                isPluginEnabled: widget.isPluginEnabled,
                avatarBuilder: widget.config.avatarBuilder,
                hostManager: widget.hostManager,
                connectManager: widget.connectManager,
                translationText: widget.translationText,
              ),
              SizedBox(width: 33.r),
              closeButton(),
              SizedBox(width: 34.r),
            ],
          ),
        ],
      ),
    );
  }

  Widget closeButton() {
    return ZegoLeaveStreamingButton(
      buttonSize: Size(52.r, 52.r),
      iconSize: Size(24.r, 24.r),
      icon: ButtonIcon(
        icon: const Icon(Icons.close, color: Colors.white),
        backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
      ),
      config: widget.config,
      hostManager: widget.hostManager,
      hostUpdateEnabledNotifier: widget.hostUpdateEnabledNotifier,
    );
  }

  Widget avatar() {
    return ValueListenableBuilder<ZegoUIKitUser?>(
      valueListenable: widget.hostManager.notifier,
      builder: (context, host, _) {
        if (host == null) {
          return Container();
        }

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
                      user: host,
                      avatarSize: Size(56.r, 56.r),
                      showSoundLevel: false,
                      avatarBuilder: widget.config.avatarBuilder,
                    ),
                    SizedBox(width: 12.r),
                    Text(
                      host.name,
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
                  color: ZegoUIKitDefaultTheme.buttonBackgroundColor,
                  borderRadius: BorderRadius.circular(68.r),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
