part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerConnectInvite {
  final _connectInviteController = ZegoLiveStreamingConnectInviteController();

  ZegoLiveStreamingConnectInviteController get connectInvite =>
      _connectInviteController;
}

/// Here are the APIs related to inviting co-hosts to connect.
class ZegoLiveStreamingConnectInviteController {
  /// host invite [audience] to be a co-host
  ///
  /// If [withToast] is set to true, a toast message will be displayed after the request succeeds or fails.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> hostSendCoHostInvitationToAudience(
    ZegoUIKitUser audience, {
    bool withToast = false,
  }) async {
    ZegoLoggerService.logInfo(
      'make audience: ${audience.id} to be a co-host',
      tag: 'live streaming',
      subTag: 'controller.connect.invite',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not invite, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      return false;
    }

    if (!_isLocalHost) {
      ZegoLoggerService.logInfo(
        'local is not a host, can not invite',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      return false;
    }

    final isInPK =
        ZegoLiveStreamingPKBattleStateCombineNotifier.instance.state.value;
    if (isInPK) {
      ZegoLoggerService.logInfo(
        'local in the pk-battle, can not invite',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      return false;
    }

    if (_connectManager!.isMaxCoHostReached) {
      _hostManager!.config.onMaxCoHostReached
          ?.call(_prebuiltConfig!.maxCoHostCount);
      ZegoLoggerService.logInfo(
        'co-host max count had reached, can not invite',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      return false;
    }

    final targetUserIsInviting =
        _connectManager!.audienceIDsOfInvitingConnect.contains(audience.id);
    final targetUserIsRequesting = -1 !=
        _connectManager!.requestCoHostUsersNotifier.value
            .indexWhere((user) => user.id == audience.id);
    if (targetUserIsInviting || targetUserIsRequesting) {
      ZegoLoggerService.logInfo(
        "you've sent the invitation, please wait for confirmation.",
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      if (withToast) {
        showError(
          targetUserIsInviting
              ? _prebuiltConfig!.innerText.repeatInviteCoHostFailedToast
              : _prebuiltConfig!.innerText.inviteCoHostFailedToast,
        );
      }

      return false;
    }

    return _connectManager!.inviteAudienceConnect(audience);
  }

  Future<bool> audienceAgreeCoHostInvitation({
    bool withToast = false,
  }) async {
    ZegoLoggerService.logInfo(
      'audience agree co-host request',
      tag: 'live streaming',
      subTag: 'controller.connect.invite',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not invite, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      return false;
    }

    if (_connectManager!.isMaxCoHostReached) {
      _prebuiltConfig!.onMaxCoHostReached?.call(
        _prebuiltConfig!.maxCoHostCount,
      );

      ZegoLoggerService.logInfo(
        'audience agree co-host request, but co-host max count had reached',
        tag: 'live streaming',
        subTag: 'controller.connect',
      );

      return false;
    }

    if (_hostManager!.notifier.value?.id.isEmpty ?? true) {
      ZegoLoggerService.logInfo(
        'audience agree co-host request, but host(${_hostManager!.notifier.value?.id}) is null',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      return false;
    }

    if (LiveStatus.living != _connectManager!.liveStatusNotifier.value) {
      ZegoLoggerService.logInfo(
        'audience agree co-host request, but not living now',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .acceptInvitation(
            inviterID: _hostManager!.notifier.value?.id ?? '', data: '')
        .then((result) async {
      ZegoLoggerService.logInfo(
        'accept co-host invite, result:$result',
        tag: 'live streaming',
        subTag: 'connect manager',
      );

      if (result.error != null) {
        if (withToast) {
          showError('${result.error}');
        }
        return false;
      }

      _events?.audienceEvents.onActionAcceptCoHostInvitation?.call();

      final permissions = _connectManager!.getCoHostPermissions();
      await permissions
          .request()
          .then((Map<Permission, PermissionStatus> statuses) {
        if (permissions.contains(Permission.camera) &&
            statuses[Permission.camera] != PermissionStatus.granted) {
          ZegoLoggerService.logInfo(
            'camera not granted when audience switch to co-host',
            tag: 'live streaming',
            subTag: 'controller.connect',
          );
        }

        if (permissions.contains(Permission.microphone) &&
            statuses[Permission.microphone] != PermissionStatus.granted) {
          ZegoLoggerService.logInfo(
            'camera not granted when audience switch to co-host',
            tag: 'live streaming',
            subTag: 'controller.connect',
          );
        }

        _connectManager!.updateAudienceConnectState(
            ZegoLiveStreamingAudienceConnectState.connected);
      });

      return true;
    });
  }

  Future<bool> audienceRejectCoHostInvitation() async {
    ZegoLoggerService.logInfo(
      'audience reject co-host request',
      tag: 'live streaming',
      subTag: 'controller.connect.invite',
    );

    if (null == _hostManager ||
        null == _connectManager ||
        null == _prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'params is not valid, can not invite, '
        'hostManager:$_hostManager, '
        'connectManager:$_connectManager, '
        'prebuiltConfig:$_prebuiltConfig, ',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      return false;
    }

    if (_hostManager!.notifier.value?.id.isEmpty ?? true) {
      ZegoLoggerService.logInfo(
        'audience reject co-host request, but host(${_hostManager!.notifier.value?.id}) is null',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      return false;
    }

    if (LiveStatus.living != _connectManager!.liveStatusNotifier.value) {
      ZegoLoggerService.logInfo(
        'audience reject co-host request, but not living now',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .refuseInvitation(
            inviterID: _hostManager!.notifier.value?.id ?? '', data: '')
        .then((result) {
      ZegoLoggerService.logInfo(
        'audience reject co-host request, result:$result',
        tag: 'live streaming',
        subTag: 'controller.connect.invite',
      );

      _events?.audienceEvents.onActionRefuseCoHostInvitation?.call();

      if (result.error != null) {
        showDebugToast('error:${result.error}');
      }

      return result.error == null;
    });
  }

  /// DO NOT CALL
  /// Call Inside By Prebuilt
  void init({ZegoUIKitPrebuiltLiveStreamingEvents? events}) {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'controller.connect.invite',
    );

    _events = events;
  }

  /// DO NOT CALL
  /// Call Inside By Prebuilt
  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'controller.connect.invite',
    );

    _events = null;
  }

  ZegoUIKitPrebuiltLiveStreamingConfig? get _prebuiltConfig =>
      ZegoLiveStreamingManagers().hostManager?.config;

  ZegoLiveHostManager? get _hostManager =>
      ZegoLiveStreamingManagers().hostManager;

  ZegoLiveConnectManager? get _connectManager =>
      ZegoLiveStreamingManagers().connectManager;

  bool get _isLocalHost => _hostManager?.isLocalHost ?? false;

  ZegoUIKitPrebuiltLiveStreamingEvents? _events;
}
