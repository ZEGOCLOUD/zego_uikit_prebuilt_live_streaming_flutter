// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/error.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/pk/layout/layout.dart';

import 'defines.dart';

class ZegoUIKitPrebuiltLiveStreamingPKServiceMixer {
  bool _init = false;

  ZegoUIKitMixerTask? _task;
  String _mixerStreamID = '';

  String _liveID = '';
  ZegoUIKitPrebuiltLiveStreamingConfig? _prebuiltConfig;

  /// is execute mute api
  bool _isMuting = false;

  /// host is muted or not
  var mutedUsersNotifier = ValueNotifier<List<String>>([]);

  List<ZegoLiveStreamingPKUser> _currentPKHosts = [];

  ZegoLiveStreamingPKMixerLayout? _layout;

  String get mixerStreamID => _mixerStreamID;

  ZegoLiveStreamingPKMixerLayout get layout =>
      _layout ?? ZegoLiveStreamingPKMixerDefaultLayout();

  bool isMuted(String targetHostID) =>
      mutedUsersNotifier.value.contains(targetHostID);

  void init({
    required String liveID,
    required ZegoUIKitPrebuiltLiveStreamingConfig? prebuiltConfig,
    required ZegoLiveStreamingPKMixerLayout? layout,
  }) async {
    if (_init) {
      return;
    }

    _currentPKHosts.clear();

    ZegoLoggerService.logInfo(
      'live id:$liveID, '
      'useVideoViewAspectFill:${prebuiltConfig?.audioVideoView.useVideoViewAspectFill}, '
      'layout:${layout.runtimeType}, ',
      tag: 'live.streaming.pk.mixer',
      subTag: 'init',
    );

    _init = true;
    _layout = layout;

    _liveID = liveID;
    _prebuiltConfig = prebuiltConfig;

    updateStreamID();
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.pk.mixer',
      subTag: 'uninit',
    );

    await stopTask();
    await stopPlayStream();

    mutedUsersNotifier.value = [];

    _isMuting = false;
    _mixerStreamID = '';

    _init = false;
    _liveID = '';
    _prebuiltConfig = null;

    ZegoLoggerService.logInfo(
      'done',
      tag: 'live.streaming.pk.mixer',
      subTag: 'uninit',
    );
  }

  void updateStreamID() {
    final hostID = ZegoLiveStreamingPageLifeCycle()
            .currentManagers
            .hostManager
            .notifier
            .value
            ?.id ??
        '';
    if (hostID.isNotEmpty) {
      _mixerStreamID = generateStreamID(hostID, _liveID, ZegoStreamType.mix);
      ZegoLoggerService.logInfo(
        'stream id:$_mixerStreamID, ',
        tag: 'live.streaming.pk.mixer',
        subTag: 'update stream id',
      );
    } else {
      ZegoLiveStreamingPageLifeCycle()
          .currentManagers
          .hostManager
          .notifier
          .addListener(onMixerStreamIDUpdateWhenHostUpdated);
    }
  }

  Future<bool> updateTask(
    List<ZegoLiveStreamingPKUser> pkHosts, {
    bool force = false,
  }) async {
    if (!_init) {
      ZegoLoggerService.logInfo(
        'not init',
        tag: 'live.streaming.pk.mixer',
        subTag: 'update mixer',
      );

      return false;
    }
    if (_mixerStreamID.isEmpty) {
      ZegoLoggerService.logInfo(
        'mixer stream id is empty',
        tag: 'live.streaming.pk.mixer',
        subTag: 'update mixer',
      );

      return false;
    }

    if (!force) {
      var isSame = false;
      if (_currentPKHosts.length == pkHosts.length) {
        isSame = true;
        for (var i = 0; i < _currentPKHosts.length; i++) {
          if (_currentPKHosts[i].userInfo.id != pkHosts[i].userInfo.id ||
              _currentPKHosts[i].liveID != pkHosts[i].liveID) {
            isSame = false;
            break;
          }
        }
      }
      if (isSame) {
        ZegoLoggerService.logInfo(
          'hosts is same, '
          'currentHosts:$_currentPKHosts, '
          'newHosts:$pkHosts',
          tag: 'live.streaming.pk.mixer',
          subTag: 'update mixer',
        );
        return true;
      }
    }

    _currentPKHosts = List.from(pkHosts);

    _task = _generateTask(pkHosts);

    ZegoLoggerService.logInfo(
      'users:$pkHosts, '
      'mutedHosts:${mutedUsersNotifier.value}, '
      'task:${_task?.toStringX()}',
      tag: 'live.streaming.pk.mixer',
      subTag: 'update mixer',
    );

    final mixResult = await ZegoUIKit().startMixerTask(_task!);
    ZegoLoggerService.logInfo(
      'update mixer result:${mixResult.toStringX()}',
      tag: 'live.streaming.pk.mixer',
      subTag: 'update mixer',
    );
    if (ZegoLiveStreamingErrorCode.success != mixResult.errorCode) {
      ZegoLoggerService.logError(
        'update mixer error: ${mixResult.errorCode}, ${mixResult.extendedData}',
        tag: 'live.streaming.pk.mixer',
        subTag: 'update mixer',
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

    _currentPKHosts.clear();
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

    await updateTask(pkHosts, force: true);

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
      mixerStreamID,
      pkHosts.map((e) => e.userInfo).toList(),
      userSoundIDs,
      onPlayerStateUpdated: onPlayerStateUpdated,
    );
  }

  Future<void> stopPlayStream() async {
    await ZegoUIKit()
        .stopPlayMixAudioVideo(targetRoomID: _liveID, mixerStreamID);
  }

  ZegoUIKitMixerTask _generateTask(
    List<ZegoLiveStreamingPKUser> hosts,
  ) {
    /// Output to the ZEGO server (stream ID is mixerStreamID),
    /// and pull by specifying this stream name
    var mixerTask = ZegoUIKitMixerTask(mixerStreamID)
      ..videoConfig.width = layout.getResolution().width.toInt()
      ..videoConfig.height = layout.getResolution().height.toInt()
      ..videoConfig.bitrate = 1500
      ..videoConfig.fps = 15
      ..enableSoundLevel = true
      ..outputList = [
        ZegoUIKitMixerOutput(mixerStreamID),
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
        ..renderMode =
            (_prebuiltConfig?.audioVideoView.useVideoViewAspectFill ?? true)
                ? ZegoUIKitMixRenderMode.Fill
                : ZegoUIKitMixRenderMode.Fit
        ..layout = rectList[hostIndex]
        ..soundLevelID = hostIndex;
      mixerTask.inputList.add(inputConfig);
    }

    return mixerTask;
  }

  void onMixerStreamIDUpdateWhenHostUpdated() {
    ZegoLiveStreamingPageLifeCycle()
        .currentManagers
        .hostManager
        .notifier
        .removeListener(onMixerStreamIDUpdateWhenHostUpdated);

    updateStreamID();
  }
}
