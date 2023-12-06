part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerPKV2 {
  final _pkV2Controller = ZegoLiveStreamingPKControllerV2();

  ZegoLiveStreamingPKControllerV2 get pkV2 => _pkV2Controller;
}

/// Here are the APIs related to PK.
class ZegoLiveStreamingPKControllerV2 {
  /// Do not modify!!! Can only be used for listening.
  ValueNotifier<ZegoLiveStreamingPKBattleStateV2> get stateNotifier =>
      ZegoUIKitPrebuiltLiveStreamingPKV2.instance.pkStateNotifier;

  /// is in pk or not
  bool get isInPK => ZegoUIKitPrebuiltLiveStreamingPKV2.instance.isInPK;

  /// mute users notifier
  ValueNotifier<List<String>> get mutedUsersNotifier =>
      ZegoUIKitPrebuiltLiveStreamingPKV2.instance.mutedUsersNotifier;

  ///  the host list in invitation or PK.
  List<AdvanceInvitationUser> getInvitees(String requestID) {
    return ZegoUIKit().getSignalingPlugin().getAdvanceInvitees(requestID);
  }

  // /// Join the ongoing PK
  // Future<ZegoSignalingPluginJoinInvitationResult> join(
  //   String requestID, {
  //   String? data,
  // }) async {
  //   return ZegoUIKit().getSignalingPlugin().joinAdvanceInvitation(
  //         invitationID: requestID,
  //         data: data,
  //       );
  // }

  /// inviting hosts for a PK.
  ///
  /// you will need to specify the [targetHostIDs] you want to connect with.
  /// Remember the hosts you invite must has started a live stream,
  /// otherwise, an error will return via the method you called.
  ///
  /// you can used f[timeout] to set the timeout duration of the PK battle
  /// request you sent. After it timed out, the host who sent the request
  /// will receive a callback notification via the [ZegoUIKitPrebuiltLiveStreamingPKV2Events.onOutgoingPKBattleRequestTimeout].
  ///
  /// if you want to customize the info that you want the host you invited to
  /// receive, you can set [customData], and the invited host will receive
  /// via [ZegoUIKitPrebuiltLiveStreamingPKV2Events.onIncomingPKBattleRequestReceived].
  ///
  /// If you want the remote host to directly accept without a confirmation
  /// dialog before entering the PK, you can set [isAutoAccept] to true.
  /// Please note that within the same PK session, this value ONLY takes
  /// effect the FIRST time it is set (after the first acceptance of the
  /// invitation), subsequent invitations will use the value set during the
  /// first acceptance.
  Future<ZegoLiveStreamingPKServiceSendRequestResult> sendRequest({
    required List<String> targetHostIDs,
    int timeout = 60,
    String customData = '',
    bool isAutoAccept = false,
  }) async {
    return ZegoUIKitPrebuiltLiveStreamingPKV2.instance.sendPKBattleRequest(
      targetHostIDs: targetHostIDs,
      timeout: timeout,
      customData: customData,
      isAutoAccept: isAutoAccept,
    );
  }

  /// Cancel the PK invitation to [targetHostIDs].
  /// You can provide your reason by attaching [customData].
  ///
  /// Please note that, if the PK has already started (and any invited host
  /// has accepted), the PK invitation cannot be cancelled.
  Future<ZegoLiveStreamingPKServiceResult> cancelRequest({
    required List<String> targetHostIDs,
    String customData = '',
  }) async {
    return ZegoUIKitPrebuiltLiveStreamingPKV2.instance.cancelPKBattleRequest(
      targetHostIDs: targetHostIDs,
      customData: customData,
    );
  }

  /// Accept the PK invitation from the [targetHost], which invitation ID is
  /// [requestID].
  ///
  /// If exceeds [timeout] seconds, the accept will be considered timed out.
  /// You can provide your reason by attaching [customData].
  Future<ZegoLiveStreamingPKServiceResult> acceptRequest({
    required String requestID,
    required ZegoUIKitPrebuiltLiveStreamingPKUser targetHost,
    int timeout = 60,
    String customData = '',
  }) async {
    return ZegoUIKitPrebuiltLiveStreamingPKV2.instance.acceptPKBattleRequest(
      requestID: requestID,
      targetHost: targetHost,
      timeout: timeout,
      customData: customData,
    );
  }

  /// Rejects the PK invitation from the [targetHost], which invitation ID is [requestID].
  ///
  /// If the rejection exceeds [timeout] seconds, the rejection will be considered timed out.
  /// You can provide your reason by attaching [customData].
  Future<ZegoLiveStreamingPKServiceResult> rejectRequest({
    required String requestID,
    required String targetHostID,
    int timeout = 60,
    String customData = '',
  }) async {
    return ZegoUIKitPrebuiltLiveStreamingPKV2.instance.rejectPKBattleRequest(
      requestID: requestID,
      targetHostID: targetHostID,
      timeout: timeout,
      customData: customData,
    );
  }

  /// Quit PK on your own.
  /// only pop the PK View on your own end,
  /// other PK participants decide on their own.
  Future<ZegoLiveStreamingPKServiceResult> quit() async {
    return ZegoUIKitPrebuiltLiveStreamingPKV2.instance.quitPKBattle(
      requestID: ZegoUIKitPrebuiltLiveStreamingPKV2.instance.currentRequestID,
    );
  }

  /// Stop PK to all pk-hosts, only the PK Initiator can stop it.
  /// The PK is over and all participants will exit the PK View.
  Future<ZegoLiveStreamingPKServiceResult> stop() async {
    return ZegoUIKitPrebuiltLiveStreamingPKV2.instance.stopPKBattle(
      requestID: ZegoUIKitPrebuiltLiveStreamingPKV2.instance.currentRequestID,
    );
  }

  /// Silence the [targetHostIDs] in PK, local host and audience in the live
  /// streaming won't hear the muted host's voice.
  ///
  /// If you want to cancel mute, set [isMute] to false.
  Future<bool> muteAudios({
    required List<String> targetHostIDs,
    required bool isMute,
  }) async {
    return ZegoUIKitPrebuiltLiveStreamingPKV2.instance.muteUserAudio(
      targetHostIDs: targetHostIDs,
      isMute: isMute,
    );
  }
}
