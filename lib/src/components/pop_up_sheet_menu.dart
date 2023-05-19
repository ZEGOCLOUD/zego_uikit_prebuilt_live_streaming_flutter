// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/src/pk_impl.dart';

/// @nodoc
class ZegoPopUpSheetMenu extends StatefulWidget {
  const ZegoPopUpSheetMenu({
    Key? key,
    required this.targetUser,
    required this.popupItems,
    required this.translationText,
    required this.hostManager,
    required this.connectManager,
    this.onPressed,
  }) : super(key: key);

  final List<PopupItem> popupItems;
  final ZegoUIKitUser targetUser;
  final ZegoLiveHostManager hostManager;
  final ZegoLiveConnectManager connectManager;
  final void Function(PopupItemValue)? onPressed;
  final ZegoInnerText translationText;

  @override
  State<ZegoPopUpSheetMenu> createState() => _ZegoPopUpSheetMenuState();
}

/// @nodoc
class _ZegoPopUpSheetMenuState extends State<ZegoPopUpSheetMenu> {
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

  Widget popUpItemWidget(int index, PopupItem popupItem) {
    return GestureDetector(
      onTap: () {
        ZegoLoggerService.logInfo(
          '[pop-up sheet] click ${popupItem.text}',
          tag: 'live streaming',
          subTag: 'pop-up sheet',
        );

        switch (popupItem.value) {
          case PopupItemValue.kickCoHost:
            widget.connectManager.kickCoHost(widget.targetUser);
            break;
          case PopupItemValue.inviteConnect:
            final pkBattleState =
                ZegoLiveStreamingPKBattleManager().state.value;
            final needHideCoHostWidget =
                pkBattleState == ZegoLiveStreamingPKBattleState.inPKBattle ||
                    pkBattleState == ZegoLiveStreamingPKBattleState.loading;
            if (needHideCoHostWidget) {
              break;
            }

            if (widget.connectManager.isMaxCoHostReached) {
              widget.hostManager.config.onMaxCoHostReached
                  ?.call(widget.hostManager.config.maxCoHostCount);

              ZegoLoggerService.logInfo(
                'co-host max count had reached',
                tag: 'live streaming',
                subTag: 'pop-up sheet',
              );

              break;
            }

            final targetUserIsInviting = widget
                .connectManager.audienceIDsOfInvitingConnect
                .contains(widget.targetUser.id);
            final targetUserIsRequesting = -1 !=
                widget.connectManager.requestCoHostUsersNotifier.value
                    .indexWhere((user) => user.id == widget.targetUser.id);
            if (targetUserIsInviting || targetUserIsRequesting) {
              showError(widget.translationText.repeatInviteCoHostFailedToast);
            } else {
              widget.connectManager.inviteAudienceConnect(widget.targetUser);
            }
            break;
          case PopupItemValue.kickOutAttendance:
            ZegoUIKit()
                .removeUserFromRoom([widget.targetUser.id]).then((result) {
              ZegoLoggerService.logInfo(
                'kick out result:$result',
                tag: 'live streaming',
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
        height: 100.r,
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
              fontSize: 28.r,
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
  required List<PopupItem> popupItems,
  required ZegoInnerText translationText,
  required ZegoLiveConnectManager connectManager,
  required ZegoPopUpManager popUpManager,
  required ZegoLiveHostManager hostManager,
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
        topLeft: Radius.circular(32.0.r),
        topRight: Radius.circular(32.0.r),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 50),
        child: Container(
          height: (popupItems.length * 101).r,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: ZegoPopUpSheetMenu(
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
