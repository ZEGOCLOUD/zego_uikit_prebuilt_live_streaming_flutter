part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

mixin ZegoLiveStreamingControllerMinimizing {
  final _minimizingImpl = ZegoLiveStreamingControllerMinimizingImpl();

  ZegoLiveStreamingControllerMinimizingImpl get minimize => _minimizingImpl;
}

/// Here are the APIs related to screen sharing.
class ZegoLiveStreamingControllerMinimizingImpl
    with ZegoLiveStreamingControllerMinimizingPrivate {
  /// current minimize state
  ZegoLiveStreamingMiniOverlayPageState get state =>
      ZegoLiveStreamingMiniOverlayMachine().state;

  /// Is it currently in the minimized state or not
  bool get isMinimizing => ZegoLiveStreamingMiniOverlayMachine().isMinimizing;

  /// restore the [ZegoUIKitPrebuiltLiveStreaming] from minimize
  bool restore(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  }) {
    if (ZegoLiveStreamingMiniOverlayPageState.minimizing != state) {
      ZegoLoggerService.logInfo(
        'is not minimizing, ignore',
        tag: 'live-streaming',
        subTag: 'controller.minimize, restore',
      );

      return false;
    }

    final minimizeData = private.minimizeData;
    if (null == minimizeData) {
      ZegoLoggerService.logError(
        'prebuiltData is null',
        tag: 'live-streaming',
        subTag: 'controller.minimize, restore',
      );

      return false;
    }

    /// re-enter prebuilt live streaming
    ZegoLiveStreamingMiniOverlayMachine().changeState(
      ZegoLiveStreamingMiniOverlayPageState.living,
    );

    try {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(
        MaterialPageRoute(builder: (context) {
          final isSwiping = minimizeData.config.swiping != null;
          final prebuiltLiveStreaming = ZegoUIKitPrebuiltLiveStreaming(
            appID: minimizeData.appID,
            appSign: minimizeData.appSign,
            userID: minimizeData.userID,
            userName: minimizeData.userName,
            liveID: isSwiping
                ? ZegoLiveStreamingManagers().swipingCurrentLiveID
                : minimizeData.liveID,
            config: minimizeData.config,
            events: minimizeData.events,
          );
          return withSafeArea
              ? SafeArea(
                  child: prebuiltLiveStreaming,
                )
              : prebuiltLiveStreaming;
        }),
      );
    } catch (e) {
      ZegoLoggerService.logInfo(
        'restore from mini exception:$e',
        tag: 'live-streaming',
        subTag: 'controller.minimize, restore',
      );
    }

    return true;
  }

  /// To minimize the [ZegoUIKitPrebuiltLiveStreaming]
  bool minimize(
    BuildContext context, {
    bool rootNavigator = true,
  }) {
    if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logInfo(
        'is minimizing, ignore',
        tag: 'live-streaming',
        subTag: 'controller.minimize, minimize',
      );

      return false;
    }

    if (!private.isLiving) {
      ZegoLoggerService.logInfo(
        'is not living, ignore',
        tag: 'live-streaming',
        subTag: 'controller.minimize, minimize',
      );

      return false;
    }

    ZegoLiveStreamingMiniOverlayMachine().changeState(
      ZegoLiveStreamingMiniOverlayPageState.minimizing,
    );

    try {
      /// pop live streaming page
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pop();
    } catch (e) {
      ZegoLoggerService.logError(
        'navigator pop exception:$e',
        tag: 'live-streaming',
        subTag: 'controller.minimize, minimize',
      );

      return false;
    }

    return true;
  }

  /// if live streaming ended in minimizing state, not need to navigate, just
  /// hide the minimize widget.
  void hide() {
    ZegoLiveStreamingMiniOverlayMachine().changeState(
      ZegoLiveStreamingMiniOverlayPageState.idle,
    );
  }
}
