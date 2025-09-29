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
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/enable_property.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/media_player.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/pip/pip_android.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/pip/pip_interface.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller/private/pip/pip_ios.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/core_managers.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/pk_combine_notifier.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/core.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/service/services.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/config.dart';

part 'controller/audio_video.dart';

part 'controller/co.host.dart';

part 'controller/message.dart';

part 'controller/minimize.dart';

part 'controller/pip.dart';

part 'controller/room.dart';

part 'controller/user.dart';

part 'controller/screen.dart';

part 'controller/media.dart';

part 'controller/pk.dart';

part 'controller/swiping.dart';

part 'controller/private/private.dart';

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
        ZegoLiveStreamingControllerSwiping,
        ZegoLiveStreamingControllerAudioVideo,
        ZegoLiveStreamingControllerMedia {
  factory ZegoUIKitPrebuiltLiveStreamingController() => instance;

  String get version => "3.14.6";

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
    final result =
        await room._leave(context, showConfirmation: showConfirmation);

    await ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();

    private.uninitByPrebuilt();
    pk.private.uninitByPrebuilt();
    room.private.uninitByPrebuilt();
    user.private.uninitByPrebuilt();
    message.private.uninitByPrebuilt();
    coHost.private.uninitByPrebuilt();
    audioVideo.private.uninitByPrebuilt();
    minimize.private.uninitByPrebuilt();
    pip.private.uninitByPrebuilt();
    screenSharing.private.uninitByPrebuilt();
    swiping.private.uninitByPrebuilt();

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
