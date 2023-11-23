part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMessage {
  final _messageController = ZegoLiveStreamingMessageController();

  ZegoLiveStreamingMessageController get message => _messageController;
}

/// Here are the APIs related to message.
class ZegoLiveStreamingMessageController {
  final _enableProperty = ZegoInRoomMessageEnableProperty();

  /// sends the chat message
  ///
  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> send(String message) async {
    if (!_enableProperty.value) {
      ZegoLoggerService.logInfo(
        'chat enabled property is false, not allow to send message',
        tag: 'live streaming',
        subTag: 'controller-message',
      );

      return false;
    }

    return ZegoUIKit().sendInRoomMessage(message);
  }

  /// Retrieves a list of chat messages that already exist in the room.
  ///
  /// @return A `List` of `ZegoInRoomMessage` objects representing the chat messages that already exist in the room.
  List<ZegoInRoomMessage> list() {
    return ZegoUIKit().getInRoomMessages();
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
  ///             color: Colors.white.withOpacity(0.2),
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
  Stream<List<ZegoInRoomMessage>> stream() {
    return ZegoUIKit().getInRoomMessageListStream();
  }
}
