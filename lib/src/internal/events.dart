// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';

class ZegoLiveStreamingEventListener {
  final String liveID;
  final ZegoUIKitPrebuiltLiveStreamingEvents? events;
  final List<StreamSubscription<dynamic>?> _subscriptions = [];

  ZegoLiveStreamingEventListener(
    this.events, {
    required this.liveID,
  });

  void init() {
    _subscriptions
      ..add(ZegoUIKit()
          .getUserJoinStream(targetRoomID: liveID)
          .listen(_onUserJoin))
      ..add(ZegoUIKit()
          .getUserLeaveStream(targetRoomID: liveID)
          .listen(_onUserLeave));

    ZegoUIKit()
        .getCameraStateNotifier(
          targetRoomID: liveID,
          ZegoUIKit().getLocalUser().id,
        )
        .addListener(_onCameraStateChanged);
    ZegoUIKit()
        .getMicrophoneStateNotifier(
          targetRoomID: liveID,
          ZegoUIKit().getLocalUser().id,
        )
        .addListener(_onMicrophoneStateChanged);
    ZegoUIKit()
        .getUseFrontFacingCameraStateNotifier(
          targetRoomID: liveID,
          ZegoUIKit().getLocalUser().id,
        )
        .addListener(_onFrontFacingCameraStateChanged);
    ZegoUIKit()
        .getAudioOutputDeviceNotifier(
          targetRoomID: liveID,
          ZegoUIKit().getLocalUser().id,
        )
        .addListener(_onAudioOutputChanged);

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .addListener(_onRoomStateChanged);
  }

  void uninit() {
    ZegoUIKit()
        .getCameraStateNotifier(
          targetRoomID: liveID,
          ZegoUIKit().getLocalUser().id,
        )
        .removeListener(_onCameraStateChanged);
    ZegoUIKit()
        .getMicrophoneStateNotifier(
          targetRoomID: liveID,
          ZegoUIKit().getLocalUser().id,
        )
        .removeListener(_onMicrophoneStateChanged);
    ZegoUIKit()
        .getUseFrontFacingCameraStateNotifier(
          targetRoomID: liveID,
          ZegoUIKit().getLocalUser().id,
        )
        .removeListener(_onFrontFacingCameraStateChanged);
    ZegoUIKit()
        .getAudioOutputDeviceNotifier(
          targetRoomID: liveID,
          ZegoUIKit().getLocalUser().id,
        )
        .removeListener(_onAudioOutputChanged);

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .removeListener(_onRoomStateChanged);

    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
  }

  void _onUserJoin(List<ZegoUIKitUser> users) {
    for (var user in users) {
      events?.user.onEnter?.call(user);
    }
  }

  void _onUserLeave(List<ZegoUIKitUser> users) {
    for (var user in users) {
      events?.user.onLeave?.call(user);
    }
  }

  void _onRoomStateChanged() {
    events?.room.onStateChanged
        ?.call(ZegoUIKit().getRoomStateStream(targetRoomID: liveID).value);
  }

  void _onCameraStateChanged() {
    events?.audioVideo.onCameraStateChanged?.call(
      ZegoUIKit()
          .getCameraStateNotifier(
            targetRoomID: liveID,
            ZegoUIKit().getLocalUser().id,
          )
          .value,
    );
  }

  void _onMicrophoneStateChanged() {
    events?.audioVideo.onMicrophoneStateChanged?.call(
      ZegoUIKit()
          .getMicrophoneStateNotifier(
            targetRoomID: liveID,
            ZegoUIKit().getLocalUser().id,
          )
          .value,
    );
  }

  void _onFrontFacingCameraStateChanged() {
    events?.audioVideo.onFrontFacingCameraStateChanged?.call(
      ZegoUIKit()
          .getUseFrontFacingCameraStateNotifier(
            targetRoomID: liveID,
            ZegoUIKit().getLocalUser().id,
          )
          .value,
    );
  }

  void _onAudioOutputChanged() {
    events?.audioVideo.onAudioOutputChanged?.call(
      ZegoUIKit()
          .getAudioOutputDeviceNotifier(
            targetRoomID: liveID,
            ZegoUIKit().getLocalUser().id,
          )
          .value,
    );
  }
}
