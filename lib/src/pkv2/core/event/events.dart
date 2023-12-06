part of '../service/services.dart';

extension ZegoUIKitPrebuiltLiveStreamingPKEventsV2
    on ZegoUIKitPrebuiltLiveStreamingPKServicesV2 {
  bool get rootNavigator => _coreData.prebuiltConfig?.rootNavigator ?? false;

  ZegoInnerText get innerText =>
      _coreData.prebuiltConfig?.innerText ?? ZegoInnerText();

  void initEvents() {
    if (_eventInitialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live streaming',
        subTag: 'pk event',
      );

      return;
    }

    _eventInitialized = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    if (isHost) {
      _initHeartBeatTimer();
    }
    _coreData.hostManager?.notifier.addListener(_onHostUpdated);

    _listenEvents();
    queryRoomProperties();
  }

  void _onHostUpdated() {
    if (isHost) {
      _initHeartBeatTimer();
    } else {
      _heartBeatTimer?.cancel();
      _heartBeatTimer = null;
    }
  }

  void onWaitingQueryRoomProperties(
    ZegoSignalingPluginRoomStateChangedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onWaitingQueryRoomProperties, event:$event',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    _waitingQueryRoomPropertiesSubscription?.cancel();
    queryRoomProperties();
  }

  void queryRoomProperties() {
    ZegoLoggerService.logInfo(
      'queryRoomProperties',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    final signalingRoomState = ZegoUIKit().getSignalingPlugin().getRoomState();
    if (ZegoSignalingPluginRoomState.connected != signalingRoomState) {
      ZegoLoggerService.logInfo(
        'room state($signalingRoomState) is not connected, wait...',
        tag: 'live streaming',
        subTag: 'pk event',
      );

      _waitingQueryRoomPropertiesSubscription = ZegoUIKit()
          .getSignalingPlugin()
          .getRoomStateStream()
          .listen(onWaitingQueryRoomProperties);
    } else {
      ZegoUIKit()
          .getSignalingPlugin()
          .queryRoomProperties(
            roomID: ZegoUIKit().getSignalingPlugin().getRoomID(),
          )
          .then((result) async {
        ZegoLoggerService.logInfo(
          'queryRoomProperties done: $result',
          tag: 'live streaming',
          subTag: 'pk event',
        );

        if (result.properties.containsKey(roomPropKeyRequestID)) {
          ZegoLoggerService.logInfo(
            'room property contain pk keys, quit pk',
            tag: 'live streaming',
            subTag: 'pk event',
          );

          quitPKBattle(
            requestID: result.properties[roomPropKeyRequestID] ?? '',
            force: true,
          );
        }

        /// After entering the room, if found that there was a PK going on,
        /// which indicates that the app was killed earlier.
        /// At this time, It cannot re-enter the PK.
        await ZegoUIKit().getSignalingPlugin().deleteRoomProperties(
          roomID: ZegoUIKit().getSignalingPlugin().getRoomID(),
          keys: [roomPropKeyRequestID, roomPropKeyHost, roomPropKeyPKUsers],
        );
      });
    }
  }

  void uninitEvents() {
    if (!_eventInitialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live streaming',
        subTag: 'pk event',
      );

      return;
    }

    _eventInitialized = false;
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    _coreData.hostManager?.notifier.removeListener(_onHostUpdated);
    _heartBeatTimer?.cancel();
    _heartBeatTimer = null;
    _waitingQueryRoomPropertiesSubscription?.cancel();
    for (final subscription in _eventSubscriptions) {
      subscription?.cancel();
    }
  }

  void _onInvitationUserStateChanged(
    ZegoSignalingPluginInvitationUserStateChangedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'onInvitationUserStateChanged, event:$event',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    if (null ==
        ZegoUIKit()
            .getSignalingPlugin()
            .getAdvanceInitiator(event.invitationID)) {
      /// a->b, b->c;
      /// in c event, a is initiator, b is inviter

      ZegoLoggerService.logInfo(
        'event is not advance invitation',
        tag: 'live streaming',
        subTag: 'pk event',
      );

      return;
    }

    for (var userInfo in event.callUserList) {
      if (userInfo.userID == ZegoUIKit().getLocalUser().id) {
        _onLocalInvitationUserStateChanged(event.invitationID, userInfo);
      } else {
        _onRemoteInvitationUserStateChanged(event.invitationID, userInfo);
      }
    }
  }

  void _onLocalInvitationUserStateChanged(
    String requestID,
    ZegoSignalingPluginInvitationUserInfo userInfo,
  ) {
    ZegoLoggerService.logInfo(
      '_onLocalInvitationUserStateChanged, user info:$userInfo',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    switch (userInfo.state) {
      case ZegoSignalingPluginInvitationUserState.timeout:
        updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);

        popupRequestReceivedDialog();
        break;
      case ZegoSignalingPluginInvitationUserState.accepted:
        if (ZegoUIKit()
                .getSignalingPlugin()
                .getAdvanceInitiator(requestID)
                ?.userID !=
            ZegoUIKit().getLocalUser().id) {
          /// a->b, b->c;
          /// in c event, a is initiator, b is inviter
          ///
          /// invitee accept, need to update to pk state, because only update to loading
          /// when call acceptPKBattleRequest->startPKBattle
          updatePKState(ZegoLiveStreamingPKBattleStateV2.inPK);
        }
        break;
      case ZegoSignalingPluginInvitationUserState.inviting:
      case ZegoSignalingPluginInvitationUserState.rejected:
      case ZegoSignalingPluginInvitationUserState.cancelled:
      case ZegoSignalingPluginInvitationUserState.offline:
      case ZegoSignalingPluginInvitationUserState.received:
      case ZegoSignalingPluginInvitationUserState.ended:
      case ZegoSignalingPluginInvitationUserState.unknown:
        break;
      case ZegoSignalingPluginInvitationUserState.quited:
        _coreData.events?.pkV2Events.onUserQuited?.call(
            ZegoPKBattleUserQuitEventV2(
              requestID: requestID,
              fromHost: ZegoUIKit().getLocalUser(),
            ),
            () {});
        break;
    }
  }

  void _onRemoteInvitationUserStateChanged(
    String requestID,
    ZegoSignalingPluginInvitationUserInfo remoteUserInfo,
  ) {
    /// a->b, b->c;
    /// in c event, a is initiator, b is inviter
    final sessionInitiator =
        ZegoUIKit().getSignalingPlugin().getAdvanceInitiator(requestID);

    ZegoLoggerService.logInfo(
      '_onRemoteInvitationUserStateChanged, '
      'sessionInitiator:$sessionInitiator, '
      'user info:$remoteUserInfo, ',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    var extendedDataMap = <String, dynamic>{};
    try {
      extendedDataMap =
          jsonDecode(remoteUserInfo.extendedData) as Map<String, dynamic>? ??
              {};
    } catch (e) {
      ZegoLoggerService.logInfo(
        'extendedData is not a json:${remoteUserInfo.extendedData}',
        tag: 'live streaming',
        subTag: 'pk event',
      );
    }

    switch (remoteUserInfo.state) {
      case ZegoSignalingPluginInvitationUserState.unknown:
        break;
      case ZegoSignalingPluginInvitationUserState.inviting:
        break;
      case ZegoSignalingPluginInvitationUserState.accepted:
        final tempSessionHost = _getSessionHostNameAndLiveIDFromExtendedData(
          remoteUserInfo.extendedData,
        );
        final String fromLiveID = tempSessionHost.fromLiveID;
        final fromHost = ZegoUIKitUser(
          id: remoteUserInfo.userID,
          name: tempSessionHost.name,
        );

        /// It may not be a self-initiated request and may also receive remote reject/agree, so it needs to be distinguished.
        ///
        /// a->b, b->c;
        /// in c event, a is initiator, b is inviter
        var isRequestFromLocal =
            ZegoUIKit().getLocalUser().id == sessionInitiator?.userID;
        if (isRequestFromLocal) {
          _onInvitationAccepted(ZegoOutgoingPKBattleRequestAcceptedEventV2(
            requestID: requestID,
            fromHost: fromHost,
            fromLiveID: fromLiveID,
          ));
        } else {
          /// invitees(other room's host) accept, update connected users
          updatePKUsers(
            List.from(_coreData.currentPKUsers.value)
              ..add(
                ZegoUIKitPrebuiltLiveStreamingPKUser(
                  userInfo: fromHost,
                  liveID: fromLiveID,
                ),
              ),
          );
        }
        break;
      case ZegoSignalingPluginInvitationUserState.rejected:
        bool isRequestFromLocal = false;
        try {
          final pkRejectData = PKServiceV2RejectData.fromJson(
            jsonDecode(remoteUserInfo.extendedData) as Map<String, dynamic>? ??
                {},
          );
          isRequestFromLocal =
              ZegoUIKit().getLocalUser().id == pkRejectData.inviterID;
        } catch (e) {
          debugPrint(
              'reject extended data, not a json:${remoteUserInfo.extendedData}');
        }

        if (isRequestFromLocal) {
          final int refuseCode = extendedDataMap['code'] ??
              ZegoLiveStreamingPKBattleRejectCodeV2.reject.index;
          final String fromHostUserName = extendedDataMap['invitee_name'] ?? '';
          _onInvitationRefused(ZegoOutgoingPKBattleRequestRejectedEventV2(
            requestID: requestID,
            fromHost: ZegoUIKitUser(
                id: remoteUserInfo.userID, name: fromHostUserName),
            refuseCode: refuseCode,
          ));
        }
        break;
      case ZegoSignalingPluginInvitationUserState.cancelled:
        // do nothing
        break;
      case ZegoSignalingPluginInvitationUserState.received:
        // do nothing
        break;
      case ZegoSignalingPluginInvitationUserState.timeout:
        _onInvitationResponseTimeout(
          ZegoOutgoingPKBattleRequestTimeoutEventV2(
            requestID: requestID,
            fromHost: ZegoUIKitUser(id: remoteUserInfo.userID, name: ''),
          ),
        );
        break;
      case ZegoSignalingPluginInvitationUserState.offline:
        _onInvitationUserOffline(
          ZegoPKBattleUserOfflineEventV2(
            requestID: requestID,
            fromHost: ZegoUIKitUser(id: remoteUserInfo.userID, name: ''),
          ),
        );
        break;
      case ZegoSignalingPluginInvitationUserState.quited:
        final String fromHostUserName = extendedDataMap['invitee_name'] ?? '';
        _onInvitationUserQuit(
          ZegoPKBattleUserQuitEventV2(
            requestID: requestID,
            fromHost: ZegoUIKitUser(
              id: remoteUserInfo.userID,
              name: fromHostUserName,
            ),
          ),
        );
        break;
      case ZegoSignalingPluginInvitationUserState.ended:
        // TODO: Handle this case.
        break;
    }
  }

  void _initHeartBeatTimer() {
    _heartBeatTimer?.cancel();
    _heartBeatTimer = null;

    _heartBeatTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (timer) {
        final now = DateTime.now();
        final tempBrokenIDs = <String>[];
        final alreadyBrokenIDs = <String>[];
        for (var pkUser in _coreData.currentPKUsers.value) {
          if (ZegoUIKit().getLocalUser().id == pkUser.userInfo.id ||
              null == pkUser.heartbeat) {
            continue;
          }

          final offlineSeconds = now.difference(pkUser.heartbeat!).inSeconds;
          if (offlineSeconds >
              (_coreData.prebuiltConfig?.pkBattleV2Config
                      .userDisconnectedSecond ??
                  60)) {
            alreadyBrokenIDs.add(pkUser.userInfo.id);

            _coreData.events?.pkV2Events.onUserDisconnected?.call(
              pkUser.toUIKitUser,
            );
          } else if (offlineSeconds >
                  (_coreData.prebuiltConfig?.pkBattleV2Config
                          .userReconnectingSecond ??
                      5) &&
              !(pkUser.heartbeatBrokenNotifier.value)) {
            ZegoLoggerService.logInfo(
              'heartbeat timer, ${pkUser.userInfo.id} heartbeat had broken,'
              'heartbeat: ${pkUser.heartbeat}, '
              'now:$now, mute audio',
              tag: 'live streaming',
              subTag: 'pk event',
            );

            ZegoUIKit().muteUserAudio(pkUser.userInfo.id, true);

            tempBrokenIDs.add(pkUser.userInfo.id);
            pkUser.heartbeatBrokenNotifier.value = true;

            _coreData.events?.pkV2Events.onUserReconnecting?.call(
              pkUser.toUIKitUser,
            );
          }
        }
        if (tempBrokenIDs.isNotEmpty) {
          ZegoLoggerService.logInfo(
            'heartbeat timer, temp broken user:$tempBrokenIDs, ',
            tag: 'live streaming',
            subTag: 'pk event',
          );
        }

        if (alreadyBrokenIDs.isNotEmpty) {
          ZegoLoggerService.logInfo(
            'heartbeat timer, $alreadyBrokenIDs heartbeat had broken so long, remove from pk,',
            tag: 'live streaming',
            subTag: 'pk event',
          );

          updatePKUsers(
            List.from(_coreData.currentPKUsers.value)
              ..removeWhere(
                (pkUser) => alreadyBrokenIDs.contains(pkUser.userInfo.id),
              ),
          );
        }
      },
    );
  }

  void _listenEvents() {
    if (_coreData.prebuiltConfig?.plugins.isEmpty ?? true) {
      ZegoLoggerService.logInfo(
        'listen, but plugin is empty',
        tag: 'live streaming',
        subTag: 'pk event',
      );
    }

    ZegoLoggerService.logInfo(
      'listen',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    _eventSubscriptions
      ..add(ZegoUIKit().getReceiveSEIStream().where((event) {
        return event.typeIdentifier ==
            ZegoUIKitInnerSEIType.mixerDeviceState.name;
      }).listen(_onReceiveSEIEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getRoomPropertiesStream()
          .listen(_onRoomAttributesUpdated))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationUserStateChangedStream()
          .listen(_onInvitationUserStateChanged))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationReceivedStream()
          .where((params) => ZegoInvitationTypeExtension.isPKV2Type(
              (params['type'] as int?) ?? -1))
          .map((params) {
        ZegoLoggerService.logInfo(
          'onInvitationReceived, params:$params',
          tag: 'live streaming',
          subTag: 'pk event',
        );

        final String requestID = params['invitation_id']!;
        final int timeoutSecond = params['timeout_second']!;
        final int createTimestampSecond = params['create_timestamp_second']!;

        final sessionHosts = _parseSessionHosts(
          requestID,
          params['session_invitees']! as List<Map<String, dynamic>>? ?? [],
        );

        final ZegoUIKitUser inviter = params['inviter']!;
        String inviterLiveID = '';

        /// a->b, b->c;
        /// in c event, a is initiator, b is inviter
        final initiatorPKRequestData = PKServiceV2RequestData.fromJson(
            jsonDecode(params['data']!) as Map<String, dynamic>);
        if (initiatorPKRequestData.inviter.id == inviter.id) {
          inviterLiveID = initiatorPKRequestData.liveID;
        } else {
          ///  a->b, b->c, find b(second inviter)
          for (var sessionHost in sessionHosts) {
            if (sessionHost.id != inviter.id) {
              continue;
            }

            if (sessionHost.customData.isEmpty) {
              continue;
            }

            final tempSessionHost =
                _getSessionHostNameAndLiveIDFromExtendedData(
              sessionHost.customData,
            );
            inviterLiveID = tempSessionHost.fromLiveID;
            inviter.name = tempSessionHost.name;
          }
        }

        return ZegoIncomingPKBattleRequestReceivedEventV2(
          fromLiveID: inviterLiveID,
          fromHost: inviter,
          startTimestampSecond: createTimestampSecond,
          timeoutSecond: timeoutSecond,
          isAutoAccept: initiatorPKRequestData.isAutoAccept,
          customData: initiatorPKRequestData.customData,
          requestID: requestID,
          sessionHosts: sessionHosts,
        );
      }).listen(_onInvitationReceived))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationCanceledStream()
          .where((params) => ZegoInvitationTypeExtension.isPKV2Type(
              (params['type'] as int?) ?? -1))
          .map((params) {
        ZegoLoggerService.logInfo(
          'onInvitationCanceled, params:$params, ',
          tag: 'live streaming',
          subTag: 'pk event',
        );

        final ZegoUIKitUser fromHost = params['inviter']!;
        final String requestID = params['invitation_id']!;
        return ZegoIncomingPKBattleRequestCancelledEventV2(
          requestID: requestID,
          fromHost: fromHost,
          customData: 'customData',
        );
      }).listen(_onInvitationCanceled))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationTimeoutStream()
          .where(
            (params) => ZegoInvitationTypeExtension.isPKV2Type(
                (params['type'] as int?) ?? -1),
          )
          .map((params) {
        ZegoLoggerService.logInfo(
          'onInvitationTimeout, params:$params',
          tag: 'live streaming',
          subTag: 'pk event',
        );

        final ZegoUIKitUser fromHost = params['inviter']!;
        final String requestID = params['invitation_id']!;
        return ZegoIncomingPKBattleRequestTimeoutEventV2(
          requestID: requestID,
          fromHost: fromHost,
        );
      }).listen(_onInvitationTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationEndedStream()
          .where(
            (params) => ZegoInvitationTypeExtension.isPKV2Type(
                (params['type'] as int?) ?? -1),
          )
          .map((params) {
        ZegoLoggerService.logInfo(
          'onInvitationEnded, params:$params, ',
          tag: 'live streaming',
          subTag: 'pk event',
        );

        final String requestID = params['invitation_id']!;
        final ZegoUIKitUser fromHost = params['inviter']!;
        final int endTime = params['end_time']!;

        final extendedDataMap =
            jsonDecode(params['data']!) as Map<String, dynamic>;
        final int endCode = extendedDataMap['code'] ??
            ZegoLiveStreamingPKBattleRejectCodeV2.reject.index;

        /// a->b, b->c;
        /// in c event, a is initiator, b is inviter
        var isRequestFromLocal = ZegoUIKit().getLocalUser().id ==
            ZegoUIKit()
                .getSignalingPlugin()
                .getAdvanceInitiator(requestID)
                ?.userID;

        return ZegoPKBattleEndedEventV2(
          isRequestFromLocal: isRequestFromLocal,
          requestID: requestID,
          fromHost: fromHost,
          time: endTime,
          code: endCode,
        );
      }).listen(_onInvitationEnded));
  }

  void _onReceiveSEIEvent(ZegoUIKitReceiveSEIEvent event) {
    final pkUserIndex = _coreData.currentPKUsers.value.indexWhere(
      (pkUser) => pkUser.userInfo.id == event.senderID,
    );
    if (-1 == pkUserIndex) {
      return;
    }

    var pkUser = _coreData.currentPKUsers.value.elementAt(pkUserIndex);
    pkUser.heartbeat = DateTime.now();

    if (pkUser.heartbeatBrokenNotifier.value) {
      /// user reconnected
      ZegoLoggerService.logInfo(
        'received ${pkUser.userInfo.id} sei, un-mute audio',
        tag: 'live streaming',
        subTag: 'pk event',
      );

      ZegoUIKit().muteUserAudio(pkUser.userInfo.id, false);

      _coreData.events?.pkV2Events.onUserReconnected?.call(
        pkUser.toUIKitUser,
      );
    }
    pkUser.heartbeatBrokenNotifier.value = false;

    // debugPrint('_onReceiveSEIEvent $event');
  }

  void _onRoomAttributesUpdated(
    ZegoSignalingPluginRoomPropertiesUpdatedEvent event,
  ) async {
    ZegoLoggerService.logInfo(
      'onRoomAttributesUpdated, event:$event',
      tag: 'live streaming',
      subTag: 'pk event',
    );
    _coreData.updatePropertyHostID(event);

    if (event.deleteProperties.containsKey(roomPropKeyPKUsers)) {
      if (!isHost) {
        await ZegoUIKit().muteUserAudioVideo(
          _coreData.hostManager?.notifier.value?.id ?? '',
          false,
        );
        await _mixer.stopPlayStream();

        updatePKUsers([]);
        updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);

        _coreData.prebuiltConfig?.onLiveStreamingStateUpdate?.call(
          isLiving
              ? ZegoLiveStreamingState.living
              : ZegoLiveStreamingState.idle,
        );
      }
    }

    if (event.setProperties.containsKey(roomPropKeyPKUsers)) {
      if (isHost) {
        /// wait start
        if (!_coreData.startedByLocalNotifier.value) {
          final completer = Completer<void>();
          void onLiveStartedByLocal() {
            if (_coreData.startedByLocalNotifier.value) {
              completer.complete();
            }
            _coreData.startedByLocalNotifier
                .removeListener(onLiveStartedByLocal);
          }

          _coreData.startedByLocalNotifier.addListener(onLiveStartedByLocal);
          ZegoLoggerService.logInfo(
            'onRoomAttributesUpdated, waiting for startedByLocalNotifier',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
          await completer.future;
          ZegoLoggerService.logInfo(
            'onRoomAttributesUpdated, startedByLocalNotifier change to '
            'true, check liveStatusNotifier',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
        }
      }

      /// wait living
      if (_coreData.liveStatusNotifier.value != LiveStatus.living) {
        final completer = Completer<void>();
        void onLiveStatusChanged() {
          if (_coreData.liveStatusNotifier.value == LiveStatus.living) {
            completer.complete();
          }
          _coreData.liveStatusNotifier.removeListener(onLiveStatusChanged);
        }

        _coreData.liveStatusNotifier.addListener(onLiveStatusChanged);
        ZegoLoggerService.logInfo(
          'onRoomAttributesUpdated, waiting for liveStatusNotifier',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );

        await completer.future;
        ZegoLoggerService.logInfo(
          'onRoomAttributesUpdated, liveStatusNotifier change to living, startPK',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );
      }

      if (!isHost) {
        final updatedPKUsers =
            (jsonDecode(event.setProperties['pk_users'] ?? '') as List<dynamic>)
                .map(
                  (userJson) =>
                      ZegoUIKitPrebuiltLiveStreamingPKUser.fromJson(userJson),
                )
                .toList();
        updatePKUsers(updatedPKUsers);
      }
    }
  }

  List<ZegoUIKitPrebuiltLiveStreamingPKUser> getAcceptedHostsInSession(
    String requestID, {
    List<String> ignoreUserIDs = const [],
  }) {
    final sessionHosts =
        ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(requestID);
    sessionHosts.removeWhere(
      (user) {
        if (ignoreUserIDs.contains(user.userID)) {
          return true;
        }

        /// remove not accepted
        return user.state != AdvanceInvitationState.accepted;
      },
    );

    return sessionHosts.map((sessionHost) {
      final tempSessionHost = _getSessionHostNameAndLiveIDFromExtendedData(
        sessionHost.extendedData,
      );
      return ZegoUIKitPrebuiltLiveStreamingPKUser(
        userInfo: ZegoUIKitUser(
          id: sessionHost.userID,
          name: tempSessionHost.name,
        ),
        liveID: tempSessionHost.fromLiveID,
      );
    }).toList();
  }

  void _onInvitationReceived(
    ZegoIncomingPKBattleRequestReceivedEventV2 event,
  ) async {
    ZegoLoggerService.logInfo(
      'onInvitationReceived, event:$event, state:${pkStateNotifier.value}',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    if (!isLiving || !isHost) {
      ZegoLoggerService.logInfo(
        '_onInvitationReceived, '
        'isLiving:$isLiving, '
        'isHost:$isHost, '
        'auto reject with code '
        '${ZegoLiveStreamingPKBattleRejectCodeV2.hostStateError.index}',
        tag: 'live streaming',
        subTag: 'pk event',
      );

      await ZegoUIKit().getSignalingPlugin().refuseAdvanceInvitation(
          invitationID: event.requestID,
          inviterID: event.fromHost.id,
          data: jsonEncode({
            'code': ZegoLiveStreamingPKBattleRejectCodeV2.hostStateError.index,
            'invitation_id': event.requestID,
            'invitee_name': ZegoUIKit().getLocalUser().name,
          }));

      return;
    }

    if (pkStateNotifier.value != ZegoLiveStreamingPKBattleStateV2.idle) {
      final ret =
          await ZegoUIKit().getSignalingPlugin().refuseAdvanceInvitation(
                invitationID: event.requestID,
                inviterID: event.fromHost.id,
                data: jsonEncode({
                  'code': ZegoLiveStreamingPKBattleRejectCodeV2.busy.index,
                  'invitation_id': event.requestID,
                  'invitee_name': ZegoUIKit().getLocalUser().name,
                }),
              );

      ((ret.error != null)
              ? ZegoLoggerService.logError
              : ZegoLoggerService.logInfo)
          .call(
        '_onInvitationReceived, '
        'busy(${pkStateNotifier.value}), '
        'auto reject, ret:$ret',
        tag: 'live streaming',
        subTag: 'pk event',
      );

      return;
    }

    /// reject/accept/quit invitation need this [event.requestID]
    _coreData.currentRequestID = event.requestID;

    event.isAutoAccept
        ? autoAcceptReceivedInvitation(event)
        : waitForeProcessingReceivedInvitation(event);
  }

  Future<void> autoAcceptReceivedInvitation(
    ZegoIncomingPKBattleRequestReceivedEventV2 event,
  ) async {
    defaultAction() async {
      await acceptPKBattleRequest(
        requestID: event.requestID,
        targetHost: ZegoUIKitPrebuiltLiveStreamingPKUser(
          userInfo: event.fromHost,
          liveID: event.fromLiveID,
        ),
      );
    }

    if (null !=
        _coreData.events?.pkV2Events.onIncomingPKBattleRequestReceived) {
      _coreData.events?.pkV2Events.onIncomingPKBattleRequestReceived
          ?.call(event, defaultAction);
    } else {
      await defaultAction.call();
    }
  }

  Future<void> waitForeProcessingReceivedInvitation(
    ZegoIncomingPKBattleRequestReceivedEventV2 event,
  ) async {
    /// check if minimizing
    _coreData.clearRequestReceivedEventInMinimizing();
    if (ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logInfo(
        'is minimizing now, cache the event:$event',
        tag: 'ZegoLiveStreamingPKBattleService',
        subTag: 'event',
      );

      _coreData.cacheRequestReceivedEventInMinimizing(event);

      return;
    }

    defaultAction() async {
      await showRequestReceivedDialog(event).then((isAccepted) async {
        if (isAccepted) {
          await acceptPKBattleRequest(
            requestID: event.requestID,
            targetHost: ZegoUIKitPrebuiltLiveStreamingPKUser(
              userInfo: event.fromHost,
              liveID: event.fromLiveID,
            ),
          );
        } else {
          await rejectPKBattleRequest(
            requestID: event.requestID,
            targetHostID: event.fromHost.id,
          );
        }
      });
    }

    if (null !=
        _coreData.events?.pkV2Events.onIncomingPKBattleRequestReceived) {
      _coreData.events?.pkV2Events.onIncomingPKBattleRequestReceived
          ?.call(event, defaultAction);
    } else {
      await defaultAction.call();
    }
  }

  void restorePKBattleRequestReceivedEventFromMinimizing() {
    if (null ==
        _coreData.pkBattleRequestReceivedEventInMinimizingNotifier.value) {
      ZegoLoggerService.logInfo(
        'restore pk battle request from minimizing, event is null',
        tag: 'live streaming',
        subTag: 'pk event',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'restore pk battle request from minimizing',
      tag: 'live streaming',
      subTag: 'pk event',
    );
    _onInvitationReceived(
      _coreData.pkBattleRequestReceivedEventInMinimizingNotifier.value!,
    );
  }

  void _onInvitationAccepted(
    ZegoOutgoingPKBattleRequestAcceptedEventV2 event,
  ) async {
    ZegoLoggerService.logInfo(
      'onInvitationAccepted, event:$event, ',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    if (!ZegoUIKitPrebuiltLiveStreamingPKV2.instance.isInPK) {
      /// first invitee(other room's host) accept, start pk, update layout

      updatePKState(ZegoLiveStreamingPKBattleStateV2.loading);

      updatePKUsers([
        ZegoUIKitPrebuiltLiveStreamingPKUser(
          userInfo: ZegoUIKit().getLocalUser(),
          liveID: _coreData.roomID,
        ),
        ZegoUIKitPrebuiltLiveStreamingPKUser(
          userInfo: event.fromHost,
          liveID: event.fromLiveID,
        ),
      ]);
    } else {
      /// invitees(other room's host) accept, update connected users
      updatePKUsers(
        List.from(_coreData.currentPKUsers.value)
          ..add(
            ZegoUIKitPrebuiltLiveStreamingPKUser(
              userInfo: event.fromHost,
              liveID: event.fromLiveID,
            ),
          ),
      );
    }

    _coreData.events?.pkV2Events.onOutgoingPKBattleRequestAccepted
        ?.call(event, () {});
  }

  void _onInvitationCanceled(
    ZegoIncomingPKBattleRequestCancelledEventV2 event,
  ) {
    ZegoLoggerService.logInfo(
      'onInvitationCanceled, event:$event',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);

    popupRequestReceivedDialog();

    _coreData.clearRequestReceivedEventInMinimizing();

    _coreData.events?.pkV2Events.onIncomingPKBattleRequestCancelled
        ?.call(event, () {});
  }

  void _onInvitationRefused(ZegoOutgoingPKBattleRequestRejectedEventV2 event) {
    var message = '';
    if (event.refuseCode == ZegoLiveStreamingPKBattleRejectCodeV2.busy.index) {
      message = 'The host is busy.';
    } else if (event.refuseCode ==
        ZegoLiveStreamingPKBattleRejectCodeV2.hostStateError.index) {
      message =
          "Failed to initiated the PK battle cause the host hasn't started a livestream.";
    } else if (event.refuseCode ==
        ZegoLiveStreamingPKBattleRejectCodeV2.reject.index) {
      message = 'The host rejected your request.';
    }
    ZegoLoggerService.logInfo(
      'onInvitationRefused, '
      'event:$event, '
      'message:$message, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    _checkNullToIdle(event.requestID);

    defaultAction() {
      showOutgoingPKBattleRequestRejectedDialog(event);
    }

    if (null !=
        _coreData.events?.pkV2Events.onOutgoingPKBattleRequestRejected) {
      _coreData.events?.pkV2Events.onOutgoingPKBattleRequestRejected?.call(
        event,
        defaultAction,
      );
    } else {
      defaultAction.call();
    }
  }

  Future<void> _checkNullToIdle(String requestID) async {
    final invitees =
        ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(requestID);
    if (invitees.isEmpty) {
      return;
    }

    final connectingInvitees = invitees
        .where((invitee) =>
            AdvanceInvitationState.waiting == invitee.state ||
            AdvanceInvitationState.accepted == invitee.state)
        .toList();

    if (connectingInvitees.isEmpty) {
      await quitPKBattle(requestID: requestID);

      _coreData.currentRequestID = '';
      updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);
    }
  }

  void _onInvitationTimeout(ZegoIncomingPKBattleRequestTimeoutEventV2 event) {
    ZegoLoggerService.logInfo(
      'onInvitationTimeout, '
      'event:$event, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    _checkNullToIdle(event.requestID);

    _coreData.clearRequestReceivedEventInMinimizing();

    defaultAction() {
      popupRequestReceivedDialog();
    }

    if (null != _coreData.events?.pkV2Events.onIncomingPKBattleRequestTimeout) {
      _coreData.events?.pkV2Events.onIncomingPKBattleRequestTimeout?.call(
        event,
        defaultAction,
      );
    } else {
      defaultAction.call();
    }
  }

  void _onInvitationResponseTimeout(
    ZegoOutgoingPKBattleRequestTimeoutEventV2 event,
  ) {
    ZegoLoggerService.logInfo(
      'onInvitationResponseTimeout, '
      'event:$event, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    _checkNullToIdle(event.requestID);

    _coreData.events?.pkV2Events.onOutgoingPKBattleRequestTimeout
        ?.call(event, () {});
  }

  void _onInvitationEnded(ZegoPKBattleEndedEventV2 event) {
    ZegoLoggerService.logInfo(
      'onInvitationEnded, event:$event, ',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    updatePKUsers([]);

    defaultAction() {
      showPKBattleEndedDialog(event);
    }

    if (null != _coreData.events?.pkV2Events.onPKBattleEnded) {
      _coreData.events?.pkV2Events.onPKBattleEnded?.call(
        event,
        defaultAction,
      );
    } else {
      defaultAction.call();
    }
  }

  void _onInvitationUserOffline(ZegoPKBattleUserOfflineEventV2 event) {
    ZegoLoggerService.logInfo(
      '_onInvitationUserOffline, '
      'event:$event, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    updatePKUsers(
      List.from(_coreData.currentPKUsers.value)
        ..removeWhere(
          (pkUser) => pkUser.userInfo.id == event.fromHost.id,
        ),
    );

    _checkNullToIdle(event.requestID);

    _coreData.events?.pkV2Events.onUserOffline?.call(event, () {});
  }

  void _onInvitationUserQuit(ZegoPKBattleUserQuitEventV2 event) async {
    ZegoLoggerService.logInfo(
      '_onInvitationUserQuit, '
      'event:$event, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live streaming',
      subTag: 'pk event',
    );

    updatePKUsers(
      List.from(_coreData.currentPKUsers.value)
        ..removeWhere(
          (pkUser) => pkUser.userInfo.id == event.fromHost.id,
        ),
    );

    await _checkNullToIdle(event.requestID);

    _coreData.events?.pkV2Events.onUserQuited?.call(event, () {});
  }

  List<ZegoIncomingPKBattleRequestUserV2> _parseSessionHosts(
    String requestID,
    List<Map<String, dynamic>> sessionHostParamList,
  ) {
    var sessionHosts = <ZegoIncomingPKBattleRequestUserV2>[];

    /// session hosts
    for (var sessionHostParam in sessionHostParamList) {
      final String sessionHostID = sessionHostParam['invitee_id'] ?? '';
      final state = sessionHostParam['state']
              as ZegoSignalingPluginInvitationUserState? ??
          ZegoSignalingPluginInvitationUserState.unknown;

      final tempSessionHost = _getSessionHostNameAndLiveIDFromExtendedData(
        sessionHostParam['data'] ?? '',
      );
      var sessionHost = ZegoIncomingPKBattleRequestUserV2(
        id: sessionHostID,
        name: tempSessionHost.name,
        fromLiveID: tempSessionHost.fromLiveID,
        state: state,
        customData: sessionHostParam['data'],
      );

      sessionHosts.add(sessionHost);
    }

    return sessionHosts;
  }

  ZegoIncomingPKBattleRequestUserV2
      _getSessionHostNameAndLiveIDFromExtendedData(String extendedData) {
    if (extendedData.isEmpty) {
      return ZegoIncomingPKBattleRequestUserV2();
    }

    /// session host's name and live id

    var user = ZegoIncomingPKBattleRequestUserV2();
    try {
      final acceptData =
          AdvanceInvitationAcceptData.fromJson(jsonDecode(extendedData));
      final pkAcceptData = PKServiceV2AcceptData.fromJson(
        jsonDecode(acceptData.customData) as Map<String, dynamic>? ?? {},
      );
      user.fromLiveID = pkAcceptData.liveID;
      user.name = pkAcceptData.name;
    } catch (e) {
      try {
        final pkAcceptData = PKServiceV2AcceptData.fromJson(
          jsonDecode(extendedData) as Map<String, dynamic>? ?? {},
        );
        user.fromLiveID = pkAcceptData.liveID;
        user.name = pkAcceptData.name;
      } catch (e) {
        debugPrint(
            '_getSessionHostNameAndLiveIDFromExtendedData, not a json:$extendedData');
      }
    }

    return user;
  }
}
