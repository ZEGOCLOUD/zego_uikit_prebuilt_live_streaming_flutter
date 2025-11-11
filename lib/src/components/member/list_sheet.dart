// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_sheet_menu.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import '../../lifecycle/instance.dart';

/// @nodoc
class ZegoLiveStreamingMemberListSheet extends StatefulWidget {
  const ZegoLiveStreamingMemberListSheet({
    Key? key,
    required this.liveID,
    required this.isCoHostEnabled,
    required this.popUpManager,
    required this.innerText,
    required this.config,
    required this.events,
    this.avatarBuilder,
    this.itemBuilder,
  }) : super(key: key);

  final String liveID;
  final bool isCoHostEnabled;
  final ZegoLiveStreamingPopUpManager popUpManager;
  final ZegoUIKitPrebuiltLiveStreamingInnerText innerText;
  final ZegoLiveStreamingMemberListConfig config;
  final ZegoLiveStreamingMemberListEvents? events;

  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoMemberListItemBuilder? itemBuilder;

  @override
  State<ZegoLiveStreamingMemberListSheet> createState() =>
      _ZegoLiveStreamingMemberListSheetState();
}

/// @nodoc
class _ZegoLiveStreamingMemberListSheetState
    extends State<ZegoLiveStreamingMemberListSheet> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          header(98.zH),
          Container(height: 1.zR, color: Colors.white.withValues(alpha: 0.15)),
          SizedBox(
            height: constraints.maxHeight - 1.zR - 98.zH,
            child: StreamBuilder<List<ZegoUIKitUser>>(
              stream: ZegoUIKit().getAudioVideoListStream(
                targetRoomID: widget.liveID,
              ),
              builder: (context, snapshot) {
                return ValueListenableBuilder<List<ZegoUIKitUser>>(
                    valueListenable: ZegoLiveStreamingPageLifeCycle()
                        .currentManagers
                        .connectManager
                        .requestCoHostUsersNotifier,
                    builder: (context, requestCoHostUsers, _) {
                      return memberListView();
                    });
              },
            ),
          ),
        ],
      );
    });
  }

  Widget memberListView() {
    return ZegoMemberList(
      roomID: widget.liveID,
      stream: ZegoUIKitPrebuiltLiveStreamingController().user.stream(
            includeFakeUser: widget.config.showFakeUser,
          ),
      showCameraState: false,
      showMicrophoneState: false,
      pseudoUsers: ZegoUIKitPrebuiltLiveStreamingController()
          .user
          .private
          .pseudoMemberListNotifier
          .value,
      sortUserList: (ZegoUIKitUser localUser, List<ZegoUIKitUser> remoteUsers) {
        /// host
        remoteUsers.removeWhere((remoteUser) =>
            ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .notifier
                .value
                ?.id ==
            remoteUser.id);

        /// co-host
        final coHostUsers = <ZegoUIKitUser>[];
        remoteUsers.removeWhere(
          (remoteUser) {
            if (ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .connectManager
                .isCoHost(remoteUser)) {
              coHostUsers.add(remoteUser);
              return true;
            }
            return false;
          },
        );

        /// requesting co-host
        final usersInRequestCoHost = <ZegoUIKitUser>[];
        remoteUsers.removeWhere(
          (remoteUser) {
            if (isUserInRequestCoHost(remoteUser.id)) {
              usersInRequestCoHost.add(remoteUser);
              return true;
            }
            return false;
          },
        );

        var sortUsers = <ZegoUIKitUser>[];
        if (ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .notifier
                .value !=
            null) {
          sortUsers.add(ZegoLiveStreamingPageLifeCycle()
              .currentManagers
              .hostManager
              .notifier
              .value!);
        }
        if (!ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .hostManager
            .isLocalHost) {
          sortUsers.add(ZegoUIKit().getLocalUser());
        }
        sortUsers += coHostUsers;
        sortUsers += usersInRequestCoHost;
        sortUsers += remoteUsers;

        /// remove other room's users
        final currentRoomUsers = ZegoUIKit().getAllUsers(
          targetRoomID: widget.liveID,
        );
        sortUsers.removeWhere((targetUser) {
          if (ZegoUIKitPrebuiltLiveStreamingController()
              .user
              .private
              .isPseudoMember(targetUser)) {
            /// skip pseudo member
            return false;
          }

          final targetIndex =
              currentRoomUsers.indexWhere((user) => targetUser.id == user.id);
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
              valueListenable: ZegoUIKitUserPropertiesNotifier(
                roomID: widget.liveID,
                user,
              ),
              builder: (context, _, __) {
                return GestureDetector(
                  onTap: () {
                    widget.events?.onClicked?.call(user);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 36.zR),
                    child: Row(
                      children: [
                        avatarItem(context, user, widget.avatarBuilder),
                        SizedBox(width: 24.zR),
                        userNameItem(user),
                        const Expanded(child: SizedBox()),
                        controlsItem(user),
                      ],
                    ),
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
                rootNavigator: ZegoLiveStreamingPageLifeCycle()
                        .currentManagers
                        .hostManager
                        .config
                        ?.rootNavigator ??
                    false,
              ).pop();
            },
            child: SizedBox(
              width: 70.zR,
              height: 70.zR,
              child:
                  ZegoLiveStreamingImage.asset(ZegoLiveStreamingIconUrls.back),
            ),
          ),
          SizedBox(width: 10.zR),
          StreamBuilder<List<ZegoUIKitUser>>(
              stream: ZegoUIKit().getUserListStream(
                targetRoomID: widget.liveID,
              ),
              builder: (context, snapshot) {
                return Text(
                  '${widget.innerText.memberListTitle} '
                  '(${ZegoUIKit().getAllUsers(
                        targetRoomID: widget.liveID,
                      ).length})',
                  style: TextStyle(
                    fontSize: 36.0.zR,
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
      valueListenable:
          ZegoLiveStreamingPageLifeCycle().currentManagers.hostManager.notifier,
      builder: (context, host, _) {
        final extensions = <String>[];
        if (ZegoUIKit().getLocalUser().id == user.id) {
          extensions.add(widget.innerText.memberListRoleYou);
        }
        if (host?.id == user.id) {
          extensions.add(widget.innerText.memberListRoleHost);
        } else if (ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .connectManager
            .isCoHost(user)) {
          extensions.add(widget.innerText.memberListRoleCoHost);
        }

        final extensionTextStyle = TextStyle(
          fontSize: 32.0.zR,
          color: const Color(0xffA7A6B7),
          decoration: TextDecoration.none,
        );
        var nameConstraintSize = Size(240.zR, 40.zR);
        if (extensions.isNotEmpty && isUserInRequestCoHost(user.id)) {
          //  ellipsis name if overflow
          nameConstraintSize = Size(
              nameConstraintSize.width -
                  5.zR -
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
                  fontSize: 32.0.zR,
                  color: const Color(0xffffffff),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(width: 5.zR),
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
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state,
      builder: (context, isInPK, _) {
        final needHideCoHostWidget = isInPK;
        if (needHideCoHostWidget) {
          if (ZegoLiveStreamingPageLifeCycle()
              .currentManagers
              .hostManager
              .isLocalHost) {
            return hostControlItem(user);
          } else {
            return Container();
          }
        } else {
          return ValueListenableBuilder<List<ZegoUIKitUser>>(
            valueListenable: ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .connectManager
                .requestCoHostUsersNotifier,
            builder: (context, requestCoHostUsers, _) {
              final index = requestCoHostUsers.indexWhere(
                  (requestCoHostUser) => user.id == requestCoHostUser.id);
              if (-1 != index) {
                return requestCoHostUserControlItem(user);
              } else if (ZegoLiveStreamingPageLifeCycle()
                  .currentManagers
                  .hostManager
                  .isLocalHost) {
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
          text: widget.innerText.disagreeButton,
          backgroundColor: const Color(0xffA7A6B7),
          onPressed: () {
            ZegoUIKitPrebuiltLiveStreamingController()
                .coHost
                .hostRejectCoHostRequest(user);
          },
        ),
        SizedBox(width: 12.zR),
        controlButton(
          text: widget.innerText.agreeButton,
          gradient: const LinearGradient(
            colors: [Color(0xffA754FF), Color(0xff510DF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onPressed: () {
            ZegoUIKitPrebuiltLiveStreamingController()
                .coHost
                .hostAgreeCoHostRequest(user);
          },
        ),
      ],
    );
  }

  Widget hostControlItem(ZegoUIKitUser user) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state,
      builder: (context, isInPK, _) {
        final needHideCoHostWidget = isInPK;

        final popupItems = <ZegoLiveStreamingPopupItem>[];
        if (user.id !=
                ZegoLiveStreamingPageLifeCycle()
                    .currentManagers
                    .hostManager
                    .notifier
                    .value
                    ?.id &&
            ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .connectManager
                .isCoHost(user) &&
            (widget.isCoHostEnabled)) {
          popupItems.add(ZegoLiveStreamingPopupItem(
            ZegoLiveStreamingPopupItemValue.kickCoHost,
            widget.innerText.removeCoHostButton,
          ));
        }

        if (widget.isCoHostEnabled &&
            //  not host
            user.id !=
                ZegoLiveStreamingPageLifeCycle()
                    .currentManagers
                    .hostManager
                    .notifier
                    .value
                    ?.id &&
            !ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .connectManager
                .isCoHost(user) &&
            !needHideCoHostWidget) {
          popupItems.add(ZegoLiveStreamingPopupItem(
              ZegoLiveStreamingPopupItemValue.inviteConnect,
              widget.innerText.inviteCoHostButton.replaceFirst(
                  ZegoUIKitPrebuiltLiveStreamingInnerText.param_1, user.name)));
        }

        if (user.id !=
            ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .notifier
                .value
                ?.id) {
          popupItems.add(ZegoLiveStreamingPopupItem(
              ZegoLiveStreamingPopupItemValue.kickOutAttendance,
              widget.innerText.removeUserMenuDialogButton.replaceFirst(
                  ZegoUIKitPrebuiltLiveStreamingInnerText.param_1, user.name)));
        }

        if (popupItems.isEmpty) {
          return Container();
        }

        popupItems.add(ZegoLiveStreamingPopupItem(
          ZegoLiveStreamingPopupItemValue.cancel,
          widget.innerText.cancelMenuDialogButton,
        ));

        return ZegoTextIconButton(
          buttonSize: Size(60.zR, 60.zR),
          iconSize: Size(60.zR, 60.zR),
          icon: ButtonIcon(
            icon: ZegoLiveStreamingImage.asset(
                ZegoLiveStreamingIconUrls.memberMore),
          ),
          onPressed: () {
            /// product manager say close sheet together
            Navigator.of(
              context,
              rootNavigator: ZegoLiveStreamingPageLifeCycle()
                      .currentManagers
                      .hostManager
                      .config
                      ?.rootNavigator ??
                  false,
            ).pop();

            showPopUpSheet(
              context: context,
              liveID: widget.liveID,
              user: user,
              popupItems: popupItems,
              hostManager:
                  ZegoLiveStreamingPageLifeCycle().currentManagers.hostManager,
              connectManager: ZegoLiveStreamingPageLifeCycle()
                  .currentManagers
                  .connectManager,
              popUpManager: widget.popUpManager,
              translationText: widget.innerText,
            );
          },
        );
      },
    );
  }

  Widget popupMenuWidget(String text) {
    return Container(
      width: 630.zR,
      height: 98.zR,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44.zR),
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
            fontSize: 28.zR,
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
      constraints: BoxConstraints.loose(Size(165.zR, 64.zR)),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(32.zR),
            gradient: gradient,
          ),
          child: Align(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 28.zR,
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
      width: 92.zR,
      height: 92.zR,
      decoration:
          const BoxDecoration(color: Color(0xffDBDDE3), shape: BoxShape.circle),
      child: Center(
        child: builder?.call(context, Size(92.zR, 92.zR), user, {}) ??
            Text(
              user.name.isNotEmpty ? user.name.characters.first : '',
              style: TextStyle(
                fontSize: 32.0.zR,
                color: const Color(0xff222222),
                decoration: TextDecoration.none,
              ),
            ),
      ),
    );
  }

  bool isUserInRequestCoHost(String userID) {
    return -1 !=
        ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .connectManager
            .requestCoHostUsersNotifier
            .value
            .indexWhere((requestCoHostUser) => userID == requestCoHostUser.id);
  }
}

/// @nodoc
Future<void> showMemberListSheet({
  ZegoAvatarBuilder? avatarBuilder,
  ZegoMemberListItemBuilder? itemBuilder,
  required String liveID,
  required bool isCoHostEnabled,
  required BuildContext context,
  required ZegoLiveStreamingPopUpManager popUpManager,
  required ZegoUIKitPrebuiltLiveStreamingConfig? liveConfig,
  required ZegoLiveStreamingMemberListConfig config,
  required ZegoLiveStreamingMemberListEvents? events,
  required ZegoUIKitPrebuiltLiveStreamingInnerText translationText,
}) async {
  final key = DateTime.now().millisecondsSinceEpoch;
  popUpManager.addAPopUpSheet(key);

  return showModalBottomSheet(
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: ZegoUIKitDefaultTheme.viewBackgroundColor,
    context: context,
    useRootNavigator: liveConfig?.rootNavigator ?? false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0.zR),
        topRight: Radius.circular(32.0.zR),
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
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ZegoLiveStreamingMemberListSheet(
                liveID: liveID,
                config: config,
                events: events,
                isCoHostEnabled: isCoHostEnabled,
                popUpManager: popUpManager,
                innerText: translationText,
                avatarBuilder: avatarBuilder,
                itemBuilder: itemBuilder,
              ),
            ),
          ),
        ),
      );
    },
  ).then((value) {
    popUpManager.removeAPopUpSheet(key);
  });
}
