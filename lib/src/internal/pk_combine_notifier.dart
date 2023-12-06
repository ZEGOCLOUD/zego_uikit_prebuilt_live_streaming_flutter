// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/src/pk_impl.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/event/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/defines.dart';

class ZegoLiveStreamingPKBattleStateCombineNotifier {
  factory ZegoLiveStreamingPKBattleStateCombineNotifier() => instance;
  static final ZegoLiveStreamingPKBattleStateCombineNotifier instance =
      ZegoLiveStreamingPKBattleStateCombineNotifier._();

  ZegoLiveStreamingPKBattleStateCombineNotifier._();

  final state = ValueNotifier<bool>(false);
  ValueNotifier<ZegoLiveStreamingPKBattleState>? _v1StateNotifier;
  ValueNotifier<ZegoLiveStreamingPKBattleStateV2>? _v2StateNotifier;

  final hasRequestEvent = ValueNotifier<bool>(false);
  ValueNotifier<ZegoIncomingPKBattleRequestReceivedEvent?>?
      _v1RequestReceivedEventInMinimizingNotifier;
  ValueNotifier<ZegoIncomingPKBattleRequestReceivedEventV2?>?
      _v2RequestReceivedEventInMinimizingNotifier;

  void init({
    required ValueNotifier<ZegoLiveStreamingPKBattleState> v1StateNotifier,
    required ValueNotifier<ZegoLiveStreamingPKBattleStateV2> v2StateNotifier,
    required ValueNotifier<ZegoIncomingPKBattleRequestReceivedEvent?>
        v1RequestReceivedEventInMinimizingNotifier,
    required ValueNotifier<ZegoIncomingPKBattleRequestReceivedEventV2?>
        v2RequestReceivedEventInMinimizingNotifier,
  }) {
    ZegoLoggerService.logInfo(
      'init, '
      'v1 State:${v1StateNotifier.value}, '
      'v2 State:${v2StateNotifier.value}, '
      'v1 RequestReceivedEventInMinimizing:${v1RequestReceivedEventInMinimizingNotifier.value}, '
      'v2 RequestReceivedEventInMinimizing:${v2RequestReceivedEventInMinimizingNotifier.value}, ',
      tag: 'live streaming',
      subTag: 'pk combine state notifier',
    );

    _v1StateNotifier = v1StateNotifier;
    _v2StateNotifier = v2StateNotifier;
    _v1StateNotifier?.addListener(_onV1StateChanged);
    _v2StateNotifier?.addListener(_onV2StateChanged);
    _onV1StateChanged();
    _onV2StateChanged();

    _v1RequestReceivedEventInMinimizingNotifier =
        v1RequestReceivedEventInMinimizingNotifier;
    _v2RequestReceivedEventInMinimizingNotifier =
        v2RequestReceivedEventInMinimizingNotifier;
    _v1RequestReceivedEventInMinimizingNotifier
        ?.addListener(_onV1RequestReceivedEventInMinimizingChanged);
    _v2RequestReceivedEventInMinimizingNotifier
        ?.addListener(onV2RequestReceivedEventInMinimizingChanged);
    _onV1RequestReceivedEventInMinimizingChanged();
    onV2RequestReceivedEventInMinimizingChanged();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'pk combine state notifier',
    );

    _v1StateNotifier?.removeListener(_onV1StateChanged);
    _v2StateNotifier?.removeListener(_onV2StateChanged);
    _v1StateNotifier = null;
    _v2StateNotifier = null;

    _v1RequestReceivedEventInMinimizingNotifier
        ?.removeListener(_onV1RequestReceivedEventInMinimizingChanged);
    _v2RequestReceivedEventInMinimizingNotifier
        ?.removeListener(onV2RequestReceivedEventInMinimizingChanged);
    _v1RequestReceivedEventInMinimizingNotifier = null;
    _v2RequestReceivedEventInMinimizingNotifier = null;
  }

  void _onV1StateChanged() {
    final pkBattleState =
        _v1StateNotifier?.value ?? ZegoLiveStreamingPKBattleState.idle;

    ZegoLoggerService.logInfo(
      '_onV1StateChanged, state:$pkBattleState',
      tag: 'live streaming',
      subTag: 'pk combine state notifier',
    );

    state.value = pkBattleState == ZegoLiveStreamingPKBattleState.inPKBattle ||
        pkBattleState == ZegoLiveStreamingPKBattleState.loading;
  }

  void _onV2StateChanged() {
    final pkBattleState =
        _v2StateNotifier?.value ?? ZegoLiveStreamingPKBattleStateV2.idle;

    ZegoLoggerService.logInfo(
      '_onV2StateChanged, state:$pkBattleState',
      tag: 'live streaming',
      subTag: 'pk combine state notifier',
    );

    state.value = pkBattleState == ZegoLiveStreamingPKBattleStateV2.inPK ||
        pkBattleState == ZegoLiveStreamingPKBattleStateV2.loading;
  }

  void _onV1RequestReceivedEventInMinimizingChanged() {
    ZegoLoggerService.logInfo(
      '_onV1RequestReceivedEventInMinimizingChanged, event:${_v1RequestReceivedEventInMinimizingNotifier?.value}',
      tag: 'live streaming',
      subTag: 'pk combine state notifier',
    );

    hasRequestEvent.value =
        null != _v1RequestReceivedEventInMinimizingNotifier?.value;
  }

  void onV2RequestReceivedEventInMinimizingChanged() {
    ZegoLoggerService.logInfo(
      'onV2RequestReceivedEventInMinimizingChanged, event:${_v2RequestReceivedEventInMinimizingNotifier?.value}',
      tag: 'live streaming',
      subTag: 'pk combine state notifier',
    );

    hasRequestEvent.value =
        null != _v2RequestReceivedEventInMinimizingNotifier?.value;
  }
}
