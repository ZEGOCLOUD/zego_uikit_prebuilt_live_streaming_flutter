part of 'services.dart';

extension PKServiceConnectedUsers on ZegoUIKitPrebuiltLiveStreamingPKServices {
  List<ZegoLiveStreamingPKUser> get removedPKUsersCompareCurrent {
    List<ZegoLiveStreamingPKUser> removedUsers = [];

    final currentPKUserIDs =
        _coreData.currentPKUsers.value.map((e) => e.userInfo.id).toList();
    for (var user in _coreData.previousPKUsers.value) {
      if (!currentPKUserIDs.contains(user.userInfo.id)) {
        removedUsers.add(user);
      }
    }

    return removedUsers;
  }

  List<ZegoLiveStreamingPKUser> get addedPKUsersCompareCurrent {
    List<ZegoLiveStreamingPKUser> addedUsers = [];

    final previousPKUserIDs =
        _coreData.previousPKUsers.value.map((e) => e.userInfo.id).toList();
    for (var user in _coreData.currentPKUsers.value) {
      if (!previousPKUserIDs.contains(user.userInfo.id)) {
        addedUsers.add(user);
      }
    }

    return addedUsers;
  }

  List<ZegoLiveStreamingPKUser> removeDuplicatePKUsers(
    List<ZegoLiveStreamingPKUser> updatedPKUsers,
  ) {
    List<ZegoLiveStreamingPKUser> distinctPKUsers = [];
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

  Future<void> updatePKUsers(
    List<ZegoLiveStreamingPKUser> tempUpdatedPKUsers,
  ) async {
    var updatedPKUsers = removeDuplicatePKUsers(tempUpdatedPKUsers);

    final currentPKUserIDs =
        _coreData.currentPKUsers.value.map((e) => e.userInfo.id).toList();
    final updatedPKUserIDs = updatedPKUsers.map((e) => e.userInfo.id).toList();
    if (!const DeepCollectionEquality().equals(
      currentPKUserIDs,
      updatedPKUserIDs,
    )) {
      _coreData.previousPKUsers.value =
          List<ZegoLiveStreamingPKUser>.from(_coreData.currentPKUsers.value);
      for (var pkUser in updatedPKUsers) {
        pkUser.heartbeat = DateTime.now();

        if (pkUser.heartbeatBrokenNotifier.value) {
          ZegoLoggerService.logInfo(
            'un-mute ${pkUser.userInfo.id} audio',
            tag: 'live.streaming.pk.services.users',
            subTag: 'updatePKUsers',
          );

          ZegoUIKit().muteUserAudio(
            targetRoomID: liveID,
            pkUser.userInfo.id,
            false,
          );

          _coreData.events?.pk.onUserReconnected?.call(
            pkUser.toUIKitUser,
          );
        }
        pkUser.heartbeatBrokenNotifier.value = false;
        ZegoLoggerService.logInfo(
          'user is not broken:$pkUser, ',
          tag: 'live.streaming.pk.events',
          subTag: 'heartbeat',
        );
      }

      ZegoLoggerService.logInfo(
        'previous:${_coreData.previousPKUsers.value}, '
        'current:$updatedPKUsers, '
        'current details:$updatedPKUsers, ',
        tag: 'live.streaming.pk.services.users',
        subTag: 'updatePKUsers',
      );
      _coreData.currentPKUsers.value = updatedPKUsers;
    } else {
      ZegoLoggerService.logInfo(
        'user is same, ignore, '
        'current:${_coreData.currentPKUsers}, '
        'target:$updatedPKUsers, ',
        tag: 'live.streaming.pk.services.users',
        subTag: 'updatePKUsers',
      );
    }
  }

  void listenPKUserChanged() {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.pk.services.users',
      subTag: 'listenPKUserChanged',
    );

    removeListenPKUserChanged();

    _coreData.connectingPKUsers.addListener(onConnectingPKUsersChanged);
    _coreData.currentPKUsers.addListener(onPKUsersChanged);
  }

  void removeListenPKUserChanged() {
    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.pk.services.users',
      subTag: 'removeListenPKUserChanged',
    );

    _coreData.connectingPKUsers.removeListener(onConnectingPKUsersChanged);
    _coreData.currentPKUsers.removeListener(onPKUsersChanged);
  }

  void onConnectingPKUsersChanged() {
    ZegoLoggerService.logInfo(
      'live id:$liveID, '
      '${_coreData.connectingPKUsers.value}, ',
      tag: 'live.streaming.pk.services.users',
      subTag: 'onConnectingPKUsersChanged',
    );
  }

  Future<void> onPKUsersChanged() async {
    ZegoLoggerService.logInfo(
      'live id:$liveID, '
      'isLiving;$isLiving, '
      'pk users:${_coreData.currentPKUsers.value}, ',
      tag: 'live.streaming.pk.services.users',
      subTag: 'onPKUsersChanged',
    );

    if (!isLiving) {
      return;
    }

    /// 注意：不能直接简化为 isHost ? await hostOnPKUsersChanged() : await audienceOnPKUsersChanged();
    /// 原因：waitCompleter 和 completeCompleter 提供了同步机制，确保同一时间只有一个 onPKUsersChanged 在执行
    /// 1. waitCompleter('onPKUsersChanged'): 等待上一次 onPKUsersChanged 调用完成（如果存在），然后创建新的 Completer
    /// 2. 执行业务逻辑：根据 isHost 调用对应的处理方法
    /// 3. completeCompleter('onPKUsersChanged'): 标记当前调用完成，允许下一次调用继续执行
    /// 如果直接简化，会失去同步保护，可能导致：
    /// - 并发执行：多次快速调用 onPKUsersChanged 可能同时执行
    /// - 状态竞争：可能同时修改共享状态（如 _coreData.currentPKUsers）
    /// - 资源冲突：可能同时操作音视频资源（如播放流、混流等）
    return waitCompleter('onPKUsersChanged').then((_) async {
      isHost ? await hostOnPKUsersChanged() : await audienceOnPKUsersChanged();
    }).then((_) {
      completeCompleter('onPKUsersChanged');
    });
  }

  Future<void> hostOnPKUsersChanged() async {
    final isLocalHostInPK = -1 !=
        _coreData.currentPKUsers.value.indexWhere(
            (pkUser) => pkUser.userInfo.id == ZegoUIKit().getLocalUser().id);

    ZegoLoggerService.logInfo(
      'live id:$liveID, '
      'isLocalHostInPK:$isLocalHostInPK, '
      'pk users:${_coreData.currentPKUsers.value}',
      tag: 'live.streaming.pk.services.users',
      subTag: 'hostOnPKUsersChanged',
    );

    return isLocalHostInPK
        ? await connectedHostOnPKUsersChanged()
        : await disconnectedHostOnPKUsersChanged();
  }

  Future<void> connectedHostOnPKUsersChanged() async {
    final onlyLocalInPK = _coreData.currentPKUsers.value.length == 1 &&
        _coreData.currentPKUsers.value.first.userInfo.id ==
            ZegoUIKit().getLocalUser().id;

    ZegoLoggerService.logInfo(
      'live id:$liveID, '
      'onlyLocalInPK:$onlyLocalInPK, '
      'pk users:${_coreData.currentPKUsers.value}, '
      'previousPKUsers:${_coreData.previousPKUsers.value}, '
      'addedPKUsersCompareCurrent:$addedPKUsersCompareCurrent, '
      'removedPKUsersCompareCurrent:$removedPKUsersCompareCurrent, '
      'playing user id:${_coreData.playingHostIDs}',
      tag: 'live.streaming.pk.services.users',
      subTag: 'connectedHostOnPKUsersChanged',
    );

    if (!isInPK) {
      /// not in pk now, init pk
      updatePKState(ZegoLiveStreamingPKBattleState.inPK);

      final isMicrophoneOn = ZegoUIKit()
          .getMicrophoneStateNotifier(
            targetRoomID: liveID,
            ZegoUIKit().getLocalUser().id,
          )
          .value;
      ZegoUIKit().turnMicrophoneOn(
        targetRoomID: liveID,
        isMicrophoneOn,
        muteMode: true,
      );
    }

    /// update mixer layout
    await _mixer.updateTask(List.from(_coreData.currentPKUsers.value));

    /// start play other room user stream
    ZegoLoggerService.logInfo(
      'live id:$liveID, '
      'try play ${_coreData.currentPKUsers.value}\'s stream',
      tag: 'live.streaming.pk.services.users',
      subTag: 'connectedHostOnPKUsersChanged',
    );
    for (var user in _coreData.currentPKUsers.value) {
      if (ZegoUIKit().getLocalUser().id == user.userInfo.id) {
        continue;
      }

      if (_coreData.playingHostIDs.contains(user.userInfo.id)) {
        ZegoLoggerService.logInfo(
          'live id:$liveID, '
          '${user.userInfo.id} is playing, ignore',
          tag: 'live.streaming.pk.services.users',
          subTag: 'connectedHostOnPKUsersChanged',
        );
        continue;
      }

      ZegoLoggerService.logInfo(
        'live id:$liveID, '
        'start play ${user.userInfo.id}',
        tag: 'live.streaming.pk.services.users',
        subTag: 'connectedHostOnPKUsersChanged',
      );
      _coreData.playingHostIDs.add(user.userInfo.id);

      final targetStreamID = ZegoUIKit().getGeneratedStreamID(
        user.userInfo.id,
        user.liveID,
        ZegoStreamType.main,
      );
      ZegoLiveStreamingReporter().report(
        event: ZegoLiveStreamingReporter.eventPKStartPlay,
        params: {
          ZegoLiveStreamingReporter.eventKeyCallID: _coreData.currentRequestID,
          ZegoLiveStreamingReporter.eventKeyStreamID: targetStreamID,
        },
      );
      await ZegoUIKit().startPlayAnotherRoomAudioVideo(
        targetRoomID: liveID,
        user.liveID,
        user.userInfo.id,
        anotherUserName: user.userInfo.name,

        /// 同ZegoLiveStreamingPKHostView ZegoAudioVideoView 的 roomID 逻辑保持一致
        /// playOnAnotherRoom true，那么就是 host 的 room id
        /// playOnAnotherRoom false, 那么就是当前直播间的 room id
        playOnAnotherRoom: false,
        onPlayerStateUpdated: (
          ZegoUIKitPlayerState state,
          int errorCode,
          Map<String, dynamic> extendedData,
        ) {
          if (ZegoUIKitPlayerState.Playing == state) {
            ZegoLiveStreamingReporter().report(
              event: ZegoLiveStreamingReporter.eventPKStartPlayFinished,
              params: {
                ZegoLiveStreamingReporter.eventKeyCallID:
                    _coreData.currentRequestID,
                ZegoLiveStreamingReporter.eventKeyStreamID: targetStreamID,
                ZegoLiveStreamingReporter.eventKeyError: errorCode,
              },
            );
          }
        },
      );
    }

    /// stop play other room user stream
    ZegoLoggerService.logInfo(
      'live id:$liveID, '
      'try stop $removedPKUsersCompareCurrent\'s stream',
      tag: 'live.streaming.pk.services.users',
      subTag: 'connectedHostOnPKUsersChanged',
    );
    for (var user in removedPKUsersCompareCurrent) {
      if (!_coreData.playingHostIDs.contains(user.userInfo.id)) {
        ZegoLoggerService.logInfo(
          'live id:$liveID, '
          '${user.userInfo.id} is not playing, ignore, ',
          tag: 'live.streaming.pk.services.users',
          subTag: 'connectedHostOnPKUsersChanged',
        );
        continue;
      }

      ZegoLoggerService.logInfo(
        'live id:$liveID, '
        'stop play ${user.userInfo.id}, ',
        tag: 'live.streaming.pk.services.users',
        subTag: 'connectedHostOnPKUsersChanged',
      );
      _coreData.playingHostIDs.remove(user.userInfo.id);
      await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
        targetRoomID: liveID,
        user.userInfo.id,
      );
    }

    /// update room property, notify the host info && layout
    await ZegoUIKit().getSignalingPlugin().updateRoomProperties(
          roomID: liveID,
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

  Future<void> disconnectedHostOnPKUsersChanged() async {
    ZegoLoggerService.logInfo(
      'pk users:${_coreData.currentPKUsers.value}',
      tag: 'live.streaming.pk.services.users',
      subTag: 'disconnectedHostOnPKUsersChanged',
    );

    if (pkStateNotifier.value != ZegoLiveStreamingPKBattleState.idle) {
      /// ready to quit pk state

      final isMicrophoneOn = ZegoUIKit()
          .getMicrophoneStateNotifier(
            targetRoomID: liveID,
            ZegoUIKit().getLocalUser().id,
          )
          .value;
      ZegoUIKit().turnMicrophoneOn(
        targetRoomID: liveID,
        isMicrophoneOn,
        muteMode: true,
      );

      /// stop play other room user stream
      for (var hostID in _coreData.playingHostIDs) {
        if (ZegoUIKit().getLocalUser().id == hostID) {
          continue;
        }
        await ZegoUIKit().stopPlayAnotherRoomAudioVideo(
          targetRoomID: liveID,
          hostID,
        );
      }
      _coreData.playingHostIDs.clear();

      /// stop mixer
      await _mixer.stopTask();

      /// delete room property, notify the host info && layout
      await ZegoUIKit().getSignalingPlugin().deleteRoomProperties(
        roomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        keys: [roomPropKeyRequestID, roomPropKeyHost, roomPropKeyPKUsers],
      );

      await quitPKBattle(requestID: _coreData.currentRequestID);

      updatePKState(ZegoLiveStreamingPKBattleState.idle);
    }
  }

  Future<void> audienceOnPKUsersChanged() async {
    ZegoLoggerService.logInfo(
      'pk users:${_coreData.currentPKUsers.value}',
      tag: 'live.streaming.pk.services.users',
      subTag: 'audienceOnPKUsersChanged(liveID:$liveID)',
    );

    final onlyLocalHostInPK = _coreData.currentPKUsers.value.length == 1 &&
        _coreData.currentPKUsers.value.first.userInfo.id ==
            ZegoLiveStreamingPageLifeCycle()
                .manager(liveID)
                .hostManager
                .notifier
                .value
                ?.id;
    if (_coreData.currentPKUsers.value.isEmpty || onlyLocalHostInPK) {
      ZegoLoggerService.logInfo(
        'pk users is empty or only local room host, not in pk, '
        'onlyLocalHostInPK:$onlyLocalHostInPK, ',
        tag: 'live.streaming.pk.services.users',
        subTag: 'audienceOnPKUsersChanged(liveID:$liveID)',
      );
      return;
    }

    /// hide invite join co-host dialog
    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .connectManager
        .isInvitedToJoinCoHostDlgVisible) {
      ZegoLoggerService.logInfo(
        'hide invite join co-host dialog',
        tag: 'live.streaming.pk.services.users',
        subTag: 'audienceOnPKUsersChanged(liveID:$liveID)',
      );
      ZegoLiveStreamingPageLifeCycle()
          .manager(liveID)
          .connectManager
          .isInvitedToJoinCoHostDlgVisible = false;

      Navigator.of(
        ZegoLiveStreamingPageLifeCycle().contextQuery!(),
        rootNavigator: _coreData.prebuiltConfig?.rootNavigator ?? false,
      ).pop();
    }

    /// hide co-host end request dialog
    if (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .connectManager
        .isEndCoHostDialogVisible) {
      ZegoLoggerService.logInfo(
        'hide co-host end request dialog',
        tag: 'live.streaming.pk.services.users',
        subTag: 'audienceOnPKUsersChanged(liveID:$liveID)',
      );
      ZegoLiveStreamingPageLifeCycle()
          .manager(liveID)
          .connectManager
          .isEndCoHostDialogVisible = false;

      Navigator.of(
        ZegoLiveStreamingPageLifeCycle().contextQuery!(),
        rootNavigator: _coreData.prebuiltConfig?.rootNavigator ?? false,
      ).pop();
    }

    ZegoLoggerService.logInfo(
      'audienceLocalConnectStateNotifier.value:${ZegoLiveStreamingPageLifeCycle().manager(liveID).connectManager.audienceLocalConnectStateNotifier.value}',
      tag: 'live.streaming.pk.services.users',
      subTag: 'audienceOnPKUsersChanged(liveID:$liveID)',
    );

    switch (ZegoLiveStreamingPageLifeCycle()
        .manager(liveID)
        .connectManager
        .audienceLocalConnectStateNotifier
        .value) {
      case ZegoLiveStreamingAudienceConnectState.connecting:

        /// cancel audience's co-host request
        ZegoLiveStreamingPageLifeCycle()
            .manager(liveID)
            .connectManager
            .updateAudienceConnectState(
              ZegoLiveStreamingAudienceConnectState.idle,
            );
        ZegoUIKit().getSignalingPlugin().cancelInvitation(
          invitees: [
            ZegoLiveStreamingPageLifeCycle()
                    .manager(liveID)
                    .hostManager
                    .notifier
                    .value
                    ?.id ??
                _coreData.propertyHostID
          ],
          data: '',
        );
        break;
      case ZegoLiveStreamingAudienceConnectState.connected:
        ZegoLiveStreamingPageLifeCycle()
            .manager(liveID)
            .connectManager
            .updateAudienceConnectState(
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
        break;
      case ZegoLiveStreamingAudienceConnectState.idle:
        break;
    }

    /// pk process
    ZegoLiveStreamingReporter().report(
      event: ZegoLiveStreamingReporter.eventPKStartPlay,
      params: {
        ZegoLiveStreamingReporter.eventKeyCallID: _coreData.currentRequestID,
        ZegoLiveStreamingReporter.eventKeyStreamID: _mixer.mixerStreamID,
      },
    );
    ZegoLoggerService.logInfo(
      'start play pk stream, pk users:${_coreData.currentPKUsers.value}',
      tag: 'live.streaming.pk.services.users',
      subTag: 'audienceOnPKUsersChanged(liveID:$liveID)',
    );
    await _mixer.startPlayStream(
      List.from(_coreData.currentPKUsers.value),
      onPlayerStateUpdated: (
        ZegoUIKitPlayerState state,
        int errorCode,
        Map<String, dynamic> extendedData,
      ) {
        if (ZegoUIKitPlayerState.Playing == state) {
          ZegoLiveStreamingReporter().report(
            event: ZegoLiveStreamingReporter.eventPKStartPlayFinished,
            params: {
              ZegoLiveStreamingReporter.eventKeyCallID:
                  _coreData.currentRequestID,
              ZegoLiveStreamingReporter.eventKeyStreamID: _mixer.mixerStreamID,
              ZegoLiveStreamingReporter.eventKeyError: errorCode,
            },
          );
        }
      },
    ).then((_) {
      ZegoLoggerService.logInfo(
        'start play pk stream finished, pk users:${_coreData.currentPKUsers.value}',
        tag: 'live.streaming.pk.services.users',
        subTag: 'audienceOnPKUsersChanged(liveID:$liveID)',
      );
    });

    final mixAudioVideoLoaded = ZegoUIKit().getMixAudioVideoLoadedNotifier(
      targetRoomID: liveID,
      _mixer.mixerStreamID,
    );
    ZegoLoggerService.logInfo(
      'wait mixAudioVideoLoaded to be true, current value: ${mixAudioVideoLoaded.value}',
      tag: 'live.streaming.pk.services.users',
      subTag: 'audienceOnPKUsersChanged(liveID:$liveID)',
    );
    if (mixAudioVideoLoaded.value) {
      /// load done
      updatePKState(ZegoLiveStreamingPKBattleState.inPK);
      ZegoUIKit().muteUserAudioVideo(
        targetRoomID: liveID,
        ZegoLiveStreamingPageLifeCycle()
                .manager(liveID)
                .hostManager
                .notifier
                .value
                ?.id ??
            _coreData.propertyHostID,
        true,
      );
    } else {
      updatePKState(ZegoLiveStreamingPKBattleState.loading);
      mixAudioVideoLoaded.addListener(onMixAudioVideoLoadStatusChanged);
    }
  }

  void onMixAudioVideoLoadStatusChanged() {
    final mixAudioVideoLoaded = ZegoUIKit().getMixAudioVideoLoadedNotifier(
      targetRoomID: liveID,
      _mixer.mixerStreamID,
    );
    mixAudioVideoLoaded.removeListener(onMixAudioVideoLoadStatusChanged);

    if (mixAudioVideoLoaded.value) {
      updatePKState(ZegoLiveStreamingPKBattleState.inPK);

      ZegoUIKit().muteUserAudioVideo(
        targetRoomID: liveID,
        ZegoLiveStreamingPageLifeCycle()
                .manager(liveID)
                .hostManager
                .notifier
                .value
                ?.id ??
            _coreData.propertyHostID,
        true,
      );
    }
  }
}
