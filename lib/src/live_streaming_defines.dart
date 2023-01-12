// Flutter imports:
import 'package:flutter/cupertino.dart';

/// prefab button on menu bar
enum ZegoMenuBarButtonName {
  toggleMicrophoneButton,
  toggleCameraButton,
  switchCameraButton,
  switchAudioOutputButton,
  leaveButton,
  coHostControlButton,
  beautyEffectButton,
  soundEffectButton,
  enableChatButton,
}

class ZegoDialogInfo {
  final String title;
  final String message;
  String cancelButtonName;
  String confirmButtonName;

  ZegoDialogInfo({
    required this.title,
    required this.message,
    this.cancelButtonName = "Cancel",
    this.confirmButtonName = "OK",
  });
}

typedef ZegoStartLiveButtonBuilder = Widget Function(
  BuildContext context,

  /// you MUST call this function to make Preview Page skip to Live Page
  VoidCallback startLive,
);
