// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/utils/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';

enum ZegoLiveStreamingPageLifeCycleEventType {
  contextInit,
}

class ZegoLiveStreamingPageLifeCycleEventData {
  String liveID;
  ZegoLiveStreamingPageLifeCycleEventType eventType;

  ZegoLiveStreamingPageLifeCycleEventData({
    required this.liveID,
    required this.eventType,
  });

  @override
  String toString() {
    return '{'
        'liveID: $liveID, '
        'eventType: $eventType}';
  }
}

class ZegoLiveStreamingPageLifeCycleContextData {
  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final int appID;

  /// You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final String appSign;

  /// The token issued by the developer's business server is used to ensure security.
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

  /// Initialize the configuration for the live-streaming.
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  /// You can listen to events that you are interested in here.
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;

  final ZegoLiveStreamingPopUpManager popUpManager;

  final ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed;

  ZegoLiveStreamingPageLifeCycleContextData({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.config,
    required this.events,
    required this.popUpManager,
    this.onRoomLoginFailed,
  });

  @override
  String toString() {
    return '{'
        'appID: $appID, '
        'appSign: $appSign, '
        'token: $token, '
        'userID: $userID, '
        'userName: $userName, '
        'config: $config, '
        'events: $events, '
        'popUpManager: $popUpManager}';
  }
}
