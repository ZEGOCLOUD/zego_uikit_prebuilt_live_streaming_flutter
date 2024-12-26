// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_streaming.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/page.dart';

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
    Key? key,
    required this.appID,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    this.appSign = '',
    this.token = '',
    this.events,
  }) : super(key: key);

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
  String get version => "3.14.0-beta.4";

  @override
  void initState() {
    ZegoLoggerService.logInfo(
      '----------init----------',
      tag: 'live-streaming',
      subTag: 'ZegoUIKitPrebuiltLiveStreaming',
    );

    super.initState();

    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'version: zego_uikit_prebuilt_live_streaming:$version; $uikitVersion, \n'
        'config:${widget.config}, \n'
        'events: ${widget.events}, ',
        tag: 'live-streaming',
        subTag: 'prebuilt',
      );
    });

    ZegoUIKit().reporter().create(
      appID: widget.appID,
      signOrToken: widget.appSign.isNotEmpty ? widget.appSign : widget.token,
      params: {
        ZegoLiveStreamingReporter.eventKeyKitVersion: version,
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

    ZegoUIKitPrebuiltLiveStreamingController().pip.cancelBackground();

    ZegoUIKit().reporter().report(event: ZegoLiveStreamingReporter.eventUninit);

    ZegoLoggerService.logInfo(
      '----------dispose----------',
      tag: 'live-streaming',
      subTag: 'ZegoUIKitPrebuiltLiveStreaming',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      /// Waiting for outside live list de-initialization to complete
      future: widget.config.outsideLives.controller?.private.private.uninit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none ||
            snapshot.connectionState == ConnectionState.done) {
          return page();
        }

        return widget.config.outsideLives.loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget page() {
    return null == widget.config.swiping
        ? ZegoLiveStreamingPage(
            appID: widget.appID,
            appSign: widget.appSign,
            token: widget.token,
            userID: widget.userID,
            userName: widget.userName,
            liveID: widget.liveID,
            config: widget.config,
            events: widget.events,
          )
        : ZegoLiveStreamingSwipingPage(
            initialLiveID: widget.liveID,
            appID: widget.appID,
            appSign: widget.appSign,
            token: widget.token,
            userID: widget.userID,
            userName: widget.userName,
            config: widget.config,
            events: widget.events,
            swipingConfig: widget.config.swiping!,
          );
  }
}
