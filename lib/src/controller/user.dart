part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

mixin ZegoLiveStreamingControllerUser {
  final _userImpl = ZegoLiveStreamingControllerUserImpl();

  ZegoLiveStreamingControllerUserImpl get user => _userImpl;
}

/// Here are the APIs related to audio video.
class ZegoLiveStreamingControllerUserImpl
    with ZegoLiveStreamingControllerUserImplPrivate {
  /// user list count notifier
  ValueNotifier<int> get countNotifier => private.countNotifier;

  /// user list stream
  Stream<List<ZegoUIKitUser>> stream({
    bool includeFakeUser = true,
  }) {
    return includeFakeUser
        ? (private.streamControllerList?.stream ??
            ZegoUIKit().getUserListStream())
        : ZegoUIKit().getUserListStream();
  }

  /// remove user from live, kick out
  ///
  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> remove(List<String> userIDs) async {
    ZegoLoggerService.logInfo(
      'remove user:$userIDs',
      tag: 'live streaming',
      subTag: 'controller.user',
    );

    return ZegoUIKit().removeUserFromRoom(userIDs);
  }

  ///  add fake user
  void addFakeUser(ZegoUIKitUser user) {
    ZegoLoggerService.logInfo(
      'add fake user:$user',
      tag: 'live streaming',
      subTag: 'controller.user',
    );

    private.streamControllerPseudoMemberEnter?.add(user);
  }

  ///  remove fake user
  void removeFakeUser(ZegoUIKitUser user) {
    ZegoLoggerService.logInfo(
      'remove fake user:$user',
      tag: 'live streaming',
      subTag: 'controller.user',
    );

    private.streamControllerPseudoMemberLeave?.add(user);
  }
}
