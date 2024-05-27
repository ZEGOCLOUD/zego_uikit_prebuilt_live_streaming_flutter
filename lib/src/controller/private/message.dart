part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMessagePrivate {
  final _impl = ZegoLiveStreamingControllerMessagePrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerMessagePrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerMessagePrivateImpl {
  List<StreamSubscription<dynamic>?> subscriptions = [];

  /// pseudo list + kit list
  StreamController<List<ZegoInRoomMessage>>? _streamControllerList;

  List<ZegoInRoomMessage> pseudoMessageList = [];
  StreamController<ZegoInRoomMessage>? streamControllerPseudoMessage;

  StreamController<List<ZegoInRoomMessage>>? get streamControllerList {
    _streamControllerList ??=
        StreamController<List<ZegoInRoomMessage>>.broadcast();
    return _streamControllerList;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt() {
    pseudoMessageList.clear();

    _streamControllerList ??=
        StreamController<List<ZegoInRoomMessage>>.broadcast();

    streamControllerPseudoMessage ??=
        StreamController<ZegoInRoomMessage>.broadcast();

    onKitMessageListUpdated(ZegoUIKit().getInRoomMessages());
    subscriptions
      ..add(
          streamControllerPseudoMessage!.stream.listen(onPseudoMessageUpdated))
      ..add(ZegoUIKit()
          .getInRoomMessageListStream()
          .listen(onKitMessageListUpdated));
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    pseudoMessageList.clear();

    _streamControllerList?.close();
    _streamControllerList = null;

    streamControllerPseudoMessage?.close();
    streamControllerPseudoMessage = null;
  }

  void onPseudoMessageUpdated(ZegoInRoomMessage message) {
    pseudoMessageList.add(message);

    onKitMessageListUpdated(ZegoUIKit().getInRoomMessages());
  }

  void onKitMessageListUpdated(List<ZegoInRoomMessage> messages) {
    var allMessages = List<ZegoInRoomMessage>.from(messages);
    allMessages.addAll(pseudoMessageList);

    allMessages.sort((left, right) {
      return left.timestamp.compareTo(right.timestamp);
    });

    _streamControllerList?.add(allMessages);
  }
}
