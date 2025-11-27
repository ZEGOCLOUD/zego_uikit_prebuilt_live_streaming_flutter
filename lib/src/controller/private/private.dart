part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerPrivate {
  final _impl = ZegoLiveStreamingControllerPrivateImpl();

  /// Don't call that
  ZegoLiveStreamingControllerPrivateImpl get private => _impl;
}

/// @nodoc
class ZegoLiveStreamingControllerPrivateImpl {
  String _liveID = '';

  String get liveID {
    assert(_liveID.isNotEmpty);
    return _liveID;
  }

  set liveID(String value) {
    ZegoLoggerService.logInfo(
      'update live id from $_liveID to $value, ',
      tag: 'live-streaming',
      subTag: 'controller.p',
    );

    _liveID = value;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt

  void initByPrebuilt({
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
    required ZegoLiveStreamingMinimizeData minimizeData,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt, '
      'live id: $liveID, ',
      tag: 'live-streaming',
      subTag: 'controller.p',
    );

    ZegoUIKitPrebuiltLiveStreamingController().pk.private.initByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController()
        .room
        .private
        .initByPrebuilt(config: config, events: events);
    ZegoUIKitPrebuiltLiveStreamingController()
        .user
        .private
        .initByPrebuilt(config: config);
    ZegoUIKitPrebuiltLiveStreamingController()
        .message
        .private
        .initByPrebuilt(liveID: liveID, config: config);
    ZegoUIKitPrebuiltLiveStreamingController()
        .media
        .private
        .initByPrebuilt(config: config);
    ZegoUIKitPrebuiltLiveStreamingController()
        .coHost
        .private
        .initByPrebuilt(configs: config, events: events);
    ZegoUIKitPrebuiltLiveStreamingController()
        .audioVideo
        .private
        .initByPrebuilt(config: config);
    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .initByPrebuilt(minimizeData: minimizeData, config: config);
    ZegoUIKitPrebuiltLiveStreamingController()
        .pip
        .private
        .initByPrebuilt(config: config);
    ZegoUIKitPrebuiltLiveStreamingController()
        .screenSharing
        .private
        .initByPrebuilt(config: config);
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  /// DO NOT CALL!!!
  /// Call Inside By Prebuilt
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'uninit by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.p',
    );

    ZegoUIKitPrebuiltLiveStreamingController().pk.private.uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController().room.private.uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController().user.private.uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController()
        .message
        .private
        .uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController().media.private.uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController()
        .coHost
        .private
        .uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController()
        .audioVideo
        .private
        .uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .private
        .uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController().pip.private.uninitByPrebuilt();
    ZegoUIKitPrebuiltLiveStreamingController()
        .screenSharing
        .private
        .uninitByPrebuilt();

    _liveID = '';
  }
}
