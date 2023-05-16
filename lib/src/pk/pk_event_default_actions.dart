// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_service.dart';

/// @nodoc
class ZegoLiveStreamingPKBattleDefaultActions {
  static BuildContext get context =>
      ZegoUIKitPrebuiltLiveStreamingService().context;

  static bool get rootNavigator =>
      ZegoUIKitPrebuiltLiveStreamingService().rootNavigator;

  static Future<void> onIncomingPKBattleRequestReceived(
      ZegoIncomingPKBattleRequestReceivedEvent event) async {
    ZegoLoggerService.logInfo(
      'onIncomingPKBattleRequestReceived, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );
    // TODO add a showing requestReceived dialog flag
    await showLiveDialog(
      context: context,
      rootNavigator: rootNavigator,
      title: 'PK Battle Request',
      content: '${event.anotherHost.name} sends a PK battle request to you.',
      leftButtonText: 'Reject',
      leftButtonCallback: () {
        ZegoUIKitPrebuiltLiveStreamingService()
            .rejectIncomingPKBattleRequest(event);
        Navigator.of(
          context,
          rootNavigator: rootNavigator,
        ).pop();
      },
      rightButtonText: 'Accept',
      rightButtonCallback: () {
        ZegoUIKitPrebuiltLiveStreamingService()
            .acceptIncomingPKBattleRequest(event);
        Navigator.of(
          context,
          rootNavigator: rootNavigator,
        ).pop();
      },
    );
  }

  static void onIncomingPKBattleRequestCancelled(
      ZegoIncomingPKBattleRequestCancelledEvent event) {
    ZegoLoggerService.logInfo(
      'onIncomingPKBattleRequestCancelled, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );
  }

  static void onIncomingPKBattleRequestTimeout(
      ZegoIncomingPKBattleRequestTimeoutEvent event) {
    ZegoLoggerService.logInfo(
      'onIncomingPKBattleRequestTimeoutt, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );
  }

  static Future<void> onPKBattleEndedByAnotherHost(
      ZegoIncomingPKBattleRequestReceivedEvent event) async {
    ZegoLoggerService.logInfo(
      'onPKBattleEndedByAnotherHost, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );
    ZegoUIKitPrebuiltLiveStreamingService()
        .stopPKBattle(triggeredByAotherHost: true);

    // TODO add a showing ok dialog flag
    showLiveDialog(
      context: context,
      rootNavigator: rootNavigator,
      title: 'PK Battle Ended',
      content: '${event.anotherHost.name} ended the PK Battle.',
      rightButtonText: 'OK',
    );
  }

  static void onOutgoingPKBattleRequestAccepted(
      ZegoOutgoingPKBattleRequestAcceptedEvent event) {
    ZegoLoggerService.logInfo(
      'onOutgoingPKBattleRequestAccepted, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );

    ZegoUIKitPrebuiltLiveStreamingService().startPKBattleWith(
      anotherHostLiveID: event.anotherHostLiveID,
      anotherHostUserID: event.anotherHost.id,
      anotherHostUserName: event.anotherHost.name,
    );
  }

  static void onOutgoingPKBattleRequestRejected(
      ZegoOutgoingPKBattleRequestRejectedEvent event) {
    ZegoLoggerService.logInfo(
      'onOutgoingPKBattleRequestRejected, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );

    var content = 'code: ${event.code}.';
    var title = 'PK Battle Initiate Failed';
    if (event.code == ZegoLiveStreamingPKBattleRejectCode.busy.index) {
      content = 'The host is busy.';
    } else if (event.code ==
        ZegoLiveStreamingPKBattleRejectCode.hostStateError.index) {
      content = 'You can only initiate the PK battle when '
          'the host has started a livestream.';
    } else if (event.code == ZegoLiveStreamingPKBattleRejectCode.reject.index) {
      title = 'PK Battle Rejected';
      content = 'The host rejected your request.';
    }

    showLiveDialog(
      context: context,
      rootNavigator: rootNavigator,
      title: title,
      content: content,
      rightButtonText: 'OK',
    );
  }

  static void onOutgoingPKBattleRequestTimeout(
      ZegoOutgoingPKBattleRequestTimeoutEvent event) {
    ZegoLoggerService.logInfo(
      'onOutgoingPKBattleRequestTimeout, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );
  }
}
