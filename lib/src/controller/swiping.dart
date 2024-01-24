part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerSwiping {
  final _swipingImpl = LiveStreamingControllerSwipingImpl();

  LiveStreamingControllerSwipingImpl get swiping => _swipingImpl;
}

/// Here are the APIs related to swiping
class LiveStreamingControllerSwipingImpl
    with ZegoLiveStreamingControllerSwipingPrivate {
  /// swiping to previous live streaming which query from [ZegoLiveStreamingSwipingConfig.requirePreviousLiveID]
  bool previous() {
    final targetLiveID = private.config?.requirePreviousLiveID.call();
    if (targetLiveID?.isEmpty ?? false) {
      ZegoLoggerService.logInfo(
        'previous, live id is empty, '
        'please check ZegoLiveStreamingSwipingConfig.requirePreviousLiveID, '
        'you can refer to https://docs.zegocloud.com/article/16478',
        tag: 'live streaming',
        subTag: 'controller.swiping',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'previous',
      tag: 'live streaming',
      subTag: 'controller.swiping',
    );

    private.stream?.add(targetLiveID!);

    return true;
  }

  /// swiping to next live streaming which query from [ZegoLiveStreamingSwipingConfig.requireNextLiveID]
  bool next() {
    final targetLiveID = private.config?.requireNextLiveID.call();
    if (targetLiveID?.isEmpty ?? false) {
      ZegoLoggerService.logInfo(
        'next, live id is empty, '
        'please check ZegoLiveStreamingSwipingConfig.requirePreviousLiveID, '
        'you can refer to https://docs.zegocloud.com/article/16478',
        tag: 'live streaming',
        subTag: 'controller.swiping',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'next',
      tag: 'live streaming',
      subTag: 'controller.swiping',
    );

    private.stream?.add(targetLiveID!);

    return true;
  }

  /// swiping to live streaming of [targetLiveID]
  bool jumpTo(String targetLiveID) {
    if (targetLiveID.isEmpty) {
      ZegoLoggerService.logInfo(
        'jump to, live id is empty',
        tag: 'live streaming',
        subTag: 'controller.swiping',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'jump to $targetLiveID',
      tag: 'live streaming',
      subTag: 'controller.swiping',
    );

    private.stream?.add(targetLiveID);

    return true;
  }
}
