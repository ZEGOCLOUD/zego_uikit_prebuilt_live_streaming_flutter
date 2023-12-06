// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/event/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/services.dart';

class ZegoUIKitPrebuiltLiveStreamingPKV2
    with ZegoUIKitPrebuiltLiveStreamingPKServicesV2 {
  ZegoUIKitPrebuiltLiveStreamingPKV2._internal();

  factory ZegoUIKitPrebuiltLiveStreamingPKV2() => instance;

  static final ZegoUIKitPrebuiltLiveStreamingPKV2 instance =
      ZegoUIKitPrebuiltLiveStreamingPKV2._internal();

  bool _initialized = false;
  final _data = ZegoUIKitPrebuiltLiveStreamingPKDataV2();

  String get currentRequestID => _data.currentRequestID;

  ValueNotifier<List<ZegoUIKitPrebuiltLiveStreamingPKUser>>
      get connectedPKHostsNotifier => _data.currentPKUsers;

  ValueNotifier<ZegoIncomingPKBattleRequestReceivedEventV2?>
      get pkBattleRequestReceivedEventInMinimizingNotifier =>
          _data.pkBattleRequestReceivedEventInMinimizingNotifier;

  void init({
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingController controller,
    required ZegoUIKitPrebuiltLiveStreamingEvents events,
    required ZegoInnerText innerText,
    required ZegoLiveHostManager hostManager,
    required ValueNotifier<LiveStatus> liveStatusNotifier,
    required ValueNotifier<bool> startedByLocalNotifier,
    required BuildContext Function()? contextQuery,
  }) {
    if (_initialized) {
      return;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    _initialized = true;

    _data.init(
      config: config,
      controller: controller,
      events: events,
      innerText: innerText,
      hostManager: hostManager,
      liveStatusNotifier: liveStatusNotifier,
      startedByLocalNotifier: startedByLocalNotifier,
      contextQuery: contextQuery,
    );

    initServices(coreData: _data);
  }

  Future<void> uninit() async {
    if (!_initialized) {
      return;
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'pk service',
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

  void updateContextQuery(BuildContext Function()? contextQuery) {
    ZegoLoggerService.logInfo(
      'update context query',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    _data.contextQuery = contextQuery;
  }
}
