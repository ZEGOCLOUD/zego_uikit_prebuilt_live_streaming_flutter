part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

mixin ZegoLiveStreamingControllerRoom {
  final _roomImpl = ZegoLiveStreamingControllerRoomImpl();

  ZegoLiveStreamingControllerRoomImpl get room => _roomImpl;
}

/// Here are the APIs related to screen sharing.
class ZegoLiveStreamingControllerRoomImpl
    with ZegoLiveStreamingControllerRoomPrivate {
  Future<bool> _leave(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
    if (null == private.hostManager) {
      ZegoLoggerService.logInfo(
        'leave, param is invalid, hostManager:${private.hostManager}',
        tag: 'live streaming',
        subTag: 'controller.room',
      );

      return false;
    }

    if (private.isLeaveRequestingNotifier.value) {
      ZegoLoggerService.logInfo(
        'leave, is leave requesting...',
        tag: 'live streaming',
        subTag: 'controller.room',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'leave, show confirmation:$showConfirmation',
      tag: 'live streaming',
      subTag: 'controller.room',
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
          'leave, refuse',
          tag: 'live streaming',
          subTag: 'controller.room',
        );

        private.isLeaveRequestingNotifier.value = false;

        return false;
      }
    }

    final isFromMinimizing = ZegoLiveStreamingMiniOverlayPageState.minimizing ==
        ZegoUIKitPrebuiltLiveStreamingController().minimize.state;
    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();

    if (private.hostManager?.isLocalHost ?? false) {
      /// live is ready to end, host will update if receive property notify
      /// so need to keep current host value, DISABLE local host value UPDATE
      private.hostManager?.hostUpdateEnabledNotifier.value = false;
      await ZegoUIKit().updateRoomProperties({
        RoomPropertyKey.host.text: '',
        RoomPropertyKey.liveStatus.text: LiveStatus.ended.index.toString()
      });
    }

    if (isFromMinimizing) {
      /// leave in minimizing
      await ZegoLiveStreamingManagers().uninitPluginAndManagers();

      await ZegoUIKit().resetSoundEffect();
      await ZegoUIKit().resetBeautyEffect();
    }

    final result = await ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'leave, leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'live streaming',
        subTag: 'controller.room',
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
      'leave, finished',
      tag: 'live streaming',
      subTag: 'controller.room',
    );

    return result;
  }

  /// set/update room property
  ///
  /// @param isForce: Whether the operation is mandatory, that is, the property of the room whose owner is another user can be modified.
  /// @param isDeleteAfterOwnerLeft: Room attributes are automatically deleted after the owner leaves the room.
  /// @param isUpdateOwner: Whether to update the owner of the room attribute involved.
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
  /// @param isForce: Whether the operation is mandatory, that is, the property of the room whose owner is another user can be modified.
  /// @param isDeleteAfterOwnerLeft: Room attributes are automatically deleted after the owner leaves the room.
  /// @param isUpdateOwner: Whether to update the owner of the room attribute involved.
  Future<bool> updateProperties({
    required String roomID,
    required Map<String, String> roomProperties,
    bool isForce = false,
    bool isDeleteAfterOwnerLeft = false,
    bool isUpdateOwner = false,
  }) async {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'updateProperties, signaling is null',
        tag: 'live streaming',
        subTag: 'controller.room',
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
          'updateProperties, error:$result',
          tag: 'live streaming',
          subTag: 'controller.room',
        );

        return false;
      }

      return true;
    });
  }

  /// delete room properties
  Future<bool> deleteProperties({
    required String roomID,
    required List<String> keys,
    bool isForce = false,
  }) async {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'deleteRoomProperties, signaling is null',
        tag: 'live streaming',
        subTag: 'controller.room',
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
          'deleteRoomProperties, error:$result',
          tag: 'live streaming',
          subTag: 'controller.room',
        );

        return false;
      }

      return true;
    });
  }

  /// query room properties
  Future<Map<String, String>> queryProperties({
    required String roomID,
  }) async {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'queryRoomProperties, signaling is null',
        tag: 'live streaming',
        subTag: 'controller.room',
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
          'queryRoomProperties, error:${result.error}',
          tag: 'live streaming',
          subTag: 'controller.room',
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
        tag: 'live streaming',
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
  Future<bool> sendCommand({
    required String roomID,
    required Uint8List command,
  }) async {
    if (null == ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)) {
      ZegoLoggerService.logInfo(
        'sendCommand, signaling is null',
        tag: 'live streaming',
        subTag: 'controller.room',
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
          'sendCommand, error:${result.error}',
          tag: 'live streaming',
          subTag: 'controller.room',
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
        tag: 'live streaming',
        subTag: 'controller.room',
      );

      return const Stream.empty();
    }

    return ZegoUIKit()
        .getSignalingPlugin()
        .getInRoomCommandMessageReceivedEventStream();
  }

  ///  add fake user
  void addFakeUser(ZegoUIKitUser user) {
    private.streamControllerPseudoMemberEnter?.add(user);
  }

  ///  remove fake user
  void removeFakeUser(ZegoUIKitUser user) {
    private.streamControllerPseudoMemberLeave?.add(user);
  }
}
