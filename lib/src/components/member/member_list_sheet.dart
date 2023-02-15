// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_sheet_menu.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_translation.dart';

class ZegoMemberListSheet extends StatefulWidget {
  const ZegoMemberListSheet({
    Key? key,
    this.avatarBuilder,
    required this.isPluginEnabled,
    required this.hostManager,
    required this.connectManager,
    required this.translationText,
  }) : super(key: key);

  final bool isPluginEnabled;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoLiveHostManager hostManager;
  final ZegoLiveConnectManager connectManager;
  final ZegoTranslationText translationText;

  @override
  State<ZegoMemberListSheet> createState() => _ZegoMemberListSheetState();
}

class _ZegoMemberListSheetState extends State<ZegoMemberListSheet> {
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
      return Column(
        children: [
          header(98.h),
          Container(height: 1.r, color: Colors.white.withOpacity(0.15)),
          SizedBox(
            height: constraints.maxHeight - 1.r - 98.h,
            child: StreamBuilder<List<ZegoUIKitUser>>(
                stream: ZegoUIKit().getAudioVideoListStream(),
                builder: (context, snapshot) {
                  return ValueListenableBuilder<List<ZegoUIKitUser>>(
                      valueListenable:
                          widget.connectManager.requestCoHostUsersNotifier,
                      builder: (context, requestCoHostUsers, _) {
                        return memberListView();
                      });
                }),
          ),
        ],
      );
    });
  }

  bool isStreamPlaying(String userID) {
    return -1 !=
        ZegoUIKit().getAudioVideoList().indexWhere((user) => userID == user.id);
  }

  Widget memberListView() {
    return ZegoMemberList(
      showCameraState: false,
      showMicrophoneState: false,
      sortUserList: (ZegoUIKitUser localUser, List<ZegoUIKitUser> remoteUsers) {
        /// host
        remoteUsers.removeWhere((remoteUser) =>
            widget.hostManager.notifier.value?.id == remoteUser.id);

        /// co-host
        final coHostUsers = <ZegoUIKitUser>[];
        remoteUsers.removeWhere((remoteUser) {
          if (isStreamPlaying(remoteUser.id)) {
            coHostUsers.add(remoteUser);
            return true;
          }
          return false;
        });

        /// requesting co-host
        final usersInRequestCoHost = <ZegoUIKitUser>[];
        remoteUsers.removeWhere((remoteUser) {
          if (isUserInRequestCoHost(remoteUser.id)) {
            usersInRequestCoHost.add(remoteUser);
            return true;
          }
          return false;
        });

        var sortUsers = <ZegoUIKitUser>[];
        if (widget.hostManager.notifier.value != null) {
          sortUsers.add(widget.hostManager.notifier.value!);
        }
        if (!widget.hostManager.isHost) {
          sortUsers.add(ZegoUIKit().getLocalUser());
        }
        sortUsers += coHostUsers;
        sortUsers += usersInRequestCoHost;
        sortUsers += remoteUsers;

        return sortUsers;
      },
      itemBuilder:
          (BuildContext context, Size size, ZegoUIKitUser user, Map extraInfo) {
        return ValueListenableBuilder<bool>(
            valueListenable: ZegoUIKit().getCameraStateNotifier(user.id),
            builder: (context, _, __) {
              return ValueListenableBuilder<bool>(
                  valueListenable:
                      ZegoUIKit().getMicrophoneStateNotifier(user.id),
                  builder: (context, _, __) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 36.r),
                      child: Row(
                        children: [
                          avatarItem(context, user, widget.avatarBuilder),
                          SizedBox(width: 24.r),
                          userNameItem(user),
                          const Expanded(child: SizedBox()),
                          controlsItem(user),
                        ],
                      ),
                    );
                  });
            });
      },
    );
  }

  Widget header(double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 70.r,
              height: 70.r,
              child: PrebuiltLiveStreamingImage.asset(
                  PrebuiltLiveStreamingIconUrls.back),
            ),
          ),
          SizedBox(width: 10.r),
          StreamBuilder<List<ZegoUIKitUser>>(
              stream: ZegoUIKit().getUserListStream(),
              builder: (context, snapshot) {
                return Text(
                  '${widget.translationText.memberListTitle} '
                  '(${ZegoUIKit().getAllUsers().length})',
                  style: TextStyle(
                    fontSize: 36.0.r,
                    color: const Color(0xffffffff),
                    decoration: TextDecoration.none,
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget userNameItem(ZegoUIKitUser user) {
    return ValueListenableBuilder<ZegoUIKitUser?>(
      valueListenable: widget.hostManager.notifier,
      builder: (context, host, _) {
        final extensions = <String>[];
        if (ZegoUIKit().getLocalUser().id == user.id) {
          extensions.add('You');
        }
        if (host?.id == user.id) {
          extensions.add('Host');
        } else if (ZegoUIKit().getCameraStateNotifier(user.id).value ||
            ZegoUIKit().getMicrophoneStateNotifier(user.id).value) {
          extensions.add('Co-host');
        }

        final extensionTextStyle = TextStyle(
          fontSize: 32.0.r,
          color: const Color(0xffA7A6B7),
          decoration: TextDecoration.none,
        );
        var nameConstraintSize = Size(240.r, 40.r);
        if (extensions.isNotEmpty && isUserInRequestCoHost(user.id)) {
          //  ellipsis name if overflow
          nameConstraintSize = Size(
              nameConstraintSize.width -
                  5.r -
                  getTextSize(extensions.join(','), extensionTextStyle).width,
              nameConstraintSize.height);
        }

        return Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints.loose(nameConstraintSize),
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 32.0.r,
                  color: const Color(0xffffffff),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(width: 5.r),
            Text(
              extensions.isEmpty ? '' : "(${extensions.join(",")})",
              style: extensionTextStyle,
            ),
          ],
        );
      },
    );
  }

  Widget controlsItem(ZegoUIKitUser user) {
    return ValueListenableBuilder<List<ZegoUIKitUser>>(
        valueListenable: widget.connectManager.requestCoHostUsersNotifier,
        builder: (context, requestCoHostUsers, _) {
          final index = requestCoHostUsers.indexWhere(
              (requestCoHostUser) => user.id == requestCoHostUser.id);
          if (-1 != index) {
            return requestCoHostUserControlItem(user);
          } else if (widget.hostManager.isHost) {
            return hostControlItem(user);
          }

          return Container();
        });
  }

  Widget requestCoHostUserControlItem(ZegoUIKitUser user) {
    return Row(
      children: [
        controlButton(
            text: widget.translationText.disagreeButton,
            backgroundColor: const Color(0xffA7A6B7),
            onPressed: () {
              ZegoUIKit()
                  .getSignalingPlugin()
                  .refuseInvitation(inviterID: user.id, data: '')
                  .then((result) {
                ZegoLoggerService.logInfo(
                  'refuse audience ${user.name} co-host request, $result',
                  tag: 'live streaming',
                  subTag: 'member list',
                );
                if (result.error == null) {
                  widget.connectManager.removeRequestCoHostUsers(user);
                } else {
                  showError('error:${result.error}');
                }
              });
            }),
        SizedBox(width: 12.r),
        controlButton(
            text: widget.translationText.agreeButton,
            gradient: const LinearGradient(
              colors: [Color(0xffA754FF), Color(0xff510DF1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onPressed: () {
              ZegoUIKit()
                  .getSignalingPlugin()
                  .acceptInvitation(inviterID: user.id, data: '')
                  .then((result) {
                ZegoLoggerService.logInfo(
                  'accept audience ${user.name} co-host request, '
                  'result:$result',
                  tag: 'live streaming',
                  subTag: 'member list',
                );
                if (result.error == null) {
                  widget.connectManager.removeRequestCoHostUsers(user);
                } else {
                  showError('error:${result.error}');
                }
              });
            }),
      ],
    );
  }

  Widget hostControlItem(ZegoUIKitUser user) {
    final popupItems = <PopupItem>[];

    if (user.id != widget.hostManager.notifier.value?.id &&
        isCoHost(user) &&
        (widget.isPluginEnabled)) {
      popupItems.add(PopupItem(
        PopupItemValue.kickCoHost,
        widget.translationText.removeCoHostButton,
      ));
    }

    if (widget.isPluginEnabled &&
        //  not host
        user.id != widget.hostManager.notifier.value?.id &&
        !isCoHost(user)) {
      popupItems.add(PopupItem(
          PopupItemValue.inviteConnect,
          widget.translationText.inviteCoHostButton
              .replaceFirst(widget.translationText.param_1, user.name)));
    }

    if (user.id != widget.hostManager.notifier.value?.id) {
      popupItems.add(PopupItem(
          PopupItemValue.kickOutAttendance,
          widget.translationText.removeUserMenuDialogButton
              .replaceFirst(widget.translationText.param_1, user.name)));
    }

    if (popupItems.isEmpty) {
      return Container();
    }

    popupItems.add(PopupItem(
      PopupItemValue.cancel,
      widget.translationText.cancelMenuDialogButton,
    ));

    return ZegoTextIconButton(
      buttonSize: Size(60.r, 60.r),
      iconSize: Size(60.r, 60.r),
      icon: ButtonIcon(
        icon: PrebuiltLiveStreamingImage.asset(
            PrebuiltLiveStreamingIconUrls.memberMore),
      ),
      onPressed: () {
        /// product manager say close sheet together
        Navigator.of(context).pop();

        showPopUpSheet(
          context: context,
          user: user,
          popupItems: popupItems,
          connectManager: widget.connectManager,
          translationText: widget.translationText,
        );
      },
    );
  }

  Widget popupMenuWidget(String text) {
    return Container(
      width: 630.r,
      height: 98.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44.r),
        gradient: const LinearGradient(
          colors: [Color(0xffA754FF), Color(0xff510DF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Align(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.r,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget controlButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Gradient? gradient,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(165.r, 64.r)),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(32.r),
            gradient: gradient,
          ),
          child: Align(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 28.r,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget avatarItem(
    BuildContext context,
    ZegoUIKitUser user,
    ZegoAvatarBuilder? builder,
  ) {
    return Container(
      width: 92.r,
      height: 92.r,
      decoration:
          const BoxDecoration(color: Color(0xffDBDDE3), shape: BoxShape.circle),
      child: Center(
        child: builder?.call(context, Size(92.r, 92.r), user, {}) ??
            Text(
              user.name.isNotEmpty ? user.name.characters.first : '',
              style: TextStyle(
                fontSize: 32.0.r,
                color: const Color(0xff222222),
                decoration: TextDecoration.none,
              ),
            ),
      ),
    );
  }

  bool isUserInRequestCoHost(String userID) {
    return -1 !=
        widget.connectManager.requestCoHostUsersNotifier.value
            .indexWhere((requestCoHostUser) => userID == requestCoHostUser.id);
  }
}

void showMemberListSheet({
  ZegoAvatarBuilder? avatarBuilder,
  required bool isPluginEnabled,
  required BuildContext context,
  required ZegoLiveHostManager hostManager,
  required ZegoLiveConnectManager connectManager,
  required ZegoTranslationText translationText,
}) {
  showModalBottomSheet(
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: ZegoUIKitDefaultTheme.viewBackgroundColor,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0.r),
        topRight: Radius.circular(32.0.r),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.85,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ZegoMemberListSheet(
              isPluginEnabled: isPluginEnabled,
              avatarBuilder: avatarBuilder,
              hostManager: hostManager,
              connectManager: connectManager,
              translationText: translationText,
            ),
          ),
        ),
      );
    },
  );
}
