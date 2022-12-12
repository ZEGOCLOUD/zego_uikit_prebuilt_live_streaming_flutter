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
