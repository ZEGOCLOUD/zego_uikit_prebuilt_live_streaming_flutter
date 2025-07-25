// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/core/event/defines.dart';

extension ZegoUIKitPrebuiltLiveStreamingPKUserList
    on List<ZegoLiveStreamingPKUser> {
  String toSimpleString() {
    return map((e) => 'id:${e.userInfo.id},live id:${e.liveID}')
        .toList()
        .toString();
  }
}

class ZegoUIKitPrebuiltLiveStreamingPKData
    with
        ZegoUIKitPrebuiltLiveStreamingPKExternalData,
        ZegoUIKitPrebuiltLiveStreamingPKServiceData,
        ZegoUIKitPrebuiltLiveStreamingPKEventData {
  String _roomID = '';

  String get roomID => _roomID;

  /// 当前PK邀请中的用户
  final connectingPKUsers = ValueNotifier<List<ZegoLiveStreamingPKUser>>([]);

  /// 当前PK的用户
  final currentPKUsers = ValueNotifier<List<ZegoLiveStreamingPKUser>>([]);
  final previousPKUsers = ValueNotifier<List<ZegoLiveStreamingPKUser>>([]);

  /// When the UI is minimized, and the host receives a pk battle request.
  final _pkBattleRequestReceivedEventInMinimizingNotifier =
      ValueNotifier<ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent?>(
          null);

  ValueNotifier<ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent?>
      get pkBattleRequestReceivedEventInMinimizingNotifier =>
          _pkBattleRequestReceivedEventInMinimizingNotifier;

  void init({
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingEvents events,
    required ZegoUIKitPrebuiltLiveStreamingInnerText innerText,
    required ZegoLiveStreamingHostManager hostManager,
    required ValueNotifier<LiveStatus> liveStatusNotifier,
    required ValueNotifier<bool> startedByLocalNotifier,
    required BuildContext Function()? contextQuery,
  }) {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'live-streaming-pk',
      subTag: 'service data',
    );

    if (ZegoUIKit().getRoomStateStream().value.reason !=
        ZegoRoomStateChangedReason.Logined) {
      ZegoUIKit().getRoomStateStream().addListener(_onRoomStateChanged);
    } else {
      _roomID = ZegoUIKit().getRoom().id;
    }

    prebuiltConfig = config;
    this.innerText = innerText;
    this.hostManager = hostManager;
    this.liveStatusNotifier = liveStatusNotifier;
    this.startedByLocalNotifier = startedByLocalNotifier;
    this.contextQuery = contextQuery;
    this.events = events;
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live-streaming-pk',
      subTag: 'service data',
    );

    _roomID = '';
    prebuiltConfig = null;
    innerText = null;
    hostManager = null;
    liveStatusNotifier = ValueNotifier<LiveStatus>(LiveStatus.notStart);
    startedByLocalNotifier = ValueNotifier<bool>(false);
    contextQuery = null;

    ZegoUIKit().getRoomStateStream().removeListener(_onRoomStateChanged);

    connectingPKUsers.value.clear();
    currentPKUsers.value = [];
  }

  void _onRoomStateChanged() {
    if (ZegoUIKit().getRoomStateStream().value.reason !=
        ZegoRoomStateChangedReason.Logined) {
      return;
    }

    ZegoUIKit().getRoomStateStream().removeListener(_onRoomStateChanged);

    _roomID = ZegoUIKit().getRoom().id;
  }

  void cacheRequestReceivedEventInMinimizing(
    ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'cacheRequestReceivedEventInMinimizing, event:$event',
      tag: 'live-streaming-pk',
      subTag: 'service data',
    );

    _pkBattleRequestReceivedEventInMinimizingNotifier.value = event;
  }

  void clearRequestReceivedEventInMinimizing() {
    ZegoLoggerService.logInfo(
      'clearRequestReceivedEventInMinimizing',
      tag: 'live-streaming-pk',
      subTag: 'service data',
    );

    _pkBattleRequestReceivedEventInMinimizingNotifier.value = null;
  }
}

mixin ZegoUIKitPrebuiltLiveStreamingPKExternalData {
  ZegoLiveStreamingHostManager? hostManager;
  var liveStatusNotifier = ValueNotifier<LiveStatus>(LiveStatus.notStart);
  var startedByLocalNotifier = ValueNotifier<bool>(false);
  ZegoUIKitPrebuiltLiveStreamingInnerText? innerText;
  BuildContext Function()? contextQuery;
  ZegoUIKitPrebuiltLiveStreamingConfig? prebuiltConfig;
  ZegoUIKitPrebuiltLiveStreamingEvents? events;
}

mixin ZegoUIKitPrebuiltLiveStreamingPKServiceData {
  bool showingRequestReceivedDialog = false;
  bool showingPKBattleEndedDialog = false;
  bool showOutgoingPKBattleRequestRejectedDialog = false;

  List<String> playingHostIDs = [];

  /// local send invitation:
  /// 1. assign:
  ///   a. send
  /// 2. clear:
  ///   a. cancel
  ///   b. timeout
  ///   c. remote rejected
  ///   d. quit
  ///   e. end
  ///
  /// local received invitation:
  /// 1. assign:
  ///   a. received
  /// 2. clear:
  ///   a. remote cancel
  ///   b. local reject
  ///   c. timeout
  ///   d. quit
  ///
  String _currentRequestID = '';

  String get currentRequestID => _currentRequestID;

  set currentRequestID(String value) {
    ZegoLoggerService.logInfo(
      'current request id set to:$value',
      tag: 'live-streaming-pk',
      subTag: 'service',
    );

    _currentRequestID = value;
  }

  /// inviting hosts
  List<String> remoteUserIDsWaitingResponseFromLocalRequest() {
    if (_currentRequestID.isEmpty) {
      return [];
    }

    List<String> userIds = [];
    for (final user in ZegoUIKit()
        .getSignalingPlugin()
        .getAdvanceInvitees(_currentRequestID)) {
      if (user.userID == ZegoUIKit().getLocalUser().id) {
        continue;
      }

      if (AdvanceInvitationState.waiting == user.state) {
        userIds.add(user.userID);
      }
    }

    return userIds;
  }

  /// being invited
  bool isRemoteRequestWaitingLocalResponse() {
    if (_currentRequestID.isEmpty) {
      return false;
    }

    String? remoteUserID;
    for (final user in ZegoUIKit()
        .getSignalingPlugin()
        .getAdvanceInvitees(_currentRequestID)) {
      if (user.userID != ZegoUIKit().getLocalUser().id) {
        continue;
      }

      if (AdvanceInvitationState.waiting == user.state) {
        remoteUserID = user.userID;
      }
    }

    return remoteUserID?.isNotEmpty ?? false;
  }
}

mixin ZegoUIKitPrebuiltLiveStreamingPKEventData {
  String propertyHostID = '';

  void updatePropertyHostID(
    ZegoSignalingPluginRoomPropertiesUpdatedEvent event,
  ) {
    if (event.setProperties.containsKey(roomPropKeyHost)) {
      propertyHostID = event.setProperties[roomPropKeyHost] ?? '';
    }

    if (event.deleteProperties.containsKey(roomPropKeyHost)) {
      propertyHostID = '';
    }
  }
}
