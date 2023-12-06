// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/enable_property.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/service/services.dart';

part 'controller/connect.dart';

part 'controller/connect.invite.dart';

part 'controller/message.dart';

part 'controller/minimize.dart';

part 'controller/room.dart';

part 'controller/screen.dart';

part 'controller/pk_v2.dart';

/// Used to control the live streaming functionality.
///
/// If the default live streaming UI and interactions do not meet your requirements, you can use this [ZegoUIKitPrebuiltLiveStreamingController] to actively control the business logic.
/// This class is used by setting the [ZegoUIKitPrebuiltLiveStreaming.controller] parameter in the constructor of [ZegoUIKitPrebuiltLiveStreaming].
class ZegoUIKitPrebuiltLiveStreamingController
    with
        ZegoLiveStreamingControllerMessage,
        ZegoLiveStreamingControllerMinimizing,
        ZegoLiveStreamingControllerScreen,
        ZegoLiveStreamingControllerConnect,
        ZegoLiveStreamingControllerConnectInvite,
        ZegoLiveStreamingControllerPKV2 {
  /// This function is used to end the Live Streaming.
  ///
  /// You can pass the context [context] for any necessary pop-ups or page transitions.
  /// By using the [showConfirmation] parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming.
  ///
  /// This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the [ZegoUIKitPrebuiltLiveStreamingConfig.onLeaveConfirmation], [ZegoUIKitPrebuiltLiveStreamingConfig.onLiveStreamingEnded] and [ZegoUIKitPrebuiltLiveStreamingConfig.onLeaveLiveStreaming] settings in the config.
  Future<bool> leave(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
    final result = await _roomController.leave(context,
        showConfirmation: showConfirmation);
    if (result) {
      uninitByPrebuilt();
    }

    return result;
  }

  /// This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
  ///
  /// You need to provide the user's ID [userID] to determine which user to perform the operation on.
  /// By using a boolean value [isFullscreen], you can specify whether the user enters or exits full-screen mode.
  @Deprecated(
      'Since 2.13.0, please use [screen.showScreenSharingViewInFullscreenMode] instead')
  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screen.showScreenSharingViewInFullscreenMode(userID, isFullscreen);
  }

  /// host remove the co-host, make co-host to be a audience
  @Deprecated('Since 2.13.0, please use [connect.removeCoHost] instead')
  Future<bool> removeCoHost(ZegoUIKitUser coHost) async {
    return connect.removeCoHost(coHost);
  }

  /// host invite audience to be a co-host
  @Deprecated(
      'Since 2.13.0, please use [connectInvite.hostSendCoHostInvitationToAudience] instead')
  Future<bool> makeAudienceCoHost(
    ZegoUIKitUser invitee, {
    required bool withToast,
  }) async {
    return connectInvite.hostSendCoHostInvitationToAudience(
      invitee,
      withToast: withToast,
    );
  }

  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void initByPrebuilt({ZegoUIKitPrebuiltLiveStreamingEvents? events}) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live streaming',
      subTag: 'controller',
    );

    connect.init(events: events);
    connectInvite.init(events: events);
  }

  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live streaming',
      subTag: 'controller',
    );

    _roomController.isLeaveRequestingNotifier.value = false;

    connect.uninit();
    connectInvite.uninit();
  }

  ValueNotifier<bool> get isLeaveRequestingNotifier =>
      _roomController.isLeaveRequestingNotifier;

  final _roomController = ZegoLiveStreamingRoomController();
}
