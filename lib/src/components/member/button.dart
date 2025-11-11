// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/member/list_sheet.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/instance.dart';

/// @nodoc
class ZegoLiveStreamingMemberButton extends StatefulWidget {
  const ZegoLiveStreamingMemberButton({
    Key? key,
    required this.liveID,
    required this.isCoHostEnabled,
    required this.popUpManager,
    required this.translationText,
    required this.config,
    required this.events,
    required this.liveConfig,
    this.avatarBuilder,
    this.itemBuilder,
    this.icon,
    this.builder,
    this.backgroundColor,
  }) : super(key: key);

  /// If you want to redefine the entire button, you can return your own Widget through [builder].
  final Widget Function(int)? builder;

  /// Customize the icon through [icon], with Icons.person being the default if not set.
  final Widget? icon;

  /// Customize the background color through [backgroundColor]
  final Color? backgroundColor;

  final String liveID;
  final bool isCoHostEnabled;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoMemberListItemBuilder? itemBuilder;
  final ZegoLiveStreamingPopUpManager popUpManager;
  final ZegoUIKitPrebuiltLiveStreamingInnerText translationText;
  final ZegoUIKitPrebuiltLiveStreamingConfig? liveConfig;
  final ZegoLiveStreamingMemberListConfig config;
  final ZegoLiveStreamingMemberListEvents? events;

  @override
  State<ZegoLiveStreamingMemberButton> createState() =>
      _ZegoLiveStreamingMemberButtonState();
}

/// @nodoc
class _ZegoLiveStreamingMemberButtonState
    extends State<ZegoLiveStreamingMemberButton> {
  var redPointNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    onRequestCoHostUsersUpdated();
    ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .connectManager
        .requestCoHostUsersNotifier
        .addListener(onRequestCoHostUsersUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .connectManager
        .requestCoHostUsersNotifier
        .removeListener(onRequestCoHostUsersUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMemberListSheet(
          context: context,
          liveID: widget.liveID,
          config: widget.config,
          events: widget.events,
          liveConfig: widget.liveConfig,
          isCoHostEnabled: widget.isCoHostEnabled,
          popUpManager: widget.popUpManager,
          translationText: widget.translationText,
          avatarBuilder: widget.avatarBuilder,
          itemBuilder: widget.itemBuilder,
        );
      },
      child: null == widget.builder
          ? Stack(
              children: [
                Container(
                  width: 106.zR,
                  height: 56.zR,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ??
                        ZegoUIKitDefaultTheme.buttonBackgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(28.zR)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon(),
                      SizedBox(width: 6.zR),
                      memberCount(),
                    ],
                  ),
                ),
                redPoint(),
              ],
            )
          : ValueListenableBuilder<int>(
              valueListenable:
                  ZegoUIKitPrebuiltLiveStreamingController().user.countNotifier,
              builder: (context, memberCount, _) {
                return widget.builder!.call(memberCount);
              },
            ),
    );
  }

  Widget redPoint() {
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state,
      builder: (context, isInPK, _) {
        final needHideCoHostWidget = isInPK;

        if (needHideCoHostWidget) {
          return Container();
        } else {
          return Positioned(
            top: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: redPointNotifier,
              builder: (context, visibility, _) {
                if (!visibility) {
                  return Container();
                }

                return Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  width: 20.zR,
                  height: 20.zR,
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget icon() {
    return SizedBox(
      width: 48.zR,
      height: 48.zR,
      child: widget.icon ??
          const Icon(
            Icons.person,
            color: Colors.white,
          ),
    );
  }

  Widget memberCount() {
    return SizedBox(
      height: 56.zR,
      child: Center(
        child: ValueListenableBuilder<int>(
          valueListenable:
              ZegoUIKitPrebuiltLiveStreamingController().user.countNotifier,
          builder: (context, memberCount, _) {
            return Text(
              memberCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.zR,
                fontWeight: FontWeight.w400,
              ),
            );
          },
        ),
      ),
    );
  }

  void onRequestCoHostUsersUpdated() {
    redPointNotifier.value = ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .connectManager
        .requestCoHostUsersNotifier
        .value
        .isNotEmpty;
  }
}
