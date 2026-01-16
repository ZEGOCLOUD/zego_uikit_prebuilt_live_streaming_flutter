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
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/event/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/core/mixer.dart';
import 'defines.dart';
import 'protocol.dart';

part '../event/events.dart';
part 'completer.dart';
part 'dialogs.dart';
part 'host.pk.dart';
part 'host.request.dart';
part 'pk_users.dart';

mixin ZegoUIKitPrebuiltLiveStreamingPKServices {
  bool _serviceInitialized = false;

  String _liveID = '';
  ZegoUIKitPrebuiltLiveStreamingConfig? _prebuiltConfig;

  bool _eventInitialized = false;
  bool _eventListened = false;
  final List<StreamSubscription<dynamic>?> _eventSubscriptions = [];
  Completer<void>? _completer;

  late ZegoUIKitPrebuiltLiveStreamingPKData _coreData;
  StreamSubscription? _waitingQueryRoomPropertiesSubscription;
  Timer? _heartBeatTimer;

  final _mixer = ZegoUIKitPrebuiltLiveStreamingPKServiceMixer();

  final pkStateNotifier = ValueNotifier<ZegoLiveStreamingPKBattleState>(
    ZegoLiveStreamingPKBattleState.idle,
  );

  /// Notifier for PK room attributes initialization completion:
  /// - Initially false, indicating room attributes are not yet initialized
  /// - Set to true after room attributes query/update events complete
  /// - The view layer can use this value to decide whether to show PK-related views
  final roomAttributesInitNotifier = ValueNotifier<bool>(false);

  bool isWaitingLocalResponse = false;

  bool get isInPK =>
      ZegoLiveStreamingPKBattleState.inPK == pkStateNotifier.value;

  ValueNotifier<List<String>> get mutedUsersNotifier =>
      _mixer.mutedUsersNotifier;

  void updatePKState(ZegoLiveStreamingPKBattleState value) {
    if (pkStateNotifier.value == value) {
      ZegoLoggerService.logInfo(
        'current state(${pkStateNotifier.value}) is same',
        tag: 'live.streaming.pk.services',
        subTag: 'updatePKState',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'from ${pkStateNotifier.value} to $value',
      tag: 'live.streaming.pk.services',
      subTag: 'updatePKState',
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

  String get currentMixerStreamID => _mixer.mixerStreamID;

  String get liveID => _liveID;

  bool get isHost =>
      ZegoLiveStreamingPageLifeCycle().currentManagers.hostManager.isLocalHost;

  bool get isLiving =>
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .liveStatusManager
          .notifier
          .value ==
      LiveStatus.living;

  BuildContext? get context =>
      ZegoLiveStreamingPageLifeCycle().contextQuery?.call();

  /// 等待PK处理完成：
  /// - 如果当前状态为loading，则等待状态变为非loading（inPK或idle）
  /// - 用于在房间属性到来后，确保后续链路（混流、拉流、状态切换）处理完成
  Future<void> waitPKRoomAttributeProcessingFinished(
    List<ZegoLiveStreamingPKUser> updatedPKUsers,
  ) async {
    if (isHost) {
      return;
    }

    /// 观众等待房间属性处理完毕
    if (updatedPKUsers.isEmpty &&
        pkStateNotifier.value == ZegoLiveStreamingPKBattleState.idle) {
      return;
    }

    final completer = Completer<void>();
    void onStateChanged() {
      if (pkStateNotifier.value != ZegoLiveStreamingPKBattleState.loading) {
        pkStateNotifier.removeListener(onStateChanged);
        completer.complete();
      }
    }

    pkStateNotifier.addListener(onStateChanged);
    await completer.future;
  }

  void initServices({
    required String liveID,
    required ZegoUIKitPrebuiltLiveStreamingConfig prebuiltConfig,
    required ZegoUIKitPrebuiltLiveStreamingPKData coreData,
  }) {
    if (_serviceInitialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live.streaming.pk.services',
        subTag: 'init',
      );

      return;
    }

    _liveID = liveID;
    _prebuiltConfig = prebuiltConfig;
    _coreData = coreData;
    _serviceInitialized = true;

    _mixer.init(
      liveID: liveID,
      layout: _coreData.prebuiltConfig?.pkBattle.mixerLayout,
      prebuiltConfig: _prebuiltConfig,
    );
    // Reset room attribute init flag during initialization
    roomAttributesInitNotifier.value = false;
    initEvents();
    queryRoomProperties();
    listenPKUserChanged();

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.pk.services',
      subTag: 'init',
    );
  }

  Future<void> uninitServices() async {
    if (!_serviceInitialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live.streaming.pk.services',
        subTag: 'uninit',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.pk.services',
      subTag: 'uninit',
    );

    removeListenPKUserChanged();
    uninitEvents();

    _liveID = '';
    _prebuiltConfig = null;
    _serviceInitialized = false;

    _mixer.uninit();
    _coreData.currentRequestID = '';
    _coreData.playingHostIDs.clear();

    updatePKState(ZegoLiveStreamingPKBattleState.idle);
    // Reset room attribute init flag to false during uninitialization
    roomAttributesInitNotifier.value = false;
  }

  Future<bool> muteUserAudio({
    required List<String> targetHostIDs,
    required bool isMute,
  }) async {
    ZegoLoggerService.logInfo(
      'targetHostIDs:$targetHostIDs, isMute:$isMute, ',
      tag: 'live.streaming.pk.services',
      subTag: 'muteUserAudio',
    );

    return _mixer.muteUserAudio(
      targetHostIDs: targetHostIDs,
      isMute: isMute,
      pkHosts: List.from(_coreData.currentPKUsers.value),
    );
  }
}
