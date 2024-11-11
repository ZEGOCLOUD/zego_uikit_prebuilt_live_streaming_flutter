// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/components.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/leave_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pip_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_button.dart';

/// @nodoc
class ZegoLiveStreamingTopBar extends StatefulWidget {
  final bool isCoHostEnabled;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingEvents events;
  final void Function(ZegoLiveStreamingEndEvent event) defaultEndAction;
  final Future<bool> Function(
    ZegoLiveStreamingLeaveConfirmationEvent event,
  ) defaultLeaveConfirmationAction;

  final ZegoLiveStreamingHostManager hostManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;

  final ZegoLiveStreamingConnectManager connectManager;
  final ZegoLiveStreamingPopUpManager popUpManager;

  final ZegoUIKitPrebuiltLiveStreamingInnerText translationText;

  final ValueNotifier<bool>? isLeaveRequestingNotifier;

  const ZegoLiveStreamingTopBar({
    Key? key,
    required this.isCoHostEnabled,
    required this.config,
    required this.events,
    required this.defaultEndAction,
    required this.defaultLeaveConfirmationAction,
    required this.hostManager,
    required this.hostUpdateEnabledNotifier,
    required this.connectManager,
    required this.popUpManager,
    required this.translationText,
    this.isLeaveRequestingNotifier,
  }) : super(key: key);

  @override
  State<ZegoLiveStreamingTopBar> createState() =>
      _ZegoLiveStreamingTopBarState();
}

/// @nodoc
class _ZegoLiveStreamingTopBarState extends State<ZegoLiveStreamingTopBar> {
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
      margin: widget.config.topMenuBar.margin,
      padding: widget.config.topMenuBar.padding,
      decoration: BoxDecoration(
        color: widget.config.topMenuBar.backgroundColor ?? Colors.transparent,
      ),
      height: widget.config.topMenuBar.height ?? 80.zR,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          hostAvatar(),
          const Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...pipButton(),
              ...minimizingButton(),
              ZegoLiveStreamingMemberButton(
                config: widget.config.memberList,
                events: widget.events.memberList,
                isCoHostEnabled: widget.isCoHostEnabled,
                hostManager: widget.hostManager,
                connectManager: widget.connectManager,
                popUpManager: widget.popUpManager,
                translationText: widget.translationText,
                builder: widget.config.memberButton.builder,
                icon: widget.config.memberButton.icon,
                backgroundColor: widget.config.memberButton.backgroundColor,
                avatarBuilder: widget.config.avatarBuilder,
                itemBuilder: widget.config.memberList.itemBuilder,
              ),
              SizedBox(width: 20.zR),
              ...closeButton(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> minimizingButton() {
    return widget.config.topMenuBar.buttons
            .contains(ZegoLiveStreamingMenuBarButtonName.minimizingButton)
        ? [
            ZegoLiveStreamingMinimizingButton(
              buttonSize: Size(52.zR, 52.zR),
              iconSize: Size(24.zR, 24.zR),
            ),
            SizedBox(width: 20.zR),
          ]
        : [
            Container(),
          ];
  }

  List<Widget> pipButton() {
    return widget.config.topMenuBar.buttons
            .contains(ZegoLiveStreamingMenuBarButtonName.pipButton)
        ? [
            ZegoLiveStreamingPIPButton(
              buttonSize: Size(52.zR, 52.zR),
              iconSize: Size(24.zR, 24.zR),
              aspectWidth: widget.config.pip.aspectWidth,
              aspectHeight: widget.config.pip.aspectHeight,
            ),
            SizedBox(width: 20.zR),
          ]
        : [
            Container(),
          ];
  }

  List<Widget> closeButton() {
    return widget.config.topMenuBar.showCloseButton
        ? [
            ZegoLiveStreamingLeaveButton(
              buttonSize: Size(52.zR, 52.zR),
              iconSize: Size(24.zR, 24.zR),
              icon: ButtonIcon(
                icon: const Icon(Icons.close, color: Colors.white),
                backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
              ),
              config: widget.config,
              events: widget.events,
              defaultEndAction: widget.defaultEndAction,
              defaultLeaveConfirmationAction:
                  widget.defaultLeaveConfirmationAction,
              hostManager: widget.hostManager,
              hostUpdateEnabledNotifier: widget.hostUpdateEnabledNotifier,
              isLeaveRequestingNotifier: widget.isLeaveRequestingNotifier,
            ),
            SizedBox(width: 33.zR),
          ]
        : [
            Container(),
          ];
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
                widget.events.topMenuBar.onHostAvatarClicked?.call(host);
              },
              child: widget.config.topMenuBar.hostAvatarBuilder?.call(host) ??
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
