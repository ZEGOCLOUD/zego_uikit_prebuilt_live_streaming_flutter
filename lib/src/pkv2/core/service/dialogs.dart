part of 'services.dart';

extension PKServiceV2Dialogs on ZegoUIKitPrebuiltLiveStreamingPKServicesV2 {
  Future<bool> showRequestReceivedDialog(
    ZegoIncomingPKBattleRequestReceivedEventV2 event,
  ) async {
    popupPKBattleEndedDialog();
    popupOutgoingPKBattleRequestRejectedDialog();

    if (_coreData.showingRequestReceivedDialog) {
      popupRequestReceivedDialog();
    }

    if (context?.mounted ?? false) {
      _coreData.showingRequestReceivedDialog = true;
      final dialogInfo = innerText.incomingPKBattleRequestReceived;
      return showLiveDialog(
        context: context,
        rootNavigator: rootNavigator,
        title: dialogInfo.title,
        content: dialogInfo.message
            .replaceFirst(ZegoInnerText.param_1, event.fromHost.name),
        leftButtonText: dialogInfo.cancelButtonName,
        leftButtonCallback: () {
          Navigator.of(
            context!,
            rootNavigator: rootNavigator,
          ).pop(false);
        },
        rightButtonText: dialogInfo.confirmButtonName,
        rightButtonCallback: () {
          Navigator.of(
            context!,
            rootNavigator: rootNavigator,
          ).pop(true);
        },
      ).then((value) {
        _coreData.showingRequestReceivedDialog = false;

        return value;
      });
    }

    return false;
  }

  void popupRequestReceivedDialog() {
    if (_coreData.showingRequestReceivedDialog) {
      _coreData.showingRequestReceivedDialog = false;

      if (context?.mounted ?? false) {
        Navigator.of(
          context!,
          rootNavigator: rootNavigator,
        ).pop();
      }
    }
  }

  Future<void> showPKBattleEndedDialog(
    ZegoPKBattleEndedEventV2 event,
  ) async {
    if (event.isRequestFromLocal) {
      return;
    }

    if (_coreData.showingPKBattleEndedDialog) {
      popupPKBattleEndedDialog();
    }

    if (context?.mounted ?? false) {
      _coreData.showingPKBattleEndedDialog = true;
      final dialogInfo = innerText.pkBattleEndedCauseByAnotherHost;
      return showLiveDialog(
        context: context!,
        rootNavigator: rootNavigator,
        title: dialogInfo.title,
        content: dialogInfo.message
            .replaceFirst(ZegoInnerText.param_1, event.fromHost.name),
        rightButtonText: dialogInfo.confirmButtonName,
      ).then((value) {
        _coreData.showingPKBattleEndedDialog = false;
      });
    }
  }

  void popupPKBattleEndedDialog() {
    if (_coreData.showingPKBattleEndedDialog) {
      _coreData.showingPKBattleEndedDialog = false;

      if (context?.mounted ?? false) {
        Navigator.of(
          context!,
          rootNavigator: rootNavigator,
        ).pop();
      }
    }
  }

  Future<void> showOutgoingPKBattleRequestRejectedDialog(
    ZegoOutgoingPKBattleRequestRejectedEventV2 event,
  ) async {
    if (_coreData.showOutgoingPKBattleRequestRejectedDialog) {
      popupOutgoingPKBattleRequestRejectedDialog();
    }

    var dialogInfo = innerText.outgoingPKBattleRequestRejectedCauseByError;
    if (event.refuseCode == ZegoLiveStreamingPKBattleRejectCodeV2.busy.index) {
      dialogInfo = innerText.outgoingPKBattleRequestRejectedCauseByBusy;
    } else if (event.refuseCode ==
        ZegoLiveStreamingPKBattleRejectCodeV2.hostStateError.index) {
      dialogInfo =
          innerText.outgoingPKBattleRequestRejectedCauseByLocalHostStateError;
    } else if (event.refuseCode ==
        ZegoLiveStreamingPKBattleRejectCodeV2.reject.index) {
      dialogInfo = innerText.outgoingPKBattleRequestRejectedCauseByReject;
    }

    if (context?.mounted ?? false) {
      _coreData.showOutgoingPKBattleRequestRejectedDialog = true;
      return showLiveDialog(
        context: context,
        rootNavigator: rootNavigator,
        title: dialogInfo.title,
        content: dialogInfo.message
            .replaceFirst(ZegoInnerText.param_1, event.fromHost.name),
        rightButtonText: dialogInfo.confirmButtonName,
      ).then((value) {
        _coreData.showOutgoingPKBattleRequestRejectedDialog = false;
      });
    }
  }

  void popupOutgoingPKBattleRequestRejectedDialog() {
    if (_coreData.showOutgoingPKBattleRequestRejectedDialog) {
      _coreData.showOutgoingPKBattleRequestRejectedDialog = false;

      if (context?.mounted ?? false) {
        Navigator.of(
          context!,
          rootNavigator: rootNavigator,
        ).pop();
      }
    }
  }
}
