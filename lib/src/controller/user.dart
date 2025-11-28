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
            ZegoUIKit().getUserListStream(
              targetRoomID:
                  ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
            ))
        : ZegoUIKit().getUserListStream(
            targetRoomID:
                ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
          );
  }

  /// remove user from live, kick out
  ///
  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> remove(List<String> userIDs) async {
    ZegoLoggerService.logInfo(
      'user ids:$userIDs',
      tag: 'live.streaming.controller.user',
      subTag: 'remove',
    );

    return ZegoUIKit().removeUserFromRoom(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
      userIDs,
    );
  }

  ///  add fake user
  void addFakeUser(ZegoUIKitUser user) {
    ZegoLoggerService.logInfo(
      'user:$user',
      tag: 'live.streaming.controller.user',
      subTag: 'addFakeUser',
    );

    private.streamControllerPseudoMemberEnter?.add(user);
  }

  ///  remove fake user
  void removeFakeUser(ZegoUIKitUser user) {
    ZegoLoggerService.logInfo(
      'user:$user',
      tag: 'live.streaming.controller.user',
      subTag: 'removeFakeUser',
    );

    private.streamControllerPseudoMemberLeave?.add(user);
  }
}
