part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMessagePrivate {
  final _impl = ZegoLiveStreamingControllerMessagePrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerMessagePrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerMessagePrivateImpl {
  final _enableProperty = ZegoLiveStreamingInRoomMessageEnableProperty();

  ZegoUIKitPrebuiltLiveStreamingConfig? config;

  List<StreamSubscription<dynamic>?> subscriptions = [];

  /// pseudo list + kit list
  StreamController<List<ZegoInRoomMessage>>? _streamControllerBroadcastList;
  StreamController<List<ZegoInRoomMessage>>? _streamControllerBarrageList;

  List<ZegoInRoomMessage> pseudoMessageList = [];
  StreamController<ZegoInRoomMessage>? streamControllerPseudoMessage;

  StreamController<List<ZegoInRoomMessage>>? get streamControllerBroadcastList {
    _streamControllerBroadcastList ??=
        StreamController<List<ZegoInRoomMessage>>.broadcast();
    return _streamControllerBroadcastList;
  }

  StreamController<List<ZegoInRoomMessage>>? get streamControllerBarrageList {
    _streamControllerBarrageList ??=
        StreamController<List<ZegoInRoomMessage>>.broadcast();
    return _streamControllerBarrageList;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt({
    required String liveID,
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) {
    _enableProperty.init(liveID: liveID);

    this.config = config;

    pseudoMessageList.clear();

    _streamControllerBroadcastList ??=
        StreamController<List<ZegoInRoomMessage>>.broadcast();
    _streamControllerBarrageList ??=
        StreamController<List<ZegoInRoomMessage>>.broadcast();

    streamControllerPseudoMessage ??=
        StreamController<ZegoInRoomMessage>.broadcast();

    onKitBroadcastMessageListUpdated(ZegoUIKit().getInRoomMessages(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
    ));
    subscriptions
      ..add(
          streamControllerPseudoMessage!.stream.listen(onPseudoMessageUpdated))
      ..add(ZegoUIKit()
          .getInRoomMessageListStream(
            targetRoomID:
                ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
            type: ZegoInRoomMessageType.broadcastMessage,
          )
          .listen(onKitBroadcastMessageListUpdated))
      ..add(ZegoUIKit()
          .getInRoomMessageListStream(
            targetRoomID:
                ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
            type: ZegoInRoomMessageType.barrageMessage,
          )
          .listen(onKitBarrageMessageListUpdated));
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    config = null;

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    pseudoMessageList.clear();

    _streamControllerBroadcastList?.close();
    _streamControllerBroadcastList = null;

    _streamControllerBarrageList?.close();
    _streamControllerBarrageList = null;

    streamControllerPseudoMessage?.close();
    streamControllerPseudoMessage = null;
  }

  void onPseudoMessageUpdated(ZegoInRoomMessage message) {
    pseudoMessageList.add(message);

    onKitBroadcastMessageListUpdated(ZegoUIKit().getInRoomMessages(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
    ));
  }

  void onKitBroadcastMessageListUpdated(List<ZegoInRoomMessage> messages) {
    var allMessages = List<ZegoInRoomMessage>.from(messages);
    allMessages.addAll(pseudoMessageList);

    allMessages.sort((left, right) {
      return left.timestamp.compareTo(right.timestamp);
    });

    _streamControllerBroadcastList?.add(allMessages);
  }

  void onKitBarrageMessageListUpdated(List<ZegoInRoomMessage> messages) {
    var allMessages = List<ZegoInRoomMessage>.from(messages);
    allMessages.addAll(pseudoMessageList);

    allMessages.sort((left, right) {
      return left.timestamp.compareTo(right.timestamp);
    });

    _streamControllerBarrageList?.add(allMessages);
  }
}
