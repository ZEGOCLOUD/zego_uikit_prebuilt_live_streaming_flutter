// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';

/// @nodoc
Future<void> checkPermissions({
  required BuildContext context,
  required ZegoInnerText translationText,
  required bool rootNavigator,
  required ZegoPopUpManager popUpManager,
  required ValueNotifier<bool> kickOutNotifier,
  List<Permission> permissions = const [
    Permission.camera,
    Permission.microphone,
  ],
  bool isShowDialog = false,
}) async {
  if (permissions.contains(Permission.camera)) {
    await Permission.camera.status.then((status) async {
      if (status != PermissionStatus.granted) {
        if (isShowDialog) {
          await showAppSettingsDialog(
            context: context,
            dialogInfo: translationText.cameraPermissionSettingDialogInfo,
            rootNavigator: rootNavigator,
            popUpManager: popUpManager,
            kickOutNotifier: kickOutNotifier,
          );
        }
      }
    });
  }

  if (permissions.contains(Permission.microphone)) {
    await Permission.microphone.status.then((status) async {
      if (status != PermissionStatus.granted) {
        if (isShowDialog) {
          await showAppSettingsDialog(
            context: context,
            dialogInfo: translationText.microphonePermissionSettingDialogInfo,
            rootNavigator: rootNavigator,
            popUpManager: popUpManager,
            kickOutNotifier: kickOutNotifier,
          );
        }
      }
    });
  }
}

/// @nodoc
Future<void> requestPermissions({
  required BuildContext context,
  required ZegoInnerText translationText,
  required bool rootNavigator,
  required ZegoPopUpManager popUpManager,
  required ValueNotifier<bool> kickOutNotifier,
  List<Permission> permissions = const [
    Permission.camera,
    Permission.microphone,
  ],
  bool isShowDialog = false,
}) async {
  await permissions
      .request()
      .then((Map<Permission, PermissionStatus> statuses) async {
    if (permissions.contains(Permission.camera) &&
        statuses[Permission.camera] != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context: context,
          dialogInfo: translationText.cameraPermissionSettingDialogInfo,
          rootNavigator: rootNavigator,
          popUpManager: popUpManager,
          kickOutNotifier: kickOutNotifier,
        );
      }
    }

    if (permissions.contains(Permission.microphone) &&
        statuses[Permission.microphone] != PermissionStatus.granted) {
      if (isShowDialog) {
        await showAppSettingsDialog(
          context: context,
          dialogInfo: translationText.microphonePermissionSettingDialogInfo,
          rootNavigator: rootNavigator,
          popUpManager: popUpManager,
          kickOutNotifier: kickOutNotifier,
        );
      }
    }
  });
}

/// @nodoc
Future<bool> showAppSettingsDialog({
  required BuildContext context,
  required ZegoDialogInfo dialogInfo,
  required bool rootNavigator,
  required ZegoPopUpManager popUpManager,
  required ValueNotifier<bool> kickOutNotifier,
}) async {
  if (kickOutNotifier.value) {
    ZegoLoggerService.logInfo(
      'local user is kick-out, ignore show app settings dialog',
      tag: 'live streaming',
      subTag: 'prebuilt',
    );
    return false;
  }

  final key = DateTime.now().millisecondsSinceEpoch;
  popUpManager.addAPopUpSheet(key);

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
  ).then((result) {
    popUpManager.removeAPopUpSheet(key);

    return result;
  });
}
