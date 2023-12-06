part of 'services.dart';

extension PKServiceV2HostRequest on ZegoUIKitPrebuiltLiveStreamingPKServicesV2 {
  /// Send PK invitation to [targetHostIDs].
  Future<ZegoLiveStreamingPKServiceSendRequestResult> sendPKBattleRequest({
    required List<String> targetHostIDs,
    int timeout = 60,
    String customData = '',
    bool isAutoAccept = false,
  }) async {
    if (!_serviceInitialized || !isLiving || !isHost) {
      ZegoLoggerService.logInfo(
        'could not send pk request, '
        'init:$_serviceInitialized, '
        'state:${pkStateNotifier.value}, '
        'is living:$isLiving, '
        'is host:$isHost',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return ZegoLiveStreamingPKServiceSendRequestResult(
        errorUserIDs: targetHostIDs,
        error: PlatformException(
          code: '-1',
          message: 'could not send pk request, '
              'init:$_serviceInitialized, '
              'state:${pkStateNotifier.value}, '
              'is living:$isLiving, '
              'is host:$isHost',
        ),
      );
    }

    if (targetHostIDs.isEmpty) {
      ZegoLoggerService.logInfo(
        'could not send pk request, '
        'param is invalid, '
        'target host user ids:$targetHostIDs',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return ZegoLiveStreamingPKServiceSendRequestResult(
        errorUserIDs: targetHostIDs,
        error: PlatformException(
          code: '-1',
          message: 'param is invalid, '
              'target host user ids:$targetHostIDs',
        ),
      );
    }

    var inInvitationUserIDs = <String>[];
    for (var userID in targetHostIDs) {
      if (ZegoUIKit()
          .getSignalingPlugin()
          .isUserInAdvanceInvitationNow(userID)) {
        inInvitationUserIDs.add(userID);
      }
    }
    var tempTargetHostUserIDs = List<String>.from(targetHostIDs);
    tempTargetHostUserIDs.removeWhere(
      (userID) => inInvitationUserIDs.contains(userID),
    );
    if (tempTargetHostUserIDs.isEmpty) {
      ZegoLoggerService.logInfo(
        'could not send pk request, '
        'all user is in PK, '
        'param target host id:$targetHostIDs, '
        'now target host user ids:$tempTargetHostUserIDs, '
        'advance data:${ZegoUIKit().getSignalingPlugin().advanceInvitationToString()}, ',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return ZegoLiveStreamingPKServiceSendRequestResult(
        errorUserIDs: inInvitationUserIDs,
        error: PlatformException(
          code: '-1',
          message: 'all user is in PK or requesting',
        ),
      );
    }

    final isWaitingRemoteResponse =
        _coreData.remoteUserIDsWaitingResponseFromLocalRequest().isNotEmpty;
    final isWaitingLocalResponse =
        _coreData.isRemoteRequestWaitingLocalResponse();
    ZegoLoggerService.logInfo(
      'send pk request, '
      'isInPK:$isInPK, '
      'isWaitingRemoteResponse:$isWaitingRemoteResponse, '
      'isWaitingLocalResponse:$isWaitingLocalResponse, ',
      tag: 'live streaming',
      subTag: 'pk service',
    );
    return (isInPK || isWaitingRemoteResponse || isWaitingLocalResponse)
        ? _addPKBattleRequest(
            _coreData.currentRequestID,
            tempTargetHostUserIDs,
            timeout: timeout,
            customData: customData,
            isAutoAccept: isAutoAccept,
          )
        : _sendPKBattleRequest(
            tempTargetHostUserIDs,
            timeout: timeout,
            customData: customData,
            isAutoAccept: isAutoAccept,
          );
  }

  Future<ZegoLiveStreamingPKServiceSendRequestResult> _sendPKBattleRequest(
    List<String> targetHostUserIDs, {
    int timeout = 60,
    String customData = '',
    bool isAutoAccept = false,
  }) async {
    ZegoLoggerService.logInfo(
      'sendPKBattleRequest, '
      'targetHostUserIDs:$targetHostUserIDs, '
      'timeout:$timeout, '
      'isAutoAccept:$isAutoAccept, '
      'customData:$customData, ',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    final sendResult =
        await ZegoUIKit().getSignalingPlugin().sendAdvanceInvitation(
              inviterID: ZegoUIKit().getLocalUser().id,
              inviterName: ZegoUIKit().getLocalUser().name,
              invitees: targetHostUserIDs,
              timeout: timeout,
              type: ZegoInvitationType.crossRoomPKBattleRequestV2.value,
              data: jsonEncode(
                PKServiceV2RequestData(
                  inviter: ZegoUIKit().getLocalUser(),
                  invitees: targetHostUserIDs,
                  liveID: _coreData.roomID,
                  isAutoAccept: isAutoAccept,
                  customData: customData,
                ),
              ),
            );
    (sendResult.error == null && sendResult.errorInvitees.isEmpty
        ? ZegoLoggerService.logInfo
        : ZegoLoggerService.logError)(
      'sendPKBattleRequest, '
      'send start request signaling result:$sendResult, '
      'error invitees:${sendResult.errorInvitees.entries.map(
            (entry) => 'user'
                ' ${entry.key}\'s reason is ${entry.value}',
          ).join(',')}',
      tag: 'live streaming',
      subTag: 'pk service',
    );
    if (null != sendResult.error) {
      return ZegoLiveStreamingPKServiceSendRequestResult(
        requestID: sendResult.invitationID,
        errorUserIDs: sendResult.errorInvitees.keys.toList(),
        error: sendResult.error,
      );
    }
    if (sendResult.errorInvitees.length == targetHostUserIDs.length) {
      /// all user failed
      return ZegoLiveStreamingPKServiceSendRequestResult(
        requestID: sendResult.invitationID,
        errorUserIDs: sendResult.errorInvitees.keys.toList(),
        error: PlatformException(
          code: '-1',
          message: 'failed to send pk battle request, '
              '${sendResult.errorInvitees.entries.map(
                    (entry) => 'user '
                        '${entry.key}\'s reason is ${entry.value}',
                  ).join(',')}',
        ),
      );
    }

    _coreData.currentRequestID = sendResult.invitationID;

    return ZegoLiveStreamingPKServiceSendRequestResult(
      requestID: sendResult.invitationID,
    );
  }

  Future<ZegoLiveStreamingPKServiceSendRequestResult> _addPKBattleRequest(
    String requestID,
    List<String> targetHostUserIDs, {
    int timeout = 60,
    String customData = '',
    bool isAutoAccept = false,
  }) async {
    ZegoLoggerService.logInfo(
      'addPKBattleRequest, '
      'requestID:$requestID, '
      'targetHostUserIDs:$targetHostUserIDs, '
      'timeout:$timeout, '
      'isAutoAccept:$isAutoAccept, '
      'customData:$customData, ',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    final addResult =
        await ZegoUIKit().getSignalingPlugin().addAdvanceInvitation(
              invitationID: requestID,
              inviterID: ZegoUIKit().getLocalUser().id,
              inviterName: ZegoUIKit().getLocalUser().name,
              invitees: targetHostUserIDs,
              type: ZegoInvitationType.crossRoomPKBattleRequestV2.value,
              data: jsonEncode(
                PKServiceV2RequestData(
                  inviter: ZegoUIKit().getLocalUser(),
                  invitees: targetHostUserIDs,
                  liveID: _coreData.roomID,
                  isAutoAccept: isAutoAccept,
                  customData: customData,
                ),
              ),
            );
    (addResult.error == null && addResult.errorInvitees.isEmpty
        ? ZegoLoggerService.logInfo
        : ZegoLoggerService.logError)(
      'addPKBattleRequest, result:$addResult, '
      'error invitees:${addResult.errorInvitees.entries.map(
            (entry) => 'user'
                ' ${entry.key}\'s reason is ${entry.value}',
          ).join(',')}',
      tag: 'live streaming',
      subTag: 'pk service',
    );
    if (null != addResult.error) {
      return ZegoLiveStreamingPKServiceSendRequestResult(
        requestID: addResult.invitationID,
        errorUserIDs: addResult.errorInvitees.keys.toList(),
        error: addResult.error,
      );
    }
    if (addResult.errorInvitees.length == targetHostUserIDs.length) {
      /// all user failed
      return ZegoLiveStreamingPKServiceSendRequestResult(
        requestID: addResult.invitationID,
        errorUserIDs: addResult.errorInvitees.keys.toList(),
        error: PlatformException(
          code: '-1',
          message: 'failed to add pk battle request, '
              '${addResult.errorInvitees.entries.map(
                    (entry) => 'user '
                        '${entry.key}\'s reason is ${entry.value}',
                  ).join(',')}',
        ),
      );
    }

    return ZegoLiveStreamingPKServiceSendRequestResult(
      requestID: addResult.invitationID,
    );
  }

  /// Cancel your PK invitation to [targetHostIDs].
  Future<ZegoLiveStreamingPKServiceResult> cancelPKBattleRequest({
    required List<String> targetHostIDs,
    String customData = '',
  }) async {
    final isWaitingRemoteResponse =
        _coreData.remoteUserIDsWaitingResponseFromLocalRequest().isNotEmpty;
    if (!_serviceInitialized ||
        !isLiving ||
        !isHost ||
        !isWaitingRemoteResponse ||

        /// zim, count not cancel if anyone accepted
        ZegoLiveStreamingPKBattleStateV2.inPK == pkStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'could not cancel pk request, '
        'init:$_serviceInitialized, '
        'state:${pkStateNotifier.value}, '
        'is living:$isLiving, '
        'is host:$isHost, '
        'isWaitingRemoteResponse:$isWaitingRemoteResponse, ',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return ZegoLiveStreamingPKServiceResult(
        error: PlatformException(
          code: '-1',
          message: 'could not cancel pk request, '
              'init:$_serviceInitialized, '
              'state:${pkStateNotifier.value}, '
              'is living:$isLiving, '
              'is host:$isHost',
        ),
      );
    }

    if (targetHostIDs.isEmpty) {
      ZegoLoggerService.logInfo(
        'could not cancel pk request, '
        'param is invalid, '
        'target host user ids:$targetHostIDs',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return ZegoLiveStreamingPKServiceResult(
        error: PlatformException(
          code: '-1',
          message: 'param is invalid, '
              'target host user ids:$targetHostIDs',
        ),
      );
    }

    ZegoLoggerService.logInfo(
      'cancelPKBattleRequest, '
      'targetHostUserIDs:$targetHostIDs, '
      'customData:$customData, ',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    final cancelResult =
        await ZegoUIKit().getSignalingPlugin().cancelAdvanceInvitation(
              invitees: targetHostIDs,
              invitationID: _coreData.currentRequestID,
              data: jsonEncode(<String, String>{
                'custom_data': customData,
              }),
            );
    ((cancelResult.error == null)
        ? ZegoLoggerService.logInfo
        : ZegoLoggerService.logError)(
      'cancelPKBattleRequest,'
      ' result:$cancelResult, '
      'error invitees:${cancelResult.errorInvitees}',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    if (null != cancelResult.error) {
      return ZegoLiveStreamingPKServiceResult(error: cancelResult.error);
    }
    if (cancelResult.errorInvitees.length == targetHostIDs.length) {
      /// all user failed
      return ZegoLiveStreamingPKServiceResult(
        error: PlatformException(
          code: '-1',
          message:
              'failed to cancel pk battle request: ${cancelResult.errorInvitees}',
        ),
      );
    }

    _coreData.currentRequestID = '';
    updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);

    return const ZegoLiveStreamingPKServiceResult();
  }

  /// Agree PK invitation from [requestID].
  Future<ZegoLiveStreamingPKServiceResult> acceptPKBattleRequest({
    required String requestID,
    required ZegoUIKitPrebuiltLiveStreamingPKUser targetHost,
    int timeout = 60,
    String customData = '',
  }) async {
    final isWaitingLocalResponse =
        _coreData.isRemoteRequestWaitingLocalResponse();
    if (!_serviceInitialized ||
        !isLiving ||
        !isHost ||
        !isWaitingLocalResponse) {
      ZegoLoggerService.logInfo(
        'could not accept pk request, '
        'init:$_serviceInitialized, '
        'state:${pkStateNotifier.value}, '
        'is living:$isLiving, '
        'is host:$isHost, '
        'isWaitingLocalResponse:$isWaitingLocalResponse, ',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return ZegoLiveStreamingPKServiceResult(
        error: PlatformException(
          code: '-1',
          message: 'could not accept pk request, '
              'init:$_serviceInitialized, '
              'state:${pkStateNotifier.value}, '
              'is living:$isLiving, '
              'is host:$isHost',
        ),
      );
    }

    _coreData.clearRequestReceivedEventInMinimizing();

    /// during the dialog box stay or somethings delay,
    /// the data will be updated,
    /// and here we need to obtain the latest data.
    final sessionHosts = getAcceptedHostsInSession(requestID, ignoreUserIDs: [
      ZegoUIKit().getLocalUser().id,
      targetHost.userInfo.id,
    ]);
    final sessionInitiator =
        ZegoUIKit().getSignalingPlugin().getAdvanceInitiator(requestID);
    if (null != sessionInitiator &&
        targetHost.userInfo.id != sessionInitiator.userID) {
      final initiatorPKRequestData = PKServiceV2RequestData.fromJson(
        jsonDecode(sessionInitiator.extendedData) as Map<String, dynamic>,
      );
      sessionHosts.add(ZegoUIKitPrebuiltLiveStreamingPKUser(
        userInfo: ZegoUIKitUser(
          id: sessionInitiator.userID,
          name: initiatorPKRequestData.inviter.name,
        ),
        liveID: initiatorPKRequestData.liveID,
      ));
    }

    ZegoLoggerService.logInfo(
      'acceptPKBattleRequest, '
      'requestID:$requestID, '
      'targetHost:${targetHost.userInfo.id}, '
      'targetHostLiveID:${targetHost.liveID}, '
      'session hosts:$sessionHosts, '
      'timeout:$timeout, '
      'customData:$customData',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    final acceptResult =
        await ZegoUIKit().getSignalingPlugin().acceptAdvanceInvitation(
              invitationID: requestID,
              inviterID: targetHost.userInfo.id,
              inviterName: targetHost.userInfo.name,
              data: jsonEncode(PKServiceV2AcceptData(
                name: ZegoUIKit().getLocalUser().name,
                liveID: _coreData.roomID,
              )),
            );
    ((acceptResult.error != null)
            ? ZegoLoggerService.logError
            : ZegoLoggerService.logInfo)
        .call(
      'acceptPKBattleRequest, result:$acceptResult',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    if (null != acceptResult.error) {
      updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);

      return ZegoLiveStreamingPKServiceResult(error: acceptResult.error);
    }

    updatePKState(ZegoLiveStreamingPKBattleStateV2.loading);
    updatePKUsers([
      ZegoUIKitPrebuiltLiveStreamingPKUser(
        userInfo: ZegoUIKit().getLocalUser(),
        liveID: _coreData.roomID,
      ),
      targetHost,
      ...sessionHosts,
    ]);

    return const ZegoLiveStreamingPKServiceResult();
  }

  /// Reject PK invitation from [requestID].
  Future<ZegoLiveStreamingPKServiceResult> rejectPKBattleRequest({
    required String requestID,
    required String targetHostID,
    int timeout = 60,
    String customData = '',
  }) async {
    final isWaitingLocalResponse =
        _coreData.isRemoteRequestWaitingLocalResponse();
    if (!_serviceInitialized ||
        !isLiving ||
        !isHost ||
        !isWaitingLocalResponse) {
      ZegoLoggerService.logInfo(
        'could not reject pk request, '
        'init:$_serviceInitialized, '
        'state:${pkStateNotifier.value}, '
        'is living:$isLiving, '
        'is host:$isHost, '
        'isWaitingLocalResponse:$isWaitingLocalResponse, ',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return ZegoLiveStreamingPKServiceResult(
        error: PlatformException(
          code: '-1',
          message: 'could not reject pk request, '
              'init:$_serviceInitialized, '
              'state:${pkStateNotifier.value}, '
              'is living:$isLiving, '
              'is host:$isHost',
        ),
      );
    }

    ZegoLoggerService.logInfo(
      'rejectPKBattleRequest, '
      'requestID:$requestID, '
      'targetHostID:$targetHostID, '
      'timeout:$timeout, '
      'customData:$customData',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    _coreData.clearRequestReceivedEventInMinimizing();

    final rejectResult =
        await ZegoUIKit().getSignalingPlugin().refuseAdvanceInvitation(
            invitationID: requestID,
            inviterID: targetHostID,
            data: jsonEncode(PKServiceV2RejectData(
              code: ZegoLiveStreamingPKBattleRejectCodeV2.reject.index,
              inviterID: targetHostID,
              inviteeName: ZegoUIKit().getLocalUser().name,
            )));
    ((rejectResult.error != null)
            ? ZegoLoggerService.logError
            : ZegoLoggerService.logInfo)
        .call(
      'rejectPKBattleRequest, result:$rejectResult',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);

    return ZegoLiveStreamingPKServiceResult(error: rejectResult.error);
  }
}
