part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// Mixin that provides room control functionality for the live streaming controller.
///
/// Access via [ZegoUIKitPrebuiltLiveStreamingController.room].
mixin ZegoLiveStreamingControllerRoom {
  final _roomImpl = ZegoLiveStreamingControllerRoomImpl();

  /// Returns the room implementation instance.
  ZegoLiveStreamingControllerRoomImpl get room => _roomImpl;
}

/// Here are the APIs related to room.
class ZegoLiveStreamingControllerRoomImpl
    with ZegoLiveStreamingControllerRoomPrivate {
  Future<bool> _leave(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
    if (private.isLeaveRequestingNotifier.value) {
      ZegoLoggerService.logInfo(
        'is leave requesting...',
        tag: 'live.streaming.controller.room',
        subTag: 'leave',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'show confirmation:$showConfirmation',
      tag: 'live.streaming.controller.room',
      subTag: 'leave',
    );
    private.isLeaveRequestingNotifier.value = true;

    if (showConfirmation) {
      ///  if there is a user-defined event before the click,
      ///  wait the synchronize execution result
      final endConfirmationEvent = ZegoLiveStreamingLeaveConfirmationEvent(
        context: context,
      );
      final canLeave = await private.defaultLeaveConfirmationAction(
        endConfirmationEvent,
      );
      if (!canLeave) {
        ZegoLoggerService.logInfo(
          'refuse by confirmation',
          tag: 'live.streaming.controller.room',
          subTag: 'leave',
        );

        private.isLeaveRequestingNotifier.value = false;

        return false;
      }
    }

    final isFromMinimizing = ZegoLiveStreamingMiniOverlayPageState.minimizing ==
        ZegoUIKitPrebuiltLiveStreamingController().minimize.state;
    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();

    if (private.hostManager.isLocalHost) {
      /// live is ready to end, host will update if receive property notify
      /// so need to keep current host value, DISABLE local host value UPDATE
      private.hostManager.hostUpdateEnabledNotifier.value = false;
      await ZegoUIKit().updateRoomProperties(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        {
          RoomPropertyKey.host.text: '',
          RoomPropertyKey.liveStatus.text: LiveStatus.ended.index.toString()
        },
      );
    }

    final result = await ZegoUIKit()
        .leaveRoom(
            targetRoomID:
                ZegoUIKitPrebuiltLiveStreamingController().private.liveID)
        .then((result) {
      ZegoLoggerService.logInfo(
        'leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'live.streaming.controller.room',
        subTag: 'leave',
      );

      return 0 == result.errorCode;
    });

    final endEvent = ZegoLiveStreamingEndEvent(
      reason: ZegoLiveStreamingEndReason.localLeave,
      isFromMinimizing: isFromMinimizing,
    );
    defaultAction() {
      private.defaultEndAction(endEvent, context, true);
    }

    if (private.events?.onEnded != null) {
      private.events?.onEnded?.call(endEvent, defaultAction);
    } else {
      defaultAction.call();
    }

    ZegoLoggerService.logInfo(
      'finished',
      tag: 'live.streaming.controller.room',
      subTag: 'leave',
    );

    return result;
  }

  /// set/update room property
  ///
  /// - [roomID] The ID of the room to update property.
  /// - [key] The property key to set/update.
  /// - [value] The property value to set/update.
  /// - [isForce] Whether the operation is mandatory, that is, the property of the room whose owner is another user can be modified.
  /// - [isDeleteAfterOwnerLeft] Room attributes are automatically deleted after the owner leaves the room.
  /// - [isUpdateOwner] Whether to update the owner of the room attribute involved.
  Future<bool> updateProperty({
    required String roomID,
    required String key,
    required String value,
    bool isForce = false,
    bool isDeleteAfterOwnerLeft = false,
    bool isUpdateOwner = false,
  }) async {
    return updateProperties(
      roomID: roomID,
      roomProperties: {key: value},
      isForce: isForce,
      isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft,
      isUpdateOwner: isUpdateOwner,
    );
  }

  /// set/update room properties
  ///
  /// - [roomID] The ID of the room to update properties.
  /// - [roomProperties] Map of property keys and values to set/update.
  /// - [isForce] Whether the operation is mandatory, that is, the property of the room whose owner is another user can be modified.
  /// - [isDeleteAfterOwnerLeft] Room attributes are automatically deleted after the owner leaves the room.
  /// - [isUpdateOwner] Whether to update the owner of the room attribute involved.
  Future<bool> updateProperties({
    required String roomID,
    required Map<String, String> roomProperties,
    bool isForce = false,
    bool isDeleteAfterOwnerLeft = false,
    bool isUpdateOwner = false,
  }) async {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'signaling is null',
        tag: 'live.streaming.controller.room',
        subTag: 'updateProperties',
      );

      return false;
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .updateRoomProperties(
          roomID: roomID,
          roomProperties: roomProperties,
          isForce: isForce,
          isDeleteAfterOwnerLeft: isDeleteAfterOwnerLeft,
          isUpdateOwner: isUpdateOwner,
        )
        .then((result) {
      if (null != result.error) {
        ZegoLoggerService.logInfo(
          'error:$result',
          tag: 'live.streaming.controller.room',
          subTag: 'updateProperties',
        );

        return false;
      }

      return true;
    });
  }

  /// delete room properties
  ///
  /// - [roomID] The ID of the room whose properties to delete.
  /// - [keys] List of property keys to delete.
  /// - [isForce] Whether the operation is mandatory.
  Future<bool> deleteProperties({
    required String roomID,
    required List<String> keys,
    bool isForce = false,
  }) async {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'signaling is null',
        tag: 'live.streaming.controller.room',
        subTag: 'deleteRoomProperties',
      );

      return false;
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .deleteRoomProperties(
          roomID: roomID,
          keys: keys,
          isForce: isForce,
        )
        .then((result) {
      if (null != result.error) {
        ZegoLoggerService.logInfo(
          'error:$result',
          tag: 'live.streaming.controller.room',
          subTag: 'deleteRoomProperties',
        );

        return false;
      }

      return true;
    });
  }

  /// query room properties
  ///
  /// - [roomID] The ID of the room whose properties to query.
  Future<Map<String, String>> queryProperties({
    required String roomID,
  }) async {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'signaling is null',
        tag: 'live.streaming.controller.room',
        subTag: 'queryRoomProperties',
      );

      return <String, String>{};
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .queryRoomProperties(
          roomID: roomID,
        )
        .then((result) {
      if (null != result.error) {
        ZegoLoggerService.logInfo(
          'error:${result.error}',
          tag: 'live.streaming.controller.room',
          subTag: 'queryRoomProperties',
        );

        return <String, String>{};
      }

      return result.properties;
    });
  }

  /// room properties stream notify
  Stream<ZegoSignalingPluginRoomPropertiesUpdatedEvent> propertiesStream() {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'getRoomPropertiesStream, signaling is null',
        tag: 'live.streaming.controller.room',
        subTag: 'controller.room',
      );

      return const Stream.empty();
    }

    return ZegoUIKit().getSignalingPlugin().getRoomPropertiesStream();
  }

  /// send room command
  ///
  /// string encoded in UTF-8 and convert to Uint8List
  ///
  /// import 'dart:convert';
  /// import 'dart:typed_data';
  ///
  /// Uint8List dataBytes = Uint8List.fromList(utf8.encode(commandString));
  ///
  /// - [roomID] The ID of the room to send the command to.
  /// - [command] The command data to send, encoded as Uint8List.
  Future<bool> sendCommand({
    required String roomID,
    required Uint8List command,
  }) async {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'signaling is null',
        tag: 'live.streaming.controller.room',
        subTag: 'sendCommand',
      );

      return false;
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .sendInRoomCommandMessage(
          roomID: roomID,
          message: command,
        )
        .then((result) {
      if (null != result.error) {
        ZegoLoggerService.logInfo(
          'error:${result.error}',
          tag: 'live.streaming.controller.room',
          subTag: 'sendCommand',
        );

        return false;
      }
      return true;
    });
  }

  /// room command stream notify
  ///
  /// If you have a string encoded in UTF-8 and want to convert a Uint8List
  /// to that string, you can use the following method:
  ///
  /// import 'dart:convert';
  /// import 'dart:typed_data';
  ///
  /// Uint8List dataBytes = Uint8List.fromList(utf8.encode(commandString));
  Stream<ZegoSignalingPluginInRoomCommandMessageReceivedEvent>
      commandReceivedStream() {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'commandReceivedStream, signaling is null',
        tag: 'live.streaming.controller.room',
        subTag: 'controller.room',
      );

      return const Stream.empty();
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .getInRoomCommandMessageReceivedEventStream();
  }

  /// when receives [ZegoLiveStreamingRoomEvents.onTokenExpired], you need use this API to update the token
  Future<void> renewToken(String token) async {
    await ZegoUIKit().renewRoomToken(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
      token,
    );

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) != null) {
      ZegoUIKit().getSignalingPlugin().renewToken(token);
    }
  }
}
