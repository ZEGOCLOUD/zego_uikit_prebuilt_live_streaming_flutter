// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/modules/minimization/overlay_machine.dart';

/// @nodoc
class ZegoLiveStreamingPlugins {
  ZegoLiveStreamingPlugins({
    this.onPluginReLogin,
  });

  int appID = -1;
  String appSign = '';
  String token = '';
  String userID = '';
  String userName = '';
  String liveID = '';
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  ZegoUIKitPrebuiltLiveStreamingEvents? events;

  final VoidCallback? onPluginReLogin;
  ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed;

  List<StreamSubscription<dynamic>?> subscriptions = [];
  ValueNotifier<ZegoSignalingPluginConnectionState> pluginUserStateNotifier =
      ValueNotifier<ZegoSignalingPluginConnectionState>(
          ZegoSignalingPluginConnectionState.disconnected);
  ValueNotifier<ZegoSignalingPluginRoomState> roomStateNotifier =
      ValueNotifier<ZegoSignalingPluginRoomState>(
          ZegoSignalingPluginRoomState.disconnected);
  bool tryReLogging = false;
  bool initialized = false;
  bool roomHasInitLogin = false;

  bool get isEnabled => config?.plugins.isNotEmpty ?? false;

  Future<void> init({
    required int appID,
    required String appSign,
    required String token,
    required String userID,
    required String userName,
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
    ZegoLiveStreamingLoginFailedEvent? onRoomLoginFailed,
  }) async {
    if (initialized) {
      ZegoLoggerService.logInfo(
        'had init',
        tag: 'live.streaming.plugin',
        subTag: 'init',
      );

      return;
    }

    initialized = true;

    this.appID = appID;
    this.appSign = appSign;
    this.token = token;
    this.userID = userID;
    this.userName = userName;
    this.config = config;
    this.events = events;
    this.onRoomLoginFailed = onRoomLoginFailed;

    pluginUserStateNotifier.value =
        ZegoUIKit().getSignalingPlugin().getConnectionState();
    roomStateNotifier.value = ZegoUIKit().getSignalingPlugin().getRoomState();

    ZegoLoggerService.logInfo(
      'user state:${pluginUserStateNotifier.value}, '
      'room state:${roomStateNotifier.value}',
      tag: 'live.streaming.plugin',
      subTag: 'init',
    );

    _install(plugins: config.plugins);

    await ZegoUIKit()
        .getSignalingPlugin()
        .init(appID, appSign: appSign)
        .then((value) {
      ZegoLoggerService.logInfo(
        'signaling plugin init done',
        tag: 'live.streaming.plugin',
        subTag: 'init',
      );
    });

    subscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getConnectionStateStream()
          .listen(_onUserConnectionState))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getRoomStateStream()
          .listen(_onRoomState));

    await _initAdvanceEffectsPlugins();

    await ZegoUIKit()
        .getSignalingPlugin()
        .login(
          id: userID,
          name: userName,
          token: token,
        )
        .then((result) {
      ZegoLoggerService.logInfo(
        'login done, login result:$result',
        tag: 'live.streaming.plugin',
        subTag: 'init',
      );
    });

    ZegoLoggerService.logInfo(
      'done',
      tag: 'live.streaming.plugin',
      subTag: 'init',
    );
  }

  Future<void> uninit() async {
    if (!initialized) {
      ZegoLoggerService.logInfo(
        'is not init before',
        tag: 'live.streaming.plugin',
        subTag: 'uninit',
      );
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live.streaming.plugin',
      subTag: 'uninit',
    );
    initialized = false;

    roomHasInitLogin = false;
    tryReLogging = false;

    if (ZegoLiveStreamingMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logInfo(
        'to minimizing, not need to leave room, logout and uninit',
        tag: 'live.streaming.plugin',
        subTag: 'uninit',
      );
    } else {
      /// todo
      if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) !=
          null) {
        if (config?.signalingPlugin.leaveRoomOnDispose ?? true) {
          await ZegoUIKit().getSignalingPlugin().leaveRoom();
        }

        /// not need logout
        // await ZegoUIKit().getSignalingPlugin().logout();
        /// not need destroy signaling sdk
        ///
        if (config?.signalingPlugin.uninitOnDispose ?? true) {
          await ZegoUIKit().getSignalingPlugin().uninit(forceDestroy: false);

          ZegoUIKit().uninstallPlugins(
            config?.plugins
                    .where((e) =>
                        e.getPluginType() == ZegoUIKitPluginType.signaling)
                    .toList() ??
                [],
          );
        }
      }
    }

    /// todo
    _uninitAdvanceEffectsPlugins();

    for (final streamSubscription in subscriptions) {
      streamSubscription?.cancel();
    }
  }

  Future<bool> joinRoom({required String liveID}) async {
    this.liveID = liveID;

    ZegoLoggerService.logInfo(
      'live id:$liveID, ',
      tag: 'live.streaming.plugin',
      subTag: 'joinRoom',
    );

    return ZegoUIKit().getSignalingPlugin().joinRoom(liveID).then((result) {
      if (result.error != null) {
        onRoomLoginFailed?.call(-1, result.error.toString());
        roomHasInitLogin = false;

        ZegoLoggerService.logInfo(
          'failed: ${result.error}',
          tag: 'live.streaming.plugin',
          subTag: 'joinRoom',
        );
      } else {
        roomHasInitLogin = true;

        ZegoLoggerService.logInfo(
          'success',
          tag: 'live.streaming.plugin',
          subTag: 'plugin',
        );
      }

      return result.error == null;
    });
  }

  Future<bool> switchRoom({required String targetLiveID}) async {
    ZegoLoggerService.logInfo(
      'current live id:$liveID, '
      'target live id:$targetLiveID, ',
      tag: 'live.streaming.plugin',
      subTag: 'switchRoom',
    );

    final previousLiveID = liveID;
    liveID = targetLiveID;
    return ZegoUIKit().getSignalingPlugin().switchRoom(liveID).then((result) {
      if (result.error != null) {
        liveID = previousLiveID;

        ZegoLoggerService.logInfo(
          'failed: ${result.error}, '
          'restore to $previousLiveID, ',
          tag: 'live.streaming.plugin',
          subTag: 'switchRoom',
        );
      } else {
        ZegoLoggerService.logInfo(
          'success',
          tag: 'live.streaming.plugin',
          subTag: 'switchRoom',
        );
      }

      return result.error == null;
    });
  }

  void _install({
    required List<IZegoUIKitPlugin> plugins,
  }) {
    ZegoLoggerService.logInfo(
      'plugins:$plugins',
      tag: 'live.streaming.plugin',
      subTag: 'install',
    );

    ZegoUIKit().installPlugins(plugins);

    for (final pluginType in ZegoUIKitPluginType.values) {
      ZegoUIKit().getPlugin(pluginType)?.getVersion().then((version) {
        ZegoLoggerService.logInfo(
          'plugin-$pluginType version: $version installed',
          tag: 'live.streaming.plugin',
          subTag: 'install',
        );
      });
    }

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) != null) {
      subscriptions.add(ZegoUIKit()
          .getSignalingPlugin()
          .getErrorStream()
          .listen(_onSignalingError));
    }

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      subscriptions
        ..add(ZegoUIKit()
            .getBeautyPlugin()
            .getErrorStream()
            .listen(_onBeautyError))
        ..add(ZegoUIKit()
            .getBeautyPlugin()
            .getFaceDetectionEventStream()
            .listen(_onFaceDetectionEvent));

      ZegoUIKit().enableCustomVideoProcessing(true);
    }
  }

  Future<void> _initAdvanceEffectsPlugins() async {
    final useAdvanceEffect =
        ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null;

    if (!useAdvanceEffect) {
      return;
    }

    ZegoUIKit()
        .getBeautyPlugin()
        .setConfig(config?.beauty ?? ZegoBeautyPluginConfig());
    await ZegoUIKit().getBeautyPlugin().init(appID, appSign).then((value) {
      ZegoLoggerService.logInfo(
        'effects plugin init done',
        tag: 'live.streaming.plugin',
        subTag: 'initAdvanceEffectsPlugins',
      );
    });
  }

  Future<void> _uninitAdvanceEffectsPlugins() async {
    ZegoLoggerService.logInfo(
      'effects plugin uninit',
      tag: 'live.streaming.plugin',
      subTag: 'uninitAdvanceEffectsPlugins',
    );

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      await ZegoUIKit().getBeautyPlugin().uninit();
    }

    ZegoUIKit().uninstallPlugins(
      config?.plugins
              .where((e) => e.getPluginType() == ZegoUIKitPluginType.beauty)
              .toList() ??
          [],
    );
  }

  Future<void> _onUserInfoUpdate(String userID, String userName) async {
    final localUser = ZegoUIKit().getLocalUser();

    ZegoLoggerService.logInfo(
      'target user($userID, $userName), '
      'local user:($localUser) '
      'initialized:$initialized, '
      'user state:${pluginUserStateNotifier.value}'
      'room state:${roomStateNotifier.value}',
      tag: 'live.streaming.plugin',
      subTag: 'onUserInfoUpdate',
    );

    if (!initialized) {
      ZegoLoggerService.logInfo(
        'plugin is not init',
        tag: 'live.streaming.plugin',
        subTag: 'onUserInfoUpdate',
      );
      return;
    }

    if (pluginUserStateNotifier.value !=
        ZegoSignalingPluginConnectionState.connected) {
      ZegoLoggerService.logInfo(
        'user state is not connected',
        tag: 'live.streaming.plugin',
        subTag: 'onUserInfoUpdate',
      );
      return;
    }

    if (ZegoSignalingPluginRoomState.connected != roomStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'room state is not connected',
        tag: 'live.streaming.plugin',
        subTag: 'onUserInfoUpdate',
      );
      return;
    }

    if (localUser.id == userID && localUser.name == userName) {
      ZegoLoggerService.logInfo(
        'same user, cancel this re-login',
        tag: 'live.streaming.plugin',
        subTag: 'onUserInfoUpdate',
      );
      return;
    }

    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().login(
          id: userID,
          name: userName,
          token: token,
        );
  }

  void _onUserConnectionState(
      ZegoSignalingPluginConnectionStateChangedEvent event) {
    ZegoLoggerService.logInfo(
      'param: $event',
      tag: 'live.streaming.plugin',
      subTag: 'onUserConnectionState',
    );

    pluginUserStateNotifier.value = event.state;

    ZegoLoggerService.logInfo(
      'user state: ${pluginUserStateNotifier.value}',
      tag: 'live.streaming.plugin',
      subTag: 'onUserConnectionState',
    );

    if (tryReLogging &&
        pluginUserStateNotifier.value ==
            ZegoSignalingPluginConnectionState.connected) {
      tryReLogging = false;
      onPluginReLogin?.call();
    }

    _tryReEnterRoom();
  }

  void _onRoomState(ZegoSignalingPluginRoomStateChangedEvent event) {
    ZegoLoggerService.logInfo(
      'event: $event',
      tag: 'live.streaming.plugin',
      subTag: 'onRoomState',
    );

    roomStateNotifier.value = event.state;

    ZegoLoggerService.logInfo(
      'state: ${roomStateNotifier.value}, '
      'networkState:${ZegoUIKit().getNetworkModeStream()}',
      tag: 'live.streaming.plugin',
      subTag: 'onRoomState',
    );

    _tryReEnterRoom();
  }

  void _onSignalingError(ZegoSignalingError error) {
    ZegoLoggerService.logError(
      'error:$error',
      tag: 'live.streaming.plugin',
      subTag: 'onSignalingError',
    );

    events?.onError?.call(ZegoUIKitError(
      code: error.code,
      message: error.message,
      method: error.method,
    ));
  }

  void _onFaceDetectionEvent(ZegoBeautyPluginFaceDetectionData data) {
    events?.beauty.onFaceDetection?.call(data);
  }

  void _onBeautyError(ZegoBeautyError error) {
    ZegoLoggerService.logError(
      'error:$error',
      tag: 'live.streaming.plugin',
      subTag: 'onBeautyError',
    );

    events?.beauty.onError?.call(error);
  }

  Future<void> tryReLogin() async {
    ZegoLoggerService.logInfo(
      'state:${pluginUserStateNotifier.value}',
      tag: 'live.streaming.plugin',
      subTag: 'tryReLogin',
    );

    if (!initialized) {
      ZegoLoggerService.logInfo(
        'plugin is not init',
        tag: 'live.streaming.plugin',
        subTag: 'tryReLogin',
      );
      return;
    }

    if (pluginUserStateNotifier.value !=
        ZegoSignalingPluginConnectionState.disconnected) {
      ZegoLoggerService.logInfo(
        'user state is not disconnected',
        tag: 'live.streaming.plugin',
        subTag: 'tryReLogin',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      're-login, id:$userID, name:$userName',
      tag: 'live.streaming.plugin',
      subTag: 'tryReLogin',
    );
    tryReLogging = true;
    return ZegoUIKit().getSignalingPlugin().logout().then((value) async {
      await ZegoUIKit().getSignalingPlugin().login(
            id: userID,
            name: userName,
            token: token,
          );
    });
  }

  Future<bool> _tryReEnterRoom() async {
    ZegoLoggerService.logInfo(
      'room state: ${roomStateNotifier.value}, '
      'networkState:${ZegoUIKit().getNetworkState()}',
      tag: 'live.streaming.plugin',
      subTag: 'tryReEnterRoom',
    );

    if (!initialized) {
      ZegoLoggerService.logInfo(
        'plugin is not init',
        tag: 'live.streaming.plugin',
        subTag: 'tryReEnterRoom',
      );
      return false;
    }
    if (!roomHasInitLogin) {
      ZegoLoggerService.logInfo(
        'first login room has not finished',
        tag: 'live.streaming.plugin',
        subTag: 'tryReEnterRoom',
      );
      return false;
    }

    if (ZegoSignalingPluginRoomState.disconnected != roomStateNotifier.value) {
      ZegoLoggerService.logInfo(
        'room state is not disconnected',
        tag: 'live.streaming.plugin',
        subTag: 'tryReEnterRoom',
      );
      return false;
    }

    if (ZegoUIKit().getNetworkState() != ZegoUIKitNetworkState.online) {
      ZegoLoggerService.logInfo(
        'network is not connected',
        tag: 'live.streaming.plugin',
        subTag: 'tryReEnterRoom',
      );
      return false;
    }

    if (pluginUserStateNotifier.value !=
        ZegoSignalingPluginConnectionState.connected) {
      ZegoLoggerService.logInfo(
        'user state is not connected',
        tag: 'live.streaming.plugin',
        subTag: 'tryReEnterRoom',
      );
      return false;
    }

    return joinRoom(liveID: liveID).then((success) {
      ZegoLoggerService.logInfo(
        'plugins room joined, join success:$success',
        tag: 'live.streaming.plugin',
        subTag: 'tryReEnterRoom',
      );

      if (!success) {
        return false;
      }

      onPluginReLogin?.call();

      return true;
    });
  }
}
