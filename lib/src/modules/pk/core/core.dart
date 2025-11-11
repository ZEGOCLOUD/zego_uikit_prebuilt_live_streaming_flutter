// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'data.dart';
import 'defines.dart';
import 'event/defines.dart';
import 'service/services.dart';

class ZegoUIKitPrebuiltLiveStreamingPK
    with ZegoUIKitPrebuiltLiveStreamingPKServices {
  ZegoUIKitPrebuiltLiveStreamingPK._internal();

  factory ZegoUIKitPrebuiltLiveStreamingPK() => instance;

  static final ZegoUIKitPrebuiltLiveStreamingPK instance =
      ZegoUIKitPrebuiltLiveStreamingPK._internal();

  bool _initialized = false;
  final _data = ZegoUIKitPrebuiltLiveStreamingPKData();

  String get currentRequestID => _data.currentRequestID;

  ValueNotifier<List<ZegoLiveStreamingPKUser>> get connectedPKHostsNotifier =>
      _data.currentPKUsers;

  ValueNotifier<ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent?>
      get pkBattleRequestReceivedEventInMinimizingNotifier =>
          _data.pkBattleRequestReceivedEventInMinimizingNotifier;

  void init({
    required String liveID,
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
    required BuildContext Function()? contextQuery,
  }) {
    if (_initialized) {
      return;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live-streaming-pk',
      subTag: 'service',
    );

    _initialized = true;

    _data.init(
      config: config,
      events: events,
      innerText: config.innerText,
      contextQuery: contextQuery,
    );

    initServices(liveID: liveID, coreData: _data);
  }

  Future<void> uninit() async {
    if (!_initialized) {
      return;
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live-streaming-pk',
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
    );

    _data.uninit();

    await uninitServices();
  }
}
