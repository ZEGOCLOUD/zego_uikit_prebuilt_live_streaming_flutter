// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/lifecycle/lifecycle.dart';

/// @nodoc
class ZegoLiveStreamingHostManager {
  ZegoUIKitPrebuiltLiveStreamingConfig? config;
  String liveID = '';

  bool _initialized = false;

  /// internal variables
  final hostUpdateEnabledNotifier = ValueNotifier<bool>(true);
  final notifier = ValueNotifier<ZegoUIKitUser?>(null);
  String pendingHostID = '';
  List<StreamSubscription<dynamic>?> subscriptions = [];
  int localHostPropertyUpdateTime = 0;
  bool configIsHost = false;

  bool get isLocalHost =>
      // if not receive room 'host' property yet, then checkout config
      (notifier.value == null && configIsHost) ||
      // if room 'host' property received, checkout notifier value
      (notifier.value != null &&
          ZegoUIKit().getLocalUser().id == notifier.value!.id);

  bool isHost(ZegoUIKitUser user) {
    return
        // if room 'host' property received, checkout notifier value
        notifier.value != null && user.id == notifier.value!.id;
  }

  Future<void> init({
    required String liveID,
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) async {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live.streaming.host-mgr',
        subTag: 'init',
      );

      return;
    }

    _initialized = true;

    this.liveID = liveID;
    this.config = config;

    configIsHost = ZegoLiveStreamingRole.host ==
        (config?.role ?? ZegoLiveStreamingRole.audience);

    final defaultHost = config?.pkBattle.internal?.defaultHost ??
        config?.pkBattle.internal?.getDefaultHost?.call(liveID);
    if (defaultHost != null && defaultHost.id.isNotEmpty) {
      notifier.value = defaultHost;
    }

    ZegoLoggerService.logInfo(
      'liveID: $liveID, config: $config,'
      'configIsHost: $configIsHost, '
      'defaultHost: $defaultHost, ',
      tag: 'live.streaming.host-mgr',
      subTag: 'init',
    );

    registerRoomEvents(liveID);
  }

  Future<void> uninit() async {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live.streaming.host-mgr',
        subTag: 'uninit',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      '',
      tag: 'live.streaming.host-mgr',
      subTag: 'uninit',
    );

    if (isLocalHost) {
      ZegoLoggerService.logInfo(
        'host uninit host property',
        tag: 'live.streaming.host-mgr',
        subTag: 'uninit',
      );
      await ZegoUIKit().setRoomProperty(
        targetRoomID: liveID,
        RoomPropertyKey.host.text,
        '',
      );
    }

    unregisterRoomEvents(liveID);

    hostUpdateEnabledNotifier.value = true;
    notifier.value = null;
    pendingHostID = '';
    localHostPropertyUpdateTime = 0;

    liveID = '';
  }

  void registerRoomEvents(String liveID) {
    onRoomPropertiesUpdated(
        ZegoUIKit().getRoomProperties(targetRoomID: liveID));
    subscriptions.add(ZegoUIKit()
        .getRoomPropertiesStream(targetRoomID: liveID)
        .listen(onRoomPropertiesUpdated));

    onUserListUpdated(ZegoUIKit().getAllUsers(targetRoomID: liveID));
    subscriptions.add(ZegoUIKit()
        .getUserListStream(targetRoomID: liveID)
        .listen(onUserListUpdated));
    subscriptions.add(ZegoUIKit()
        .getUserLeaveStream(targetRoomID: liveID)
        .listen(onUserLeaved));

    onRoomStateUpdated();
    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .addListener(onRoomStateUpdated);
  }

  void unregisterRoomEvents(String liveID) {
    ZegoUIKit()
        .getRoomStateStream(targetRoomID: liveID)
        .removeListener(onRoomStateUpdated);

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
    subscriptions.clear();
  }

  void onRoomSwitched({
    required String liveID,
    required ZegoUIKitPrebuiltLiveStreamingConfig? config,
  }) {
    ZegoLoggerService.logInfo(
      'from ${this.liveID} to $liveID, ',
      tag: 'live.streaming.host-mgr',
      subTag: 'onRoomSwitched',
    );

    unregisterRoomEvents(this.liveID);

    hostUpdateEnabledNotifier.value = true;
    notifier.value = null;
    pendingHostID = '';
    localHostPropertyUpdateTime = 0;

    this.liveID = liveID;
    this.config = config;

    configIsHost = ZegoLiveStreamingRole.host ==
        (config?.role ?? ZegoLiveStreamingRole.audience);

    registerRoomEvents(this.liveID);
  }

  void onRoomStateUpdated() {
    final roomState = ZegoUIKit().getRoomStateStream(targetRoomID: liveID);
    if (!roomState.value.isLogin2) {
      return;
    }

    if (configIsHost) {
      ZegoLoggerService.logInfo(
        'local user ${ZegoUIKit().getLocalUser()} is host in config',
        tag: 'live.streaming.host-mgr',
        subTag: 'onRoomStateUpdated',
      );
      if (notifier.value != null &&
          notifier.value!.id != ZegoUIKit().getLocalUser().id) {
        /// host is exist
        ZegoLoggerService.logInfo(
          'host is exist:${notifier.value!.id} ${notifier.value!.name}',
          tag: 'live.streaming.host-mgr',
          subTag: 'onRoomStateUpdated',
        );
      } else {
        localHostPropertyUpdateTime = DateTime.now().millisecondsSinceEpoch;
        ZegoLoggerService.logInfo(
          'set room property to notify, timestamp:$localHostPropertyUpdateTime',
          tag: 'live.streaming.host-mgr',
          subTag: 'onRoomStateUpdated',
        );
        updateHostValue(ZegoUIKit().getLocalUser());
        ZegoUIKit().setRoomProperty(
          targetRoomID: liveID,
          RoomPropertyKey.host.text,
          ZegoUIKit().getLocalUser().id,
        );
      }
    }
  }

  void onUserLeaved(List<ZegoUIKitUser> users) {
    if (notifier.value?.id.isNotEmpty ?? false) {
      final hostIndex = users.indexWhere((e) => e.id == notifier.value?.id);
      if (-1 != hostIndex) {
        ZegoLoggerService.logInfo(
          'host leave',
          tag: 'live.streaming.host-mgr',
          subTag: 'onUserLeaved',
        );

        /// host leave
        updateHostValue(null);
      }
    }
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    if (pendingHostID.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'exist pending host $pendingHostID',
        tag: 'live.streaming.host-mgr',
        subTag: 'onUserListUpdated',
      );

      final host = ZegoUIKit().getUser(targetRoomID: liveID, pendingHostID);
      if (!host.isEmpty()) {
        ZegoLoggerService.logInfo(
          'host updated, $host',
          tag: 'live.streaming.host-mgr',
          subTag: 'onUserListUpdated',
        );
        updateHostValue(host);
        pendingHostID = '';
      }
    }
  }

  void onRoomPropertiesUpdated(Map<String, RoomProperty> updatedProperties) {
    if (!updatedProperties.containsKey(RoomPropertyKey.host.text)) {
      ZegoLoggerService.logInfo(
        'update properties not contain host',
        tag: 'live.streaming.host-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
      return;
    }

    final roomProperties = ZegoUIKit().getRoomProperties(targetRoomID: liveID);
    ZegoLoggerService.logInfo(
      'onRoomPropertiesUpdated roomProperties:$roomProperties',
      tag: 'live.streaming.host-mgr',
      subTag: 'onRoomPropertiesUpdated',
    );

    /// host exist
    final hostIDProperty = roomProperties[RoomPropertyKey.host.text];
    if (null == hostIDProperty) {
      ZegoLoggerService.logInfo(
        'onRoomPropertiesUpdated, not exist host property',
        tag: 'live.streaming.host-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );

      return;
    }

    if (hostIDProperty.updateUserID == ZegoUIKit().getLocalUser().id) {
      ZegoLoggerService.logInfo(
        'cause by local user update, ignore',
        tag: 'live.streaming.host-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );

      return;
    }

    if (hostIDProperty.updateTime < localHostPropertyUpdateTime) {
      /// local property(config set in init) is newer than current room property (sdk)
      ZegoLoggerService.logInfo(
        'host property update time is older than local setting time, '
        'property timestamp:${hostIDProperty.updateTime}, '
        'local timestamp:$localHostPropertyUpdateTime',
        tag: 'live.streaming.host-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
      return;
    }

    if (hostIDProperty.value.isEmpty) {
      /// host gone or null
      final localHostReceived = notifier.value != null &&
          ZegoUIKit().getLocalUser().id == notifier.value!.id;
      ZegoLoggerService.logInfo(
        'host key is not exist, host is gone or null, '
        'local host had received: $localHostReceived',
        tag: 'live.streaming.host-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
      if (localHostReceived) {
        ZegoLoggerService.logInfo(
          'sync host property',
          tag: 'live.streaming.host-mgr',
          subTag: 'onRoomPropertiesUpdated',
        );
        ZegoUIKit().setRoomProperty(
          targetRoomID: liveID,
          RoomPropertyKey.host.text,
          ZegoUIKit().getLocalUser().id,
        );
      } else {
        updateHostValue(null);
      }
    } else if (notifier.value?.id != hostIDProperty.value) {
      ZegoLoggerService.logInfo(
        'update host to be: $hostIDProperty',
        tag: 'live.streaming.host-mgr',
        subTag: 'onRoomPropertiesUpdated',
      );
      final host = ZegoUIKit().getUser(
        targetRoomID: liveID,
        hostIDProperty.value,
      );
      if (host.isEmpty() && hostIDProperty.value.isNotEmpty) {
        ZegoLoggerService.logInfo(
          '$hostIDProperty user is not exist, host will be wait update util user list update',
          tag: 'live.streaming.host-mgr',
          subTag: 'onRoomPropertiesUpdated',
        );
        pendingHostID = hostIDProperty.value;
      } else {
        if (host.id != notifier.value?.id &&
            notifier.value?.id == ZegoUIKit().getLocalUser().id) {
          /// local host, change by new host, switch to audience
          ZegoLiveStreamingPageLifeCycle()
              .currentManagers
              .connectManager
              .updateAudienceConnectState(
                  ZegoLiveStreamingAudienceConnectState.connecting);
          ZegoLiveStreamingPageLifeCycle()
              .currentManagers
              .connectManager
              .updateAudienceConnectState(
                  ZegoLiveStreamingAudienceConnectState.idle);
        }

        updateHostValue(host);
      }
    }
  }

  void updateHostValue(ZegoUIKitUser? host) {
    if (hostUpdateEnabledNotifier.value) {
      ZegoLoggerService.logInfo(
        'host updated, '
        'from ${notifier.value} to $host, ',
        tag: 'live.streaming.host-mgr',
        subTag: 'updateHostValue',
      );
      if (notifier.value?.id != host?.id) {
        if (ZegoLiveStreamingRole.host == config?.role &&
            host?.id != ZegoUIKit().getLocalUser().id) {
          configIsHost = false;
        }

        notifier.value = host;
      }
    } else {
      /// in host ready to end, host should not update, otherwise host condition will failed
      ZegoLoggerService.logInfo(
        'host update disabled, $host',
        tag: 'live.streaming.host-mgr',
        subTag: 'updateHostValue',
      );
    }
  }
}
