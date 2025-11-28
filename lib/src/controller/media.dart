part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerMedia {
  final ZegoLiveStreamingControllerMediaImpl _mediaController =
      ZegoLiveStreamingControllerMediaImpl();

  ZegoLiveStreamingControllerMediaImpl get media => _mediaController;
}

/// media series API
class ZegoLiveStreamingControllerMediaImpl
    with ZegoLiveStreamingControllerMediaPrivate {
  ZegoLiveStreamingControllerMediaDefaultPlayer get defaultPlayer =>
      private.defaultPlayer;

  /// volume of current media
  int get volume => ZegoUIKit().getMediaVolume();

  /// the total progress(millisecond) of current media resources
  int get totalDuration => ZegoUIKit().getMediaTotalDuration();

  /// current playing progress of current media
  int get currentProgress => ZegoUIKit().getMediaCurrentProgress();

  /// media type  of current media
  ZegoUIKitMediaType get type => ZegoUIKit().getMediaType();

  /// volume notifier of current media
  ValueNotifier<int> get volumeNotifier => ZegoUIKit().getMediaVolumeNotifier();

  /// current progress notifier of current media
  ValueNotifier<int> get currentProgressNotifier =>
      ZegoUIKit().getMediaCurrentProgressNotifier();

  /// play state notifier of current media
  ValueNotifier<ZegoUIKitMediaPlayState> get playStateNotifier =>
      ZegoUIKit().getMediaPlayStateNotifier();

  /// type notifier of current media
  ValueNotifier<ZegoUIKitMediaType> get typeNotifier =>
      ZegoUIKit().getMediaTypeNotifier();

  /// mute state notifier of current media
  ValueNotifier<bool> get muteNotifier => ZegoUIKit().getMediaMuteNotifier();

  /// info of current media
  ZegoUIKitMediaInfo get info => ZegoUIKit().getMediaInfo();

  /// start play current media
  Future<ZegoUIKitMediaPlayResult> play({
    required String filePathOrURL,
    bool enableRepeat = false,
    bool autoStart = true,
  }) async {
    ZegoLoggerService.logInfo(
      'play, '
      'filePathOrURL:$filePathOrURL, '
      'enableRepeat:$enableRepeat, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().playMedia(
      filePathOrURL: filePathOrURL,
      enableRepeat: enableRepeat,
      autoStart: autoStart,
    );
  }

  /// stop play current media
  Future<void> stop() async {
    ZegoLoggerService.logInfo(
      'stop, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().stopMedia();
  }

  /// destroy current media
  Future<void> destroy() async {
    ZegoLoggerService.logInfo(
      'destroy, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().destroyMedia();
  }

  /// pause current media
  Future<void> pause() async {
    ZegoLoggerService.logInfo(
      'pause, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().pauseMedia();
  }

  /// resume current media
  Future<void> resume() async {
    ZegoLoggerService.logInfo(
      'resume, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().resumeMedia();
  }

  /// set the current media playback progress
  /// - [millisecond] Point in time of specified playback progress
  Future<ZegoUIKitMediaSeekToResult> seekTo(int millisecond) async {
    ZegoLoggerService.logInfo(
      'seekTo, '
      'millisecond:$millisecond, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().seekTo(millisecond);
  }

  /// Set media player volume. Both the local play volume and the publish volume are set.
  ///
  /// set [isSyncToRemote] to be true if you want to sync both the local play volume
  /// and the publish volume, if [isSyncToRemote] is false, that will only adjust the
  /// local play volume.
  ///
  /// - [volume] The range is 0 ~ 100. The default is 30.
  Future<void> setVolume(
    int volume, {
    bool isSyncToRemote = false,
  }) async {
    ZegoLoggerService.logInfo(
      'setVolume, '
      'volume:$volume, '
      'isSyncToRemote:$isSyncToRemote, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().setMediaVolume(
      volume,
      isSyncToRemote: isSyncToRemote,
    );
  }

  /// mute current media
  Future<void> muteLocal(bool mute) async {
    ZegoLoggerService.logInfo(
      'muteLocal, '
      'mute:$mute, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().muteMediaLocal(mute);
  }

  /// pick pure audio media file
  Future<List<ZegoUIKitPlatformFile>> pickPureAudioFile() async {
    ZegoLoggerService.logInfo(
      'pickPureAudioFile, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().pickPureAudioMediaFile();
  }

  /// pick video media file
  Future<List<ZegoUIKitPlatformFile>> pickVideoFile() async {
    ZegoLoggerService.logInfo(
      'pickVideoFile, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().pickVideoMediaFile();
  }

  /// If you want to specify the allowed formats, you can set them using [allowedExtensions].
  /// Currently, for video, we support "avi", "flv", "mkv", "mov", "mp4", "mpeg", "webm", "wmv".
  /// For audio, we support "aac", "midi", "mp3", "ogg", "wav".
  Future<List<ZegoUIKitPlatformFile>> pickFile(
      {List<String>? allowedExtensions}) async {
    ZegoLoggerService.logInfo(
      'pickFile, '
      'allowedExtensions:$allowedExtensions, ',
      tag: 'live.streaming.controller.media',
      subTag: 'controller.media',
    );

    return ZegoUIKit().pickMediaFile(
      allowedExtensions: allowedExtensions,
    );
  }
}
