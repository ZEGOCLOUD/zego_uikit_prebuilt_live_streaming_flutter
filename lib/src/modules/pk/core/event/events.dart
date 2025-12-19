part of 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/service/services.dart';

extension ZegoUIKitPrebuiltLiveStreamingPKEventsV2
    on ZegoUIKitPrebuiltLiveStreamingPKServices {
  bool get rootNavigator => _coreData.prebuiltConfig?.rootNavigator ?? false;

  ZegoUIKitPrebuiltLiveStreamingInnerText get innerText =>
      _coreData.prebuiltConfig?.innerText ??
      ZegoUIKitPrebuiltLiveStreamingInnerText();

  bool get hostExist =>
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .hostManager
          .notifier
          .value
          ?.id
          .isNotEmpty ??
      false;

  bool get isLiving =>
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .liveStatusManager
          .notifier
          .value ==
      LiveStatus.living;

  void initEvents() {
    if (_eventInitialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'init',
      );

      return;
    }

    _eventInitialized = true;

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'init',
    );

    if (isHost) {
      _initHeartBeatTimer();
    }
    ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .notifier
        .addListener(_onHostUpdated);

    addEventListener(liveID: _liveID);
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
      'event:$event, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onWaitingQueryRoomProperties',
    );

    _waitingQueryRoomPropertiesSubscription?.cancel();
    queryRoomProperties();
  }

  void queryUserStates() {
    return;

    ZegoLoggerService.logInfo(
      'queryUserStates',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'pk event',
    );

    ///  Pull the latest invitation user status
    /// todo
    /// - The audience needs to know the exit status of the opposing PK LIVE creator when the current host app crashes, and cannot rely solely on the notification from the current LIVE creator.
    /// - After the current LIVE creator restarts following a crash, it is necessary to check whether the peer LIVE creator is still in a PK session, and PK cannot be resumed casually.
    ///
    /// Waiting for the ZIM team to add new interfaces
  }

  void queryRoomProperties() {
    ZegoLoggerService.logInfo(
      'queryRoomProperties',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'pk event',
    );

    final signalingRoomState = ZegoUIKit().getSignalingPlugin().getRoomState();
    if (ZegoSignalingPluginRoomState.connected != signalingRoomState) {
      ZegoLoggerService.logInfo(
        'room state($signalingRoomState) is not connected, wait...',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'queryRoomProperties',
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
          'result: $result',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: 'queryRoomProperties',
        );

        if (isHost) {
          ///  Check if there are any PK-related attributes, and if so, display the Restore PK dialog box
          if (result.properties.containsKey(roomPropKeyRequestID) ||
              result.properties.containsKey(roomPropKeyPKUsers)) {
            /// Restore PK - Show Confirmation Dialog
            queryUserStates();

            /// If there are still PK users in the current PK invitation link, then there can be an option to resume PK; otherwise, directly exit.
            /// Since this interface is currently unavailable, we will directly exit PK
            /// if() {
            ///
            /// }
            /// final shouldResume = await showHostResumePKConfirmDialog();
            /// ZegoLoggerService.logInfo(
            ///   'resume or not:$shouldResume, ',
            ///   tag: 'live.streaming.pk.events($hashCode)',
            ///   subTag: 'queryRoomProperties',
            /// );

            if (false /*shouldResume*/) {
              /// Select Restore PK
              _onRoomAttributesQueried(result);
            } else {
              /// Choose not to restore PK and exit
              ///
              /// Enter the room to discover PK attributes, exit PK to clear attributes
              if (result.properties.containsKey(roomPropKeyRequestID)) {
                /// After entering the room, if found that there was a PK going on,
                /// which indicates that the app was killed earlier.
                /// At this time, It cannot re-enter the PK.

                ZegoLoggerService.logInfo(
                  'room property contain pk keys, quit pk',
                  tag: 'live.streaming.pk.events($hashCode)',
                  subTag: 'queryRoomProperties',
                );

                quitPKBattle(
                  requestID: result.properties[roomPropKeyRequestID] ?? '',
                  force: true,
                );
              }

              await ZegoUIKit().getSignalingPlugin().deleteRoomProperties(
                    roomID: ZegoUIKit().getSignalingPlugin().getRoomID(),
                    keys: [
                      roomPropKeyRequestID,
                      roomPropKeyHost,
                      roomPropKeyPKUsers
                    ],
                    showErrorLog: false,
                  );
            }
          } else {
            /// There are no PK-related attributes, so continue directly
            _onRoomAttributesQueried(result);
          }
        } else {
          /// The audience exits and restarts the app to resume the PK state
          _onRoomAttributesQueried(result);
        }
      });
    }
  }

  void uninitEvents() {
    if (!_eventInitialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'uninit',
      );

      return;
    }

    _eventInitialized = false;
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'uninit',
    );

    ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .notifier
        .removeListener(_onHostUpdated);
    _heartBeatTimer?.cancel();
    _heartBeatTimer = null;
    _waitingQueryRoomPropertiesSubscription?.cancel();

    removeEventListener();
  }

  void removeEventListener() {
    if (!_eventListened) {
      ZegoLoggerService.logInfo(
        'not listen before',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'removeEventListener',
      );

      return;
    }

    _eventListened = false;
    ZegoLoggerService.logInfo(
      'remove',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'removeEventListener',
    );

    for (final subscription in _eventSubscriptions) {
      subscription?.cancel();
    }
  }

  void _onInvitationUserStateChanged(
    ZegoSignalingPluginInvitationUserStateChangedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'event:$event， ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationUserStateChanged',
    );

    if (null ==
        ZegoUIKit()
            .getSignalingPlugin()
            .getAdvanceInitiator(event.invitationID)) {
      /// a->b, b->c;
      /// in c event, a is initiator, b is inviter

      ZegoLoggerService.logInfo(
        'event is not advance invitation',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'onInvitationUserStateChanged',
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
      'user info:$userInfo, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onLocalInvitationUserStateChanged',
    );

    switch (userInfo.state) {
      case ZegoSignalingPluginInvitationUserState.timeout:
        updatePKState(ZegoLiveStreamingPKBattleState.idle);

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
          updatePKState(ZegoLiveStreamingPKBattleState.inPK);
        }
        break;
      case ZegoSignalingPluginInvitationUserState.inviting:
      case ZegoSignalingPluginInvitationUserState.rejected:
      case ZegoSignalingPluginInvitationUserState.cancelled:
      case ZegoSignalingPluginInvitationUserState.offline:
      case ZegoSignalingPluginInvitationUserState.received:
      case ZegoSignalingPluginInvitationUserState.ended:
      case ZegoSignalingPluginInvitationUserState.unknown:
      case ZegoSignalingPluginInvitationUserState.notYetReceived:
      case ZegoSignalingPluginInvitationUserState.beCanceled:
        break;
      case ZegoSignalingPluginInvitationUserState.quited:
        _coreData.events?.pk.onUserQuited?.call(
            ZegoLiveStreamingPKBattleUserQuitEvent(
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
      'sessionInitiator:$sessionInitiator, '
      'user info:$remoteUserInfo, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onRemoteInvitationUserStateChanged',
    );

    var extendedDataMap = <String, dynamic>{};
    if (remoteUserInfo.extendedData.isNotEmpty) {
      try {
        extendedDataMap =
            jsonDecode(remoteUserInfo.extendedData) as Map<String, dynamic>? ??
                {};
      } catch (e) {
        ZegoLoggerService.logError(
          'extendedData is not a json:${remoteUserInfo.extendedData}, '
          'e:$e, ',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: 'onRemoteInvitationUserStateChanged',
        );
      }
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
          _onInvitationAccepted(
              ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent(
            requestID: requestID,
            fromHost: fromHost,
            fromLiveID: fromLiveID,
          ));
        } else {
          /// invitees(other room's host) accept, update connected users
          updatePKUsers(
            List.from(_coreData.currentPKUsers.value)
              ..add(
                ZegoLiveStreamingPKUser(
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
          final pkRejectData = PKServiceRejectData.fromJson(
            jsonDecode(remoteUserInfo.extendedData) as Map<String, dynamic>? ??
                {},
          );
          isRequestFromLocal =
              ZegoUIKit().getLocalUser().id == pkRejectData.inviterID;
        } catch (e) {
          ZegoLoggerService.logError(
            'reject extended data, not a json:${remoteUserInfo.extendedData}',
            tag: 'live.streaming.pk.events($hashCode)',
            subTag: 'onRemoteInvitationUserStateChanged',
          );
        }

        if (isRequestFromLocal) {
          final int refuseCode = extendedDataMap['code'] ??
              ZegoLiveStreamingPKBattleRejectCode.reject.index;
          final String fromHostUserName = extendedDataMap['invitee_name'] ?? '';
          _onInvitationRefused(
              ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent(
            requestID: requestID,
            fromHost: ZegoUIKitUser(
              id: remoteUserInfo.userID,
              name: fromHostUserName,
            ),
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
          ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent(
            requestID: requestID,
            fromHost: ZegoUIKitUser(
              id: remoteUserInfo.userID,
              name: '',
            ),
          ),
        );
        break;
      case ZegoSignalingPluginInvitationUserState.offline:
        _onInvitationUserOffline(
          ZegoLiveStreamingPKBattleUserOfflineEvent(
            requestID: requestID,
            fromHost: ZegoUIKitUser(
              id: remoteUserInfo.userID,
              name: '',
            ),
          ),
        );
        break;
      case ZegoSignalingPluginInvitationUserState.quited:
        final String fromHostUserName = extendedDataMap['invitee_name'] ?? '';
        _onInvitationUserQuit(
          ZegoLiveStreamingPKBattleUserQuitEvent(
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
      case ZegoSignalingPluginInvitationUserState.notYetReceived:
        // TODO: Handle this case.
        break;
      case ZegoSignalingPluginInvitationUserState.beCanceled:
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
        final userDisconnectedSecond =
            _coreData.prebuiltConfig?.pkBattle.userDisconnectedSecond ?? 60;
        final userReconnectingSecond =
            _coreData.prebuiltConfig?.pkBattle.userReconnectingSecond ?? 5;

        final now = DateTime.now();
        final tempBrokenIDs = <String>[];
        final alreadyBrokenIDs = <String>[];
        for (var pkUser in _coreData.currentPKUsers.value) {
          if (ZegoUIKit().getLocalUser().id == pkUser.userInfo.id ||
              null == pkUser.heartbeat) {
            continue;
          }

          final offlineSeconds = now.difference(pkUser.heartbeat!).inSeconds;
          if (offlineSeconds > userDisconnectedSecond) {
            alreadyBrokenIDs.add(pkUser.userInfo.id);

            _coreData.events?.pk.onUserDisconnected?.call(pkUser.toUIKitUser);
          } else if (offlineSeconds > userReconnectingSecond &&
              !(pkUser.heartbeatBrokenNotifier.value)) {
            ZegoLoggerService.logInfo(
              '${pkUser.userInfo.id} heartbeat had broken,'
              'heartbeat: ${pkUser.heartbeat}, '
              'now:$now, mute audio',
              tag: 'live.streaming.pk.events($hashCode)',
              subTag: 'heartbeat',
            );

            ZegoUIKit().muteUserAudio(
              targetRoomID: _liveID,
              pkUser.userInfo.id,
              true,
            );

            tempBrokenIDs.add(pkUser.userInfo.id);
            pkUser.heartbeatBrokenNotifier.value = true;
            ZegoLoggerService.logInfo(
              'user is broken:$pkUser, ',
              tag: 'live.streaming.pk.events($hashCode)',
              subTag: 'heartbeat',
            );

            _coreData.events?.pk.onUserReconnecting?.call(
              pkUser.toUIKitUser,
            );
          }
        }
        if (tempBrokenIDs.isNotEmpty) {
          ZegoLoggerService.logInfo(
            'temp broken user:$tempBrokenIDs, ',
            tag: 'live.streaming.pk.events($hashCode)',
            subTag: 'heartbeat',
          );
        }

        if (alreadyBrokenIDs.isNotEmpty) {
          ZegoLoggerService.logInfo(
            '$alreadyBrokenIDs heartbeat had broken so long, remove from pk,',
            tag: 'live.streaming.pk.events($hashCode)',
            subTag: 'heartbeat',
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

  void addEventListener({
    required String liveID,
  }) {
    if (_eventListened) {
      ZegoLoggerService.logInfo(
        'had listen',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'addEventListener',
      );

      return;
    }

    _eventListened = true;

    ZegoLoggerService.logInfo(
      'listen, '
      'live id:$liveID, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'addEventListener',
    );

    _eventSubscriptions
      ..add(
          ZegoUIKit().getReceiveSEIStream(targetRoomID: liveID).where((event) {
        return event.typeIdentifier ==
            ZegoUIKitInnerSEIType.mixerDeviceState.name;
      }).listen(_onReceiveSEIEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getRoomPropertiesStream()
          .listen(_onRoomAttributesUpdated))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getRoomMemberLeftEventStream()
          .listen(_onRoomMemberLeft))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getRoomMemberJoinedEventStream()
          .listen(_onRoomMemberJoined))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationUserStateChangedStream()
          .listen(_onInvitationUserStateChanged))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationReceivedStream()
          .where((params) => ZegoInvitationTypeExtension.isPKType(
              (params['type'] as int?) ?? -1))
          .map((params) {
        ZegoLoggerService.logInfo(
          'params:$params',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: 'on invitation received',
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
        final initiatorPKRequestData = PKServiceRequestData.fromJson(
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

        return ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent(
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
          .where((params) => ZegoInvitationTypeExtension.isPKType(
              (params['type'] as int?) ?? -1))
          .map((params) {
        ZegoLoggerService.logInfo(
          'params:$params, ',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: 'onInvitationCanceled',
        );

        final ZegoUIKitUser fromHost = params['inviter']!;
        final String requestID = params['invitation_id']!;
        return ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent(
          requestID: requestID,
          fromHost: fromHost,
          customData: 'customData',
        );
      }).listen(_onInvitationCanceled))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationTimeoutStream()
          .where(
            (params) => ZegoInvitationTypeExtension.isPKType(
                (params['type'] as int?) ?? -1),
          )
          .map((params) {
        ZegoLoggerService.logInfo(
          'params:$params',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: 'onInvitationTimeout',
        );

        final ZegoUIKitUser fromHost = params['inviter']!;
        final String requestID = params['invitation_id']!;
        return ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent(
          requestID: requestID,
          fromHost: fromHost,
        );
      }).listen(_onInvitationTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationEndedStream()
          .where(
            (params) => ZegoInvitationTypeExtension.isPKType(
                (params['type'] as int?) ?? -1),
          )
          .map((params) {
        ZegoLoggerService.logInfo(
          'params:$params, ',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: 'onInvitationEnded',
        );

        final String requestID = params['invitation_id']!;
        final ZegoUIKitUser fromHost = params['inviter']!;
        final int endTime = params['end_time']!;

        final extendedDataMap =
            jsonDecode(params['data']!) as Map<String, dynamic>;
        final int endCode = extendedDataMap['code'] ??
            ZegoLiveStreamingPKBattleRejectCode.reject.index;

        /// a->b, b->c;
        /// in c event, a is initiator, b is inviter
        var isRequestFromLocal = ZegoUIKit().getLocalUser().id ==
            ZegoUIKit()
                .getSignalingPlugin()
                .getAdvanceInitiator(requestID)
                ?.userID;

        return ZegoLiveStreamingPKBattleEndedEvent(
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
      ZegoLoggerService.logWarn(
        'event user:${event.senderID}, '
        'pk user not exist',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'onReceiveSEIEvent',
      );

      return;
    }

    /// update heartbeat timestamp
    var pkUser = _coreData.currentPKUsers.value.elementAt(pkUserIndex);
    pkUser.heartbeat = DateTime.now();

    if (pkUser.heartbeatBrokenNotifier.value) {
      /// heart broken before
      /// user reconnected now
      pkUser.heartbeatBrokenNotifier.value = false;

      ZegoLoggerService.logInfo(
        'received ${pkUser.userInfo.id} sei, un-mute audio',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'heartbeat',
      );

      ZegoUIKit().muteUserAudio(
        targetRoomID: _liveID,
        pkUser.userInfo.id,
        false,
      );

      _coreData.events?.pk.onUserReconnected?.call(
        pkUser.toUIKitUser,
      );
    }

    // if (ZegoUIKit().useDebugMode) {
    //   ZegoLoggerService.logInfo(
    //     '${pkUser.userInfo.id}, onReceiveSEIEvent $event',
    //     tag: 'live.streaming.pk.events($hashCode)',
    //     subTag: 'heartbeat',
    //   );
    // }
  }

  void _onRoomAttributesQueried(
    ZegoSignalingPluginQueryRoomPropertiesResult event,
  ) {
    ZegoLoggerService.logInfo(
      'event:$event, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onRoomAttributesQueried',
    );
    _coreData.updatePropertyHostIDByQuery(event);

    if (event.properties.containsKey(roomPropKeyPKUsers)) {
      _onRoomAttributeUpdatedPKUsers(
        event.properties[roomPropKeyPKUsers] ?? '',

        /// host也需要更新
        hostCanUpdatePKUsers: true,
      );
    }
  }

  void _onRoomMemberLeft(ZegoSignalingPluginRoomMemberLeftEvent event) async {
    final hostID = ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .hostManager
            .notifier
            .value
            ?.id ??
        '';

    ZegoLoggerService.logInfo(
      'event:$event, '
      'isHost:$isHost, '
      'hostID:$hostID, '
      'liveID:$liveID, '
      'hostExist:$hostExist, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onRoomMemberLeft',
    );

    if (isHost) {
    } else {
      /// During the audience PK, the LIVE creator leaves, and the state reverts to non-PK
      if (ZegoUIKitPrebuiltLiveStreamingPK.instance.isInPK) {
        if (event.roomID == liveID) {
          final canQuitPK =

              /// host quit
              event.usersID.contains(hostID) ||

                  /// not host
                  !hostExist;
          if (canQuitPK) {
            await audienceQuitPK();
          }
        }
      }
    }
  }

  void _onRoomMemberJoined(ZegoSignalingPluginRoomMemberJoinedEvent event) {
    ZegoLoggerService.logInfo(
      'event:$event, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onRoomMemberJoined',
    );
  }

  void _onRoomAttributesUpdated(
    ZegoSignalingPluginRoomPropertiesUpdatedEvent event,
  ) async {
    ZegoLoggerService.logInfo(
      'event:$event, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onRoomAttributesUpdated',
    );
    _coreData.updatePropertyHostIDByUpdated(event);

    if (event.deleteProperties.containsKey(roomPropKeyPKUsers)) {
      _onRoomAttributeDeletePKUsers(
        event.deleteProperties[roomPropKeyPKUsers] ?? '',
      );
    }

    if (event.setProperties.containsKey(roomPropKeyPKUsers)) {
      _onRoomAttributeUpdatedPKUsers(
        event.setProperties[roomPropKeyPKUsers] ?? '',
        hostCanUpdatePKUsers: false,
      );
    }
  }

  Future<void> _onRoomAttributeDeletePKUsers(String property) async {
    await audienceQuitPK();
  }

  Future<void> audienceQuitPK() async {
    ZegoLoggerService.logInfo(
      'isHost:$isHost, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'audienceQuitPK',
    );

    if (!isHost) {
      await ZegoUIKit().muteUserAudioVideo(
        targetRoomID: _liveID,
        ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .hostManager
                .notifier
                .value
                ?.id ??
            '',
        false,
      );
      await _mixer.stopPlayStream();

      updatePKUsers([]);
      updatePKState(ZegoLiveStreamingPKBattleState.idle);

      _coreData.events?.onStateUpdated?.call(
        isLiving ? ZegoLiveStreamingState.living : ZegoLiveStreamingState.idle,
      );
    }
  }

  Future<void> _onRoomAttributeUpdatedPKUsers(
    String property, {
    required bool hostCanUpdatePKUsers,
  }) async {
    if (isHost) {
      /// wait start
      if (ZegoLiveStreamingPageLifeCycle()
          .previewPageVisibilityNotifier
          .value) {
        final completer = Completer<void>();
        void onLiveStartedByLocal() {
          if (!ZegoLiveStreamingPageLifeCycle()
              .previewPageVisibilityNotifier
              .value) {
            completer.complete();
          }
          ZegoLiveStreamingPageLifeCycle()
              .previewPageVisibilityNotifier
              .removeListener(onLiveStartedByLocal);
        }

        ZegoLiveStreamingPageLifeCycle()
            .previewPageVisibilityNotifier
            .addListener(onLiveStartedByLocal);
        ZegoLoggerService.logInfo(
          'waiting for startedByLocalNotifier',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: 'onRoomAttributesUpdated',
        );
        await completer.future;
        ZegoLoggerService.logInfo(
          'startedByLocalNotifier change to true, check liveStatusNotifier',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: 'onRoomAttributesUpdated',
        );
      }
    }

    /// wait living
    if (ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .liveStatusManager
            .notifier
            .value !=
        LiveStatus.living) {
      final completer = Completer<void>();
      void onLiveStatusChanged() {
        if (ZegoLiveStreamingPageLifeCycle()
                .currentManagers
                .liveStatusManager
                .notifier
                .value ==
            LiveStatus.living) {
          completer.complete();
        }
        ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .liveStatusManager
            .notifier
            .removeListener(onLiveStatusChanged);
      }

      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .liveStatusManager
          .notifier
          .addListener(onLiveStatusChanged);
      ZegoLoggerService.logInfo(
        'waiting for liveStatusNotifier',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'onRoomAttributesUpdated',
      );

      await completer.future;
      ZegoLoggerService.logInfo(
        'liveStatusNotifier change to living, startPK',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'onRoomAttributesUpdated',
      );
    }

    if (hostCanUpdatePKUsers || !isHost) {
      final updatedPKUsers = (jsonDecode(property) as List<dynamic>)
          .map(
            (userJson) => ZegoLiveStreamingPKUser.fromJson(userJson),
          )
          .toList();
      updatePKUsers(updatedPKUsers);
    }
  }

  List<ZegoLiveStreamingPKUser> getAcceptedHostsInSession(
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
      return ZegoLiveStreamingPKUser(
        userInfo: ZegoUIKitUser(
          id: sessionHost.userID,
          name: tempSessionHost.name,
          isAnotherRoomUser: true,
        ),
        liveID: tempSessionHost.fromLiveID,
      );
    }).toList();
  }

  void _onInvitationReceived(
    ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent event,
  ) async {
    ZegoLoggerService.logInfo(
      'event:$event, '
      'state:${pkStateNotifier.value}, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationReceived',
    );

    if (!isLiving || !isHost) {
      ZegoLoggerService.logInfo(
        'isLiving:$isLiving, '
        'isHost:$isHost, '
        'auto reject with code '
        '${ZegoLiveStreamingPKBattleRejectCode.hostStateError.index}',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'onInvitationReceived',
      );

      await ZegoUIKit().getSignalingPlugin().refuseAdvanceInvitation(
          invitationID: event.requestID,
          inviterID: event.fromHost.id,
          data: jsonEncode(PKServiceRejectData(
            code: ZegoLiveStreamingPKBattleRejectCode.hostStateError.index,
            inviterID: event.fromHost.id,
            inviteeName: ZegoUIKit().getLocalUser().name,
          ).toJson()));

      return;
    }

    if (pkStateNotifier.value != ZegoLiveStreamingPKBattleState.idle) {
      final ret =
          await ZegoUIKit().getSignalingPlugin().refuseAdvanceInvitation(
                invitationID: event.requestID,
                inviterID: event.fromHost.id,
                data: jsonEncode(PKServiceRejectData(
                  code: ZegoLiveStreamingPKBattleRejectCode.busy.index,
                  inviterID: event.fromHost.id,
                  inviteeName: ZegoUIKit().getLocalUser().name,
                ).toJson()),
              );

      ((ret.error != null)
              ? ZegoLoggerService.logError
              : ZegoLoggerService.logInfo)
          .call(
        'busy(${pkStateNotifier.value}), '
        'auto reject, ret:$ret',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'onInvitationReceived',
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
    ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent event,
  ) async {
    defaultAction() async {
      await acceptPKBattleRequest(
        requestID: event.requestID,
        targetHost: ZegoLiveStreamingPKUser(
          userInfo: event.fromHost,
          liveID: event.fromLiveID,
        ),
      );
    }

    if (null != _coreData.events?.pk.onIncomingRequestReceived) {
      _coreData.events?.pk.onIncomingRequestReceived
          ?.call(event, defaultAction);
    } else {
      await defaultAction.call();
    }
  }

  Future<void> waitForeProcessingReceivedInvitation(
    ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent event,
  ) async {
    /// check if minimizing
    _coreData.clearRequestReceivedEventInMinimizing();
    if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logInfo(
        'is minimizing now, cache the event:$event',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'waitForeProcessingReceivedInvitation',
      );

      _coreData.cacheRequestReceivedEventInMinimizing(event);

      return;
    }

    defaultAction() async {
      await showRequestReceivedDialog(event).then((isAccepted) async {
        if (isAccepted) {
          await acceptPKBattleRequest(
            requestID: event.requestID,
            targetHost: ZegoLiveStreamingPKUser(
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

    if (null != _coreData.events?.pk.onIncomingRequestReceived) {
      _coreData.events?.pk.onIncomingRequestReceived
          ?.call(event, defaultAction);
    } else {
      await defaultAction.call();
    }
  }

  void restorePKBattleRequestReceivedEventFromMinimizing() {
    if (null ==
        _coreData.pkBattleRequestReceivedEventInMinimizingNotifier.value) {
      ZegoLoggerService.logInfo(
        'event is null',
        tag: 'live.streaming.pk.events($hashCode)',
        subTag: 'restorePKBattleRequestReceivedEventFromMinimizing',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'restorePKBattleRequestReceivedEventFromMinimizing',
    );
    _onInvitationReceived(
      _coreData.pkBattleRequestReceivedEventInMinimizingNotifier.value!,
    );
  }

  void _onInvitationAccepted(
    ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent event,
  ) async {
    ZegoLoggerService.logInfo(
      'event:$event, '
      'now pk state:${ZegoUIKitPrebuiltLiveStreamingPK.instance.pkStateNotifier.value}, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationAccepted',
    );

    if (!ZegoUIKitPrebuiltLiveStreamingPK.instance.isInPK) {
      /// first invitee(other room's host) accept, start pk, update layout
      updatePKState(ZegoLiveStreamingPKBattleState.loading);

      updatePKUsers([
        ZegoLiveStreamingPKUser(
          userInfo: ZegoUIKit().getLocalUser(),
          liveID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        ),
        ZegoLiveStreamingPKUser(
          userInfo: event.fromHost,
          liveID: event.fromLiveID,
        ),
      ]);
    } else {
      /// invitees(other room's host) accept, update connected users
      updatePKUsers(
        List.from(_coreData.currentPKUsers.value)
          ..add(
            ZegoLiveStreamingPKUser(
              userInfo: event.fromHost,
              liveID: event.fromLiveID,
            ),
          ),
      );
    }

    _coreData.events?.pk.onOutgoingRequestAccepted?.call(event, () {});
  }

  void _onInvitationCanceled(
    ZegoLiveStreamingIncomingPKBattleRequestCancelledEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'event:$event, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationCanceled',
    );

    updatePKState(ZegoLiveStreamingPKBattleState.idle);

    popupRequestReceivedDialog();

    _coreData.clearRequestReceivedEventInMinimizing();

    _coreData.events?.pk.onIncomingRequestCancelled?.call(event, () {});
  }

  void _onInvitationRefused(
      ZegoLiveStreamingOutgoingPKBattleRequestRejectedEvent event) {
    var message = '';
    if (event.refuseCode == ZegoLiveStreamingPKBattleRejectCode.busy.index) {
      message = 'The host is busy.';
    } else if (event.refuseCode ==
        ZegoLiveStreamingPKBattleRejectCode.hostStateError.index) {
      message =
          "Failed to initiated the PK battle cause the host hasn't started a livestream.";
    } else if (event.refuseCode ==
        ZegoLiveStreamingPKBattleRejectCode.reject.index) {
      message = 'The host rejected your request.';
    }
    ZegoLoggerService.logInfo(
      'event:$event, '
      'message:$message, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationRefused',
    );

    _checkNullToIdle(event.requestID);

    defaultAction() {
      showOutgoingPKBattleRequestRejectedDialog(event);
    }

    if (null != _coreData.events?.pk.onOutgoingRequestRejected) {
      _coreData.events?.pk.onOutgoingRequestRejected?.call(
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
      updatePKState(ZegoLiveStreamingPKBattleState.idle);
    }
  }

  void _onInvitationTimeout(
      ZegoLiveStreamingIncomingPKBattleRequestTimeoutEvent event) {
    ZegoLoggerService.logInfo(
      'event:$event, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationTimeout',
    );

    _checkNullToIdle(event.requestID);

    _coreData.clearRequestReceivedEventInMinimizing();

    defaultAction() {
      popupRequestReceivedDialog();
    }

    if (null != _coreData.events?.pk.onIncomingRequestTimeout) {
      _coreData.events?.pk.onIncomingRequestTimeout?.call(
        event,
        defaultAction,
      );
    } else {
      defaultAction.call();
    }
  }

  void _onInvitationResponseTimeout(
    ZegoLiveStreamingOutgoingPKBattleRequestTimeoutEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'event:$event, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationResponseTimeout',
    );

    _checkNullToIdle(event.requestID);

    _coreData.events?.pk.onOutgoingRequestTimeout?.call(event, () {});
  }

  void _onInvitationEnded(ZegoLiveStreamingPKBattleEndedEvent event) {
    ZegoLoggerService.logInfo(
      'event:$event, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationEnded',
    );

    updatePKUsers([]);

    defaultAction() {
      showPKBattleEndedDialog(event);
    }

    if (null != _coreData.events?.pk.onEnded) {
      _coreData.events?.pk.onEnded?.call(
        event,
        defaultAction,
      );
    } else {
      defaultAction.call();
    }
  }

  void _onInvitationUserOffline(
      ZegoLiveStreamingPKBattleUserOfflineEvent event) {
    ZegoLoggerService.logInfo(
      'event:$event, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationUserOffline',
    );

    updatePKUsers(
      List.from(_coreData.currentPKUsers.value)
        ..removeWhere(
          (pkUser) => pkUser.userInfo.id == event.fromHost.id,
        ),
    );

    _checkNullToIdle(event.requestID);

    _coreData.events?.pk.onUserOffline?.call(event, () {});
  }

  void _onInvitationUserQuit(
      ZegoLiveStreamingPKBattleUserQuitEvent event) async {
    ZegoLoggerService.logInfo(
      'event:$event, '
      'remaining number of participants in the PK session:${ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(event.requestID)}, ',
      tag: 'live.streaming.pk.events($hashCode)',
      subTag: 'onInvitationUserQuit',
    );

    updatePKUsers(
      List.from(_coreData.currentPKUsers.value)
        ..removeWhere(
          (pkUser) => pkUser.userInfo.id == event.fromHost.id,
        ),
    );

    await _checkNullToIdle(event.requestID);

    _coreData.events?.pk.onUserQuited?.call(event, () {});
  }

  List<ZegoLiveStreamingIncomingPKBattleRequestUser> _parseSessionHosts(
    String requestID,
    List<Map<String, dynamic>> sessionHostParamList,
  ) {
    var sessionHosts = <ZegoLiveStreamingIncomingPKBattleRequestUser>[];

    /// session hosts
    for (var sessionHostParam in sessionHostParamList) {
      final String sessionHostID = sessionHostParam['invitee_id'] ?? '';
      final state = sessionHostParam['state']
              as ZegoSignalingPluginInvitationUserState? ??
          ZegoSignalingPluginInvitationUserState.unknown;

      final tempSessionHost = _getSessionHostNameAndLiveIDFromExtendedData(
        sessionHostParam['data'] ?? '',
      );
      var sessionHost = ZegoLiveStreamingIncomingPKBattleRequestUser(
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

  ZegoLiveStreamingIncomingPKBattleRequestUser
      _getSessionHostNameAndLiveIDFromExtendedData(
    String extendedData,
  ) {
    if (extendedData.isEmpty) {
      return ZegoLiveStreamingIncomingPKBattleRequestUser();
    }

    /// session host's name and live id

    var user = ZegoLiveStreamingIncomingPKBattleRequestUser();
    try {
      final acceptData = ZegoUIKitAdvanceInvitationAcceptProtocol.fromJson(
          jsonDecode(extendedData));
      final pkAcceptData = PKServiceAcceptData.fromJson(
        jsonDecode(acceptData.customData) as Map<String, dynamic>? ?? {},
      );
      user.fromLiveID = pkAcceptData.liveID;
      user.name = pkAcceptData.name;
    } catch (e) {
      try {
        final pkAcceptData = PKServiceAcceptData.fromJson(
          jsonDecode(extendedData) as Map<String, dynamic>? ?? {},
        );
        user.fromLiveID = pkAcceptData.liveID;
        user.name = pkAcceptData.name;
      } catch (e) {
        ZegoLoggerService.logInfo(
          'not a json:$extendedData, ',
          tag: 'live.streaming.pk.events($hashCode)',
          subTag: '_getSessionHostNameAndLiveIDFromExtendedData',
        );
      }
    }

    return user;
  }
}
