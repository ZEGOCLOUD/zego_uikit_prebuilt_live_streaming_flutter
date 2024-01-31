part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerAudioVideo {
  final _audioVideoImpl = ZegoLiveStreamingControllerAudioVideoImpl();

  ZegoLiveStreamingControllerAudioVideoImpl get audioVideo => _audioVideoImpl;
}

/// Here are the APIs related to audio video.
class ZegoLiveStreamingControllerAudioVideoImpl
    with ZegoLiveStreamingControllerAudioVideoImplPrivate {
  /// microphone series APIs
  ZegoLiveStreamingControllerAudioVideoMicrophoneImpl get microphone =>
      private._microphone;

  /// camera series APIs
  ZegoLiveStreamingControllerAudioVideoCameraImpl get camera => private._camera;
}

class ZegoLiveStreamingControllerAudioVideoMicrophoneImpl
    with ZegoLiveStreamingControllerAudioVideoDeviceImplPrivate {
  /// microphone state of local user
  bool get localState => ZegoUIKit()
      .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
      .value;

  /// microphone state notifier of local user
  ValueNotifier<bool> get localStateNotifier =>
      ZegoUIKit().getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id);

  /// microphone state of [userID]
  bool state(String userID) =>
      ZegoUIKit().getMicrophoneStateNotifier(userID).value;

  /// microphone state notifier of [userID]
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getMicrophoneStateNotifier(userID);

  /// turn on/off [userID] microphone, if [userID] is empty, then it refers to local user
  void turnOn(bool isOn, {String? userID}) {
    final needUseMuteMode =
        (!(private.config?.stopCoHostingWhenMicCameraOff ?? false)) ||
            ZegoUIKitPrebuiltLiveStreamingController().pk.isInPK;

    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID microphone,"
      "mute mode:$needUseMuteMode, ",
      tag: 'live streaming',
      subTag: 'controller-audioVideo',
    );

    return ZegoUIKit().turnMicrophoneOn(
      isOn,
      userID: userID,
      muteMode: needUseMuteMode,
    );
  }

  /// switch [userID] microphone state, if [userID] is empty, then it refers to local user
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentMicrophoneState =
        ZegoUIKit().getMicrophoneStateNotifier(targetUserID).value;

    turnOn(!currentMicrophoneState, userID: targetUserID);
  }
}

class ZegoLiveStreamingControllerAudioVideoCameraImpl
    with ZegoLiveStreamingControllerAudioVideoDeviceImplPrivate {
  /// camera state of local user
  bool get localState =>
      ZegoUIKit().getCameraStateNotifier(ZegoUIKit().getLocalUser().id).value;

  /// camera state notifier of local user
  ValueNotifier<bool> get localStateNotifier =>
      ZegoUIKit().getCameraStateNotifier(ZegoUIKit().getLocalUser().id);

  /// camera state of [userID]
  bool state(String userID) => ZegoUIKit().getCameraStateNotifier(userID).value;

  /// camera state notifier of [userID]
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getCameraStateNotifier(userID);

  /// turn on/off [userID] camera, if [userID] is empty, then it refers to local user
  void turnOn(bool isOn, {String? userID}) {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID camera",
      tag: 'live streaming',
      subTag: 'controller-audioVideo',
    );

    return ZegoUIKit().turnCameraOn(
      isOn,
      userID: userID,
    );
  }

  /// switch [userID] camera state, if [userID] is empty, then it refers to local user
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentCameraState =
        ZegoUIKit().getCameraStateNotifier(targetUserID).value;

    turnOn(!currentCameraState, userID: targetUserID);
  }
}
