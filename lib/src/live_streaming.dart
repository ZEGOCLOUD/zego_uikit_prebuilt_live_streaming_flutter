// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:http/http.dart' as http;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/permissions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/preview_page.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/toast.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/live_status_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/connect/plugins.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'live_streaming_config.dart';

class ZegoUIKitPrebuiltLiveStreaming extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreaming({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    this.tokenServerUrl = '',
  }) : super(key: key);

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appID you obtained from console.zegocloud.com
  final String appSign;

  /// tokenServerUrl is only for web.
  /// If you have to support Web and Android, iOS, then you can use it like this
  /// ```
  ///   ZegoUIKitPrebuiltLiveStreaming(
  ///     appID: appID,
  ///     appSign: kIsWeb ? '' : appSign,
  ///     userID: userID,
  ///     userName: userName,
  ///     tokenServerUrl: kIsWeb ? tokenServerUrl：'',
  ///   );
  /// ```
  final String tokenServerUrl;

  /// local user info
  final String userID;
  final String userName;

  /// You can customize the liveName arbitrarily,
  /// just need to know: users who use the same liveName can talk with each other.
  final String liveID;

  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  @override
  State<ZegoUIKitPrebuiltLiveStreaming> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingState();
}

class _ZegoUIKitPrebuiltLiveStreamingState
    extends State<ZegoUIKitPrebuiltLiveStreaming> with WidgetsBindingObserver {
  List<StreamSubscription<dynamic>?> subscriptions = [];

  var readyNotifier = ValueNotifier<bool>(false);
  var startedByLocalNotifier = ValueNotifier<bool>(false);
  late final ZegoLiveHostManager hostManager;
  late final ZegoLiveStatusManager liveStatusManager;
  ZegoPrebuiltPlugins? plugins;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    ZegoUIKit().getZegoUIKitVersion().then((version) {
      log("version: zego_uikit_prebuilt_live_streaming: 1.4.3; $version");
    });

    hostManager = ZegoLiveHostManager(config: widget.config);
    liveStatusManager = ZegoLiveStatusManager(
      hostManager: hostManager,
      config: widget.config,
    );

    if (widget.config.plugins.isNotEmpty) {
      plugins = ZegoPrebuiltPlugins(
        appID: widget.appID,
        appSign: widget.appSign,
        userID: widget.userID,
        userName: widget.userName,
        roomID: widget.liveID,
        plugins: widget.config.plugins,
      );
    }
    plugins?.init();

    subscriptions.add(
        ZegoUIKit().getMeRemovedFromRoomStream().listen(onMeRemovedFromRoom));

    initToast();
    initContext();
  }

  @override
  void dispose() async {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);

    plugins?.uninit();

    hostManager.uninit();
    liveStatusManager.uninit();

    uninitContext();

    for (var subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  @override
  void didUpdateWidget(ZegoUIKitPrebuiltLiveStreaming oldWidget) {
    super.didUpdateWidget(oldWidget);

    plugins?.onUserInfoUpdate(widget.userID, widget.userName);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    ZegoLoggerService.logInfo(
      "didChangeAppLifecycleState $state",
      tag: "live streaming",
      subTag: "prebuilt",
    );

    switch (state) {
      case AppLifecycleState.resumed:
        plugins?.tryReLogin();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.config.onLeaveConfirmation ??= onLeaveConfirmation;

    return hostManager.isHost
        ? ValueListenableBuilder<ZegoUIKitUser?>(
            valueListenable: hostManager.notifier,
            builder: (context, host, _) {
              /// local is host, but host updated
              if (hostManager.isHost) {
                return ValueListenableBuilder<bool>(
                    valueListenable: startedByLocalNotifier,
                    builder: (context, isStartedByLocal, _) {
                      return isStartedByLocal ? livePage() : previewPage();
                    });
              } else {
                return livePage();
              }
            })
        : livePage();
  }

  Future<void> initPermissions() async {
    bool isCameraGranted = true;
    bool isMicrophoneGranted = true;
    if (widget.config.turnOnCameraWhenJoining) {
      isCameraGranted = await requestPermission(Permission.camera);
    }
    if (widget.config.turnOnMicrophoneWhenJoining) {
      isMicrophoneGranted = await requestPermission(Permission.microphone);
    }

    if (!isCameraGranted) {
      await showAppSettingsDialog(
        context,
        widget.config.translationText.cameraPermissionSettingDialogInfo,
      );
    }
    if (!isMicrophoneGranted) {
      await showAppSettingsDialog(
        context,
        widget.config.translationText.microphonePermissionSettingDialogInfo,
      );
    }
  }

  void initContext() {
    if (!kIsWeb) {
      assert(widget.appSign.isNotEmpty);
      initPermissions().then((value) {
        ZegoUIKit().login(widget.userID, widget.userName).then((value) {
          ZegoUIKit()
              .init(
                appID: widget.appID,
                appSign: widget.appSign,
                scenario: ZegoScenario.Broadcast,
              )
              .then(onContextInit);
        });
      });
    } else {
      assert(widget.tokenServerUrl.isNotEmpty);
      ZegoUIKit().login(widget.userID, widget.userName).then((value) {
        ZegoUIKit()
            .init(
              appID: widget.appID,
              tokenServerUrl: widget.tokenServerUrl,
              scenario: ZegoScenario.Broadcast,
            )
            .then(onContextInit);
      });
    }
  }

  void onContextInit(_) {
    var useBeautyEffect = widget.config.bottomMenuBarConfig.hostButtons
            .contains(ZegoMenuBarButtonName.beautyEffectButton) ||
        widget.config.bottomMenuBarConfig.coHostButtons
            .contains(ZegoMenuBarButtonName.beautyEffectButton);

    if (useBeautyEffect) {
      ZegoUIKit()
          .startEffectsEnv()
          .then((value) => ZegoUIKit().enableBeauty(true));
    }

    ZegoUIKit()
      ..useFrontFacingCamera(true)
      ..updateVideoViewMode(
          widget.config.audioVideoViewConfig.useVideoViewAspectFill)
      ..enableVideoMirroring(widget.config.audioVideoViewConfig.isVideoMirror)
      ..turnCameraOn(widget.config.turnOnCameraWhenJoining)
      ..turnMicrophoneOn(widget.config.turnOnMicrophoneWhenJoining)
      ..setAudioOutputToSpeaker(widget.config.useSpeakerWhenJoining);

    if (!kIsWeb) {
      ZegoUIKit()
          .joinRoom(
        widget.liveID,
        markAsLargeRoom: widget.config.markAsLargeRoom,
      )
          .then((result) async {
        await onRoomLogin(result);
      });
    } else {
      getToken(widget.userID).then((token) {
        assert(token.isNotEmpty);
        ZegoUIKit().joinRoom(widget.liveID, token: token).then((result) async {
          await onRoomLogin(result);
        });
      });
    }
  }

  Future<void> onRoomLogin(ZegoRoomLoginResult result) async {
    await hostManager.init();
    await liveStatusManager.init();

    readyNotifier.value = true;
  }

  /// Get your token from tokenServer
  Future<String> getToken(String userID) async {
    final response = await http
        .get(Uri.parse('${widget.tokenServerUrl}/access_token?uid=$userID'));
    if (response.statusCode == 200) {
      final jsonObj = json.decode(response.body);
      return jsonObj['token'];
    } else {
      return "";
    }
  }

  void uninitContext() async {
    // var useBeautyEffect = widget.config.bottomMenuBarConfig.buttons
    //     .contains(ZegoMenuBarButtonName.beautyEffectButton);
    // if (useBeautyEffect) {
    //   await ZegoUIKit().stopEffectsEnv();
    // }

    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();

    await ZegoUIKit().leaveRoom();

    // await ZegoUIKit().uninit();
  }

  void initToast() {
    ZegoToast.instance.init(contextQuery: () {
      return context;
    });
  }

  Future<bool> onLeaveConfirmation(BuildContext context) async {
    if (widget.config.confirmDialogInfo == null) {
      return true;
    }

    return await showLiveDialog(
      context: context,
      title: widget.config.confirmDialogInfo!.title,
      content: widget.config.confirmDialogInfo!.message,
      leftButtonText: widget.config.confirmDialogInfo!.cancelButtonName,
      leftButtonCallback: () {
        //  pop this dialog
        Navigator.of(context).pop(false);
      },
      rightButtonText: widget.config.confirmDialogInfo!.confirmButtonName,
      rightButtonCallback: () {
        //  pop this dialog
        Navigator.of(context).pop(true);
      },
    );
  }

  void onMeRemovedFromRoom(String fromUserID) {
    ZegoLoggerService.logInfo(
      "local user removed by $fromUserID",
      tag: "live streaming",
      subTag: "prebuilt",
    );

    if (null != widget.config.onMeRemovedFromRoom) {
      widget.config.onMeRemovedFromRoom!.call(fromUserID);
    } else {
      //  pop this dialog
      Navigator.of(context).pop(true);
    }
  }

  Widget previewPage() {
    return ZegoPreviewPage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      config: widget.config,
      tokenServerUrl: widget.tokenServerUrl,
      startedNotifier: startedByLocalNotifier,
      hostManager: hostManager,
      translationText: widget.config.translationText,
      liveStreamingPageReady: readyNotifier,
    );
  }

  Widget livePage() {
    return ZegoLivePage(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      liveID: widget.liveID,
      config: widget.config,
      tokenServerUrl: widget.tokenServerUrl,
      hostManager: hostManager,
      liveStatusManager: liveStatusManager,
      plugins: plugins,
    );
  }
}
