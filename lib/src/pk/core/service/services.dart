// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/event/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/mixer.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/protocol.dart';

part 'completer.dart';

part 'dialogs.dart';

part 'host.pk.dart';

part 'host.request.dart';

part 'pk_users.dart';

part '../event/events.dart';

mixin ZegoUIKitPrebuiltLiveStreamingPKServices {
  bool _serviceInitialized = false;

  bool _eventInitialized = false;
  final List<StreamSubscription<dynamic>?> _eventSubscriptions = [];
  Completer<void>? _completer;

  late ZegoUIKitPrebuiltLiveStreamingPKData _coreData;
  StreamSubscription? _waitingQueryRoomPropertiesSubscription;
  Timer? _heartBeatTimer;

  final _mixer = ZegoUIKitPrebuiltLiveStreamingPKServiceMixer();

  final pkStateNotifier = ValueNotifier<ZegoLiveStreamingPKBattleState>(
    ZegoLiveStreamingPKBattleState.idle,
  );

  bool isWaitingLocalResponse = false;

  bool get isInPK =>
      ZegoLiveStreamingPKBattleState.inPK == pkStateNotifier.value;

  ValueNotifier<List<String>> get mutedUsersNotifier =>
      _mixer.mutedUsersNotifier;

  void updatePKState(ZegoLiveStreamingPKBattleState value) {
    if (pkStateNotifier.value == value) {
      return;
    }

    ZegoLoggerService.logInfo(
      'update pk state, from ${pkStateNotifier.value} to $value',
      tag: 'live-streaming-pk',
      subTag: 'service',
    );
    pkStateNotifier.value = value;

    _coreData.events?.onStateUpdated?.call(
      (ZegoLiveStreamingPKBattleState.loading == value || isInPK)
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
    required ZegoUIKitPrebuiltLiveStreamingPKData coreData,
  }) {
    if (_serviceInitialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live-streaming-pk',
        subTag: 'service',
      );

      return;
    }

    _coreData = coreData;
    _serviceInitialized = true;

    _mixer.init(
      layout: _coreData.prebuiltConfig?.pkBattle.mixerLayout,
    );
    initEvents();
    listenPKUserChanged();

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live-streaming-pk',
      subTag: 'service',
    );
  }

  Future<void> uninitServices() async {
    if (!_serviceInitialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live-streaming-pk',
        subTag: 'service',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live-streaming-pk',
      subTag: 'service',
    );

    removeListenPKUserChanged();
    uninitEvents();

    _serviceInitialized = false;

    _mixer.uninit();
    _coreData.currentRequestID = '';
    _coreData.playingHostIDs.clear();

    updatePKState(ZegoLiveStreamingPKBattleState.idle);
  }

  Future<bool> muteUserAudio({
    required List<String> targetHostIDs,
    required bool isMute,
  }) async {
    ZegoLoggerService.logInfo(
      'targetHostIDs:$targetHostIDs, isMute:$isMute, ',
      tag: 'live-streaming-pk',
      subTag: 'service, muteUserAudio',
    );

    return _mixer.muteUserAudio(
      targetHostIDs: targetHostIDs,
      isMute: isMute,
      pkHosts: List.from(_coreData.currentPKUsers.value),
    );
  }
}
