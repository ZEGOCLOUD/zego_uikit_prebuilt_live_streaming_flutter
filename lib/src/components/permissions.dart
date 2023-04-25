// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_translation.dart';

Future<void> checkPermissions({
  required BuildContext context,
  required ZegoTranslationText translationText,
  required bool rootNavigator,
  bool isShowDialog = false,
}) async {
  await Permission.camera.status.then((status) async {
    if (status != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context: context,
          dialogInfo: translationText.cameraPermissionSettingDialogInfo,
          rootNavigator: rootNavigator,
        );
      }
    }
  });

  await Permission.microphone.status.then((status) async {
    if (status != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context: context,
          dialogInfo: translationText.microphonePermissionSettingDialogInfo,
          rootNavigator: rootNavigator,
        );
      }
    }
  });
}

Future<void> requestPermissions({
  required BuildContext context,
  required ZegoTranslationText translationText,
  required bool rootNavigator,
  bool isShowDialog = false,
}) async {
  await [
    Permission.camera,
    Permission.microphone,
  ].request().then((Map<Permission, PermissionStatus> statuses) async {
    if (statuses[Permission.camera] != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context: context,
          dialogInfo: translationText.cameraPermissionSettingDialogInfo,
          rootNavigator: rootNavigator,
        );
      }
    }

    if (statuses[Permission.microphone] != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context: context,
          dialogInfo: translationText.microphonePermissionSettingDialogInfo,
          rootNavigator: rootNavigator,
        );
      }
    }
  });
}

Future<bool> showAppSettingsDialog({
  required BuildContext context,
  required ZegoDialogInfo dialogInfo,
  required bool rootNavigator,
}) async {
  return showLiveDialog(
    context: context,
    title: dialogInfo.title,
    content: dialogInfo.message,
    rootNavigator: rootNavigator,
    leftButtonText: dialogInfo.cancelButtonName,
    leftButtonCallback: () {
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pop(false);
    },
    rightButtonText: dialogInfo.confirmButtonName,
    rightButtonCallback: () async {
      await openAppSettings();
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pop(false);
    },
  );
}
