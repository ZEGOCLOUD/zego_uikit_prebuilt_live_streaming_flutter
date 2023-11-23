// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/live_streaming.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/swiping/live_streaming_swiping.dart';

/// Live Streaming Widget.
///
/// You can embed this widget into any page of your project to integrate the functionality of a live streaming.
///
/// You can refer to our [documentation](https://docs.zegocloud.com/article/14846), [documentation with cohosting](https://docs.zegocloud.com/article/14882)
/// or our [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_live_streaming_example_flutter).
class ZegoUIKitPrebuiltLiveStreaming extends StatefulWidget {
  const ZegoUIKitPrebuiltLiveStreaming({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.liveID,
    required this.config,
    this.controller,
    this.events,
    @Deprecated('Since 2.15.0') this.onDispose,
    @Deprecated('Since 2.4.1') this.appDesignSize,
  }) : super(key: key);

  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final int appID;

  /// You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final String appSign;

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

  /// You can invoke the methods provided by [ZegoUIKitPrebuiltLiveStreaming] through the [controller].
  final ZegoUIKitPrebuiltLiveStreamingController? controller;

  /// You can listen to events that you are interested in here.
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;

  /// Callback when the page is destroyed.
  @Deprecated('Since 2.15.0')
  final VoidCallback? onDispose;

  /// @nodoc
  @Deprecated('Since 2.4.1')
  final Size? appDesignSize;

  /// @nodoc
  @override
  State<ZegoUIKitPrebuiltLiveStreaming> createState() =>
      _ZegoUIKitPrebuiltLiveStreamingState();
}

/// @nodoc
class _ZegoUIKitPrebuiltLiveStreamingState
    extends State<ZegoUIKitPrebuiltLiveStreaming> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return null == widget.config.swipingConfig
        ? ZegoUIKitPrebuiltLiveStreamingPage(
            appID: widget.appID,
            appSign: widget.appSign,
            userID: widget.userID,
            userName: widget.userName,
            liveID: widget.liveID,
            config: widget.config,
            controller: widget.controller,
            events: widget.events,
          )
        : ZegoUIKitPrebuiltLiveStreamingSwiping(
            initialLiveID: widget.liveID,
            appID: widget.appID,
            appSign: widget.appSign,
            userID: widget.userID,
            userName: widget.userName,
            config: widget.config,
            controller: widget.controller,
            events: widget.events,
            swipingConfig: widget.config.swipingConfig!,
          );
  }
}
