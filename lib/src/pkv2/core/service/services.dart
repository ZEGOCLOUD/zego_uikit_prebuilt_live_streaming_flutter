// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/event/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/mixer.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/protocol.dart';

part 'completer.dart';

part 'dialogs.dart';

part 'host.pk.dart';

part 'host.request.dart';

part 'pk_users.dart';

part '../event/events.dart';

mixin ZegoUIKitPrebuiltLiveStreamingPKServicesV2 {
  bool _serviceInitialized = false;

  bool _eventInitialized = false;
  final List<StreamSubscription<dynamic>?> _eventSubscriptions = [];
  Completer<void>? _completer;

  late ZegoUIKitPrebuiltLiveStreamingPKDataV2 _coreData;
  StreamSubscription? _waitingQueryRoomPropertiesSubscription;
  Timer? _heartBeatTimer;

  final _mixer = ZegoUIKitPrebuiltLiveStreamingPKServiceMixer();

  final pkStateNotifier = ValueNotifier<ZegoLiveStreamingPKBattleStateV2>(
    ZegoLiveStreamingPKBattleStateV2.idle,
  );

  bool isWaitingLocalResponse = false;

  bool get isInPK =>
      ZegoLiveStreamingPKBattleStateV2.inPK == pkStateNotifier.value;

  ValueNotifier<List<String>> get mutedUsersNotifier =>
      _mixer.mutedUsersNotifier;

  void updatePKState(ZegoLiveStreamingPKBattleStateV2 value) {
    if (pkStateNotifier.value == value) {
      return;
    }

    ZegoLoggerService.logInfo(
      'update pk state, from ${pkStateNotifier.value} to $value',
      tag: 'live streaming',
      subTag: 'pk service',
    );
    pkStateNotifier.value = value;

    _coreData.prebuiltConfig?.onLiveStreamingStateUpdate?.call(
      (ZegoLiveStreamingPKBattleStateV2.loading == value || isInPK)
          ? ZegoLiveStreamingState.inPKBattle
          : (isLiving
              ? ZegoLiveStreamingState.living
              : ZegoLiveStreamingState.idle),
    );
  }

  String get currentMixerStreamID => _mixer.mixerID;

  bool get isHost => _coreData.hostManager?.isLocalHost ?? false;

  bool get isLiving => _coreData.liveStatusNotifier.value == LiveStatus.living;

  BuildContext? get context => _coreData.contextQuery?.call();

  void initServices({
    required ZegoUIKitPrebuiltLiveStreamingPKDataV2 coreData,
  }) {
    if (_serviceInitialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return;
    }

    _coreData = coreData;
    _serviceInitialized = true;

    _mixer.init(
      layout: _coreData.prebuiltConfig?.pkBattleV2Config.mixerLayout,
    );
    initEvents();
    listenPKUserChanged();

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'pk service',
    );
  }

  Future<void> uninitServices() async {
    if (!_serviceInitialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live streaming',
        subTag: 'pk service',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'pk service',
    );

    removeListenPKUserChanged();
    uninitEvents();

    _serviceInitialized = false;

    _mixer.uninit();
    _coreData.currentRequestID = '';
    _coreData.playingHostIDs.clear();

    updatePKState(ZegoLiveStreamingPKBattleStateV2.idle);
  }

  Future<bool> muteUserAudio({
    required List<String> targetHostIDs,
    required bool isMute,
  }) async {
    return _mixer.muteUserAudio(
      targetHostIDs: targetHostIDs,
      isMute: isMute,
      pkHosts: List.from(_coreData.currentPKUsers.value),
    );
  }
}
