// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_translation.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/defines.dart';

class ZegoLiveConnectManager {
  ZegoLiveConnectManager({
    required this.hostManager,
    required this.liveStatusNotifier,
    required this.config,
    required this.translationText,
    required this.contextQuery,
  }) {
    listenStream();
  }
  final ZegoLiveHostManager hostManager;
  final ValueNotifier<LiveStatus> liveStatusNotifier;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final BuildContext Function() contextQuery;
  final ZegoTranslationText translationText;

  /// internal variables
  /// audience: current audience connection state, audience or co-host
  final audienceLocalConnectStateNotifier =
      ValueNotifier<ConnectState>(ConnectState.idle);

  /// host: current requesting co-host's users
  final requestCoHostUsersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  ///
  bool isInviteToJoinCoHostDlgVisible = false;
  bool isEndCoHostDialogVisible = false;

  List<String> audienceIDsOfInvitingConnect = [];
  List<StreamSubscription<dynamic>?> subscriptions = [];

  void init() {
    if (ZegoLiveStreamingRole.host == config.role &&
        hostManager.notifier.value != null &&
        hostManager.notifier.value!.id != ZegoUIKit().getLocalUser().id) {
      ZegoLoggerService.logInfo(
        'switch local to be co-host',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      updateAudienceConnectState(ConnectState.idle);
    }
  }

  void uninit() {
    audienceLocalConnectStateNotifier.value = ConnectState.idle;
    requestCoHostUsersNotifier.value = [];
    isInviteToJoinCoHostDlgVisible = false;
    isEndCoHostDialogVisible = false;
    audienceIDsOfInvitingConnect.clear();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void listenStream() {
    if (config.plugins.isNotEmpty) {
      subscriptions
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationReceivedStream()
            .listen(onInvitationReceived))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationAcceptedStream()
            .listen(onInvitationAccepted))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationCanceledStream()
            .listen(onInvitationCanceled))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationRefusedStream()
            .listen(onInvitationRefused))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationTimeoutStream()
            .listen(onInvitationTimeout))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationResponseTimeoutStream()
            .listen(onInvitationResponseTimeout));
    }
  }

  Future<bool> kickCoHost(ZegoUIKitUser coHost) async {
    ZegoLoggerService.logInfo(
      'kick-out co-host ${coHost.toString()}',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    return ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [coHost.id],
          timeout: 60,
          type: ZegoInvitationType.removeFromCoHost.value,
          data: '',
        )
        .then((result) {
      ZegoLoggerService.logInfo(
        'kick co-host ${coHost.id} ${coHost.name}, result:$result',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return result.error == null;
    });
  }

  void inviteAudienceConnect(ZegoUIKitUser invitee) async {
    ZegoLoggerService.logInfo(
      'invite audience connect, ${invitee.id} ${invitee.name}',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (audienceIDsOfInvitingConnect.contains(invitee.id)) {
      ZegoLoggerService.logInfo(
        'audience is int connect inviting',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    audienceIDsOfInvitingConnect.add(invitee.id);

    await ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [invitee.id],
          timeout: 60,
          type: ZegoInvitationType.inviteToJoinCoHost.value,
          data: '',
        )
        .then((result) {
      if (result.error != null) {
        audienceIDsOfInvitingConnect.remove(invitee.id);

        showError(translationText.inviteCoHostFailedToast);
      }
    });
  }

  void audienceEndConnect() {
    ZegoLoggerService.logInfo(
      'audience end connect',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    updateAudienceConnectState(ConnectState.idle);
  }

  void onInvitationReceived(Map params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final int type = params['type']!; // call type
    final String data = params['data']!; // extended field

    final invitationType = ZegoInvitationTypeExtension.mapValue[type]!;

    ZegoLoggerService.logInfo(
      'on invitation received, data:${inviter.toString()},'
      ' $type($invitationType) $data',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isHost) {
      if (ZegoInvitationType.requestCoHost == invitationType) {
        final translation = translationText.receivedCoHostRequestDialogInfo;
        requestCoHostUsersNotifier.value =
            List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
              ..add(inviter);

        showSuccess(translation.message
            .replaceFirst(translationText.param_1, inviter.name));
      }
    } else {
      if (ZegoInvitationType.inviteToJoinCoHost == invitationType) {
        onAudienceReceivedCoHostInvitation(inviter);
      } else if (ZegoInvitationType.removeFromCoHost == invitationType) {
        updateAudienceConnectState(ConnectState.idle);
      }
    }
  }

  void onAudienceReceivedCoHostInvitation(ZegoUIKitUser host) {
    if (isInviteToJoinCoHostDlgVisible) {
      ZegoLoggerService.logInfo(
        'invite to join co-host dialog is visibile',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    if (isCoHost(ZegoUIKit().getLocalUser())) {
      ZegoLoggerService.logInfo(
        'audience is co-host now',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    final translation = translationText.receivedCoHostInvitationDialogInfo;
    isInviteToJoinCoHostDlgVisible = true;

    showLiveDialog(
      context: contextQuery(),
      title: translation.title,
      content: translation.message,
      leftButtonText: translation.cancelButtonName,
      leftButtonCallback: () {
        isInviteToJoinCoHostDlgVisible = false;

        if (LiveStatus.living == liveStatusNotifier.value) {
          ZegoUIKit()
              .getSignalingPlugin()
              .refuseInvitation(inviterID: host.id, data: '')
              .then((result) {
            ZegoLoggerService.logInfo(
              'refuse co-host invite, result:$result',
              tag: 'live streaming',
              subTag: 'connect manager',
            );
          });
        } else {
          ZegoLoggerService.logInfo(
            'refuse co-host invite, not living now',
            tag: 'live streaming',
            subTag: 'connect manager',
          );
        }

        Navigator.of(contextQuery()).pop();
      },
      rightButtonText: translation.confirmButtonName,
      rightButtonCallback: () {
        isInviteToJoinCoHostDlgVisible = false;

        ZegoLoggerService.logInfo(
          'accept co-host invite',
          tag: 'live streaming',
          subTag: 'connect manager',
        );
        if (LiveStatus.living == liveStatusNotifier.value) {
          ZegoUIKit()
              .getSignalingPlugin()
              .acceptInvitation(inviterID: host.id, data: '')
              .then((result) {
            ZegoLoggerService.logInfo(
              'accept co-host invite, result:$result',
              tag: 'live streaming',
              subTag: 'connect manager',
            );

            if (result.error != null) {
              showError('${result.error}');
              return;
            }

            requestPermissions(
              context: contextQuery(),
              isShowDialog: true,
              translationText: translationText,
            ).then((_) {
              updateAudienceConnectState(ConnectState.connected);
            });
          });
        } else {
          ZegoLoggerService.logInfo(
            'accept co-host invite, not living now',
            tag: 'live streaming',
            subTag: 'connect manager',
          );
        }

        Navigator.of(contextQuery()).pop();
      },
    );
  }

  void onInvitationAccepted(Map params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation accepted, invitee:${invitee.toString()}, data:$data',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isHost) {
      audienceIDsOfInvitingConnect.remove(invitee.id);
    } else {
      requestPermissions(
        context: contextQuery(),
        isShowDialog: true,
        translationText: translationText,
      ).then((value) {
        ZegoUIKit().turnCameraOn(true);
        ZegoUIKit().turnMicrophoneOn(true);

        updateAudienceConnectState(ConnectState.connected);
      });
    }
  }

  void onInvitationCanceled(Map params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation canceled, data:${inviter.toString()}, $data',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isHost) {
      requestCoHostUsersNotifier.value =
          List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
            ..removeWhere((user) => user.id == inviter.id);
    }
  }

  void onInvitationRefused(Map params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation refused, data: $data, invitee:${invitee.toString()}',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isHost) {
      audienceIDsOfInvitingConnect.remove(invitee.id);

      showError(translationText.audienceRejectInvitationToast.replaceFirst(
          translationText.param_1,
          ZegoUIKit().getUser(invitee.id)?.name ?? ''));
    } else {
      showError(translationText.hostRejectCoHostRequestToast);
      updateAudienceConnectState(ConnectState.idle);
    }
  }

  void onInvitationTimeout(Map params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation timeout, data:${inviter.toString()}, $data',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isHost) {
      requestCoHostUsersNotifier.value =
          List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
            ..removeWhere((user) => user.id == inviter.id);
    } else {
      /// hide invite join co-host dialog
      if (isInviteToJoinCoHostDlgVisible) {
        isInviteToJoinCoHostDlgVisible = false;
        Navigator.of(contextQuery()).pop();
      }
    }
  }

  void onInvitationResponseTimeout(Map params) {
    final List<ZegoUIKitUser> invitees = params['invitees']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation response timeout, data: $data, '
      'invitees:${invitees.map((e) => e.toString())}',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    if (hostManager.isHost) {
      for (final invitee in invitees) {
        audienceIDsOfInvitingConnect.remove(invitee.id);
      }
    } else {
      updateAudienceConnectState(ConnectState.idle);
    }
  }

  void removeRequestCoHostUsers(ZegoUIKitUser targetUser) {
    requestCoHostUsersNotifier.value =
        List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
          ..removeWhere((user) => user.id == targetUser.id);
  }

  void coHostRequestToEnd() {
    if (isEndCoHostDialogVisible) {
      ZegoLoggerService.logInfo(
        'end host dialog is visible',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    isEndCoHostDialogVisible = true;
    showLiveDialog(
      context: contextQuery(),
      title: translationText.endConnectionDialogInfo.title,
      content: translationText.endConnectionDialogInfo.message,
      leftButtonText: translationText.endConnectionDialogInfo.cancelButtonName,
      leftButtonCallback: () {
        isEndCoHostDialogVisible = false;
        //  pop this dialog
        Navigator.of(contextQuery()).pop(false);
      },
      rightButtonText:
          translationText.endConnectionDialogInfo.confirmButtonName,
      rightButtonCallback: () {
        isEndCoHostDialogVisible = false;
        Navigator.of(contextQuery()).pop(true);

        audienceEndConnect();
      },
    );
  }

  void updateAudienceConnectState(ConnectState state) {
    if (state == audienceLocalConnectStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'audience connect state is same: $state',
        tag: 'live streaming',
        subTag: 'connect manager',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'update audience connect state: $state',
      tag: 'live streaming',
      subTag: 'connect manager',
    );

    switch (state) {
      case ConnectState.idle:
        ZegoUIKit().resetSoundEffect();
        ZegoUIKit().resetBeautyEffect();

        ZegoUIKit().turnCameraOn(false);
        ZegoUIKit().turnMicrophoneOn(false);

        /// hide invite join co-host dialog
        if (isInviteToJoinCoHostDlgVisible) {
          isInviteToJoinCoHostDlgVisible = false;
          Navigator.of(contextQuery()).pop();
        }

        /// hide co-host end request dialog
        if (isEndCoHostDialogVisible) {
          isEndCoHostDialogVisible = false;
          Navigator.of(contextQuery()).pop();
        }
        break;
      case ConnectState.connecting:
        break;
      case ConnectState.connected:
        ZegoUIKit().turnCameraOn(true);
        ZegoUIKit().turnMicrophoneOn(true);
        break;
    }

    audienceLocalConnectStateNotifier.value = state;
  }
}
