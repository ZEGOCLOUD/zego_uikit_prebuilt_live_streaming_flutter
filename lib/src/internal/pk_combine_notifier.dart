// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/event/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/defines.dart';

class ZegoLiveStreamingPKBattleStateCombineNotifier {
  factory ZegoLiveStreamingPKBattleStateCombineNotifier() => instance;
  static final ZegoLiveStreamingPKBattleStateCombineNotifier instance =
      ZegoLiveStreamingPKBattleStateCombineNotifier._();

  ZegoLiveStreamingPKBattleStateCombineNotifier._();

  final state = ValueNotifier<bool>(false);
  ValueNotifier<ZegoLiveStreamingPKBattleState>? _v2StateNotifier;

  final hasRequestEvent = ValueNotifier<bool>(false);
  ValueNotifier<ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent?>?
      _v2RequestReceivedEventInMinimizingNotifier;

  void init({
    required ValueNotifier<ZegoLiveStreamingPKBattleState> v2StateNotifier,
    required ValueNotifier<
            ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent?>
        v2RequestReceivedEventInMinimizingNotifier,
  }) {
    ZegoLoggerService.logInfo(
      'init, '
      'v2 State:${v2StateNotifier.value}, '
      'v2 RequestReceivedEventInMinimizing:${v2RequestReceivedEventInMinimizingNotifier.value}, ',
      tag: 'live-streaming',
      subTag: 'pk combine state notifier',
    );

    _v2StateNotifier = v2StateNotifier;
    _v2StateNotifier?.addListener(_onV2StateChanged);
    _onV2StateChanged();

    _v2RequestReceivedEventInMinimizingNotifier =
        v2RequestReceivedEventInMinimizingNotifier;
    _v2RequestReceivedEventInMinimizingNotifier
        ?.addListener(onV2RequestReceivedEventInMinimizingChanged);
    onV2RequestReceivedEventInMinimizingChanged();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live-streaming',
      subTag: 'pk combine state notifier',
    );

    _v2StateNotifier?.removeListener(_onV2StateChanged);
    _v2StateNotifier = null;

    _v2RequestReceivedEventInMinimizingNotifier
        ?.removeListener(onV2RequestReceivedEventInMinimizingChanged);
    _v2RequestReceivedEventInMinimizingNotifier = null;
  }

  void _onV2StateChanged() {
    final pkBattleState =
        _v2StateNotifier?.value ?? ZegoLiveStreamingPKBattleState.idle;

    ZegoLoggerService.logInfo(
      '_onV2StateChanged, state:$pkBattleState',
      tag: 'live-streaming',
      subTag: 'pk combine state notifier',
    );

    state.value = pkBattleState == ZegoLiveStreamingPKBattleState.inPK ||
        pkBattleState == ZegoLiveStreamingPKBattleState.loading;
  }

  void onV2RequestReceivedEventInMinimizingChanged() {
    ZegoLoggerService.logInfo(
      'onV2RequestReceivedEventInMinimizingChanged, event:${_v2RequestReceivedEventInMinimizingNotifier?.value}',
      tag: 'live-streaming',
      subTag: 'pk combine state notifier',
    );

    hasRequestEvent.value =
        null != _v2RequestReceivedEventInMinimizingNotifier?.value;
  }
}
