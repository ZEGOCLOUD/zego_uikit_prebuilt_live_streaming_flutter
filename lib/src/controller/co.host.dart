part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

mixin ZegoLiveStreamingControllerCoHost {
  final _coHostImpl = ZegoLiveStreamingControllerCoHostImpl();

  ZegoLiveStreamingControllerCoHostImpl get coHost => _coHostImpl;
}

/// Here are the APIs related to inviting co-hosts to connect.
class ZegoLiveStreamingControllerCoHostImpl
    with ZegoLiveStreamingControllerCoHostPrivate {
  /// for audience: current audience connection state, audience or co-host(connected)
  ValueNotifier<ZegoLiveStreamingAudienceConnectState>
      get audienceLocalConnectStateNotifier =>
          private.audienceLocalConnectStateNotifier;

  ValueNotifier<ZegoUIKitUser?> get hostNotifier {
    private.initByCoreManager();
    return private.hostNotifier;
  }

  /// for host: current requesting co-host's audiences
  ValueNotifier<List<ZegoUIKitUser>> get requestCoHostUsersNotifier =>
      private.requestCoHostUsersNotifier;

  /// current co-host total count
  ValueNotifier<int> get coHostCountNotifier =>
      private.connectManager.coHostCount;

  /// host invite [audience] to be a co-host
  ///
  /// If [withToast] is set to true, a toast message will be displayed after the request succeeds or fails.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> hostSendCoHostInvitationToAudience(
    ZegoUIKitUser audience, {
    bool withToast = false,
    int timeoutSecond = 60,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'make audience: ${audience.id} to be a co-host',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, hostSendCoHostInvitationToAudience',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not invite, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostSendCoHostInvitationToAudience',
      );

      return false;
    }

    if (!private.isLocalHost) {
      ZegoLoggerService.logInfo(
        'local is not a host, can not invite',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostSendCoHostInvitationToAudience',
      );

      return false;
    }

    final isInPK =
        ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state.value;
    if (isInPK) {
      ZegoLoggerService.logInfo(
        'local in the pk-battle, can not invite',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostSendCoHostInvitationToAudience',
      );

      return false;
    }

    if (private.connectManager.isMaxCoHostReached) {
      private.events?.coHost.onMaxCountReached
          ?.call(private.configs!.coHost.maxCoHostCount);
      ZegoLoggerService.logInfo(
        'co-host max count had reached, can not invite',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostSendCoHostInvitationToAudience',
      );

      return false;
    }

    final targetUserIsInviting = private
        .connectManager.audienceIDsOfInvitingConnect
        .contains(audience.id);
    final targetUserIsRequesting = -1 !=
        private.connectManager.requestCoHostUsersNotifier.value
            .indexWhere((user) => user.id == audience.id);
    if (targetUserIsInviting || targetUserIsRequesting) {
      ZegoLoggerService.logInfo(
        "you've sent the invitation, please wait for confirmation.",
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostSendCoHostInvitationToAudience',
      );

      if (withToast) {
        showError(
          targetUserIsInviting
              ? private.configs!.innerText.repeatInviteCoHostFailedToast
              : private.configs!.innerText.inviteCoHostFailedToast,
        );
      }

      return false;
    }

    return private.connectManager.inviteAudienceConnect(
      audience,
      timeoutSecond: timeoutSecond,
      customData: customData,
    );
  }

  Future<bool> audienceAgreeCoHostInvitation({
    bool withToast = false,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'withToast:$withToast, customData:$customData, ',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, audienceAgreeCoHostInvitation',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not invite, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceAgreeCoHostInvitation',
      );

      return false;
    }

    if (private.connectManager.isMaxCoHostReached) {
      private.events?.coHost.onMaxCountReached?.call(
        private.configs!.coHost.maxCoHostCount,
      );

      ZegoLoggerService.logInfo(
        'co-host max count had reached',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceAgreeCoHostInvitation',
      );

      return false;
    }

    if (private.hostManager.notifier.value?.id.isEmpty ?? true) {
      ZegoLoggerService.logInfo(
        'host(${private.hostManager.notifier.value?.id}) is null',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceAgreeCoHostInvitation',
      );

      return false;
    }

    if (LiveStatus.living !=
        ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .liveStatusManager
            .notifier
            .value) {
      ZegoLoggerService.logInfo(
        'not living now',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceAgreeCoHostInvitation',
      );
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .acceptInvitation(
          inviterID: private.hostManager.notifier.value?.id ?? '',
          data: customData,
        )
        .then((result) async {
      ZegoLoggerService.logInfo(
        'result:$result',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceAgreeCoHostInvitation',
      );

      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostAudienceRespond,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
          ZegoLiveStreamingReporter.eventKeyAction:
              ZegoLiveStreamingReporter.eventKeyActionAccept,
        },
      );

      if (result.error != null) {
        if (withToast) {
          showError('${result.error}');
        }
        return false;
      }

      private.events?.coHost.audience.onActionAcceptInvitation?.call();

      final permissions = private.connectManager.getCoHostPermissions();
      await permissions
          .request()
          .then((Map<Permission, PermissionStatus> statuses) {
        if (permissions.contains(Permission.camera) &&
            statuses[Permission.camera] != PermissionStatus.granted) {
          ZegoLoggerService.logInfo(
            'camera not granted when audience switch to co-host',
            tag: 'live.streaming.controller.co-host',
            subTag: 'controller, audienceAgreeCoHostInvitation',
          );
        }

        if (permissions.contains(Permission.microphone) &&
            statuses[Permission.microphone] != PermissionStatus.granted) {
          ZegoLoggerService.logInfo(
            'camera not granted when audience switch to co-host',
            tag: 'live.streaming.controller.co-host',
            subTag: 'controller, audienceAgreeCoHostInvitation',
          );
        }

        private.connectManager.updateAudienceConnectState(
          ZegoLiveStreamingAudienceConnectState.connected,
        );
      });

      return true;
    });
  }

  Future<bool> audienceRejectCoHostInvitation({
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'customData:$customData',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, audienceRejectCoHostInvitation',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not invite, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceRejectCoHostInvitation',
      );

      return false;
    }

    if (private.hostManager.notifier.value?.id.isEmpty ?? true) {
      ZegoLoggerService.logInfo(
        'host(${private.hostManager.notifier.value?.id}) is null',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceRejectCoHostInvitation',
      );

      return false;
    }

    if (LiveStatus.living !=
        ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .liveStatusManager
            .notifier
            .value) {
      ZegoLoggerService.logInfo(
        'not living now',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceRejectCoHostInvitation',
      );
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .refuseInvitation(
          inviterID: private.hostManager.notifier.value?.id ?? '',
          data: customData,
        )
        .then((result) {
      ZegoLoggerService.logInfo(
        'result:$result',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceRejectCoHostInvitation',
      );

      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostAudienceRespond,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
          ZegoLiveStreamingReporter.eventKeyAction:
              ZegoLiveStreamingReporter.eventKeyActionRefuse,
        },
      );

      private.events?.coHost.audience.onActionRefuseInvitation?.call();

      if (result.error != null) {
        showDebugToast('error:${result.error}');
      }

      return result.error == null;
    });
  }

  /// audience requests to become a co-host by sending a request to the host.
  /// if you want audience be co-host without request to the host, use [startCoHost]
  ///
  /// If [withToast] is set to true, a toast message will be displayed after the request succeeds or fails.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> audienceSendCoHostRequest({
    bool withToast = false,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'withToast:$withToast, customData:$customData, ',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, audienceSendCoHostRequest',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not request, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceSendCoHostRequest',
      );

      return false;
    }

    if (!private.hostExist) {
      if (withToast) {
        showError(private.configs!.innerText.requestCoHostFailedToast);
      }
      return false;
    }

    if (!private.isLiving) {
      if (withToast) {
        showError(private.configs!.innerText.requestCoHostFailedToast);
      }
      return false;
    }

    if (ZegoLiveStreamingAudienceConnectState.connecting ==
        private.connectManager.audienceLocalConnectStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'not need request more',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceSendCoHostRequest',
      );
      return false;
    }

    final result = await ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterID: ZegoUIKit().getLocalUser().id,
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [private.hostManager.notifier.value?.id ?? ''],
          timeout: 60,
          type: ZegoLiveStreamingInvitationType.requestCoHost.value,
          data: customData,
        )
        .then((result) {
      ZegoLoggerService.logInfo(
        'result:$result',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceSendCoHostRequest',
      );

      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostAudienceInvite,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
          ZegoLiveStreamingReporter.eventKeyRoomID:
              ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        },
      );

      if (withToast) {
        if (result.error?.code.isNotEmpty ?? false) {
          showError('${private.configs!.innerText.requestCoHostFailedToast}, '
              '${result.error?.code} ${result.error?.message}');
        } else {
          showSuccess(private.configs!.innerText.sendRequestCoHostToast);
        }
      }

      return result.error == null;
    });

    if (result) {
      private.events?.coHost.audience.onRequestSent?.call();

      private.connectManager.updateAudienceConnectState(
          ZegoLiveStreamingAudienceConnectState.connecting);
    }

    return result;
  }

  /// audience cancels the co-host request to the host.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> audienceCancelCoHostRequest({
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'customData:$customData',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, audienceCancelCoHostRequest',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not request, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceCancelCoHostRequest',
      );

      return false;
    }

    if (ZegoLiveStreamingAudienceConnectState.connecting !=
        private.connectManager.audienceLocalConnectStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'not need cancel',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, audienceCancelCoHostRequest',
      );
      return false;
    }

    final result = await ZegoUIKit().getSignalingPlugin().cancelInvitation(
      invitees: [private.hostManager.notifier.value?.id ?? ''],
      data: customData,
    );
    ZegoLoggerService.logInfo(
      'result:$result',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, audienceCancelCoHostRequest',
    );

    ZegoLiveStreamingReporter().report(
      event: ZegoLiveStreamingReporter.eventCoHostAudienceRespond,
      params: {
        ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
        ZegoLiveStreamingReporter.eventKeyAction:
            ZegoLiveStreamingReporter.eventKeyActionCancel,
      },
    );

    private.events?.coHost.audience.onActionCancelRequest?.call();

    private.connectManager
        .updateAudienceConnectState(ZegoLiveStreamingAudienceConnectState.idle);

    return result.error == null;
  }

  /// audience switch to be an co-host directly, without request to host
  /// if you want audience be co-host with request to the host, use [audienceSendCoHostRequest]
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> startCoHost() async {
    ZegoLoggerService.logInfo(
      'audience switch to co-host',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, startCoHost',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not request, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, startCoHost',
      );

      return false;
    }

    if (!private.hostExist) {
      ZegoLoggerService.logInfo(
        'host is not exist, ignore current co-host switch',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, startCoHost',
      );

      return false;
    }

    if (!private.isLiving) {
      ZegoLoggerService.logInfo(
        'is not in living, ignore current co-host switch',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, startCoHost',
      );

      return false;
    }

    if (private.connectManager.isCoHost(ZegoUIKit().getLocalUser())) {
      ZegoLoggerService.logInfo(
        'audience is co-host now',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, startCoHost',
      );
      return false;
    }

    if (private.connectManager.isMaxCoHostReached) {
      private.events?.coHost.onMaxCountReached?.call(
        private.configs!.coHost.maxCoHostCount,
      );

      ZegoLoggerService.logInfo(
        'co-host max count had reached, ignore current co-host switch',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, startCoHost',
      );

      return false;
    }

    final permissions = private.connectManager.getCoHostPermissions();
    await permissions
        .request()
        .then((Map<Permission, PermissionStatus> statuses) {
      if (permissions.contains(Permission.camera) &&
          statuses[Permission.camera] != PermissionStatus.granted) {
        ZegoLoggerService.logInfo(
          'camera not granted when audience switch to co-host',
          tag: 'live.streaming.controller.co-host',
          subTag: 'controller, startCoHost',
        );
      }
      if (permissions.contains(Permission.microphone) &&
          statuses[Permission.microphone] != PermissionStatus.granted) {
        ZegoLoggerService.logInfo(
          'microphone not granted when audience switch to co-host',
          tag: 'live.streaming.controller.co-host',
          subTag: 'controller, startCoHost',
        );
      }

      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostAudienceStart,
      );
      private.connectManager.updateAudienceConnectState(
        ZegoLiveStreamingAudienceConnectState.connected,
      );
    });

    return true;
  }

  /// co-host ends the connection and switches to the audience role voluntarily.
  ///
  /// If [showRequestDialog] is true, a confirmation dialog will be displayed to prevent accidental clicks.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> stopCoHost({
    bool showRequestDialog = true,
  }) async {
    ZegoLoggerService.logInfo(
      'co-host switch to audience',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, stopCoHost',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not request, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, stopCoHost',
      );

      return false;
    }

    if (showRequestDialog) {
      return private.connectManager.coHostRequestToEnd();
    }

    return private.connectManager.coHostEndConnect();
  }

  /// host approve the co-host request made by [audience].
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> hostAgreeCoHostRequest(
    ZegoUIKitUser audience, {
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'audience:${audience.id}, customData:$customData, ',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, hostAgreeCoHostRequest',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not agree, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostAgreeCoHostRequest',
      );

      return false;
    }

    if (!private.isLocalHost) {
      ZegoLoggerService.logInfo(
        'local is not a host, can not agree',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostAgreeCoHostRequest',
      );

      return false;
    }

    if (private.connectManager.coHostCount.value +
            private.agreeRequestingUserIDs.length >=
        private.connectManager.maxCoHostCount) {
      private.events?.coHost.onMaxCountReached
          ?.call(private.configs!.coHost.maxCoHostCount);

      ZegoLoggerService.logInfo(
        'co-host max count had reached, can not agree',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostAgreeCoHostRequest',
      );

      return false;
    }

    private.agreeRequestingUserIDs.add(audience.id);
    ZegoLoggerService.logInfo(
      'agree requesting count:${private.agreeRequestingUserIDs.length}',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, hostAgreeCoHostRequest',
    );

    return ZegoUIKit()
        .getSignalingPlugin()
        .acceptInvitation(
          inviterID: audience.id,
          data: customData,
        )
        .then((result) {
      ZegoLoggerService.logInfo(
        'agree the co-host request from ${audience.id}, result:$result',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostAgreeCoHostRequest',
      );

      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostHostRespond,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
          ZegoLiveStreamingReporter.eventKeyAction:
              ZegoLiveStreamingReporter.eventKeyActionAccept,
        },
      );

      if (result.error == null) {
        private.events?.coHost.host.onActionAcceptRequest?.call();

        private.connectManager.removeRequestCoHostUsers(audience);
      } else {
        showDebugToast('error:${result.error}');
      }

      return result.error == null;
    });
  }

  /// host reject the co-host request made by [audience].
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> hostRejectCoHostRequest(
    ZegoUIKitUser audience, {
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'audience:${audience.id}, customData:$customData',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, hostRejectCoHostRequest',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not reject, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostRejectCoHostRequest',
      );

      return false;
    }

    if (!private.isLocalHost) {
      ZegoLoggerService.logInfo(
        'local is not a host',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostRejectCoHostRequest',
      );

      return false;
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .refuseInvitation(
          inviterID: audience.id,
          data: customData,
        )
        .then((result) {
      ZegoLoggerService.logInfo(
        'refuse audience ${audience.name} co-host request, $result',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, hostRejectCoHostRequest',
      );

      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventCoHostHostRespond,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: result.invitationID,
          ZegoLiveStreamingReporter.eventKeyAction:
              ZegoLiveStreamingReporter.eventKeyActionRefuse,
        },
      );

      if (result.error == null) {
        private.events?.coHost.host.onActionRefuseRequest?.call();

        private.connectManager.removeRequestCoHostUsers(audience);
      } else {
        showDebugToast('error:${result.error}');
      }

      return result.error == null;
    });
  }

  /// host remove the co-host, make [coHost] to be a audience
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> removeCoHost(
    ZegoUIKitUser coHost, {
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'remove co-host:${coHost.id}, '
      'customData:$customData, ',
      tag: 'live.streaming.controller.co-host',
      subTag: 'controller, removeCoHost',
    );

    if (null == private.configs) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not remove, '
        'hostManager:${private.hostManager}, '
        'connectManager:${private.connectManager}, '
        'prebuiltConfig:${private.configs}, ',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, removeCoHost',
      );

      return false;
    }

    if (!private.isLocalHost) {
      ZegoLoggerService.logInfo(
        'local is not a host',
        tag: 'live.streaming.controller.co-host',
        subTag: 'controller, removeCoHost',
      );

      return false;
    }

    return private.connectManager.kickCoHost(
      coHost,
      customData: customData,
    );
  }
}
