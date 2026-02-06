// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/events.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'defines.dart';
import 'event/defines.dart';

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
  /// Users currently in PK invitation
  final connectingPKUsers = ValueNotifier<List<ZegoLiveStreamingPKUser>>([]);

  /// Current PK users
  final currentPKUsers = ValueNotifier<List<ZegoLiveStreamingPKUser>>([]);
  final previousPKUsers = ValueNotifier<List<ZegoLiveStreamingPKUser>>([]);

  /// When the UI is minimization, and the host receives a pk battle request.
  final _pkBattleRequestReceivedEventInMinimizingNotifier =
      ValueNotifier<ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent?>(
          null);

  ValueNotifier<ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent?>
      get pkBattleRequestReceivedEventInMinimizingNotifier =>
          _pkBattleRequestReceivedEventInMinimizingNotifier;

  void init({
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoUIKitPrebuiltLiveStreamingEvents? events,
    required ZegoUIKitPrebuiltLiveStreamingInnerText innerText,
    required BuildContext Function()? contextQuery,
  }) {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'live.streaming.pk.data',
      subTag: 'service data',
    );

    prebuiltConfig = config;
    this.innerText = innerText;
    this.events = events;
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'live.streaming.pk.data',
      subTag: 'service data',
    );

    prebuiltConfig = null;
    innerText = null;

    connectingPKUsers.value.clear();
    currentPKUsers.value = [];
  }

  void cacheRequestReceivedEventInMinimizing(
    ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'cacheRequestReceivedEventInMinimizing, event:$event',
      tag: 'live.streaming.pk.data',
      subTag: 'service data',
    );

    _pkBattleRequestReceivedEventInMinimizingNotifier.value = event;
  }

  void clearRequestReceivedEventInMinimizing() {
    ZegoLoggerService.logInfo(
      'clearRequestReceivedEventInMinimizing',
      tag: 'live.streaming.pk.data',
      subTag: 'service data',
    );

    _pkBattleRequestReceivedEventInMinimizingNotifier.value = null;
  }
}

mixin ZegoUIKitPrebuiltLiveStreamingPKExternalData {
  ZegoUIKitPrebuiltLiveStreamingInnerText? innerText;
  ZegoUIKitPrebuiltLiveStreamingConfig? prebuiltConfig;
  ZegoUIKitPrebuiltLiveStreamingEvents? events;
}

mixin ZegoUIKitPrebuiltLiveStreamingPKServiceData {
  bool showingRequestReceivedDialog = false;
  bool showingPKBattleEndedDialog = false;
  bool showOutgoingPKBattleRequestRejectedDialog = false;
  bool showingHostResumePKConfirmDialog = false;

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
      tag: 'live.streaming.pk.data',
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
    final initiator =
        ZegoUIKit().getSignalingPlugin().getAdvanceInitiator(_currentRequestID);
    if (initiator?.userID == ZegoUIKit().getLocalUser().id &&
        AdvanceInvitationState.waiting == initiator?.state) {
      /// As the sponsor, after leaving, he was invited again by others
      remoteUserID = initiator?.userID ?? '';
    } else {
      /// Check again if it is the invitee
      for (final invitee in ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitees(_currentRequestID)) {
        if (invitee.userID != ZegoUIKit().getLocalUser().id) {
          continue;
        }

        if (AdvanceInvitationState.waiting == invitee.state) {
          remoteUserID = invitee.userID;
        }
      }
    }

    return remoteUserID?.isNotEmpty ?? false;
  }
}

mixin ZegoUIKitPrebuiltLiveStreamingPKEventData {
  String propertyHostID = '';

  void updatePropertyHostIDByUpdated(
    ZegoSignalingPluginRoomPropertiesUpdatedEvent event,
  ) {
    if (event.setProperties.containsKey(roomPropKeyHost)) {
      propertyHostID = event.setProperties[roomPropKeyHost] ?? '';
    }

    if (event.deleteProperties.containsKey(roomPropKeyHost)) {
      propertyHostID = '';
    }
  }

  void updatePropertyHostIDByQuery(
    ZegoSignalingPluginQueryRoomPropertiesResult event,
  ) {
    if (event.properties.containsKey(roomPropKeyHost)) {
      propertyHostID = event.properties[roomPropKeyHost] ?? '';
    }
  }
}
