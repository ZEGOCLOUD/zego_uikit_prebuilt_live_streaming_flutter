// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/src/pk_impl.dart';

export 'defines.dart';
export 'src/pk_impl.dart';

class ZegoUIKitPrebuiltLiveStreamingService {
  Future<ZegoLiveStreamingPKBattleResult> sendPKBattleRequest(
    String anotherHostUserID, {
    int timeout = 60,
    String customData = '',
  }) async {
    return _pkImpl.sendPKBattleRequest(
      anotherHostUserID,
      timeout: timeout,
      customData: customData,
    );
  }

  Future<ZegoLiveStreamingPKBattleResult> acceptIncomingPKBattleRequest(
    ZegoIncomingPKBattleRequestReceivedEvent event,
  ) async {
    return _pkImpl.acceptIncomingPKBattleRequest(event);
  }

  Future<ZegoLiveStreamingPKBattleResult> rejectIncomingPKBattleRequest(
    ZegoIncomingPKBattleRequestReceivedEvent event, {
    int? rejectCode,
  }) async {
    return _pkImpl.rejectIncomingPKBattleRequest(event, rejectCode: rejectCode);
  }

  Future<ZegoLiveStreamingPKBattleResult> cancelPKBattleRequest({
    String customData = '',
  }) async {
    return _pkImpl.cancelPKBattleRequest(
      customData: customData,
    );
  }

  Future<ZegoLiveStreamingPKBattleResult> startPKBattleWith({
    required String anotherHostLiveID,
    required String anotherHostUserID,
    required String anotherHostUserName,
  }) async {
    return _pkImpl.startPKBattleWith(
      anotherHostLiveID: anotherHostLiveID,
      anotherHostUserID: anotherHostUserID,
      anotherHostUserName: anotherHostUserName,
    );
  }

  Future<ZegoLiveStreamingPKBattleResult> stopPKBattle(
      {String customData = '', bool triggeredByAotherHost = false}) async {
    return _pkImpl.stopPKBattle(
      customData: customData,
      triggeredByAotherHost: triggeredByAotherHost,
    );
  }

  ValueNotifier<ZegoLiveStreamingPKBattleState> get pkBattleState =>
      _pkImpl.state;

  Future<void> muteAnotherHostAudio({required bool mute}) async =>
      _pkImpl.muteAnotherHostAudio(mute: mute);

  ValueNotifier<bool> get isAnotherHostMuted => _pkImpl.isAnotherHostMuted;

  String? get anotherHostLiveID => _pkImpl.anotherHostLiveID;

  ZegoUIKitUser? get anotherHost => _pkImpl.anotherHost;

  BuildContext get context => _pkImpl.context;

  bool get rootNavigator => _pkImpl.config.rootNavigator;

  // internal
  factory ZegoUIKitPrebuiltLiveStreamingService() => instance;

  ZegoUIKitPrebuiltLiveStreamingService._();

  static final ZegoUIKitPrebuiltLiveStreamingService instance =
      ZegoUIKitPrebuiltLiveStreamingService._();
  static final ZegoLiveStreamingPKBattleManager _pkImpl =
      ZegoLiveStreamingPKBattleManager();
}
