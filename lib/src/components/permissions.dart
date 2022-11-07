// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_translation.dart';
import 'dialogs.dart';

Future<void> checkPermissions({
  required BuildContext context,
  required ZegoTranslationText translationText,
  bool isShowDialog = false,
}) async {
  await Permission.camera.status.then((status) async {
    if (status != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context,
          translationText.cameraPermissionSettingDialogInfo,
        );
      }
    }
  });

  await Permission.microphone.status.then((status) async {
    if (status != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context,
          translationText.microphonePermissionSettingDialogInfo,
        );
      }
    }
  });
}

Future<void> requestPermissions({
  required BuildContext context,
  required ZegoTranslationText translationText,
  bool isShowDialog = false,
}) async {
  await [
    Permission.camera,
    Permission.microphone,
  ].request().then((Map<Permission, PermissionStatus> statuses) async {
    if (statuses[Permission.camera] != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context,
          translationText.cameraPermissionSettingDialogInfo,
        );
      }
    }

    if (statuses[Permission.microphone] != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context,
          translationText.microphonePermissionSettingDialogInfo,
        );
      }
    }
  });
}

Future<bool> showAppSettingsDialog(
  BuildContext context,
  ZegoDialogInfo dialogInfo,
) async {
  return await showLiveDialog(
    context: context,
    title: dialogInfo.title,
    content: dialogInfo.message,
    leftButtonText: dialogInfo.cancelButtonName,
    leftButtonCallback: () {
      Navigator.of(context).pop(false);
    },
    rightButtonText: dialogInfo.confirmButtonName,
    rightButtonCallback: () async {
      await openAppSettings();
      Navigator.of(context).pop(false);
    },
  );
}
