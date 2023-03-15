part of 'pk_impl.dart';

extension ZegoLiveStreamingPKBattleManagerEventConv
    on ZegoLiveStreamingPKBattleManager {
  Stream<ZegoIncomingPKBattleRequestReceivedEvent>
      getPKBattleEndedByAnotherHostEventStream() {
    return _getIncomingPKBattleRequestReceivedEventStream()
        .where((event) => event.subType == ZegoPKBattleRequestSubType.stop);
  }

  Stream<ZegoIncomingPKBattleRequestReceivedEvent>
      getIncomingPKBattleRequestReceivedEventStream() {
    return _getIncomingPKBattleRequestReceivedEventStream()
        .where((event) => event.subType == ZegoPKBattleRequestSubType.start);
  }

  Stream<ZegoIncomingPKBattleRequestReceivedEvent>
      _getIncomingPKBattleRequestReceivedEventStream() {
    return ZegoUIKit()
        .getSignalingPlugin()
        .getInvitationReceivedStream()
        .where((param) =>
            param['type'] == ZegoInvitationType.crossRoomPKBattleRequest.value)
        .map((param) {
      final ZegoUIKitUser inviter = param['inviter']!;
      final String data = param['data']!;
      final String invitationID = param['invitation_id']!;
      final int timeoutSecond = param['timeout_second']!;

      final extendedDataMap = jsonDecode(data) as Map<String, dynamic>;
      final String inviterLiveID = extendedDataMap['live_id'] ?? '';
      final String customData = extendedDataMap['custom_data'] ?? '';
      final subType = ZegoPKBattleRequestSubType
          .values[(extendedDataMap['sub_type'] as int)];

      final event = ZegoIncomingPKBattleRequestReceivedEvent(
        subType: subType,
        anotherHostLiveID: inviterLiveID,
        anotherHost: inviter,
        timeoutSecond: timeoutSecond,
        customData: customData,
        requestID: invitationID,
      );

      return event;
    });
  }

  Stream<ZegoIncomingPKBattleRequestCancelledEvent>
      getIncomingPKBattleRequestCancelledEventStream() {
    return ZegoUIKit()
        .getSignalingPlugin()
        .getInvitationCanceledStream()
        .where((param) =>
            param['type'] == ZegoInvitationType.crossRoomPKBattleRequest.value)
        .map((param) {
      final ZegoUIKitUser inviter = param['inviter']!;
      final String data = param['data']!;
      final String invitationID = param['invitation_id']!;

      final extendedDataMap = jsonDecode(data) as Map<String, dynamic>;
      final String customData = extendedDataMap['custom_data'] ?? '';

      final event = ZegoIncomingPKBattleRequestCancelledEvent(
        requestID: invitationID,
        anotherHost: inviter,
        customData: customData,
      );

      return event;
    });
  }

  Stream<ZegoIncomingPKBattleRequestTimeoutEvent>
      getIncomingPKBattleRequestTimeoutEventStream() {
    return ZegoUIKit()
        .getSignalingPlugin()
        .getInvitationTimeoutStream()
        .where((param) =>
            param['type'] == ZegoInvitationType.crossRoomPKBattleRequest.value)
        .map((param) {
      final ZegoUIKitUser inviter = param['inviter']!;
      final String invitationID = param['invitation_id']!;
      final String data = param['data']!;

      final extendedDataMap = jsonDecode(data) as Map<String, dynamic>;
      final subType = ZegoPKBattleRequestSubType
          .values[(extendedDataMap['sub_type'] as int)];

      final event = ZegoIncomingPKBattleRequestTimeoutEvent(
        anotherHost: inviter,
        requestID: invitationID,
        subType: subType,
      );

      return event;
    }).where((event) => event.subType == ZegoPKBattleRequestSubType.start);
  }

  Stream<ZegoOutgoingPKBattleRequestAcceptedEvent>
      getOutgoingPKBattleRequestAcceptedEventStream() {
    return ZegoUIKit()
        .getSignalingPlugin()
        .getInvitationAcceptedStream()
        .where((param) =>
            param['type'] == ZegoInvitationType.crossRoomPKBattleRequest.value)
        .map((param) {
      final ZegoUIKitUser invitee = param['invitee']!;
      final String data = param['data']!;
      final String invitationID = param['invitation_id']!;

      final extendedDataMap = jsonDecode(data) as Map<String, dynamic>;
      final String anotherHostLiveID = extendedDataMap['live_id'] ?? '';
      final String anotherHostUserName = extendedDataMap['invitee_name'] ?? '';
      final subType = ZegoPKBattleRequestSubType
          .values[(extendedDataMap['sub_type'] as int)];

      final event = ZegoOutgoingPKBattleRequestAcceptedEvent(
        anotherHostLiveID: anotherHostLiveID,
        requestID: invitationID,
        anotherHost: invitee..name = anotherHostUserName,
        subType: subType,
      );

      return event;
    }).where((event) => event.subType == ZegoPKBattleRequestSubType.start);
  }

  Stream<ZegoOutgoingPKBattleRequestRejectedEvent>
      getOutgoingPKBattleRequestRejectedEventStream() {
    return ZegoUIKit()
        .getSignalingPlugin()
        .getInvitationRefusedStream()
        .where((param) =>
            param['type'] == ZegoInvitationType.crossRoomPKBattleRequest.value)
        .map((param) {
      final ZegoUIKitUser invitee = param['invitee']!;
      final String data = param['data']!;
      final String invitationID = param['invitation_id']!;

      final extendedDataMap = jsonDecode(data) as Map<String, dynamic>;
      final String anotherHostUserName = extendedDataMap['invitee_name'] ?? '';
      final int code = extendedDataMap['code'] ?? 0;
      final subType = ZegoPKBattleRequestSubType
          .values[(extendedDataMap['sub_type'] as int)];

      final event = ZegoOutgoingPKBattleRequestRejectedEvent(
        code: code,
        requestID: invitationID,
        anotherHost: invitee..name = anotherHostUserName,
        subType: subType,
      );

      return event;
    }).where((event) => event.subType == ZegoPKBattleRequestSubType.start);
  }

  Stream<ZegoOutgoingPKBattleRequestTimeoutEvent>
      getOutgoingPKBattleRequestTimeoutEventStream() {
    return ZegoUIKit()
        .getSignalingPlugin()
        .getInvitationResponseTimeoutStream()
        .where((param) =>
            (param['type'] ==
                ZegoInvitationType.crossRoomPKBattleRequest.value) &&
            ((param['invitees'] as List?)?.isNotEmpty ?? false))
        .map((param) {
      final String invitationID = param['invitation_id']!;
      final List<ZegoUIKitUser> invitees = param['invitees']!;

      final event = ZegoOutgoingPKBattleRequestTimeoutEvent(
        requestID: invitationID,
        anotherHost: invitees.first,
      );

      return event;
    });
  }

  void initEvent() {
    _subscriptions.addAll([
      getIncomingPKBattleRequestReceivedEventStream().listen((event) async {
        ZegoLoggerService.logInfo(
          'onIncomingPKBattleRequestReceived, $event',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );
        if (!isLiving || !isHost) {
          ZegoLoggerService.logInfo(
            'onIncomingPKBattleRequestReceived, isLiving:$isLiving, '
            'isHost:$isHost, auto reject with code '
            '${ZegoLiveStreamingPKBattleRejectCode.hostStateError.index}',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
          ZegoUIKit().getSignalingPlugin().refuseInvitation(
              inviterID: event.anotherHost.id,
              data: jsonEncode({
                'sub_type': ZegoPKBattleRequestSubType.start.index,
                'code':
                    ZegoLiveStreamingPKBattleRejectCode.hostStateError.index,
                'invitation_id': event.requestID,
                'invitee_name': ZegoUIKit().getLocalUser().name,
              }));
          return;
        }

        if (state.value != ZegoLiveStreamingPKBattleState.idle) {
          final ret = await ZegoUIKit().getSignalingPlugin().refuseInvitation(
                inviterID: event.anotherHost.id,
                data: jsonEncode({
                  'sub_type': ZegoPKBattleRequestSubType.start.index,
                  'code': ZegoLiveStreamingPKBattleRejectCode.busy.index,
                  'invitation_id': event.requestID,
                  'invitee_name': ZegoUIKit().getLocalUser().name,
                }),
              );

          ((ret.error != null)
                  ? ZegoLoggerService.logError
                  : ZegoLoggerService.logInfo)
              .call(
            'onIncomingPKBattleRequestReceived, busy, auto reject, ret:$ret',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'api',
          );
          return;
        }

        ZegoUIKitPrebuiltLiveStreamingService().pkBattleState.value =
            ZegoLiveStreamingPKBattleState.waitingMyResponse;
        void defaultAction() => ZegoLiveStreamingPKBattleDefaultActions
            .onIncomingPKBattleRequestReceived(event);
        void customAction() =>
            config.pkBattleEvents.onIncomingPKBattleRequestReceived
                ?.call(event, defaultAction);
        (config.pkBattleEvents.onIncomingPKBattleRequestReceived != null)
            ? customAction()
            : defaultAction();
      }),
      getPKBattleEndedByAnotherHostEventStream().listen((event) {
        ZegoLoggerService.logInfo(
          'onPKBattleEndedByAnotherHost, $event',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );
        if (!isLiving ||
            !isHost ||
            (state.value != ZegoLiveStreamingPKBattleState.inPKBattle)) {
          ZegoLoggerService.logInfo(
            'onPKBattleEndedByAnotherHost, isLiving:$isLiving, '
            'isHost:$isHost, state:${state.value.name}, ignore stop',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
          ZegoUIKit().getSignalingPlugin().refuseInvitation(
              inviterID: event.anotherHost.id,
              data: jsonEncode({
                'sub_type': ZegoPKBattleRequestSubType.stop.index,
                'code':
                    ZegoLiveStreamingPKBattleRejectCode.hostStateError.index,
                'invitation_id': event.requestID,
                'invitee_name': ZegoUIKit().getLocalUser().name,
              }));
          return;
        }

        void defaultAction() => ZegoLiveStreamingPKBattleDefaultActions
            .onPKBattleEndedByAnotherHost(event);
        void customAction() =>
            config.pkBattleEvents.onPKBattleEndedByAnotherHost
                ?.call(event, defaultAction);
        (config.pkBattleEvents.onPKBattleEndedByAnotherHost != null)
            ? customAction()
            : defaultAction();
      }),
      getIncomingPKBattleRequestCancelledEventStream().listen((event) {
        ZegoLoggerService.logInfo(
          'onIncomingPKBattleRequestReceived, $event',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );
        // TODO add a inner dialog flag
        if (ZegoUIKitPrebuiltLiveStreamingService().pkBattleState.value ==
            ZegoLiveStreamingPKBattleState.waitingMyResponse) {
          ZegoLoggerService.logInfo(
            'onIncomingPKBattleRequestReceived, close inner dialog',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
          Navigator.of(
            context,
            rootNavigator: config.rootNavigator,
          ).pop();
          ZegoUIKitPrebuiltLiveStreamingService().pkBattleState.value =
              ZegoLiveStreamingPKBattleState.idle;
        }
        void defaultAction() => ZegoLiveStreamingPKBattleDefaultActions
            .onIncomingPKBattleRequestCancelled(event);
        void customAction() =>
            config.pkBattleEvents.onIncomingPKBattleRequestCancelled
                ?.call(event, defaultAction);
        (config.pkBattleEvents.onIncomingPKBattleRequestCancelled != null)
            ? customAction()
            : defaultAction();
      }),
      getIncomingPKBattleRequestTimeoutEventStream().listen((event) {
        ZegoLoggerService.logInfo(
          'onIncomingPKBattleRequestTimeout, $event',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );
        // TODO add a inner dialog flag
        if (ZegoUIKitPrebuiltLiveStreamingService().pkBattleState.value ==
            ZegoLiveStreamingPKBattleState.waitingMyResponse) {
          ZegoLoggerService.logInfo(
            'onIncomingPKBattleRequestTimeout, closes inner dialog',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
          Navigator.of(
            context,
            rootNavigator: config.rootNavigator,
          ).pop();
          ZegoUIKitPrebuiltLiveStreamingService().pkBattleState.value =
              ZegoLiveStreamingPKBattleState.idle;
        }
        void defaultAction() => ZegoLiveStreamingPKBattleDefaultActions
            .onIncomingPKBattleRequestTimeout(event);
        void customAction() =>
            config.pkBattleEvents.onIncomingPKBattleRequestTimeout
                ?.call(event, defaultAction);
        (config.pkBattleEvents.onIncomingPKBattleRequestTimeout != null)
            ? customAction()
            : defaultAction();
      }),
      getOutgoingPKBattleRequestAcceptedEventStream().listen((event) {
        ZegoLoggerService.logInfo(
          'onOutgoingPKBattleRequestAccepted, $event',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );
        waitingOutgoingPKBattleRequestID = '';
        waitingOutgoingPKBattleRequestUserID = '';
        void defaultAction() => ZegoLiveStreamingPKBattleDefaultActions
            .onOutgoingPKBattleRequestAccepted(event);
        void customAction() =>
            config.pkBattleEvents.onOutgoingPKBattleRequestAccepted
                ?.call(event, defaultAction);
        (config.pkBattleEvents.onOutgoingPKBattleRequestAccepted != null)
            ? customAction()
            : defaultAction();
      }),
      getOutgoingPKBattleRequestRejectedEventStream().listen((event) {
        var message = 'code: ${event.code}.';
        if (event.code == ZegoLiveStreamingPKBattleRejectCode.busy.index) {
          message = 'The host is busy.';
        } else if (event.code ==
            ZegoLiveStreamingPKBattleRejectCode.hostStateError.index) {
          message =
              "Failed to initiated the PK battle cause the host hasn't started a livestream.";
        } else if (event.code ==
            ZegoLiveStreamingPKBattleRejectCode.reject.index) {
          message = 'The host rejected your request.';
        }
        ZegoLoggerService.logInfo(
          'onOutgoingPKBattleRequestRejected, $event ($message)',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );
        waitingOutgoingPKBattleRequestID = '';
        waitingOutgoingPKBattleRequestUserID = '';
        state.value = ZegoLiveStreamingPKBattleState.idle;

        void defaultAction() => ZegoLiveStreamingPKBattleDefaultActions
            .onOutgoingPKBattleRequestRejected(event);
        void customAction() =>
            config.pkBattleEvents.onOutgoingPKBattleRequestRejected
                ?.call(event, defaultAction);
        (config.pkBattleEvents.onOutgoingPKBattleRequestRejected != null)
            ? customAction()
            : defaultAction();
      }),
      getOutgoingPKBattleRequestTimeoutEventStream().listen((event) {
        ZegoLoggerService.logInfo(
          'onOutgoingPKBattleRequestTimeout, $event',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'event',
        );
        waitingOutgoingPKBattleRequestID = '';
        waitingOutgoingPKBattleRequestUserID = '';
        ZegoUIKitPrebuiltLiveStreamingService().pkBattleState.value =
            ZegoLiveStreamingPKBattleState.idle;
        void defaultAction() => ZegoLiveStreamingPKBattleDefaultActions
            .onOutgoingPKBattleRequestTimeout(event);
        void customAction() =>
            config.pkBattleEvents.onOutgoingPKBattleRequestTimeout
                ?.call(event, defaultAction);
        (config.pkBattleEvents.onOutgoingPKBattleRequestTimeout != null)
            ? customAction()
            : defaultAction();
      }),
    ]);
  }

  void uninitEvent() {
    ZegoLoggerService.logInfo(
      'uninitEvent',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    for (final element in _subscriptions) {
      element.cancel();
    }
  }
}
