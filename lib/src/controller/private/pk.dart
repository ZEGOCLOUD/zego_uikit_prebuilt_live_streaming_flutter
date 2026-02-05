part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerPKPrivate {
  final _impl = ZegoLiveStreamingControllerPKPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerPKPrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerPKPrivateImpl {
  final pkStateNotifier = ValueNotifier<ZegoLiveStreamingPKBattleState>(
    ZegoLiveStreamingPKBattleState.idle,
  );
  final mutedUsersNotifier = ValueNotifier<List<String>>([]);

  ZegoUIKitPrebuiltLiveStreamingPK? _currentPK;

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt({required ZegoUIKitPrebuiltLiveStreamingPK pk}) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live.streaming.controller.pk',
      subTag: 'controller.pk.p',
    );

    _currentPK = pk;

    _currentPK?.pkStateNotifier.addListener(
      _onPKStateChanged,
    );
    _currentPK?.mutedUsersNotifier.addListener(
      _onMutedUsersChanged,
    );
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt({required ZegoUIKitPrebuiltLiveStreamingPK pk}) {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live.streaming.controller.pk',
      subTag: 'controller.pk.p',
    );

    if (_currentPK != pk) {
      ZegoLoggerService.logInfo(
        'current pk is not equal to target pk, ignore',
        tag: 'live.streaming.controller.pk',
        subTag: 'controller.pk.p',
      );
      return;
    }

    pkStateNotifier.value = ZegoLiveStreamingPKBattleState.idle;

    _currentPK?.pkStateNotifier.removeListener(_onPKStateChanged);
    _currentPK?.mutedUsersNotifier.removeListener(_onMutedUsersChanged);
    _currentPK = null;
  }

  void _onPKStateChanged() {
    final pkState = _currentPK?.pkStateNotifier.value;
    if (pkState == null) return;

    ZegoLoggerService.logInfo(
      'onPKStateChanged, pkState:$pkState',
      tag: 'live.streaming.controller.pk',
      subTag: 'controller.pk.p',
    );

    pkStateNotifier.value = pkState;
  }

  void _onMutedUsersChanged() {
    final mutedUsers = _currentPK?.mutedUsersNotifier.value;
    if (mutedUsers == null) return;

    ZegoLoggerService.logInfo(
      'onMutedUsersChanged, mutedUsers:$mutedUsers',
      tag: 'live.streaming.controller.pk',
      subTag: 'controller.pk.p',
    );

    mutedUsersNotifier.value = mutedUsers;
  }
}
