// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';

/// @nodoc
class ZegoLiveHostManager {
  ZegoLiveConnectManager? connectManager;
  final ZegoUIKitPrebuiltLiveStreamingConfig config;

  bool _initialized = false;

  ZegoLiveHostManager({required this.config}) {
    configIsHost = ZegoLiveStreamingRole.host == config.role;

    subscriptions
      ..add(
          ZegoUIKit().getRoomPropertiesStream().listen(onRoomPropertiesUpdated))
      ..add(ZegoUIKit().getUserListStream().listen(onUserListUpdated));
  }

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

  Future<void> init() async {
    if (_initialized) {
      ZegoLoggerService.logInfo(
        'had already init',
        tag: 'live streaming',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'live streaming',
      subTag: 'host manager',
    );

    if (configIsHost) {
      ZegoLoggerService.logInfo(
        'local user ${ZegoUIKit().getLocalUser()} is host in config',
        tag: 'live streaming',
        subTag: 'host manager',
      );
      if (notifier.value != null &&
          notifier.value!.id != ZegoUIKit().getLocalUser().id) {
        /// host is exist
        ZegoLoggerService.logInfo(
          'host is exist:${notifier.value!.id} ${notifier.value!.name}',
          tag: 'live streaming',
          subTag: 'host manager',
        );
      } else {
        localHostPropertyUpdateTime = DateTime.now().millisecondsSinceEpoch;
        ZegoLoggerService.logInfo(
          'set room property to notify, timestamp:$localHostPropertyUpdateTime',
          tag: 'live streaming',
          subTag: 'host manager',
        );
        updateHostValue(ZegoUIKit().getLocalUser());
        await ZegoUIKit().setRoomProperty(
          RoomPropertyKey.host.text,
          ZegoUIKit().getLocalUser().id,
        );
      }
    }
  }

  Future<void> uninit() async {
    if (!_initialized) {
      ZegoLoggerService.logInfo(
        'not init before',
        tag: 'live streaming',
        subTag: 'seat manager',
      );

      return;
    }

    _initialized = false;

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live streaming',
      subTag: 'host manager',
    );

    if (isLocalHost) {
      ZegoLoggerService.logInfo(
        'host uninit host property',
        tag: 'live streaming',
        subTag: 'host manager',
      );
      await ZegoUIKit().setRoomProperty(RoomPropertyKey.host.text, '');
    }

    hostUpdateEnabledNotifier.value = true;
    notifier.value = null;
    pendingHostID = '';

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    if (pendingHostID.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'exist pending host $pendingHostID',
        tag: 'live streaming',
        subTag: 'host manager',
      );

      final host = ZegoUIKit().getUser(pendingHostID);
      if (!host.isEmpty()) {
        ZegoLoggerService.logInfo(
          'host updated, $host',
          tag: 'live streaming',
          subTag: 'host manager',
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
        tag: 'live streaming',
        subTag: 'host manager',
      );
      return;
    }

    final roomProperties = ZegoUIKit().getRoomProperties();
    ZegoLoggerService.logInfo(
      'onRoomPropertiesUpdated roomProperties:$roomProperties',
      tag: 'live streaming',
      subTag: 'host manager',
    );

    /// host exist
    final hostIDProperty = roomProperties[RoomPropertyKey.host.text];
    if (null == hostIDProperty) {
      ZegoLoggerService.logInfo(
        'onRoomPropertiesUpdated, not exist host property',
        tag: 'live streaming',
        subTag: 'host manager',
      );

      return;
    }

    if (hostIDProperty.updateUserID == ZegoUIKit().getLocalUser().id) {
      return;
    }

    if (hostIDProperty.updateTime < localHostPropertyUpdateTime) {
      /// local property(config set in init) is newer than current room property (sdk)
      ZegoLoggerService.logInfo(
        'host property update time is older than local setting time, '
        'property timestamp:${hostIDProperty.updateTime}, '
        'local timestamp:$localHostPropertyUpdateTime',
        tag: 'live streaming',
        subTag: 'host manager',
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
        tag: 'live streaming',
        subTag: 'host manager',
      );
      if (localHostReceived) {
        ZegoLoggerService.logInfo(
          'sync host property',
          tag: 'live streaming',
          subTag: 'host manager',
        );
        ZegoUIKit().setRoomProperty(
            RoomPropertyKey.host.text, ZegoUIKit().getLocalUser().id);
      } else {
        updateHostValue(null);
      }
    } else if (notifier.value?.id != hostIDProperty.value) {
      ZegoLoggerService.logInfo(
        'update host to be: $hostIDProperty',
        tag: 'live streaming',
        subTag: 'host manager',
      );
      final host = ZegoUIKit().getUser(hostIDProperty.value);
      if (host.isEmpty() && hostIDProperty.value.isNotEmpty) {
        ZegoLoggerService.logInfo(
          '$hostIDProperty user is not exist, host will be wait update util user list update',
          tag: 'live streaming',
          subTag: 'host manager',
        );
        pendingHostID = hostIDProperty.value;
      } else {
        if (host.id != notifier.value?.id &&
            notifier.value?.id == ZegoUIKit().getLocalUser().id) {
          /// local host, change by new host, switch to audience
          connectManager?.updateAudienceConnectState(
              ZegoLiveStreamingAudienceConnectState.connecting);
          connectManager?.updateAudienceConnectState(
              ZegoLiveStreamingAudienceConnectState.idle);
        }

        updateHostValue(host);
      }
    }
  }

  void setConnectManger(ZegoLiveConnectManager manager) {
    connectManager = manager;

    ZegoLoggerService.logInfo(
      'set connect manager',
      tag: 'live streaming',
      subTag: 'host manager',
    );
  }

  void updateHostValue(ZegoUIKitUser? host) {
    if (hostUpdateEnabledNotifier.value) {
      ZegoLoggerService.logInfo(
        'host updated, $host',
        tag: 'live streaming',
        subTag: 'host manager',
      );
      if (notifier.value?.id != host?.id) {
        if (ZegoLiveStreamingRole.host == config.role &&
            host?.id != ZegoUIKit().getLocalUser().id) {
          configIsHost = false;
        }

        notifier.value = host;
      }
    } else {
      /// in host ready to end, host should not update, otherwise host condition will failed
      ZegoLoggerService.logInfo(
        'host update disabled, $host',
        tag: 'live streaming',
        subTag: 'host manager',
      );
    }
  }
}
