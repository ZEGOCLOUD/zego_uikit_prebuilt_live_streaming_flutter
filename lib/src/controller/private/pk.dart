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

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt() {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live streaming',
      subTag: 'controller.pk.p',
    );

    ZegoUIKitPrebuiltLiveStreamingPK.instance.pkStateNotifier.addListener(
      _onPKStateChanged,
    );
    ZegoUIKitPrebuiltLiveStreamingPK.instance.mutedUsersNotifier.addListener(
      _onMutedUsersChanged,
    );
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live streaming',
      subTag: 'controller.pk.p',
    );

    ZegoUIKitPrebuiltLiveStreamingPK.instance.pkStateNotifier
        .removeListener(_onPKStateChanged);
  }

  void _onPKStateChanged() {
    final pkState =
        ZegoUIKitPrebuiltLiveStreamingPK.instance.pkStateNotifier.value;

    ZegoLoggerService.logInfo(
      'onPKStateChanged, pkState:$pkState',
      tag: 'live streaming',
      subTag: 'controller.pk.p',
    );

    pkStateNotifier.value = pkState;
  }

  void _onMutedUsersChanged() {
    final mutedUsers =
        ZegoUIKitPrebuiltLiveStreamingPK.instance.mutedUsersNotifier.value;

    ZegoLoggerService.logInfo(
      'onMutedUsersChanged, mutedUsers:$mutedUsers',
      tag: 'live streaming',
      subTag: 'controller.pk.p',
    );

    mutedUsersNotifier.value = mutedUsers;
  }
}
