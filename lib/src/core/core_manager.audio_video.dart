part of 'core_managers.dart';

extension ZegoLiveStreamingAudioVideoManagers on ZegoLiveStreamingManagers {
  ZegoPlayCoHostAudioVideoCallback? get playCoHostAudioConfig =>
      hostManager.config?.audioVideoView.playCoHostAudio;

  ZegoPlayCoHostAudioVideoCallback? get playCoHostVideoConfig =>
      hostManager.config?.audioVideoView.playCoHostVideo;

  void initAudioVideoManagers() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'live-streaming-coHost',
      subTag: 'audio video',
    );

    subscriptions.add(ZegoUIKit()
        .getAudioVideoListStream(targetRoomID: liveID)
        .listen(onAudioVideoListUpdated));

    hostManager.notifier.addListener(onHostUpdated);
  }

  void uninitAudioVideoManagers() {
    hostManager.notifier.removeListener(onHostUpdated);
  }

  void onHostUpdated() {
    muteCoHostAudioVideo(ZegoUIKit().getAudioVideoList(targetRoomID: liveID));
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> audioVideoUsers) {
    muteCoHostAudioVideo(audioVideoUsers);
  }

  void muteCoHostAudioVideo(List<ZegoUIKitUser> audioVideoUsers) {
    final localRole = connectManager.localRole;

    if (null != playCoHostAudioConfig) {
      for (final audioVideoUser in audioVideoUsers) {
        if (audioVideoUser.id == ZegoUIKit().getLocalUser().id) {
          continue;
        }
        if (hostManager.notifier.value?.id == audioVideoUser.id) {
          continue;
        }

        final isPlayAudio = playCoHostAudioConfig!.call(
          ZegoUIKit().getLocalUser(),
          localRole,
          audioVideoUser,
        );
        ZegoLoggerService.logInfo(
          'mute co-host(${audioVideoUser.id}) audio, local role:$localRole, is play:$isPlayAudio, '
          'co-host microphone state:${audioVideoUser.microphone.value}',
          tag: 'live-streaming-coHost',
          subTag: 'audio video',
        );
        if (isPlayAudio && audioVideoUser.microphone.value) {
          ZegoUIKit().muteUserAudio(
            targetRoomID: liveID,
            audioVideoUser.id,
            false,
          );
        } else if (!isPlayAudio) {
          ZegoUIKit().muteUserAudio(
            targetRoomID: liveID,
            audioVideoUser.id,
            true,
          );
        }
      }
    }

    if (null != playCoHostVideoConfig) {
      for (final audioVideoUser in audioVideoUsers) {
        if (audioVideoUser.id == ZegoUIKit().getLocalUser().id) {
          continue;
        }
        if (hostManager.notifier.value?.id == audioVideoUser.id) {
          /// host can not mute
          ZegoUIKit().muteUserVideo(
            targetRoomID: liveID,
            audioVideoUser.id,
            false,
          );
          continue;
        }

        final isPlayVideo = playCoHostVideoConfig!.call(
          ZegoUIKit().getLocalUser(),
          localRole,
          audioVideoUser,
        );
        ZegoLoggerService.logInfo(
          'mute co-host(${audioVideoUser.id}) video, local role:$localRole, is play:$isPlayVideo, '
          'co-host camera state:${audioVideoUser.camera.value}',
          tag: 'live-streaming-coHost',
          subTag: 'audio video',
        );
        if (isPlayVideo && audioVideoUser.camera.value) {
          ZegoUIKit().muteUserVideo(
            targetRoomID: liveID,
            audioVideoUser.id,
            false,
          );
        } else if (!isPlayVideo) {
          ZegoUIKit()
              .muteUserVideo(targetRoomID: liveID, audioVideoUser.id, true);
        }
      }
    }
  }
}
