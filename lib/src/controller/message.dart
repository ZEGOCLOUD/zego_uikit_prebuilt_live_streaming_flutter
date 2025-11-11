part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

mixin ZegoLiveStreamingControllerMessage {
  final _messageImpl = ZegoLiveStreamingControllerMessageImpl();

  ZegoLiveStreamingControllerMessageImpl get message => _messageImpl;
}

/// Here are the APIs related to message.
class ZegoLiveStreamingControllerMessageImpl
    with ZegoLiveStreamingControllerMessagePrivate {
  /// sends the chat message
  ///
  /// [payloadAttributes] same as
  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> send(
    String message, {
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) async {
    if (!private._enableProperty.value) {
      ZegoLoggerService.logInfo(
        'chat enabled property is false, not allow to send message',
        tag: 'live-streaming',
        subTag: 'controller.message',
      );

      return false;
    }

    final attributes = private.config?.inRoomMessage.attributes?.call();
    if (attributes?.isEmpty ?? true) {
      return ZegoUIKit().sendInRoomMessage(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        message,
        type: type,
      );
    }

    return ZegoUIKit().sendInRoomMessage(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
      ZegoInRoomMessage.jsonBody(
        message: message,
        attributes: attributes!,
      ),
      type: type,
    );
  }

  /// Retrieves a list of chat messages that already exist in the room.
  ///
  /// @return A `List` of `ZegoInRoomMessage` objects representing the chat messages that already exist in the room.
  List<ZegoInRoomMessage> list({
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    return ZegoUIKit().getInRoomMessages(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
      type: type,
    );
  }

  /// Retrieves a list stream of chat messages that already exist in the room.
  /// the stream will dynamically update when new chat messages are received,
  /// and you can use a `StreamBuilder` to listen to it and update the UI in real time.
  ///
  /// @return A `List` of `ZegoInRoomMessage` objects representing the chat messages that already exist in the room.
  ///
  /// Example:
  ///
  /// ```dart
  /// ..foreground = Positioned(
  ///     left: 10,
  ///     bottom: 50,
  ///     child: StreamBuilder<List<ZegoInRoomMessage>>(
  ///       stream: liveController.message.stream(),
  ///       builder: (context, snapshot) {
  ///         final messages = snapshot.data ?? <ZegoInRoomMessage>[];
  ///
  ///         return Container(
  ///           width: 200,
  ///           height: 200,
  ///           decoration: BoxDecoration(
  ///             color: Colors.white.withValues(alpha: 0.2),
  ///           ),
  ///           child: ListView.builder(
  ///             itemCount: messages.length,
  ///             itemBuilder: (context, index) {
  ///               final message = messages[index];
  ///               return Text('${message.user.name}: ${message.message}');
  ///             },
  ///           ),
  ///         );
  ///       },
  ///     ),
  ///   )
  /// ```
  Stream<List<ZegoInRoomMessage>> stream({
    bool includeFakeMessage = true,
    ZegoInRoomMessageType type = ZegoInRoomMessageType.broadcastMessage,
  }) {
    if (includeFakeMessage) {
      return (type == ZegoInRoomMessageType.broadcastMessage
              ? private.streamControllerBroadcastList?.stream
              : private._streamControllerBarrageList?.stream) ??
          ZegoUIKit().getInRoomMessageListStream(
            targetRoomID:
                ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
            type: type,
          );
    }
    return ZegoUIKit().getInRoomMessageListStream(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
      type: type,
    );
  }

  /// send fake message in message list,
  /// please make sure [message].timestamp has valid value
  void sendFakeMessage({
    required ZegoUIKitUser sender,
    required String message,
    Map<String, String>? attributes,
  }) {
    private.streamControllerPseudoMessage?.add(
      ZegoInRoomMessage(
        user: sender,
        message: (attributes?.isEmpty ?? true)
            ? message
            : ZegoInRoomMessage.jsonBody(
                message: message,
                attributes: attributes!,
              ),
        timestamp: ZegoUIKit().getNetworkTime().value?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch,
        messageID: '-1',
      ),
    );
  }
}
