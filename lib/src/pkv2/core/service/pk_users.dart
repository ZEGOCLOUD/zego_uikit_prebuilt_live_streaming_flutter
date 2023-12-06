part of 'services.dart';

extension PKServiceV2ConnectedUsers
    on ZegoUIKitPrebuiltLiveStreamingPKServicesV2 {
  List<ZegoUIKitPrebuiltLiveStreamingPKUser> get removedPKUsersCompareCurrent {
    List<ZegoUIKitPrebuiltLiveStreamingPKUser> removedUsers = [];

    final currentPKUserIDs =
        _coreData.currentPKUsers.value.map((e) => e.userInfo.id).toList();
    for (var user in _coreData.previousPKUsers.value) {
      if (!currentPKUserIDs.contains(user.userInfo.id)) {
        removedUsers.add(user);
      }
    }

    return removedUsers;
  }

  List<ZegoUIKitPrebuiltLiveStreamingPKUser> get addedPKUsersCompareCurrent {
    List<ZegoUIKitPrebuiltLiveStreamingPKUser> addedUsers = [];

    final previousPKUserIDs =
        _coreData.previousPKUsers.value.map((e) => e.userInfo.id).toList();
    for (var user in _coreData.currentPKUsers.value) {
      if (!previousPKUserIDs.contains(user.userInfo.id)) {
        addedUsers.add(user);
      }
    }

    return addedUsers;
  }

  List<ZegoUIKitPrebuiltLiveStreamingPKUser> removeDuplicatePKUsers(
      List<ZegoUIKitPrebuiltLiveStreamingPKUser> updatedPKUsers) {
    List<ZegoUIKitPrebuiltLiveStreamingPKUser> distinctPKUsers = [];
    for (var user in updatedPKUsers) {
      bool isDuplicate = false;
      for (var distinctUser in distinctPKUsers) {
        if (user.userInfo.id == distinctUser.userInfo.id) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate) {
        distinctPKUsers.add(user);
      }
    }

    return distinctPKUsers;
  }

  void updatePKUsers(
    List<ZegoUIKitPrebuiltLiveStreamingPKUser> updatedPKUsers,
  ) {
    updatedPKUsers = removeDuplicatePKUsers(updatedPKUsers);

    final currentPKUserIDs =
        _coreData.currentPKUsers.value.map((e) => e.userInfo.id).toList();
    final updatedPKUserIDs = updatedPKUsers.map((e) => e.userInfo.id).toList();
    if (!const DeepCollectionEquality().equals(
      currentPKUserIDs,
      updatedPKUserIDs,
    )) {
      _coreData.previousPKUsers.value =
          List<ZegoUIKitPrebuiltLiveStreamingPKUser>.from(
              _coreData.currentPKUsers.value);
      for (var pkUser in updatedPKUsers) {
        pkUser.heartbeat = DateTime.now();

        if (pkUser.heartbeatBrokenNotifier.value) {
          ZegoLoggerService.logInfo(
            'update pk users, un-mute ${pkUser.userInfo.id} audio',
            tag: 'live streaming',
            subTag: 'pk event',
          );

          ZegoUIKit().muteUserAudio(pkUser.userInfo.id, false);

          _coreData.events?.pkV2Events.onUserReconnected?.call(
            pkUser.toUIKitUser,
          );
        }
        pkUser.heartbeatBrokenNotifier.value = false;
      }

      ZegoLoggerService.logInfo(
        'update pk users, '
        'previous:${_coreData.previousPKUsers.value.toSimpleString()}, '
        'current:${updatedPKUsers.toSimpleString()}, '
        'current details:$updatedPKUsers, ',
        tag: 'live streaming',
        subTag: 'service data',
      );
      _coreData.currentPKUsers.value = updatedPKUsers;
    }
  }

  void listenPKUserChanged() {
    ZegoLoggerService.logInfo(
      'listenPKUserChanged',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    removeListenPKUserChanged();

    _coreData.connectingPKUsers.addListener(onConnectingPKUsersChanged);
    _coreData.currentPKUsers.addListener(onPKUsersChanged);
  }

  void removeListenPKUserChanged() {
    ZegoLoggerService.logInfo(
      'removeListenPKUserChanged',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    _coreData.connectingPKUsers.removeListener(onConnectingPKUsersChanged);
    _coreData.currentPKUsers.removeListener(onPKUsersChanged);
  }

  void onConnectingPKUsersChanged() {
    ZegoLoggerService.logInfo(
      'onConnectingPKUsersChanged:${_coreData.connectingPKUsers.value}',
      tag: 'live streaming',
      subTag: 'pk service',
    );
  }

  Future<void> onPKUsersChanged() async {
    ZegoLoggerService.logInfo(
      'onPKUsersChanged, '
      'pk users:${_coreData.currentPKUsers.value.toSimpleString()}, '
      'isLiving;$isLiving, ',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    if (!isLiving) {
      return;
    }

    // isHost ? await hostOnPKUsersChanged() : await audienceOnPKUsersChanged();
    return waitCompleter('onPKUsersChanged').then((_) async {
      isHost ? await hostOnPKUsersChanged() : await audienceOnPKUsersChanged();
    }).then((_) {
      completeCompleter('onPKUsersChanged');
    });
  }

  Future<void> hostOnPKUsersChanged() async {
    final localHostInPK = -1 !=
        _coreData.currentPKUsers.value.indexWhere(
            (pkUser) => pkUser.userInfo.id == ZegoUIKit().getLocalUser().id);

    ZegoLoggerService.logInfo(
      'hostOnPKUsersChanged,'
      'localHostInPK:$localHostInPK, '
      'pk users:${_coreData.currentPKUsers.value.toSimpleString()}',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    return localHostInPK
        ? await hostConnectedOnPKUsersChanged()
        : await hostDisconnectedOnPKUsersChanged();
  }

  Future<void> hostConnectedOnPKUsersChanged() async {
    final onlyLocalInPK = _coreData.currentPKUsers.value.length == 1 &&
        _coreData.currentPKUsers.value.first.userInfo.id ==
            ZegoUIKit().getLocalUser().id;

    ZegoLoggerService.logInfo(
      'hostConnectedOnPKUsersChanged,'
      'onlyLocalInPK:$onlyLocalInPK, '
      'pk users:${_coreData.currentPKUsers.value.toSimpleString()}, '
      'previousPKUsers:${_coreData.previousPKUsers.value.toSimpleString()}, '
      'addedPKUsersCompareCurrent:${addedPKUsersCompareCurrent.toSimpleString()}, '
      'removedPKUsersCompareCurrent:${removedPKUsersCompareCurrent.toSimpleString()}, '
      'playing user id:${_coreData.playingHostIDs}',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    if (!isInPK) {
      /// not in pk now, init pk
      updatePKState(ZegoLiveStreamingPKBattleStateV2.inPK);

      final isMicrophoneOn = ZegoUIKit()
          .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
          .value;
      ZegoUIKit().turnMicrophoneOn(isMicrophoneOn, muteMode: true);
    }

    /// update mixer layout
    await _mixer.updateTask(List.from(_coreData.currentPKUsers.value));

    /// start play other room user stream
    ZegoLoggerService.logInfo(
      'try play ${_coreData.currentPKUsers.value.toSimpleString()}\'s stream',
      tag: 'live streaming',
      subTag: 'pk service',
    );
    for (var user in _coreData.currentPKUsers.value) {
      if (ZegoUIKit().getLocalUser().id == user.userInfo.id) {
        continue;
      }

      if (_coreData.playingHostIDs.contains(user.userInfo.id)) {
        ZegoLoggerService.logInfo(
          '${user.userInfo.id} is playing, ignore',
          tag: 'live streaming',
          subTag: 'pk service',
        );
        continue;
      }

      ZegoLoggerService.logInfo(
        'start play ${user.userInfo.id}',
        tag: 'live streaming',
        subTag: 'pk service',
      );
      _coreData.playingHostIDs.add(user.userInfo.id);
      await ZegoUIKit().startPlayAnotherRoomAudioVideo(
        user.liveID,
        user.userInfo.id,
        userName: user.userInfo.name,
      );
    }

    /// stop play other room user stream
    ZegoLoggerService.logInfo(
      'try stop ${removedPKUsersCompareCurrent.toSimpleString()}\'s stream',
      tag: 'live streaming',
      subTag: 'pk service',
    );
    for (var user in removedPKUsersCompareCurrent) {
      if (!_coreData.playingHostIDs.contains(user.userInfo.id)) {
        ZegoLoggerService.logInfo(
          '${user.userInfo.id} is not playing, ignore',
          tag: 'live streaming',
          subTag: 'pk service',
        );
        continue;
      }

      ZegoLoggerService.logInfo(
        'stop play ${user.userInfo.id}',
        tag: 'live streaming',
        subTag: 'pk service',
      );
      _coreData.playingHostIDs.remove(user.userInfo.id);
      await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
        user.userInfo.id,
      );
    }

    /// update room property, notify the host info && layout
    await ZegoUIKit().getSignalingPlugin().updateRoomProperties(
          roomID: _coreData.roomID,
          roomProperties: {
            roomPropKeyRequestID: _coreData.currentRequestID,
            roomPropKeyHost: ZegoUIKit().getLocalUser().id,
            roomPropKeyPKUsers: jsonEncode(
              _coreData.currentPKUsers.value,
            )
          },
          isForce: true,
          isUpdateOwner: true,
        );

    if (onlyLocalInPK) {
      /// all leave but only local
      await quitPKBattle(requestID: _coreData.currentRequestID);
    }
  }

  Future<void> hostDisconnectedOnPKUsersChanged() async {
    ZegoLoggerService.logInfo(
      'hostDisconnectedOnPKUsersChanged,'
      'pk users:${_coreData.currentPKUsers.value.toSimpleString()}',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    if (pkStateNotifier.value != ZegoLiveStreamingPKBattleStateV2.idle) {
      /// ready to quit pk state

      final isMicrophoneOn = ZegoUIKit()
          .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
          .value;
      ZegoUIKit().turnMicrophoneOn(isMicrophoneOn, muteMode: true);

      /// stop play other room user stream
      for (var hostID in _coreData.playingHostIDs) {
        if (ZegoUIKit().getLocalUser().id == hostID) {
          continue;
        }
        await ZegoUIKit().stopPlayAnotherRoomAudioVideo(hostID);
      }
      _coreData.playingHostIDs.clear();

      /// stop mixer
      await _mixer.stopTask();

      /// delete room property, notify the host info && layout
      await ZegoUIKit().getSignalingPlugin().deleteRoomProperties(
        roomID: _coreData.roomID,
        keys: [roomPropKeyRequestID, roomPropKeyHost, roomPropKeyPKUsers],
      );

      await quitPKBattle(requestID: _coreData.currentRequestID);

      updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);
    }
  }

  Future<void> audienceOnPKUsersChanged() async {
    ZegoLoggerService.logInfo(
      'audienceOnPKUsersChanged, '
      'pk users:${_coreData.currentPKUsers.value.toSimpleString()}',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    if (_coreData.currentPKUsers.value.isEmpty ||
        (_coreData.currentPKUsers.value.length == 1 &&
            _coreData.currentPKUsers.value.first.userInfo.id ==
                _coreData.hostManager?.notifier.value?.id)) {
      ///  pk users is empty or only local room host, not in pk
      return;
    }

    /// hide invite join co-host dialog
    if (_coreData
            .hostManager?.connectManager?.isInvitedToJoinCoHostDlgVisible ??
        false) {
      _coreData.hostManager?.connectManager!.isInvitedToJoinCoHostDlgVisible =
          false;
      Navigator.of(
        _coreData.contextQuery!(),
        rootNavigator: _coreData.prebuiltConfig?.rootNavigator ?? false,
      ).pop();
    }

    /// hide co-host end request dialog
    if (_coreData.hostManager?.connectManager?.isEndCoHostDialogVisible ??
        false) {
      _coreData.hostManager?.connectManager!.isEndCoHostDialogVisible = false;
      Navigator.of(
        _coreData.contextQuery!(),
        rootNavigator: _coreData.prebuiltConfig?.rootNavigator ?? false,
      ).pop();
    }

    /// cancel audience's co-host request
    if (ZegoLiveStreamingAudienceConnectState.connecting ==
        _coreData.hostManager?.connectManager?.audienceLocalConnectStateNotifier
            .value) {
      _coreData.hostManager?.connectManager?.updateAudienceConnectState(
        ZegoLiveStreamingAudienceConnectState.idle,
      );
      ZegoUIKit().getSignalingPlugin().cancelInvitation(
        invitees: [
          _coreData.hostManager?.notifier.value?.id ?? _coreData.propertyHostID
        ],
        data: '',
      );
    } else if (ZegoLiveStreamingAudienceConnectState.connected ==
        _coreData.hostManager?.connectManager?.audienceLocalConnectStateNotifier
            .value) {
      _coreData.hostManager?.connectManager?.updateAudienceConnectState(
        ZegoLiveStreamingAudienceConnectState.idle,
      );

      final dialogInfo = _coreData.innerText!.coHostEndCauseByHostStartPK;
      showLiveDialog(
        context: context,
        rootNavigator: _coreData.prebuiltConfig?.rootNavigator ?? false,
        title: dialogInfo.title,
        content: dialogInfo.message,
        rightButtonText: dialogInfo.confirmButtonName,
      );
    }

    /// pk process
    await _mixer.startPlayStream(List.from(_coreData.currentPKUsers.value));

    final mixAudioVideoLoaded =
        ZegoUIKit().getMixAudioVideoLoadedNotifier(_mixer.mixerID);
    if (mixAudioVideoLoaded.value) {
      /// load done
      updatePKState(ZegoLiveStreamingPKBattleStateV2.inPK);
      ZegoUIKit().muteUserAudioVideo(
        _coreData.hostManager?.notifier.value?.id ?? _coreData.propertyHostID,
        true,
      );
    } else {
      updatePKState(ZegoLiveStreamingPKBattleStateV2.loading);
      mixAudioVideoLoaded.addListener(onMixAudioVideoLoadStatusChanged);
    }
  }

  void onMixAudioVideoLoadStatusChanged() {
    final mixAudioVideoLoaded =
        ZegoUIKit().getMixAudioVideoLoadedNotifier(_mixer.mixerID);
    mixAudioVideoLoaded.removeListener(onMixAudioVideoLoadStatusChanged);

    if (mixAudioVideoLoaded.value) {
      updatePKState(ZegoLiveStreamingPKBattleStateV2.inPK);

      ZegoUIKit().muteUserAudioVideo(
        _coreData.hostManager?.notifier.value?.id ?? _coreData.propertyHostID,
        true,
      );
    }
  }
}
