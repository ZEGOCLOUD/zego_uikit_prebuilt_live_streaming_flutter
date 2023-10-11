// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/prebuilt_data.dart';

/// @nodoc
enum PrebuiltLiveStreamingMiniOverlayPageState {
  idle,
  living,
  minimizing,
}

/// @nodoc
typedef PrebuiltLiveStreamingMiniOverlayMachineStateChanged = void Function(
    PrebuiltLiveStreamingMiniOverlayPageState);

/// @nodoc
class ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine {
  factory ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine() => _instance;

  ZegoUIKitPrebuiltLiveStreamingData? get prebuiltData => _prebuiltData;

  sm.Machine<PrebuiltLiveStreamingMiniOverlayPageState> get machine => _machine;

  bool get isMinimizing =>
      PrebuiltLiveStreamingMiniOverlayPageState.minimizing == state();

  PrebuiltLiveStreamingMiniOverlayPageState state() {
    return _machine.current?.identifier ??
        PrebuiltLiveStreamingMiniOverlayPageState.idle;
  }

  DateTime durationStartTime() {
    return _durationStartTime ?? DateTime.now();
  }

  ValueNotifier<Duration> durationNotifier() {
    return _durationNotifier;
  }

  void listenStateChanged(
      PrebuiltLiveStreamingMiniOverlayMachineStateChanged listener) {
    _onStateChangedListeners.add(listener);

    ZegoLoggerService.logInfo(
      'add listener:$listener, size:${_onStateChangedListeners.length}',
      tag: 'call',
      subTag: 'overlay machine',
    );
  }

  void removeListenStateChanged(
      PrebuiltLiveStreamingMiniOverlayMachineStateChanged listener) {
    _onStateChangedListeners.remove(listener);

    ZegoLoggerService.logInfo(
      'remove listener:$listener, size:${_onStateChangedListeners.length}',
      tag: 'call',
      subTag: 'overlay machine',
    );
  }

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'call',
      subTag: 'overlay machine',
    );

    _machine.onAfterTransition.listen((event) {
      ZegoLoggerService.logInfo(
        'mini overlay, from ${event.source} to ${event.target}',
        tag: 'call',
        subTag: 'overlay machine',
      );

      for (final listener in _onStateChangedListeners) {
        listener.call(_machine.current!.identifier);
      }
    });

    _stateIdle = _machine.newState(
        PrebuiltLiveStreamingMiniOverlayPageState.idle); //  default state;
    _stateLiving =
        _machine.newState(PrebuiltLiveStreamingMiniOverlayPageState.living);
    _stateMinimizing =
        _machine.newState(PrebuiltLiveStreamingMiniOverlayPageState.minimizing);
  }

  void changeState(
    PrebuiltLiveStreamingMiniOverlayPageState state, {
    ZegoUIKitPrebuiltLiveStreamingData? prebuiltData,
  }) {
    ZegoLoggerService.logInfo(
      'change state outside to $state',
      tag: 'call',
      subTag: 'overlay machine',
    );

    switch (state) {
      case PrebuiltLiveStreamingMiniOverlayPageState.idle:
        _prebuiltData = null;
        kickOutSubscription?.cancel();

        _stateIdle.enter();

        stopDurationTimer();
        break;
      case PrebuiltLiveStreamingMiniOverlayPageState.living:
        _prebuiltData = null;
        kickOutSubscription?.cancel();

        _stateLiving.enter();
        break;
      case PrebuiltLiveStreamingMiniOverlayPageState.minimizing:
        ZegoLoggerService.logInfo(
          'data: $_prebuiltData',
          tag: 'call',
          subTag: 'overlay machine',
        );
        assert(null != prebuiltData);
        _prebuiltData = prebuiltData;

        kickOutSubscription = ZegoUIKit()
            .getMeRemovedFromRoomStream()
            .listen(onMeRemovedFromRoom);

        _stateMinimizing.enter();

        startDurationTimer();
        break;
    }
  }

  void startDurationTimer() {
    if (!(prebuiltData?.config.durationConfig.isVisible ?? true)) {
      return;
    }

    _durationStartTime = prebuiltData?.durationStartTime ?? DateTime.now();
    _durationNotifier.value = DateTime.now().difference(_durationStartTime!);

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _durationNotifier.value = DateTime.now().difference(_durationStartTime!);
      prebuiltData?.config.durationConfig.onDurationUpdate
          ?.call(_durationNotifier.value);
    });
  }

  void stopDurationTimer() {
    _durationTimer?.cancel();

    _durationTimer = null;
  }

  Future<void> onMeRemovedFromRoom(String fromUserID) async {
    ZegoLoggerService.logInfo(
      'local user removed by $fromUserID',
      tag: 'live audio room',
      subTag: 'mini overlay page',
    );
    changeState(PrebuiltLiveStreamingMiniOverlayPageState.idle);

    ZegoLiveStreamingManagers().uninitPluginAndManagers();

    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();
    // await ZegoUIKit().leaveRoom(); //  kick-out will leave in zego_uikit

    _prebuiltData?.controller.uninitByPrebuilt();
    _prebuiltData?.config.onMeRemovedFromRoom?.call(fromUserID);
  }

  /// private variables

  ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine._internal() {
    init();
  }

  static final ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine _instance =
      ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine._internal();

  final _machine = sm.Machine<PrebuiltLiveStreamingMiniOverlayPageState>();
  final List<PrebuiltLiveStreamingMiniOverlayMachineStateChanged>
      _onStateChangedListeners = [];

  late sm.State<PrebuiltLiveStreamingMiniOverlayPageState> _stateIdle;
  late sm.State<PrebuiltLiveStreamingMiniOverlayPageState> _stateLiving;
  late sm.State<PrebuiltLiveStreamingMiniOverlayPageState> _stateMinimizing;

  StreamSubscription<dynamic>? kickOutSubscription;

  ZegoUIKitPrebuiltLiveStreamingData? _prebuiltData;

  DateTime? _durationStartTime;
  Timer? _durationTimer;
  final _durationNotifier = ValueNotifier<Duration>(Duration.zero);
}
