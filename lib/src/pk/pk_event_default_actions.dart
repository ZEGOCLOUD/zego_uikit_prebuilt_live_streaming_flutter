// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_service.dart';

/// @nodoc
class ZegoLiveStreamingPKBattleDefaultActions {
  static BuildContext get context =>
      ZegoUIKitPrebuiltLiveStreamingPKService().context;

  static bool get rootNavigator =>
      ZegoUIKitPrebuiltLiveStreamingPKService().rootNavigator;

  static ZegoInnerText get innerText =>
      ZegoUIKitPrebuiltLiveStreamingPKService().innerText;

  static Future<void> onIncomingPKBattleRequestReceived(
      ZegoIncomingPKBattleRequestReceivedEvent event) async {
    ZegoLoggerService.logInfo(
      'onIncomingPKBattleRequestReceived, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );

    final dialogInfo = innerText.incomingPKBattleRequestReceived;

    ZegoLiveStreamingPKBattleManager().showingRequestReceivedDialog = true;
    await showLiveDialog(
      context: context,
      rootNavigator: rootNavigator,
      title: dialogInfo.title,
      content: dialogInfo.message
          .replaceFirst(ZegoInnerText.param_1, event.anotherHost.name),
      leftButtonText: dialogInfo.cancelButtonName,
      leftButtonCallback: () {
        ZegoLiveStreamingPKBattleManager().showingRequestReceivedDialog = false;
        ZegoUIKitPrebuiltLiveStreamingPKService()
            .rejectIncomingPKBattleRequest(event);
        Navigator.of(
          context,
          rootNavigator: rootNavigator,
        ).pop();
      },
      rightButtonText: dialogInfo.confirmButtonName,
      rightButtonCallback: () {
        ZegoLiveStreamingPKBattleManager().showingRequestReceivedDialog = false;
        ZegoUIKitPrebuiltLiveStreamingPKService()
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
      'onIncomingPKBattleRequestTimeout, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );
  }

  static Future<void> onPKBattleEndedByAnotherHost(
    ZegoIncomingPKBattleRequestReceivedEvent event,
  ) async {
    ZegoLoggerService.logInfo(
      'onPKBattleEndedByAnotherHost, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );
    ZegoUIKitPrebuiltLiveStreamingPKService()
        .stopPKBattle(triggeredByAotherHost: true);

    final dialogInfo = innerText.pkBattleEndedCauseByAnotherHost;
    showLiveDialog(
      context: context,
      rootNavigator: rootNavigator,
      title: dialogInfo.title,
      content: dialogInfo.message
          .replaceFirst(ZegoInnerText.param_1, event.anotherHost.name),
      rightButtonText: dialogInfo.confirmButtonName,
    );
  }

  static void onOutgoingPKBattleRequestAccepted(
      ZegoOutgoingPKBattleRequestAcceptedEvent event) {
    ZegoLoggerService.logInfo(
      'onOutgoingPKBattleRequestAccepted, running default action',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );

    ZegoUIKitPrebuiltLiveStreamingPKService().startPKBattleWith(
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

    var dialogInfo = innerText.outgoingPKBattleRequestRejectedCauseByError;
    if (event.code == ZegoLiveStreamingPKBattleRejectCode.busy.index) {
      dialogInfo = innerText.outgoingPKBattleRequestRejectedCauseByBusy;
    } else if (event.code ==
        ZegoLiveStreamingPKBattleRejectCode.hostStateError.index) {
      dialogInfo =
          innerText.outgoingPKBattleRequestRejectedCauseByLocalHostStateError;
    } else if (event.code == ZegoLiveStreamingPKBattleRejectCode.reject.index) {
      dialogInfo = innerText.outgoingPKBattleRequestRejectedCauseByReject;
    }

    showLiveDialog(
      context: context,
      rootNavigator: rootNavigator,
      title: dialogInfo.title,
      content: dialogInfo.message
          .replaceFirst(ZegoInnerText.param_1, event.anotherHost.name),
      rightButtonText: dialogInfo.confirmButtonName,
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
