part of 'package:zego_uikit_prebuilt_live_streaming/src/controller.dart';

/// @nodoc
mixin ZegoLiveStreamingControllerScreen {
  final _screenController = ZegoLiveStreamingScreenController();

  ZegoLiveStreamingScreenController get screen => _screenController;
}

/// Here are the APIs related to screen sharing.
class ZegoLiveStreamingScreenController {
  final screenSharingViewController = ZegoScreenSharingViewController();

  /// This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
  ///
  /// You need to provide the user's ID [userID] to determine which user to perform the operation on.
  /// By using a boolean value [isFullscreen], you can specify whether the user enters or exits full-screen mode.
  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screenSharingViewController.showScreenSharingViewInFullscreenMode(
        userID, isFullscreen);
  }
}
