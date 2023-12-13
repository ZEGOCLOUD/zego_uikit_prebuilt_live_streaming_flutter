// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/components.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/leave_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/prebuilt_data.dart';

/// @nodoc
class ZegoTopBar extends StatefulWidget {
  final bool isCoHostEnabled;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingData prebuiltData;

  final ZegoLiveHostManager hostManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;

  final ZegoLiveConnectManager connectManager;
  final ZegoPopUpManager popUpManager;
  final ZegoUIKitPrebuiltLiveStreamingController prebuiltController;

  final ZegoInnerText translationText;

  final ValueNotifier<bool>? isLeaveRequestingNotifier;

  const ZegoTopBar({
    Key? key,
    required this.isCoHostEnabled,
    required this.config,
    required this.prebuiltData,
    required this.hostManager,
    required this.hostUpdateEnabledNotifier,
    required this.connectManager,
    required this.popUpManager,
    required this.prebuiltController,
    required this.translationText,
    this.isLeaveRequestingNotifier,
  }) : super(key: key);

  @override
  State<ZegoTopBar> createState() => _ZegoTopBarState();
}

/// @nodoc
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
      margin: widget.config.topMenuBarConfig.margin,
      padding: widget.config.topMenuBarConfig.padding,
      decoration: BoxDecoration(
        color: widget.config.topMenuBarConfig.backgroundColor ??
            Colors.transparent,
      ),
      height: widget.config.topMenuBarConfig.height ?? 80.zR,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          hostAvatar(),
          const Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              minimizingButton(),
              SizedBox(width: 20.zR),
              ZegoMemberButton(
                avatarBuilder: widget.config.avatarBuilder,
                itemBuilder: widget.config.memberListConfig.itemBuilder,
                isCoHostEnabled: widget.isCoHostEnabled,
                hostManager: widget.hostManager,
                connectManager: widget.connectManager,
                popUpManager: widget.popUpManager,
                prebuiltController: widget.prebuiltController,
                translationText: widget.translationText,
                builder: widget.config.memberButtonConfig.builder,
                icon: widget.config.memberButtonConfig.icon,
                backgroundColor:
                    widget.config.memberButtonConfig.backgroundColor,
              ),
              SizedBox(width: 20.zR),
              closeButton(),
              SizedBox(width: 33.zR),
            ],
          ),
        ],
      ),
    );
  }

  Widget minimizingButton() {
    return widget.config.topMenuBarConfig.buttons
            .contains(ZegoMenuBarButtonName.minimizingButton)
        ? ZegoUIKitPrebuiltLiveStreamingMinimizingButton(
            buttonSize: Size(52.zR, 52.zR),
            iconSize: Size(24.zR, 24.zR),
          )
        : Container();
  }

  Widget closeButton() {
    return widget.config.topMenuBarConfig.showCloseButton
        ? ZegoLeaveStreamingButton(
            buttonSize: Size(52.zR, 52.zR),
            iconSize: Size(24.zR, 24.zR),
            icon: ButtonIcon(
              icon: const Icon(Icons.close, color: Colors.white),
              backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
            ),
            config: widget.config,
            hostManager: widget.hostManager,
            hostUpdateEnabledNotifier: widget.hostUpdateEnabledNotifier,
            isLeaveRequestingNotifier: widget.isLeaveRequestingNotifier,
          )
        : Container();
  }

  Widget hostAvatar() {
    return ValueListenableBuilder<ZegoUIKitUser?>(
      valueListenable: widget.hostManager.notifier,
      builder: (context, host, _) {
        if (host == null) {
          return Container();
        }

        return Row(
          children: [
            SizedBox(width: 32.zR),
            GestureDetector(
              onTap: () {
                widget.config.topMenuBarConfig.onHostAvatarClicked?.call(host);
              },
              child: widget.config.topMenuBarConfig.hostAvatarBuilder
                      ?.call(host) ??
                  SizedBox(
                    height: 68.zR,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ZegoUIKitDefaultTheme.buttonBackgroundColor,
                        borderRadius: BorderRadius.circular(68.zR),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 6.zR),
                          ZegoAvatar(
                            user: host,
                            avatarSize: Size(56.zR, 56.zR),
                            showSoundLevel: false,
                            avatarBuilder: widget.config.avatarBuilder,
                          ),
                          SizedBox(width: 12.zR),
                          Text(
                            host.name,
                            style: TextStyle(
                              fontSize: 24.zR,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 24.zR),
                        ],
                      ),
                    ),
                  ),
            ),
          ],
        );
      },
    );
  }
}
