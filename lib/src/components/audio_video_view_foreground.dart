// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_sheet_menu.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';

/// @nodoc
class ZegoLiveStreamingAudioVideoForeground extends StatelessWidget {
  final Size size;

  final String liveID;
  final ZegoUIKitUser? user;

  final ZegoLiveStreamingPopUpManager popUpManager;
  final ZegoUIKitPrebuiltLiveStreamingInnerText translationText;

  final bool showMicrophoneStateOnView;
  final bool showCameraStateOnView;
  final bool showUserNameOnView;

  const ZegoLiveStreamingAudioVideoForeground({
    super.key,
    this.user,
    required this.liveID,
    required this.size,
    required this.popUpManager,
    required this.translationText,
    this.showMicrophoneStateOnView = true,
    this.showCameraStateOnView = true,
    this.showUserNameOnView = true,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Container(color: Colors.transparent);
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(3.zR),
              padding: EdgeInsets.all(3.zR),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  userName(
                    context,
                    constraints.maxWidth * 0.7,
                  ),
                  microphoneStateIcon(),
                  cameraStateIcon(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            right: 0.0,
            child: audioVideoViewForegroundControlButton(
              context,
              user,
              constraints.maxWidth,
              constraints.maxHeight,
            ),
          ),
        ],
      );
    });
  }

  Widget userName(BuildContext context, double maxWidth) {
    return showUserNameOnView
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Text(
              user?.name ?? '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22.0.zR,
                color: const Color(0xffffffff),
                decoration: TextDecoration.none,
              ),
            ),
          )
        : const SizedBox();
  }

  Widget microphoneStateIcon() {
    if (!showMicrophoneStateOnView) {
      return const SizedBox();
    }

    return SizedBox(
      width: 20.zR,
      height: 33.zR,
      child: ZegoMicrophoneStateIcon(roomID: liveID, targetUser: user),
    );
  }

  Widget cameraStateIcon() {
    if (!showCameraStateOnView) {
      return const SizedBox();
    }

    return SizedBox(
      width: 20.zR,
      height: 33.zR,
      child: ZegoCameraStateIcon(roomID: liveID, targetUser: user),
    );
  }

  Widget audioVideoViewForegroundControlButton(
    BuildContext context,
    ZegoUIKitUser? user,
    double maxWidth,
    double maxHeight,
  ) {
    if (!ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .hostManager
            .isLocalHost ||
        user == null ||
        user.id ==
            ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .notifier
                .value
                ?.id) {
      return Container();
    }

    final popupItems = <ZegoLiveStreamingPopupItem>[];

    if (popupItems.isEmpty) {
      return Container();
    }

    popupItems.add(ZegoLiveStreamingPopupItem(
      ZegoLiveStreamingPopupItemValue.cancel,
      translationText.cancelMenuDialogButton,
    ));

    return GestureDetector(
      onTap: () {
        showPopUpSheet(
          context: context,
          liveID: liveID,
          user: user,
          popupItems: popupItems,
          hostManager:
              ZegoLiveStreamingPageLifeCycle().currentManagers.hostManager,
          connectManager:
              ZegoLiveStreamingPageLifeCycle().currentManagers.connectManager,
          popUpManager: popUpManager,
          translationText: translationText,
        );
      },
      child: Container(
        color: Colors.transparent,
        //  need for click
        width: maxWidth,
        height: maxHeight * 0.33,
        padding: EdgeInsets.all(5.zR),
        child: Align(
          alignment: Alignment.topRight,
          child: ZegoTextIconButton(
            buttonSize: Size(28.zR, 28.zR),
            iconSize: Size(28.zR, 28.zR),
            icon: ButtonIcon(
              backgroundColor: Colors.black.withValues(alpha: 0.6),
              icon: ZegoLiveStreamingImage.asset(
                  ZegoLiveStreamingIconUrls.bottomBarMore),
            ),
          ),
        ),
      ),
    );
  }
}
