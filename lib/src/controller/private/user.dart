part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerUserImplPrivate {
  final _private = ZegoLiveStreamingControllerUserImplPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerUserImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoLiveStreamingControllerUserImplPrivateImpl {
  List<StreamSubscription<dynamic>?> subscriptions = [];

  var countNotifier = ValueNotifier<int>(0);

  /// pseudo list + kit list
  StreamController<List<ZegoUIKitUser>>? _streamControllerList;

  ZegoUIKitPrebuiltLiveStreamingConfig? config;

  /// pseudo abouts.
  final pseudoMemberListNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);
  StreamController<ZegoUIKitUser>? streamControllerPseudoMemberEnter;
  StreamController<ZegoUIKitUser>? streamControllerPseudoMemberLeave;

  StreamController<List<ZegoUIKitUser>>? get streamControllerList {
    _streamControllerList ??= StreamController<List<ZegoUIKitUser>>.broadcast();
    return _streamControllerList;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.user.p',
    );

    this.config = config;

    _streamControllerList ??= StreamController<List<ZegoUIKitUser>>.broadcast();
    countNotifier.value = ZegoUIKit()
            .getAllUsers(
              targetRoomID:
                  ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
            )
            .length +
        pseudoMemberListNotifier.value.length;

    pseudoMemberListNotifier.value.clear();
    streamControllerPseudoMemberEnter ??=
        StreamController<ZegoUIKitUser>.broadcast();
    streamControllerPseudoMemberLeave ??=
        StreamController<ZegoUIKitUser>.broadcast();

    subscriptions
      ..add(
          streamControllerPseudoMemberEnter?.stream.listen(onPseudoMemberEnter))
      ..add(streamControllerPseudoMemberLeave?.stream
          .listen(onPseudoMemberLeaved))
      ..add(ZegoUIKit()
          .getUserListStream(
            targetRoomID:
                ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
          )
          .listen(onKitMemberListUpdated));
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.user.p',
    );

    config = null;

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    _streamControllerList?.close();
    _streamControllerList = null;
    countNotifier.value = 0;

    pseudoMemberListNotifier.value.clear();
    streamControllerPseudoMemberEnter?.close();
    streamControllerPseudoMemberEnter = null;
    streamControllerPseudoMemberLeave?.close();
    streamControllerPseudoMemberLeave = null;
  }

  bool isPseudoMember(ZegoUIKitUser user) {
    return -1 !=
        pseudoMemberListNotifier.value
            .indexWhere((pseudoMember) => user.id == pseudoMember.id);
  }

  void onPseudoMemberEnter(ZegoUIKitUser member) {
    final targetIndex = pseudoMemberListNotifier.value
        .indexWhere((user) => member.id == user.id);
    if (-1 != targetIndex) {
      return;
    }

    pseudoMemberListNotifier.value = List.from(pseudoMemberListNotifier.value)
      ..add(member);

    onKitMemberListUpdated(ZegoUIKit().getAllUsers(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
    ));
  }

  void onPseudoMemberLeaved(ZegoUIKitUser member) {
    final targetIndex = pseudoMemberListNotifier.value
        .indexWhere((user) => member.id == user.id);
    if (-1 == targetIndex) {
      return;
    }

    pseudoMemberListNotifier.value = List.from(pseudoMemberListNotifier.value)
      ..removeAt(targetIndex);

    onKitMemberListUpdated(ZegoUIKit().getAllUsers(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
    ));
  }

  void onKitMemberListUpdated(List<ZegoUIKitUser> users) {
    var allUsers = List<ZegoUIKitUser>.from(users);
    allUsers.addAll(pseudoMemberListNotifier.value);
    _streamControllerList?.add(allUsers);

    countNotifier.value = allUsers.length;
  }
}
