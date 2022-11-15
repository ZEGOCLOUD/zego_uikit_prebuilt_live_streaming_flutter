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
import 'defines.dart';

class ZegoLiveConnectManager {
  final ZegoLiveHostManager hostManager;
  final ValueNotifier<LiveStatus> liveStatusNotifier;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final BuildContext Function() contextQuery;
  final ZegoTranslationText translationText;

  ZegoLiveConnectManager({
    required this.hostManager,
    required this.liveStatusNotifier,
    required this.config,
    required this.translationText,
    required this.contextQuery,
  }) {
    listenStream();
  }

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
      debugPrint("[connect mgr] switch local to be co-host");
      updateAudienceConnectState(ConnectState.idle);
    }
  }

  void uninit() {
    audienceLocalConnectStateNotifier.value = ConnectState.idle;
    requestCoHostUsersNotifier.value = [];
    isInviteToJoinCoHostDlgVisible = false;
    isEndCoHostDialogVisible = false;
    audienceIDsOfInvitingConnect.clear();

    for (var subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void listenStream() {
    if (config.plugins.isNotEmpty) {
      subscriptions
        ..add(ZegoUIKitSignalingPluginImp.shared
            .getInvitationReceivedStream()
            .listen(onInvitationReceived))
        ..add(ZegoUIKitSignalingPluginImp.shared
            .getInvitationAcceptedStream()
            .listen(onInvitationAccepted))
        ..add(ZegoUIKitSignalingPluginImp.shared
            .getInvitationCanceledStream()
            .listen(onInvitationCanceled))
        ..add(ZegoUIKitSignalingPluginImp.shared
            .getInvitationRefusedStream()
            .listen(onInvitationRefused))
        ..add(ZegoUIKitSignalingPluginImp.shared
            .getInvitationTimeoutStream()
            .listen(onInvitationTimeout))
        ..add(ZegoUIKitSignalingPluginImp.shared
            .getInvitationResponseTimeoutStream()
            .listen(onInvitationResponseTimeout));
    }
  }

  Future<bool> kickCoHost(ZegoUIKitUser coHost) async {
    debugPrint("[connect manager] kick-out co-host ${coHost.toString()}");

    return await ZegoUIKitSignalingPluginImp.shared
        .sendInvitation(
      ZegoUIKit().getLocalUser().name,
      [coHost.id],
      60,
      ZegoInvitationType.removeFromCoHost.value,
      "",
    )
        .then((result) {
      debugPrint(
          "[connect manager] kick co-host ${coHost.id} ${coHost.name}, code:${result.code}, message:${result.message}, error invitees:${result.result as List<String>}");
      return result.code.isEmpty;
    });
  }

  void inviteAudienceConnect(ZegoUIKitUser invitee) async {
    debugPrint("invite audience connect, ${invitee.id} ${invitee.name}");

    if (audienceIDsOfInvitingConnect.contains(invitee.id)) {
      debugPrint("audience is int connect inviting");
      return;
    }

    audienceIDsOfInvitingConnect.add(invitee.id);

    await ZegoUIKitSignalingPluginImp.shared
        .sendInvitation(
      ZegoUIKit().getLocalUser().name,
      [invitee.id],
      60,
      ZegoInvitationType.inviteToJoinCoHost.value,
      '',
    )
        .then((result) {
      if (result.code.isNotEmpty) {
        audienceIDsOfInvitingConnect.remove(invitee.id);

        showError(translationText.inviteCoHostFailedToast);
      }
    });
  }

  void audienceEndConnect() {
    debugPrint("[connect manager] audience end connect");

    updateAudienceConnectState(ConnectState.idle);
  }

  void onInvitationReceived(Map params) {
    ZegoUIKitUser inviter = params['inviter']!;
    int type = params['type']!; // call type
    String data = params['data']!; // extended field

    var invitationType =
        ZegoInvitationTypeExtension.mapValue[type] as ZegoInvitationType;

    debugPrint(
        "[connect mgr] on invitation received, data:${inviter.toString()}, $type($invitationType) $data");

    if (hostManager.isHost) {
      if (ZegoInvitationType.requestCoHost == invitationType) {
        var translation = translationText.receivedCoHostRequestDialogInfo;
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
      debugPrint("invite to join co-host dialog is visibile");
      return;
    }

    if (isCoHost(ZegoUIKit().getLocalUser())) {
      debugPrint("[connect mgr] audience is co-host now");
      return;
    }

    var translation = translationText.receivedCoHostInvitationDialogInfo;
    isInviteToJoinCoHostDlgVisible = true;

    showLiveDialog(
      context: contextQuery(),
      title: translation.title,
      content: translation.message,
      leftButtonText: translation.cancelButtonName,
      leftButtonCallback: () {
        isInviteToJoinCoHostDlgVisible = false;

        if (LiveStatus.living == liveStatusNotifier.value) {
          ZegoUIKitSignalingPluginImp.shared
              .refuseInvitation(host.id, '')
              .then((result) {
            debugPrint(
                "[connect mgr] refuse co-host invite, code:${result.code}, message:${result.message}");
          });
        } else {
          debugPrint("[connect mgr] refuse co-host invite, not living now");
        }

        Navigator.of(contextQuery()).pop();
      },
      rightButtonText: translation.confirmButtonName,
      rightButtonCallback: () {
        isInviteToJoinCoHostDlgVisible = false;

        debugPrint("[connect mgr] accept co-host invite");
        if (LiveStatus.living == liveStatusNotifier.value) {
          ZegoUIKitSignalingPluginImp.shared
              .acceptInvitation(host.id, '')
              .then((result) {
            debugPrint(
                "[connect mgr] accept co-host invite, code:${result.code}, message:${result.message}");

            if (result.code.isNotEmpty) {
              showError("${result.code} ${result.message}");
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
          debugPrint("[connect mgr] accept co-host invite, not living now");
        }

        Navigator.of(contextQuery()).pop();
      },
    );
  }

  void onInvitationAccepted(Map params) {
    ZegoUIKitUser invitee = params['invitee']!;
    String data = params['data']!; // extended field

    debugPrint(
        "[connect mgr] on invitation accepted, invitee:${invitee.toString()}, data:$data");

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
    ZegoUIKitUser inviter = params['inviter']!;
    String data = params['data']!; // extended field

    debugPrint(
        "[connect mgr] on invitation canceled, data:${inviter.toString()}, $data");

    if (hostManager.isHost) {
      requestCoHostUsersNotifier.value =
          List<ZegoUIKitUser>.from(requestCoHostUsersNotifier.value)
            ..removeWhere((user) => user.id == inviter.id);
    } else {
      //
    }
  }

  void onInvitationRefused(Map params) {
    ZegoUIKitUser invitee = params['invitee']!;
    String data = params['data']!; // extended field

    debugPrint(
        "[connect mgr] on invitation refused, data: $data, invitee:${invitee.toString()}");

    if (hostManager.isHost) {
      audienceIDsOfInvitingConnect.remove(invitee.id);

      showError(translationText.audienceRejectInvitationToast.replaceFirst(
          translationText.param_1,
          ZegoUIKit().getUser(invitee.id)?.name ?? ""));
    } else {
      showError(translationText.hostRejectCoHostRequestToast);
      updateAudienceConnectState(ConnectState.idle);
    }
  }

  void onInvitationTimeout(Map params) {
    ZegoUIKitUser inviter = params['inviter']!;
    String data = params['data']!; // extended field

    debugPrint(
        "[connect mgr] on invitation timeout, data:${inviter.toString()}, $data");

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
    List<ZegoUIKitUser> invitees = params['invitees']!;
    String data = params['data']!; // extended field

    debugPrint(
        "[connect mgr] on invitation response timeout, data: $data, invitees:${invitees.map((e) => e.toString())}");

    if (hostManager.isHost) {
      for (var invitee in invitees) {
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
      debugPrint("end host dialog is visible");
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
      debugPrint("[connect mgr] audience connect state is same: $state");
      return;
    }

    debugPrint("[connect mgr] update audience connect state: $state");

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
