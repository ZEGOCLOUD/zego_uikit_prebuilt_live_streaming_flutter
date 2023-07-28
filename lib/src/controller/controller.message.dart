part of 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMessage {
  final ZegoLiveStreamingMessageController _messageController =
      ZegoLiveStreamingMessageController();

  ZegoLiveStreamingMessageController get message => _messageController;
}

/// @nodoc
class ZegoLiveStreamingMessageController {
  final _enableProperty = ZegoInRoomMessageEnableProperty();

  /// send in-room message
  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
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

  /// get existed in-room messages
  List<ZegoInRoomMessage> list() {
    return ZegoUIKit().getInRoomMessages();
  }

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
  /// get in-room messages notifier
  Stream<List<ZegoInRoomMessage>> stream() {
    return ZegoUIKit().getInRoomMessageListStream();
  }
}
