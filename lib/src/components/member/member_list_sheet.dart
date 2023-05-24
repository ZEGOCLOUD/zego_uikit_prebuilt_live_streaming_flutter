// Flutter imports:
import 'dart:async';

import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_sheet_menu.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/src/pk_impl.dart';

/// @nodoc
class ZegoMemberListSheet extends StatefulWidget {
  const ZegoMemberListSheet({
    Key? key,
    this.avatarBuilder,
    this.itemBuilder,
    required this.isPluginEnabled,
    required this.hostManager,
    required this.connectManager,
    required this.popUpManager,
    required this.translationText,
  }) : super(key: key);

  final bool isPluginEnabled;
  final ZegoLiveHostManager hostManager;
  final ZegoLiveConnectManager connectManager;
  final ZegoPopUpManager popUpManager;
  final ZegoInnerText translationText;

  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoMemberListItemBuilder? itemBuilder;

  @override
  State<ZegoMemberListSheet> createState() => _ZegoMemberListSheetState();
}

/// @nodoc
class _ZegoMemberListSheetState extends State<ZegoMemberListSheet> {
  List<String> agreeRequestingUserIDs = [];
  List<StreamSubscription<dynamic>?> subscriptions = [];

  @override
  void initState() {
    super.initState();

    subscriptions.add(
        ZegoUIKit().getAudioVideoListStream().listen(onAudioVideoListUpdated));
  }

  @override
  void dispose() {
    super.dispose();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
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
        if (!widget.hostManager.isLocalHost) {
          sortUsers.add(ZegoUIKit().getLocalUser());
        }
        sortUsers += coHostUsers;
        sortUsers += usersInRequestCoHost;
        sortUsers += remoteUsers;

        // remove other room's users
        final currentRoomUsers = ZegoUIKit().getAllUsers();
        sortUsers.removeWhere((element) {
          final targetIndex =
              currentRoomUsers.indexWhere((user) => element.id == user.id);
          return targetIndex == -1;
        });

        return sortUsers;
      },
      itemBuilder: widget.itemBuilder ??
          (
            BuildContext context,
            Size size,
            ZegoUIKitUser user,
            Map<String, dynamic> extraInfo,
          ) {
            return ValueListenableBuilder(
              valueListenable: ZegoUIKitUserPropertiesNotifier(user),
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
              },
            );
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
              Navigator.of(
                context,
                rootNavigator: widget.hostManager.config.rootNavigator,
              ).pop();
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
          extensions.add(widget.translationText.memberListRoleYou);
        }
        if (host?.id == user.id) {
          extensions.add(widget.translationText.memberListRoleHost);
        } else if (ZegoUIKit().getCameraStateNotifier(user.id).value ||
            ZegoUIKit().getMicrophoneStateNotifier(user.id).value) {
          extensions.add(widget.translationText.memberListRoleCoHost);
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
    return ValueListenableBuilder(
      valueListenable: ZegoLiveStreamingPKBattleManager().state,
      builder: (context, pkBattleState, _) {
        final needHideCoHostWidget =
            pkBattleState == ZegoLiveStreamingPKBattleState.inPKBattle ||
                pkBattleState == ZegoLiveStreamingPKBattleState.loading;
        if (needHideCoHostWidget) {
          if (widget.hostManager.isLocalHost) {
            return hostControlItem(user);
          } else {
            return Container();
          }
        } else {
          return ValueListenableBuilder<List<ZegoUIKitUser>>(
            valueListenable: widget.connectManager.requestCoHostUsersNotifier,
            builder: (context, requestCoHostUsers, _) {
              final index = requestCoHostUsers.indexWhere(
                  (requestCoHostUser) => user.id == requestCoHostUser.id);
              if (-1 != index) {
                return requestCoHostUserControlItem(user);
              } else if (widget.hostManager.isLocalHost) {
                return hostControlItem(user);
              }

              return Container();
            },
          );
        }
      },
    );
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
                  showDebugToast('error:${result.error}');
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
              if (widget.connectManager.coHostCount.value +
                      agreeRequestingUserIDs.length >=
                  widget.connectManager.maxCoHostCount) {
                widget.hostManager.config.onMaxCoHostReached
                    ?.call(widget.hostManager.config.maxCoHostCount);

                ZegoLoggerService.logInfo(
                  'co-host max count had reached',
                  tag: 'live streaming',
                  subTag: 'member list',
                );

                return;
              }
              agreeRequestingUserIDs.add(user.id);

              ZegoLoggerService.logInfo(
                'agree requesting count:${agreeRequestingUserIDs.length}',
                tag: 'live streaming',
                subTag: 'member list',
              );
              ZegoUIKit()
                  .getSignalingPlugin()
                  .acceptInvitation(inviterID: user.id, data: '')
                  .then((result) {
                ZegoLoggerService.logInfo(
                  'accept audience ${user.name} co-host request, result:$result, ',
                  tag: 'live streaming',
                  subTag: 'member list',
                );

                if (result.error == null) {
                  widget.connectManager.removeRequestCoHostUsers(user);
                } else {
                  showDebugToast('error:${result.error}');
                }
              });
            }),
      ],
    );
  }

  Widget hostControlItem(ZegoUIKitUser user) {
    return ValueListenableBuilder(
      valueListenable: ZegoLiveStreamingPKBattleManager().state,
      builder: (context, pkBattleState, _) {
        final needHideCoHostWidget =
            pkBattleState == ZegoLiveStreamingPKBattleState.inPKBattle ||
                pkBattleState == ZegoLiveStreamingPKBattleState.loading;

        final popupItems = <PopupItem>[];

        if (user.id != widget.hostManager.notifier.value?.id &&
            widget.connectManager.isCoHost(user) &&
            (widget.isPluginEnabled)) {
          popupItems.add(PopupItem(
            PopupItemValue.kickCoHost,
            widget.translationText.removeCoHostButton,
          ));
        }

        if (widget.isPluginEnabled &&
            //  not host
            user.id != widget.hostManager.notifier.value?.id &&
            !widget.connectManager.isCoHost(user) &&
            !needHideCoHostWidget) {
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
            Navigator.of(
              context,
              rootNavigator: widget.hostManager.config.rootNavigator,
            ).pop();

            showPopUpSheet(
              context: context,
              user: user,
              popupItems: popupItems,
              hostManager: widget.hostManager,
              connectManager: widget.connectManager,
              popUpManager: widget.popUpManager,
              translationText: widget.translationText,
            );
          },
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

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    agreeRequestingUserIDs.removeWhere(
        (userID) => -1 != users.indexWhere((user) => user.id == userID));
  }
}

/// @nodoc
Future<void> showMemberListSheet({
  ZegoAvatarBuilder? avatarBuilder,
  ZegoMemberListItemBuilder? itemBuilder,
  required bool isPluginEnabled,
  required BuildContext context,
  required ZegoLiveHostManager hostManager,
  required ZegoLiveConnectManager connectManager,
  required ZegoPopUpManager popUpManager,
  required ZegoInnerText translationText,
}) async {
  final key = DateTime.now().millisecondsSinceEpoch;
  popUpManager.addAPopUpSheet(key);

  return showModalBottomSheet(
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: ZegoUIKitDefaultTheme.viewBackgroundColor,
    context: context,
    useRootNavigator: hostManager.config.rootNavigator,
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
              avatarBuilder: avatarBuilder,
              itemBuilder: itemBuilder,
              isPluginEnabled: isPluginEnabled,
              hostManager: hostManager,
              connectManager: connectManager,
              popUpManager: popUpManager,
              translationText: translationText,
            ),
          ),
        ),
      );
    },
  ).then((value) {
    popUpManager.removeAPopUpSheet(key);
  });
}
