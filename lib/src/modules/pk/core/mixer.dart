// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/error.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/layout/layout.dart';
import 'defines.dart';

class ZegoUIKitPrebuiltLiveStreamingPKServiceMixer {
  bool _init = false;

  ZegoUIKitMixerTask? _task;
  String _mixerID = '';

  String _liveID = '';

  /// is execute mute api
  bool _isMuting = false;

  /// host is muted or not
  var mutedUsersNotifier = ValueNotifier<List<String>>([]);

  ZegoLiveStreamingPKMixerLayout? _layout;

  String get mixerID => _mixerID;

  ZegoLiveStreamingPKMixerLayout get layout =>
      _layout ?? ZegoLiveStreamingPKMixerDefaultLayout();

  bool isMuted(String targetHostID) =>
      mutedUsersNotifier.value.contains(targetHostID);

  void init({
    required String liveID,
    required ZegoLiveStreamingPKMixerLayout? layout,
  }) async {
    if (_init) {
      return;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live-streaming-pk',
      subTag: 'mixer',
    );

    _init = true;
    _layout = layout;

    _liveID = liveID;
    _mixerID = '${liveID}__mix';
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live-streaming-pk',
      subTag: 'mixer',
    );

    await stopTask();
    await stopPlayStream();

    mutedUsersNotifier.value = [];

    _isMuting = false;
    _mixerID = '';

    _init = false;

    ZegoLoggerService.logInfo(
      'uninit done',
      tag: 'live-streaming-pk',
      subTag: 'mixer',
    );
  }

  Future<bool> updateTask(
    List<ZegoLiveStreamingPKUser> pkHosts,
  ) async {
    if (!_init) {
      ZegoLoggerService.logInfo(
        'update mixer, but not init',
        tag: 'live-streaming-pk',
        subTag: 'mixer',
      );

      return false;
    }
    if (_mixerID.isEmpty) {
      ZegoLoggerService.logInfo(
        'update mixer, but mixer stream id is empty',
        tag: 'live-streaming-pk',
        subTag: 'mixer',
      );

      return false;
    }

    _task = _generateTask(pkHosts);

    ZegoLoggerService.logInfo(
      'update mixer, '
      'users:$pkHosts, '
      'mutedHosts:${mutedUsersNotifier.value}, '
      'task:${_task?.toStringX()}',
      tag: 'live-streaming-pk',
      subTag: 'mixer',
    );

    final mixResult = await ZegoUIKit().startMixerTask(_task!);
    ZegoLoggerService.logInfo(
      'update mixer result:${mixResult.toStringX()}',
      tag: 'live-streaming-pk',
      subTag: 'mixer',
    );
    if (ZegoLiveStreamingErrorCode.success != mixResult.errorCode) {
      ZegoLoggerService.logError(
        'update mixer error: ${mixResult.errorCode}, ${mixResult.extendedData}',
        tag: 'live-streaming-pk',
        subTag: 'mixer',
      );

      return false;
    }

    return true;
  }

  Future<void> stopTask() async {
    if (null != _task) {
      await ZegoUIKit().stopMixerTask(_task!);
      _task = null;
    }
  }

  Future<bool> muteUserAudio({
    required List<String> targetHostIDs,
    required bool isMute,
    required List<ZegoLiveStreamingPKUser> pkHosts,
  }) async {
    if (!_init) {
      return false;
    }
    if (_isMuting) {
      return false;
    }

    _isMuting = true;

    if (isMute) {
      mutedUsersNotifier.value = [
        ...mutedUsersNotifier.value,
        ...targetHostIDs,
      ];
    } else {
      final currentMutedUsers = List<String>.from(mutedUsersNotifier.value);
      currentMutedUsers.removeWhere((userID) => targetHostIDs.contains(userID));
      mutedUsersNotifier.value = currentMutedUsers;
    }
    for (var hostID in targetHostIDs) {
      await ZegoUIKit().muteUserAudio(targetRoomID: _liveID, hostID, isMute);
    }

    await updateTask(pkHosts);

    _isMuting = false;

    return true;
  }

  Future<void> startPlayStream(
    List<ZegoLiveStreamingPKUser> pkHosts, {
    PlayerStateUpdateCallback? onPlayerStateUpdated,
  }) async {
    Map<String, int> userSoundIDs = {};
    for (int hostIndex = 0; hostIndex < pkHosts.length; ++hostIndex) {
      userSoundIDs[pkHosts[hostIndex].userInfo.id] = hostIndex;
    }
    await ZegoUIKit().startPlayMixAudioVideo(
      targetRoomID: _liveID,
      mixerID,
      pkHosts.map((e) => e.userInfo).toList(),
      userSoundIDs,
      onPlayerStateUpdated: onPlayerStateUpdated,
    );
  }

  Future<void> stopPlayStream() async {
    await ZegoUIKit().stopPlayMixAudioVideo(targetRoomID: _liveID, mixerID);
  }

  ZegoUIKitMixerTask _generateTask(
    List<ZegoLiveStreamingPKUser> hosts,
  ) {
    var mixerTask = ZegoUIKitMixerTask(mixerID)
      ..videoConfig.width = layout.getResolution().width.toInt()
      ..videoConfig.height = layout.getResolution().height.toInt()
      ..videoConfig.bitrate = 1500
      ..videoConfig.fps = 15
      ..enableSoundLevel = true
      ..outputList = [
        ZegoUIKitMixerOutput(mixerID),
      ];

    final rectList = layout.getRectList(
      hosts.length,
    );
    for (int hostIndex = 0; hostIndex < hosts.length; ++hostIndex) {
      final host = hosts.elementAt(hostIndex);
      final contentType = mutedUsersNotifier.value.contains(host.userInfo.id)
          ? ZegoUIKitMixerInputContentType.VideoOnly
          : ZegoUIKitMixerInputContentType.Video;
      var inputConfig = ZegoUIKitMixerInput.defaultConfig()
        ..streamID = host.streamID
        ..contentType = contentType
        ..volume = 100
        ..renderMode = ZegoUIKitMixRenderMode.Fill
        ..layout = rectList[hostIndex]
        ..soundLevelID = hostIndex;
      mixerTask.inputList.add(inputConfig);
    }

    return mixerTask;
  }
}
