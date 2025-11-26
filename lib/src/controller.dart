// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:floating/floating.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'components/message/enable_property.dart';
import 'components/utils/dialogs.dart';
import 'components/utils/toast.dart';
import 'config.dart';
import 'controller/private/media_player.dart';
import 'controller/private/pip/pip_android.dart';
import 'controller/private/pip/pip_interface.dart';
import 'controller/private/pip/pip_ios.dart';
import 'core/connect_manager.dart';
import 'core/defines.dart';
import 'core/host_manager.dart';
import 'defines.dart';
import 'events.dart';
import 'events.defines.dart';
import 'internal/defines.dart';
import 'internal/pk_combine_notifier.dart';
import 'internal/reporter.dart';
import 'live_streaming.dart';
import 'lifecycle/lifecycle.dart';
import 'modules/hall/controller.dart';
import 'modules/minimizing/data.dart';
import 'modules/minimizing/defines.dart';
import 'modules/minimizing/overlay_machine.dart';
import 'modules/pk/core/core.dart';
import 'modules/pk/core/defines.dart';
import 'modules/pk/core/service/defines.dart';
import 'modules/pk/core/service/services.dart';

part 'controller/audio_video.dart';

part 'controller/co.host.dart';

part 'controller/message.dart';

part 'controller/minimize.dart';

part 'controller/pip.dart';

part 'controller/log.dart';

part 'controller/room.dart';

part 'controller/user.dart';

part 'controller/screen.dart';

part 'controller/media.dart';

part 'controller/pk.dart';

part 'controller/swiping.dart';

part 'controller/private/private.dart';

part 'controller/hall.dart';

part 'controller/private/hall.dart';

part 'controller/private/audio_video.dart';

part 'controller/private/co.host.dart';

part 'controller/private/message.dart';

part 'controller/private/minimize.dart';

part 'controller/private/pip.dart';

part 'controller/private/room.dart';

part 'controller/private/user.dart';

part 'controller/private/pk.dart';

part 'controller/private/swiping.dart';

part 'controller/private/screen.dart';

part 'controller/private/media.dart';

/// Used to control the live streaming functionality.
///
/// [ZegoUIKitPrebuiltLiveStreamingController] is a **singleton instance** class,
/// you can directly invoke it by ZegoUIKitPrebuiltLiveStreamingController().
///
/// If the default live streaming UI and interactions do not meet your requirements, you can use this [ZegoUIKitPrebuiltLiveStreamingController] to actively control the business logic.
/// This class is used by setting the [ZegoUIKitPrebuiltLiveStreaming.controller] parameter in the constructor of [ZegoUIKitPrebuiltLiveStreaming].
class ZegoUIKitPrebuiltLiveStreamingController
    with
        ZegoLiveStreamingControllerPrivate,
        ZegoLiveStreamingControllerMessage,
        ZegoLiveStreamingControllerMinimizing,
        ZegoLiveStreamingControllerPIP,
        ZegoLiveStreamingControllerRoom,
        ZegoLiveStreamingControllerUser,
        ZegoLiveStreamingControllerScreen,
        ZegoLiveStreamingControllerCoHost,
        ZegoLiveStreamingControllerPK,
        ZegoLiveStreamingControllerLog,
        ZegoLiveStreamingControllerAudioVideo,
        ZegoLiveStreamingControllerMedia,
        ZegoLiveStreamingControllerHall {
  factory ZegoUIKitPrebuiltLiveStreamingController() => instance;

  String get version => "3.15.2"; // zego_uikit_prebuilt_live_streaming:

  /// This function is used to end the Live Streaming.
  ///
  /// You can pass the context [context] for any necessary pop-ups or page transitions.
  /// By using the [showConfirmation] parameter, you can control whether to display a confirmation dialog to confirm ending the Live Streaming.
  ///
  /// This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the [ZegoUIKitPrebuiltLiveStreamingEvents.onLeaveConfirmation], [ZegoUIKitPrebuiltLiveStreamingEvents.onEnded] settings in the config.
  Future<bool> leave(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
    final result = await room._leave(
      context,
      showConfirmation: showConfirmation,
    );

    await ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();

    private.uninitByPrebuilt();

    return result;
  }

  ValueNotifier<bool> get isLeaveRequestingNotifier =>
      room.private.isLeaveRequestingNotifier;

  ZegoUIKitPrebuiltLiveStreamingController._internal() {
    ZegoLoggerService.logInfo(
      'ZegoUIKitPrebuiltLiveStreamingController create',
      tag: 'live-streaming',
      subTag: 'controller',
    );
  }

  static final ZegoUIKitPrebuiltLiveStreamingController instance =
      ZegoUIKitPrebuiltLiveStreamingController._internal();
}
