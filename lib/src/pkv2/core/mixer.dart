// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pkv2/layout/layout.dart';

class ZegoUIKitPrebuiltLiveStreamingPKServiceMixer {
  ZegoUIKitPrebuiltLiveStreamingPKServiceMixer();

  ZegoMixerTask? _task;
  String _mixerID = '';
  bool _init = false;

  /// is execute mute api
  bool _isMuting = false;

  /// host is muted or not
  var mutedUsersNotifier = ValueNotifier<List<String>>([]);

  ZegoPKV2MixerLayout? _layout;

  String get mixerID => _mixerID;

  ZegoPKV2MixerLayout get layout => _layout ?? ZegoPKV2MixerDefaultLayout();

  bool isMuted(String targetHostID) =>
      mutedUsersNotifier.value.contains(targetHostID);

  void init({
    required ZegoPKV2MixerLayout? layout,
  }) async {
    if (_init) {
      return;
    }

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'pk mixer',
    );

    _init = true;

    _layout = layout;

    if (ZegoUIKit().getRoomStateStream().value.reason !=
        ZegoRoomStateChangedReason.Logined) {
      ZegoUIKit().getRoomStateStream().addListener(_onRoomStateChanged);
    } else {
      _mixerID = '${ZegoUIKit().getRoom().id}__mix';
    }
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'pk mixer',
    );

    await stopTask();
    await stopPlayStream();

    _isMuting = false;
    mutedUsersNotifier.value.clear();
    _mixerID = '';
    ZegoUIKit().getRoomStateStream().removeListener(_onRoomStateChanged);

    _init = false;

    ZegoLoggerService.logInfo(
      'uninit done',
      tag: 'live streaming',
      subTag: 'pk mixer',
    );
  }

  Future<bool> updateTask(
    List<ZegoUIKitPrebuiltLiveStreamingPKUser> pkHosts,
  ) async {
    if (!_init) {
      ZegoLoggerService.logInfo(
        'update mixer, but not init',
        tag: 'live streaming',
        subTag: 'pk mixer',
      );

      return false;
    }
    if (_mixerID.isEmpty) {
      ZegoLoggerService.logInfo(
        'update mixer, but mixer stream id is empty',
        tag: 'live streaming',
        subTag: 'pk mixer',
      );

      return false;
    }

    _task = _generateTask(pkHosts);

    ZegoLoggerService.logInfo(
      'update mixer, '
      'users:${pkHosts.toSimpleString}, '
      'mutedHosts:${mutedUsersNotifier.value}, '
      'task:${_task?.toStringX()}',
      tag: 'live streaming',
      subTag: 'pk mixer',
    );

    final mixResult = await ZegoUIKit().startMixerTask(_task!);
    ZegoLoggerService.logInfo(
      'update mixer result:${mixResult.toStringX()}',
      tag: 'live streaming',
      subTag: 'pk mixer',
    );
    if (ZegoErrorCode.CommonSuccess != mixResult.errorCode) {
      ZegoLoggerService.logInfo(
        'update mixer error: ${mixResult.errorCode}, ${mixResult.extendedData}',
        tag: 'live streaming',
        subTag: 'pk mixer',
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
    required List<ZegoUIKitPrebuiltLiveStreamingPKUser> pkHosts,
  }) async {
    if (!_init) {
      return false;
    }
    if (_isMuting) {
      return false;
    }

    _isMuting = true;

    if (isMute) {
      mutedUsersNotifier.value.addAll(targetHostIDs);
    } else {
      mutedUsersNotifier.value
          .removeWhere((userID) => targetHostIDs.contains(userID));
    }
    for (var hostID in targetHostIDs) {
      await ZegoUIKit().muteUserAudio(hostID, isMute);
    }

    await updateTask(pkHosts);

    _isMuting = false;

    return true;
  }

  Future<void> startPlayStream(
    List<ZegoUIKitPrebuiltLiveStreamingPKUser> pkHosts,
  ) async {
    Map<String, int> userSoundIDs = {};
    for (int hostIndex = 0; hostIndex < pkHosts.length; ++hostIndex) {
      userSoundIDs[pkHosts[hostIndex].userInfo.id] = hostIndex;
    }
    await ZegoUIKit().startPlayMixAudioVideo(
      mixerID,
      pkHosts.map((e) => e.userInfo).toList(),
      userSoundIDs,
    );
  }

  Future<void> stopPlayStream() async {
    await ZegoUIKit().stopPlayMixAudioVideo(mixerID);
  }

  ZegoMixerTask _generateTask(
    List<ZegoUIKitPrebuiltLiveStreamingPKUser> hosts,
  ) {
    var mixerTask = ZegoMixerTask(mixerID)
      ..videoConfig.width = layout.getResolution().width.toInt()
      ..videoConfig.height = layout.getResolution().height.toInt()
      ..videoConfig.bitrate = 1500
      ..videoConfig.fps = 15
      ..enableSoundLevel = true
      ..outputList = [
        ZegoMixerOutput(mixerID),
      ];

    final rectList = layout.getRectList(
      hosts.length,
    );
    for (int hostIndex = 0; hostIndex < hosts.length; ++hostIndex) {
      final host = hosts.elementAt(hostIndex);
      final contentType = mutedUsersNotifier.value.contains(host.userInfo.id)
          ? ZegoMixerInputContentType.VideoOnly
          : ZegoMixerInputContentType.Video;
      var inputConfig = ZegoMixerInput.defaultConfig()
        ..streamID = host.streamID
        ..contentType = contentType
        ..volume = 100
        ..renderMode = ZegoMixRenderMode.Fill
        ..layout = rectList[hostIndex]
        ..soundLevelID = hostIndex;
      mixerTask.inputList.add(inputConfig);
    }

    return mixerTask;
  }

  void _onRoomStateChanged() {
    if (ZegoUIKit().getRoomStateStream().value.reason !=
        ZegoRoomStateChangedReason.Logined) {
      return;
    }

    ZegoUIKit().getRoomStateStream().removeListener(_onRoomStateChanged);

    _mixerID = '${ZegoUIKit().getRoom().id}__mix';
  }
}
