part of 'services.dart';

extension PKServiceHost on ZegoUIKitPrebuiltLiveStreamingPKServices {
  /// Quit PK on your own.
  /// only pop the PK View on your own end,
  /// other PK participants decide on their own.
  Future<ZegoLiveStreamingPKServiceResult> quitPKBattle({
    required String requestID,
    bool force = false,
  }) async {
    if (!force && (!_serviceInitialized || !isLiving || !isHost || !isInPK)) {
      ZegoLoggerService.logInfo(
        'could not quit pk battle, '
        'init:$_serviceInitialized, '
        'state:${pkStateNotifier.value}, '
        'is living:$isLiving, '
        'is host:$isHost, ',
        tag: 'live-streaming-pk',
        subTag: 'service, host, quitPKBattle',
      );

      return ZegoLiveStreamingPKServiceResult(
        error: PlatformException(
          code: '-1',
          message: 'could not quit pk battle, '
              'init:$_serviceInitialized, '
              'state:${pkStateNotifier.value}, '
              'is living:$isLiving, '
              'is host:$isHost, ',
        ),
      );
    }

    ZegoLoggerService.logInfo(
      'quit pk battle, force:$force',
      tag: 'live-streaming-pk',
      subTag: 'service, host, quitPKBattle',
    );

    updatePKUsers([]);

    final quitResult =
        await ZegoUIKit().getSignalingPlugin().quitAdvanceInvitation(
            invitationID: requestID,

            /// notify all user in current invitation
            data: jsonEncode({
              'code': ZegoLiveStreamingPKBattleRejectCode.reject.index,
              'invitation_id': requestID,
              'invitee_name': ZegoUIKit().getLocalUser().name,
            }));
    ZegoLoggerService.logInfo(
      'requestID:$requestID, result:$quitResult',
      tag: 'live-streaming-pk',
      subTag: 'service, host, quitPKBattle',
    );

    ZegoLiveStreamingReporter().report(
      event: ZegoLiveStreamingReporter.eventPKQuit,
      params: {
        ZegoLiveStreamingReporter.eventKeyCallID: quitResult.invitationID,
      },
    );

    return const ZegoLiveStreamingPKServiceResult();
  }

  /// Stop PK to all pk-hosts, only the PK Initiator can stop it.
  /// The PK is over and all participants have exited the PK View.
  Future<ZegoLiveStreamingPKServiceResult> stopPKBattle({
    required String requestID,
  }) async {
    var isRequestFromLocal = ZegoUIKit().getLocalUser().id ==
        ZegoUIKit().getSignalingPlugin().getAdvanceInitiator(requestID)?.userID;
    if (!_serviceInitialized ||
        !isLiving ||
        !isHost ||
        !isInPK ||
        !isRequestFromLocal) {
      ZegoLoggerService.logInfo(
        'could not stop pk battle, '
        'init:$_serviceInitialized, '
        'state:${pkStateNotifier.value}, '
        'is living:$isLiving, '
        'is host:$isHost, '
        'isRequestFromLocal:$isRequestFromLocal, ',
        tag: 'live-streaming-pk',
        subTag: 'service, host, stopPKBattle',
      );

      return ZegoLiveStreamingPKServiceResult(
        error: PlatformException(
          code: '-1',
          message: 'could stop end pk battle, '
              'init:$_serviceInitialized, '
              'state:${pkStateNotifier.value}, '
              'is living:$isLiving, '
              'is host:$isHost, '
              'isRequestFromLocal:$isRequestFromLocal, ',
        ),
      );
    }

    updatePKUsers([]);

    final endResult =
        await ZegoUIKit().getSignalingPlugin().endAdvanceInvitation(
            invitationID: requestID,

            /// notify all user in current invitation
            data: jsonEncode({
              'code': ZegoLiveStreamingPKBattleRejectCode.reject.index,
              'invitation_id': requestID,
              'invitee_name': ZegoUIKit().getLocalUser().name,
            }));
    ZegoLoggerService.logInfo(
      'requestID:$requestID, result:$endResult',
      tag: 'live-streaming-pk',
      subTag: 'service, host, stopPKBattle',
    );

    ZegoLiveStreamingReporter().report(
      event: ZegoLiveStreamingReporter.eventPKEnd,
      params: {
        ZegoLiveStreamingReporter.eventKeyCallID: endResult.invitationID,
      },
    );

    return const ZegoLiveStreamingPKServiceResult();
  }
}
