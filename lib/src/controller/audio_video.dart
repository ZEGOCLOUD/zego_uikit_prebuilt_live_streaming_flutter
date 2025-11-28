part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

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

  /// audio output series APIs
  ZegoLiveStreamingControllerAudioVideoAudioOutputImpl get audioOutput =>
      private._audioOutput;
}

class ZegoLiveStreamingControllerAudioVideoMicrophoneImpl
    with ZegoLiveStreamingControllerAudioVideoDeviceImplPrivate {
  /// microphone state of local user
  bool get localState => ZegoUIKit()
      .getMicrophoneStateNotifier(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        ZegoUIKit().getLocalUser().id,
      )
      .value;

  /// microphone state notifier of local user
  ValueNotifier<bool> get localStateNotifier =>
      ZegoUIKit().getMicrophoneStateNotifier(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        ZegoUIKit().getLocalUser().id,
      );

  /// microphone state of [userID]
  bool state(String userID) => ZegoUIKit()
      .getMicrophoneStateNotifier(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        userID,
      )
      .value;

  /// microphone state notifier of [userID]
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getMicrophoneStateNotifier(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        userID,
      );

  /// turn on/off [userID] microphone, if [userID] is empty, then it refers to local user
  Future<void> turnOn(bool isOn, {String? userID}) async {
    final needUseMuteMode =
        (!(private.config?.coHost.stopCoHostingWhenMicCameraOff ?? false)) ||
            ZegoUIKitPrebuiltLiveStreamingController().pk.isInPK;

    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID microphone,"
      "mute mode:$needUseMuteMode, ",
      tag: 'live.streaming.controller.audio-video',
      subTag: 'controller-audioVideo',
    );

    await ZegoUIKit().turnMicrophoneOn(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
      isOn,
      userID: userID,
      muteMode: needUseMuteMode,
    );
  }

  /// switch [userID] microphone state, if [userID] is empty, then it refers to local user
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentMicrophoneState = ZegoUIKit()
        .getMicrophoneStateNotifier(
          targetRoomID:
              ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
          targetUserID,
        )
        .value;

    turnOn(!currentMicrophoneState, userID: targetUserID);
  }
}

class ZegoLiveStreamingControllerAudioVideoCameraImpl
    with ZegoLiveStreamingControllerAudioVideoDeviceImplPrivate {
  /// camera state of local user
  bool get localState => ZegoUIKit()
      .getCameraStateNotifier(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        ZegoUIKit().getLocalUser().id,
      )
      .value;

  /// camera state notifier of local user
  ValueNotifier<bool> get localStateNotifier =>
      ZegoUIKit().getCameraStateNotifier(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        ZegoUIKit().getLocalUser().id,
      );

  /// camera state of [userID]
  bool state(String userID) => ZegoUIKit()
      .getCameraStateNotifier(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        userID,
      )
      .value;

  /// camera state notifier of [userID]
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getCameraStateNotifier(
        targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
        userID,
      );

  /// turn on/off [userID] camera, if [userID] is empty, then it refers to local user
  Future<void> turnOn(bool isOn, {String? userID}) async {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID camera",
      tag: 'live.streaming.controller.audio-video',
      subTag: 'controller-audioVideo',
    );

    await ZegoUIKit().turnCameraOn(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
      isOn,
      userID: userID,
    );
  }

  /// switch [userID] camera state, if [userID] is empty, then it refers to local user
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentCameraState = ZegoUIKit()
        .getCameraStateNotifier(
          targetRoomID:
              ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
          targetUserID,
        )
        .value;

    turnOn(!currentCameraState, userID: targetUserID);
  }

  /// local use front facing camera
  void switchFrontFacing(bool isFrontFacing) {
    ZegoUIKit().useFrontFacingCamera(isFrontFacing);
  }

  /// set video mirror mode
  void switchVideoMirroring(bool isVideoMirror) {
    ZegoUIKit().enableVideoMirroring(isVideoMirror);
  }
}

class ZegoLiveStreamingControllerAudioVideoAudioOutputImpl
    with ZegoLiveStreamingControllerAudioVideoDeviceImplPrivate {
  /// local audio output device notifier
  ValueNotifier<ZegoUIKitAudioRoute> get localNotifier =>
      notifier(ZegoUIKit().getLocalUser().id);

  /// get audio output device notifier
  ValueNotifier<ZegoUIKitAudioRoute> notifier(
    String userID,
  ) {
    return ZegoUIKit().getAudioOutputDeviceNotifier(
      targetRoomID: ZegoUIKitPrebuiltLiveStreamingController().private.liveID,
      userID,
    );
  }

  /// set audio output to speaker or earpiece(telephone receiver)
  void switchToSpeaker(bool isSpeaker) {
    ZegoLoggerService.logInfo(
      "switchToSpeaker, isSpeaker:$isSpeaker, ",
      tag: 'live.streaming.controller.audio-video',
      subTag: 'controller-audioVideo',
    );

    ZegoUIKit().setAudioOutputToSpeaker(isSpeaker);
  }
}
