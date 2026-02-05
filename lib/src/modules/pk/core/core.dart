// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/pk_combine_notifier.dart';
import 'data.dart';
import 'defines.dart';
import 'event/defines.dart';
import 'service/services.dart';

class ZegoUIKitPrebuiltLiveStreamingPK
    with ZegoUIKitPrebuiltLiveStreamingPKServices {
  ZegoUIKitPrebuiltLiveStreamingPK({
    required this.liveID,
  });

  @override
  final String liveID;

  bool _initialized = false;
  final _data = ZegoUIKitPrebuiltLiveStreamingPKData();
  final combineNotifier = ZegoLiveStreamingPKBattleStateCombineNotifier();

  String get currentRequestID => _data.currentRequestID;

  ValueNotifier<List<ZegoLiveStreamingPKUser>> get connectedPKHostsNotifier =>
      _data.currentPKUsers;

  ValueNotifier<ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent?>
      get pkBattleRequestReceivedEventInMinimizingNotifier =>
          _data.pkBattleRequestReceivedEventInMinimizingNotifier;

  void init({
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
    required BuildContext Function()? contextQuery,
  }) {
    if (_initialized) {
      return;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live.streaming.pk',
      subTag: 'service',
    );

    _initialized = true;

    _data.init(
      config: config,
      events: events,
      innerText: config.innerText,
      contextQuery: contextQuery,
    );

    initServices(
      coreData: _data,
      prebuiltConfig: config,
    );

    combineNotifier.init(
      v2StateNotifier: pkStateNotifier,
      v2RequestReceivedEventInMinimizingNotifier:
          pkBattleRequestReceivedEventInMinimizingNotifier,
    );
  }

  Future<void> uninit({
    required bool isFromMinimize,
  }) async {
    if (!_initialized) {
      return;
    }

    ZegoLoggerService.logInfo(
      'uninit, '
      'isFromMinimize:$isFromMinimize, ',
      tag: 'live.streaming.pk',
      subTag: 'service',
    );

    _initialized = false;

    await cancelPKBattleRequest(
      targetHostIDs: ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitees(
            _data.currentRequestID,
          )
          .map((e) => e.userID)
          .toList(),
    );
    await quitPKBattle(
      requestID: _data.currentRequestID,
      force: isFromMinimize,
    );

    _data.uninit();

    await uninitServices();

    combineNotifier.uninit();
  }
}
