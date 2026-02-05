// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'components/components.dart';
import 'components/live_streaming_page.dart';
import 'components/utils/pop_up_manager.dart';
import 'config.dart';
import 'controller.dart';
import 'events.dart';
import 'events.defines.dart';
import 'internal/reporter.dart';
import 'lifecycle/defines.dart';
import 'lifecycle/lifecycle.dart';
import 'modules/minimization/defines.dart';
import 'modules/minimization/overlay_machine.dart';
import 'modules/swiping/page.dart';

/// Live Streaming Widget.
///
/// You can embed this widget into any page of your project to integrate the functionality of a live streaming.
///
/// You can refer to our [documentation](https://docs.zegocloud.com/article/14846), [documentation with cohosting](https://docs.zegocloud.com/article/14882)
/// or our [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_live_streaming_example_flutter).
///
/// {@category APIs}
/// {@category Events}
/// {@category Configs}
/// {@category Components}
/// {@category Migration_v3.x}
///
class ZegoUIKitPrebuiltLiveStreaming extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreaming({
    super.key,
    required this.appID,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    this.appSign = '',
    this.token = '',
    this.events,
  });

  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final int appID;

  /// log in by using [appID] + [appSign].
  ///
  /// You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  ///
  /// Of course, you can also log in by using [appID] + [token]. For details, see [token].
  final String appSign;

  /// log in by using [appID] + [token].
  ///
  /// The token issued by the developer's business server is used to ensure security.
  /// Please note that if you want to use [appID] + [token] login, do not assign a value to [appSign]
  ///
  /// For the generation rules, please refer to [Using Token Authentication] (https://doc-zh.zego.im/article/10360), the default is an empty string, that is, no authentication.
  ///
  /// if appSign is not passed in or if appSign is empty, this parameter must be set for authentication when logging in to a room.
  final String token;

  /// The ID of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the ID from your own user system, such as Firebase.
  final String userID;

  /// The name of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the name from your own user system, such as Firebase.
  final String userName;

  /// You can customize the live ID arbitrarily,
  /// just need to know: users who use the same live ID can talk with each other.
  final String liveID;

  /// Initialize the configuration for the live-streaming.
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  /// You can listen to events that you are interested in here.
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;

  @override
  State<ZegoUIKitPrebuiltLiveStreaming> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingState();
}

class _ZegoUIKitPrebuiltLiveStreamingState
    extends State<ZegoUIKitPrebuiltLiveStreaming> {
  bool isPrebuiltFromMinimizing = false;
  bool isPrebuiltFromHall = false;
  final popUpManager = ZegoLiveStreamingPopUpManager();

  @override
  void initState() {
    ZegoLoggerService.logInfo(
      '----------init----------',
      tag: 'live.streaming.',
      subTag: 'ZegoUIKitPrebuiltLiveStreaming',
    );

    super.initState();

    isPrebuiltFromMinimizing = ZegoLiveStreamingMiniOverlayPageState.idle !=
        ZegoLiveStreamingMiniOverlayMachine().state;
    isPrebuiltFromHall = ZegoUIKitPrebuiltLiveStreamingController()
            .minimize
            .private
            .minimizeData
            ?.isPrebuiltFromHall ??
        ZegoUIKitHallRoomIDHelper.isRandomRoomID(
            ZegoUIKit().getCurrentRoom().id);

    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'version: zego_uikit_prebuilt_live_streaming:${ZegoUIKitPrebuiltLiveStreamingController().version}; $uikitVersion, \n'
        'config:${widget.config.toString()}, \n'
        'events: ${widget.events}, '
        'isPrebuiltFromMinimizing:$isPrebuiltFromMinimizing, '
        'isPrebuiltFromHall:$isPrebuiltFromHall, ',
        tag: 'live.streaming.prebuilt',
        subTag: 'initState',
      );
    });

    ZegoUIKit().reporter().create(
      userID: widget.userID,
      appID: widget.appID,
      signOrToken: widget.appSign.isNotEmpty ? widget.appSign : widget.token,
      params: {
        ZegoLiveStreamingReporter.eventKeyKitVersion:
            ZegoUIKitPrebuiltLiveStreamingController().version,
        ZegoUIKitReporter.eventKeyUserID: widget.userID,
      },
    ).then((_) {
      ZegoUIKit().reporter().report(
        event: ZegoLiveStreamingReporter.eventInit,
        params: {
          ZegoUIKitReporter.eventKeyErrorCode: 0,
          ZegoUIKitReporter.eventKeyStartTime:
              DateTime.now().millisecondsSinceEpoch,
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();

    ZegoLiveStreamingPageLifeCycle().uninitFromPreview(
      liveID: widget.liveID,
      isPrebuiltFromHall: isPrebuiltFromHall,
      isFromMinimize: false,
    );

    ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();

    ZegoUIKit().reporter().report(event: ZegoLiveStreamingReporter.eventUninit);

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.prebuilt',
      subTag: 'dispose',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        page(),
        FutureBuilder<void>(
          future: ZegoLiveStreamingPageLifeCycle().initFromPreview(
            targetLiveID: widget.liveID,
            isPrebuiltFromMinimizing: isPrebuiltFromMinimizing,
            isPrebuiltFromHall: isPrebuiltFromHall,
            contextData: ZegoLiveStreamingPageLifeCycleContextData(
              appID: widget.appID,
              appSign: widget.appSign,
              token: widget.token,
              userID: widget.userID,
              userName: widget.userName,
              config: widget.config,
              events: widget.events,
              popUpManager: popUpManager,
              onRoomLoginFailed: onRoomLoginFailed,
            ),
            onRoomLoginFailed: onRoomLoginFailed,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none ||
                snapshot.connectionState == ConnectionState.done) {
              return Container();
            }

            return widget.config.hall.loadingBuilder?.call(context) ??
                Center(
                  child: ZegoLoadingIndicator(
                    text: kDebugMode ? "PrebuiltLiveStreaming" : "",
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget page() {
    final usingSwiping = null != widget.config.swiping;
    return usingSwiping
        ? ZegoLiveStreamingSwipingPage(
            appID: widget.appID,
            appSign: widget.appSign,
            token: widget.token,
            userID: widget.userID,
            userName: widget.userName,
            config: widget.config,
            events: widget.events,
            swipingModel: widget.config.swiping?.model,
            swipingModelDelegate: widget.config.swiping?.modelDelegate,
            popUpManager: popUpManager,
            isPrebuiltFromMinimizing: isPrebuiltFromMinimizing,
            isPrebuiltFromHall: isPrebuiltFromHall,
            onRoomLoginFailed: onRoomLoginFailed,
          )
        : ZegoLiveStreamingPage(
            appID: widget.appID,
            appSign: widget.appSign,
            token: widget.token,
            userID: widget.userID,
            userName: widget.userName,
            liveID: widget.liveID,
            config: widget.config,
            events: widget.events,
            popUpManager: popUpManager,
            isPrebuiltFromMinimizing: isPrebuiltFromMinimizing,
            isPrebuiltFromHall: isPrebuiltFromHall,
            onRoomLoginFailed: onRoomLoginFailed,
          );
  }

  void onRoomLoginFailed(int code, String message) {
    ZegoLoggerService.logInfo(
      'room login failed: $code, $message',
      tag: 'live-streaming',
      subTag: 'prebuilt, room login failed',
    );

    final event = ZegoLiveStreamingRoomLoginFailedEvent(
      errorCode: code,
      message: message,
    );

    if (null != widget.events?.room.onLoginFailed) {
      widget.events?.room.onLoginFailed!.call(
        event,
        defaultRoomLoginFailedAction,
      );
    } else {
      defaultRoomLoginFailedAction(event);
    }
  }

  Future<bool> defaultRoomLoginFailedAction(
    ZegoLiveStreamingRoomLoginFailedEvent event,
  ) async {
    return showLiveDialog(
      context: context,
      rootNavigator: widget.config.rootNavigator,
      title: widget.config.innerText.loginFailedDialogInfo.title,
      content: widget.config.innerText.loginFailedDialogInfo.message,
      rightButtonText:
          widget.config.innerText.loginFailedDialogInfo.confirmButtonName,
      rightButtonCallback: () {
        Navigator.of(
          context,
          rootNavigator: widget.config.rootNavigator,
        ).pop(true);
        Navigator.of(context).pop();
      },
    );
  }
}
