// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';

/// @nodoc
class ZegoLiveStreamingPopUpSheetMenu extends StatefulWidget {
  const ZegoLiveStreamingPopUpSheetMenu({
    Key? key,
    required this.targetUser,
    required this.popupItems,
    required this.translationText,
    required this.hostManager,
    required this.connectManager,
    this.onPressed,
  }) : super(key: key);

  final List<ZegoLiveStreamingPopupItem> popupItems;
  final ZegoUIKitUser targetUser;
  final ZegoLiveStreamingHostManager hostManager;
  final ZegoLiveStreamingConnectManager connectManager;
  final void Function(ZegoLiveStreamingPopupItemValue)? onPressed;
  final ZegoUIKitPrebuiltLiveStreamingInnerText translationText;

  @override
  State<ZegoLiveStreamingPopUpSheetMenu> createState() =>
      _ZegoLiveStreamingPopUpSheetMenuState();
}

/// @nodoc
class _ZegoLiveStreamingPopUpSheetMenuState
    extends State<ZegoLiveStreamingPopUpSheetMenu> {
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
    return LayoutBuilder(builder: (context, constraints) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.popupItems.length,
          itemBuilder: (context, index) {
            final popupItem = widget.popupItems[index];
            return popUpItemWidget(index, popupItem);
          },
        ),
      );
    });
  }

  Widget popUpItemWidget(int index, ZegoLiveStreamingPopupItem popupItem) {
    return GestureDetector(
      onTap: () {
        ZegoLoggerService.logInfo(
          '[pop-up sheet] click ${popupItem.text}',
          tag: 'live-streaming',
          subTag: 'pop-up sheet',
        );

        final isPseudoMember = ZegoUIKitPrebuiltLiveStreamingController()
            .user
            .private
            .isPseudoMember(widget.targetUser);
        switch (popupItem.value) {
          case ZegoLiveStreamingPopupItemValue.kickCoHost:
            if (isPseudoMember) {
              /// pseudo user can't be co-host
              ZegoLoggerService.logInfo(
                'pseudo user, ignore',
                tag: 'live-streaming',
                subTag: 'pop-up sheet',
              );
              break;
            }

            ZegoUIKitPrebuiltLiveStreamingController()
                .coHost
                .removeCoHost(widget.targetUser);
            break;
          case ZegoLiveStreamingPopupItemValue.inviteConnect:
            if (isPseudoMember) {
              /// pseudo user can't be co-host
              ZegoLoggerService.logInfo(
                'pseudo user, ignore',
                tag: 'live-streaming',
                subTag: 'pop-up sheet',
              );
              break;
            }

            ZegoUIKitPrebuiltLiveStreamingController()
                .coHost
                .hostSendCoHostInvitationToAudience(
                  widget.targetUser,
                  withToast: true,
                  timeoutSecond:
                      widget.connectManager.config.coHost.inviteTimeoutSecond,
                );
            break;
          case ZegoLiveStreamingPopupItemValue.kickOutAttendance:
            if (isPseudoMember) {
              ZegoLoggerService.logInfo(
                'pseudo user, remove',
                tag: 'live-streaming',
                subTag: 'pop-up sheet',
              );
              ZegoUIKitPrebuiltLiveStreamingController()
                  .user
                  .removeFakeUser(widget.targetUser);
              break;
            }

            ZegoUIKit()
                .removeUserFromRoom([widget.targetUser.id]).then((result) {
              ZegoLoggerService.logInfo(
                'kick out result:$result',
                tag: 'live-streaming',
                subTag: 'pop-up sheet',
              );
            });
            break;
          default:
            break;
        }

        widget.onPressed?.call(popupItem.value);

        Navigator.of(
          context,
          rootNavigator: widget.connectManager.config.rootNavigator,
        ).pop();
      },
      child: Container(
        width: double.infinity,
        height: 100.zR,
        decoration: BoxDecoration(
          border: (index == (widget.popupItems.length - 1))
              ? null
              : Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
        ),
        child: Center(
          child: Text(
            popupItem.text,
            style: TextStyle(
              fontSize: 28.zR,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showPopUpSheet({
  required BuildContext context,
  required ZegoUIKitUser user,
  required List<ZegoLiveStreamingPopupItem> popupItems,
  required ZegoUIKitPrebuiltLiveStreamingInnerText translationText,
  required ZegoLiveStreamingConnectManager connectManager,
  required ZegoLiveStreamingPopUpManager popUpManager,
  required ZegoLiveStreamingHostManager hostManager,
}) async {
  final key = DateTime.now().millisecondsSinceEpoch;
  popUpManager.addAPopUpSheet(key);

  return showModalBottomSheet(
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: const Color(0xff111014),
    //ZegoUIKitDefaultTheme.viewBackgroundColor,
    context: context,
    useRootNavigator: connectManager.config.rootNavigator,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0.zR),
        topRight: Radius.circular(32.0.zR),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 50),
        child: Container(
          height: (popupItems.length * 101).zR,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: ZegoLiveStreamingPopUpSheetMenu(
            targetUser: user,
            popupItems: popupItems,
            translationText: translationText,
            hostManager: hostManager,
            connectManager: connectManager,
          ),
        ),
      );
    },
  ).then((value) {
    popUpManager.removeAPopUpSheet(key);
  });
}
