// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/dialogs.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/inner_text.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_event_default_actions.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/pk_service.dart';

part 'pk_event_conv.dart';

part 'pk_utils.dart';

/// @nodoc
class ZegoLiveStreamingPKBattleManager {
  late ZegoInnerText innerText;
  BuildContext Function()? contextQuery;
  late ZegoUIKitPrebuiltLiveStreamingConfig config;
  late ZegoLiveHostManager hostManager;
  late ValueNotifier<LiveStatus> liveStatusNotifier;
  late ValueNotifier<bool> startedByLocalNotifier;
  ZegoLiveStreamingPKBattleStreamCreator? streamCreator;

  /// When the UI is minimized, and the host receives a pk battle request.
  final pkBattleRequestReceivedEventInMinimizingNotifier =
      ValueNotifier<ZegoIncomingPKBattleRequestReceivedEvent?>(null);

  ValueNotifier<ZegoLiveStreamingPKBattleState> state = ValueNotifier(
    ZegoLiveStreamingPKBattleState.idle,
  );

  bool get isInPK =>
      state.value == ZegoLiveStreamingPKBattleState.inPKBattle ||
      state.value == ZegoLiveStreamingPKBattleState.loading;

  ValueNotifier<bool> isAnotherHostMuted = ValueNotifier(false);
  ValueNotifier<bool> anotherHostHeartBeatTimeout = ValueNotifier(false);

  bool muting = false;

  String waitingOutgoingPKBattleRequestUserID = '';
  String waitingOutgoingPKBattleRequestID = '';

  bool showingRequestReceivedDialog = false;

  ZegoIncomingPKBattleRequestReceivedEvent?
      cachedIncomingPKBattleRequestReceivedEvent;

  BuildContext get context => contextQuery!();

  bool get isLiving => liveStatusNotifier.value == LiveStatus.living;

  bool get isHost => hostManager.isLocalHost;
  String cachedRoomID = '';
  Completer<void>? stateTransformCompleter;

  bool inited = false;
  List<StreamSubscription<dynamic>> subscriptions = [];

  void init({
    required ZegoUIKitPrebuiltLiveStreamingConfig config,
    required ZegoInnerText innerText,
    required ZegoLiveHostManager hostManager,
    required ValueNotifier<LiveStatus> liveStatusNotifier,
    required ValueNotifier<bool> startedByLocalNotifier,
    required BuildContext Function()? contextQuery,
  }) {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    this.config = config;
    this.innerText = innerText;
    this.hostManager = hostManager;
    this.liveStatusNotifier = liveStatusNotifier;
    this.startedByLocalNotifier = startedByLocalNotifier;
    this.contextQuery = contextQuery;

    initEvent();
    subscriptions.addAll([
      ZegoUIKit()
          .getSignalingPlugin()
          .getRoomPropertiesStream()
          .listen(onRoomAttributesUpdated),
    ]);
    inited = true;
  }

  Future<void> uninit() async {
    if (!inited) {
      return;
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );

    if (streamCreator != null) {
      if (isHost) {
        await stopPKBattle();
      } else {
        await ZegoUIKit().stopPlayMixAudioVideo(streamCreator!.mixerID);
      }
    }
    streamCreator = null;
    cachedRoomID = '';
    state.value = ZegoLiveStreamingPKBattleState.idle;
    inited = false;
    for (final sub in subscriptions) {
      sub.cancel();
    }
    uninitEvent();
  }

  Future<ZegoLiveStreamingPKBattleResult> sendPKBattleRequest(
    String anotherHostUserID, {
    int timeout = 60,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'sendPKBattleRequest, anotherHostUserID:$anotherHostUserID',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    late PlatformException? error;
    if (anotherHostUserID.isEmpty) {
      error =
          PlatformException(code: '-1', message: 'anotherHostUserID is empty');
    } else if (state.value != ZegoLiveStreamingPKBattleState.idle) {
      error = PlatformException(
          code: '-1',
          message:
              'Only PK battle request can be initiated when in idle state, '
              'now state is ${state.value.name}');
    } else if (!inited ||
        !isLiving ||
        !isHost ||
        ZegoUIKit().getRoom().id.isEmpty) {
      error = PlatformException(
          code: '-1',
          message: 'Only Host is allowed to initiate PK during live broadcast.'
              ' (inited:$inited ${inited ? ', isLiving:$isLiving, '
                  'isHost:$isHost' : ''})');
    } else {
      error = null;
    }

    // When you have already received an invitation, if you then send an invitation to the other party,
    // it is also considered that both parties agree to engage in a competition.
    if ((state.value == ZegoLiveStreamingPKBattleState.waitingMyResponse) &&
        (cachedIncomingPKBattleRequestReceivedEvent?.anotherHost.id ==
            anotherHostUserID)) {
      if (showingRequestReceivedDialog) {
        showingRequestReceivedDialog = false;
        Navigator.of(
          context,
          rootNavigator: config.rootNavigator,
        ).pop();
      }
      final ret = await acceptIncomingPKBattleRequest(
          cachedIncomingPKBattleRequestReceivedEvent!);

      ((ret.error != null)
              ? ZegoLoggerService.logError
              : ZegoLoggerService.logInfo)
          .call(
        'sendPKBattleRequest, auto accept, ret:$ret',
        tag: 'ZegoLiveStreamingPKBattleService',
        subTag: 'api',
      );

      return ret;
    }

    if (error != null) {
      ZegoLoggerService.logError(
        'sendPKBattleRequest, code:${error.code}, message:${error.message}',
        tag: 'ZegoLiveStreamingPKBattleService',
        subTag: 'api',
      );
      return ZegoLiveStreamingPKBattleResult(error: error);
    }

    ZegoLoggerService.logInfo(
      'sendPKBattleRequest, send start request signaling',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );

    final ret = await ZegoUIKit().getSignalingPlugin().sendInvitation(
          inviterID: ZegoUIKit().getLocalUser().id,
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: [anotherHostUserID],
          timeout: timeout,
          type: ZegoInvitationType.crossRoomPKBattleRequest.value,
          data: jsonEncode(<String, dynamic>{
            'custom_data': customData,
            'live_id': ZegoUIKit().getRoom().id,
            'sub_type': ZegoPKBattleRequestSubType.start.index,
          }),
        );
    (ret.error == null && ret.errorInvitees.isEmpty
        ? ZegoLoggerService.logInfo
        : ZegoLoggerService.logError)(
      'sendPKBattleRequest, send start request signaling ret:$ret',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    if (ret.error == null) {
      if (ret.errorInvitees.isEmpty) {
        waitingOutgoingPKBattleRequestID = ret.invitationID;
        waitingOutgoingPKBattleRequestUserID = anotherHostUserID;
        state.value = ZegoLiveStreamingPKBattleState.waitingAnotherHostResponse;
        return const ZegoLiveStreamingPKBattleResult();
      } else {
        final errorUserID = ret.errorInvitees.entries.first.key;
        final errorReason = ret.errorInvitees.entries.first.value;
        return ZegoLiveStreamingPKBattleResult(
          error: PlatformException(
            code: '-1',
            message: "user $errorUserID's reason is $errorReason",
          ),
        );
      }
    } else {
      return ZegoLiveStreamingPKBattleResult(error: ret.error);
    }
  }

  Future<ZegoLiveStreamingPKBattleResult> cancelPKBattleRequest({
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'cancelPKBattleRequest',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );

    if (state.value !=
        ZegoLiveStreamingPKBattleState.waitingAnotherHostResponse) {
      return ZegoLiveStreamingPKBattleResult(
          error: PlatformException(
        code: '-1',
        message: 'not in waitingAnotherHostResponse state, '
            'state is ${state.value.name}',
      ));
    }

    ZegoLoggerService.logInfo(
      'cancelPKBattleRequest, send cancel signaling',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    final ret = await ZegoUIKit().getSignalingPlugin().cancelInvitation(
      invitees: [waitingOutgoingPKBattleRequestUserID],
      data: jsonEncode(<String, String>{
        'invitation_id': waitingOutgoingPKBattleRequestID,
        'custom_data': customData,
      }),
    );
    ((ret.error == null)
        ? ZegoLoggerService.logInfo
        : ZegoLoggerService.logError)(
      'cancelPKBattleRequest, ret:$ret',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );

    if (ret.error == null) {
      if (ret.errorInvitees.isEmpty) {
        waitingOutgoingPKBattleRequestID = '';
        waitingOutgoingPKBattleRequestUserID = '';
        state.value = ZegoLiveStreamingPKBattleState.idle;
        return const ZegoLiveStreamingPKBattleResult(error: null);
      } else {
        final errorUserID = ret.errorInvitees.first;
        return ZegoLiveStreamingPKBattleResult(
          error: PlatformException(
            code: '-1',
            message: 'cancelFailed: [$errorUserID]',
          ),
        );
      }
    } else {
      return ZegoLiveStreamingPKBattleResult(error: ret.error);
    }
  }

  Future<ZegoLiveStreamingPKBattleResult> rejectIncomingPKBattleRequest(
    ZegoIncomingPKBattleRequestReceivedEvent event, {
    int? rejectCode,
  }) async {
    ZegoLoggerService.logInfo(
      'rejectIncomingPKBattleRequest, event:$event',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    // As long as respond to the any request, the cache can be cleared.
    cachedIncomingPKBattleRequestReceivedEvent = null;
    if (state.value == ZegoLiveStreamingPKBattleState.waitingMyResponse) {
      state.value = ZegoLiveStreamingPKBattleState.idle;
    }

    final ret = await ZegoUIKit().getSignalingPlugin().refuseInvitation(
          inviterID: event.anotherHost.id,
          data: jsonEncode({
            'sub_type': ZegoPKBattleRequestSubType.start.index,
            'code': ZegoLiveStreamingPKBattleRejectCode.reject.index,
            'invitation_id': event.requestID,
            'invitee_name': ZegoUIKit().getLocalUser().name,
          }),
        );

    ((ret.error != null)
            ? ZegoLoggerService.logError
            : ZegoLoggerService.logInfo)
        .call(
      'rejectIncomingPKBattleRequest, ret:$ret',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    return ZegoLiveStreamingPKBattleResult(error: ret.error);
  }

  Future<ZegoLiveStreamingPKBattleResult> acceptIncomingPKBattleRequest(
    ZegoIncomingPKBattleRequestReceivedEvent event,
  ) async {
    ZegoLoggerService.logInfo(
      'acceptIncomingPKBattleRequest, event:$event',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    // As long as respond to the any request, the cache can be cleared.
    cachedIncomingPKBattleRequestReceivedEvent = null;
    final ret = await ZegoUIKit().getSignalingPlugin().acceptInvitation(
        inviterID: event.anotherHost.id,
        data: jsonEncode({
          'invitee_name': ZegoUIKit().getLocalUser().name,
          'live_id': ZegoUIKit().getRoom().id,
          'sub_type': ZegoPKBattleRequestSubType.start.index,
        }));

    ((ret.error != null)
            ? ZegoLoggerService.logError
            : ZegoLoggerService.logInfo)
        .call(
      'acceptIncomingPKBattleRequest, ret:$ret',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );

    if (ret.error != null) {
      if (state.value == ZegoLiveStreamingPKBattleState.waitingMyResponse) {
        state.value = ZegoLiveStreamingPKBattleState.idle;
      }
      return ZegoLiveStreamingPKBattleResult(error: ret.error);
    } else {
      if (state.value == ZegoLiveStreamingPKBattleState.waitingMyResponse) {
        state.value = ZegoLiveStreamingPKBattleState.loading;
      }
      return startPKBattleWith(
        anotherHostLiveID: event.anotherHostLiveID,
        anotherHostUserID: event.anotherHost.id,
        anotherHostUserName: event.anotherHost.name,
      );
    }
  }

  Future<ZegoLiveStreamingPKBattleResult> startPKBattleWith({
    required String anotherHostLiveID,
    required String anotherHostUserID,
    required String anotherHostUserName,
  }) async {
    ZegoLoggerService.logInfo(
      'startPKBattleWith, anotherHostLiveID:$anotherHostLiveID, '
      'anotherHostUserID:$anotherHostUserID',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    return _waitCompleter('startPKBattleWith').then((_) async {
      late PlatformException? error;
      if (anotherHostUserID.isEmpty || anotherHostLiveID.isEmpty) {
        error = PlatformException(
            code: '-1',
            message: 'anotherHostUserID($anotherHostUserID) or '
                'anotherHostLiveID($anotherHostLiveID) is empty');
      } else if (!inited ||
          !isLiving ||
          !isHost ||
          ZegoUIKit().getRoom().id.isEmpty) {
        error = PlatformException(
          code: '-1',
          message: 'Only Host is allowed to initiate PK during live broadcast.'
              ' (inited:$inited${inited ? ', isLiving:$isLiving, '
                  'isHost:$isHost' : ''})',
        );
      } else if (state.value == ZegoLiveStreamingPKBattleState.inPKBattle) {
        error = PlatformException(code: '-1', message: 'already in pk battle.');
      } else {
        error = null;
      }

      if (error != null) {
        ZegoLoggerService.logError(
          'startPKBattleWith, code:${error.code}, message:${error.message}',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'api',
        );
        return ZegoLiveStreamingPKBattleResult(error: error);
      }

      state.value = ZegoLiveStreamingPKBattleState.loading;

      streamCreator = ZegoLiveStreamingPKBattleStreamCreator(
        anotherHostLiveID: anotherHostLiveID,
        anotherHostUserID: anotherHostUserID,
        anotherHostUserName: anotherHostUserName,
      );

      ZegoUIKit().startPlayAnotherRoomAudioVideo(
        anotherHostLiveID,
        anotherHostUserID,
        userName: anotherHostUserName,
      );
      state.value = ZegoLiveStreamingPKBattleState.inPKBattle;
      config.onLiveStreamingStateUpdate?.call(
        ZegoLiveStreamingState.inPKBattle,
      );

      ZegoLoggerService.logInfo(
        'startPKBattleWith, startMixerTask:${streamCreator!.task.toMap()}',
        tag: 'ZegoLiveStreamingPKBattleService',
        subTag: 'api',
      );

      final isMicrophoneOn = ZegoUIKit()
          .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
          .value;
      ZegoUIKit().turnMicrophoneOn(isMicrophoneOn, muteMode: true);

      final mixResult = await ZegoUIKit().startMixerTask(streamCreator!.task);

      if (mixResult.errorCode != 0) {
        error = PlatformException(
          code: '${mixResult.errorCode}',
          message: '${mixResult.extendedData}',
        );
        ZegoLoggerService.logError(
          'startPKBattleWith, startMixerTask failed, code:${error.code}, message:${error.message}. ',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'api',
        );
        state.value = ZegoLiveStreamingPKBattleState.idle;
        stopPKBattle();
      } else {
        ZegoLoggerService.logInfo(
          'startPKBattleWith, startMixerTask success, extendedData:${mixResult.extendedData}',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'api',
        );
      }

      cachedRoomID = ZegoUIKit().getRoom().id;
      ZegoUIKit().getSignalingPlugin().updateRoomProperties(
            roomID: cachedRoomID,
            roomProperties: streamCreator!.toRoomAttributes,
            isForce: true,
            // isDeleteAfterOwnerLeft: true,
            isUpdateOwner: true,
          );

      return ZegoLiveStreamingPKBattleResult(error: error);
    }).then((ret) {
      _completeCompleter('startPKBattleWith');
      return ret;
    });
  }

  Future<ZegoLiveStreamingPKBattleResult> stopPKBattle(
      {String customData = '', bool triggeredByAotherHost = false}) async {
    ZegoLoggerService.logInfo(
      'stopPKBattle, isHost:$isHost, state:${state.value}',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    return _waitCompleter('stopPKBattle').then((_) async {
      if (state.value != ZegoLiveStreamingPKBattleState.inPKBattle) {
        ZegoLoggerService.logError(
          'stopPKBattle, state is not inPkBattle, state:${state.value}',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'api',
        );
        return ZegoLiveStreamingPKBattleResult(
            error: PlatformException(
          code: '-1',
          message: 'state is not inPkBattle, state:${state.value}',
        ));
      }

      if (isHost) {
        final isMicrophoneOn = ZegoUIKit()
            .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
            .value;
        ZegoUIKit()
          ..turnMicrophoneOn(isMicrophoneOn, muteMode: true)
          ..stopPlayAnotherRoomAudioVideo(streamCreator!.anotherHostUserID)
          ..stopMixerTask(streamCreator!.task);

        await ZegoUIKit().getSignalingPlugin().deleteRoomProperties(
              roomID: cachedRoomID,
              keys: ZegoLiveStreamingPKBattleStreamCreator.roomAttributesKeys,
            );

        isAnotherHostMuted.value = false;
        state.value = ZegoLiveStreamingPKBattleState.idle;
        config.onLiveStreamingStateUpdate?.call(
          isLiving
              ? ZegoLiveStreamingState.living
              : ZegoLiveStreamingState.idle,
        );
        if (triggeredByAotherHost) {
          ZegoLoggerService.logInfo(
            'stopPKBattle, send stop ack signaling',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'api',
          );

          final ret = await ZegoUIKit().getSignalingPlugin().acceptInvitation(
              inviterID: streamCreator!.anotherHostUserID,
              data: jsonEncode({
                'invitee_name': ZegoUIKit().getLocalUser().name,
                'sub_type': ZegoPKBattleRequestSubType.stop.index,
              }));

          ((ret.error != null)
                  ? ZegoLoggerService.logError
                  : ZegoLoggerService.logInfo)
              .call(
            'stopPKBattle, send stop ack signaling, ret:$ret',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'api',
          );
        } else {
          ZegoLoggerService.logInfo(
            'stopPKBattle, send stop request signaling',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'api',
          );
          final ret = await ZegoUIKit().getSignalingPlugin().sendInvitation(
                inviterID: ZegoUIKit().getLocalUser().id,
                inviterName: ZegoUIKit().getLocalUser().name,
                invitees: [streamCreator!.anotherHostUserID],
                timeout: 60,
                type: ZegoInvitationType.crossRoomPKBattleRequest.value,
                data: jsonEncode(<String, dynamic>{
                  'custom_data': customData,
                  'sub_type': ZegoPKBattleRequestSubType.stop.index,
                }),
              );

          (ret.error == null && ret.errorInvitees.isEmpty
              ? ZegoLoggerService.logInfo
              : ZegoLoggerService.logError)(
            'stopPKBattle, send stop request signaling ret:$ret',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'api',
          );

          if (ret.error == null) {
            if (ret.errorInvitees.isEmpty) {
              return const ZegoLiveStreamingPKBattleResult();
            } else {
              final errorUserID = ret.errorInvitees.entries.first.key;
              final errorReason = ret.errorInvitees.entries.first.value;
              return ZegoLiveStreamingPKBattleResult(
                error: PlatformException(
                  code: '-1',
                  message: "user $errorUserID's reason is $errorReason",
                ),
              );
            }
          } else {
            return ZegoLiveStreamingPKBattleResult(error: ret.error);
          }
        }
      } else {
        return ZegoLiveStreamingPKBattleResult(
            error: PlatformException(
          code: '-1',
          message: 'Only host can stop the pk battle.',
        ));
      }
      return const ZegoLiveStreamingPKBattleResult();
    }).then((ret) {
      streamCreator = null;
      _completeCompleter('stopPKBattle');
      return ret;
    });
  }

  Future<void> muteAnotherHostAudio({required bool mute}) async {
    ZegoLoggerService.logInfo(
      'muteAnotherHostAudio,  mute:$mute, isAnotherHostMuted:'
      '${isAnotherHostMuted.value}, muting:$muting',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'api',
    );
    if (muting || (isAnotherHostMuted.value == mute)) {
      return;
    }
    ZegoUIKit().muteUserAudio(streamCreator!.anotherHostUserID, mute);
    muting = true;
    isAnotherHostMuted.value = mute;

    if (streamCreator != null) {
      streamCreator!.mute(mute);
      final mixResult = await ZegoUIKit().startMixerTask(streamCreator!.task);
      muting = false;
      if (mixResult.errorCode != 0) {
        isAnotherHostMuted.value = !mute;

        final error = PlatformException(
          code: '${mixResult.errorCode}',
          message: '${mixResult.extendedData}',
        );
        ZegoLoggerService.logError(
          'muteAnotherHostAudio, startMixerTask failed, code:${error.code}, message:${error.message}. ',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'api',
        );
      } else {
        ZegoLoggerService.logInfo(
          'muteAnotherHostAudio, startMixerTask success, extendedData:${mixResult.extendedData}',
          tag: 'ZegoLiveStreamingPKBattleService',
          subTag: 'api',
        );
      }
    }
  }

  String? get anotherHostLiveID {
    return streamCreator?.anotherHostLiveID;
  }

  ZegoUIKitUser? get anotherHost {
    if (streamCreator != null) {
      return ZegoUIKitUser(
          id: streamCreator!.anotherHostUserID,
          name: streamCreator!.anotherHostUserName);
    } else {
      return null;
    }
  }

  Future<void> onRoomAttributesUpdated(
      ZegoSignalingPluginRoomPropertiesUpdatedEvent propertiesData) async {
    ZegoLoggerService.logInfo(
      'onRoomAttributesUpdated, $propertiesData}',
      tag: 'ZegoLiveStreamingPKBattleService',
      subTag: 'event',
    );

    // audience stop watch pk
    if (propertiesData.deleteProperties.containsKey('pk_room')) {
      if (isHost) {
        return;
      }

      ZegoUIKit()
          .muteUserAudioVideo(hostManager.notifier.value?.id ?? '', false);
      ZegoUIKit().stopPlayMixAudioVideo(streamCreator!.mixerID);
      streamCreator = null;
      state.value = ZegoLiveStreamingPKBattleState.idle;
      config.onLiveStreamingStateUpdate?.call(
        isLiving ? ZegoLiveStreamingState.living : ZegoLiveStreamingState.idle,
      );
    }
    if (propertiesData.setProperties.containsKey('pk_room')) {
      final anotherHostLiveID = propertiesData.setProperties['pk_room']!;
      final anotherHostUserID = propertiesData.setProperties['pk_user_id']!;
      final anotherHostUserName = propertiesData.setProperties['pk_user_name']!;
      final hostID = propertiesData.setProperties['host']!;

      if (isHost) {
        if (!startedByLocalNotifier.value) {
          final completer = Completer<void>();
          void onLiveStartedByLocal() {
            if (startedByLocalNotifier.value) {
              completer.complete();
            }
            startedByLocalNotifier.removeListener(onLiveStartedByLocal);
          }

          startedByLocalNotifier.addListener(onLiveStartedByLocal);
          ZegoLoggerService.logInfo(
            'onRoomAttributesUpdated, waiting for startedByLocalNotifier',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
          await completer.future;
          ZegoLoggerService.logInfo(
            'onRoomAttributesUpdated, startedByLocalNotifier change to '
            'true, check liveStatusNotifier',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
        }

        if (liveStatusNotifier.value != LiveStatus.living) {
          final completer = Completer<void>();
          void onLiveStatusChanged() {
            if (liveStatusNotifier.value == LiveStatus.living) {
              completer.complete();
            }
            liveStatusNotifier.removeListener(onLiveStatusChanged);
          }

          liveStatusNotifier.addListener(onLiveStatusChanged);
          ZegoLoggerService.logInfo(
            'onRoomAttributesUpdated, waiting for liveStatusNotifier',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
          await completer.future;
          ZegoLoggerService.logInfo(
            'onRoomAttributesUpdated, liveStatusNotifier change to liveing, startPK',
            tag: 'ZegoLiveStreamingPKBattleService',
            subTag: 'event',
          );
        }
      }

      // host relogin room
      if ((isHost || hostID == ZegoUIKit().getLocalUser().id) &&
          state.value != ZegoLiveStreamingPKBattleState.inPKBattle) {
        startPKBattleWith(
          anotherHostLiveID: anotherHostLiveID,
          anotherHostUserID: anotherHostUserID,
          anotherHostUserName: anotherHostUserName,
        );
      }

      // audience
      if (!isHost) {
        /// hide invite join co-host dialog
        if (hostManager.connectManager?.isInvitedToJoinCoHostDlgVisible ??
            false) {
          hostManager.connectManager!.isInvitedToJoinCoHostDlgVisible = false;
          Navigator.of(
            contextQuery!(),
            rootNavigator: config.rootNavigator,
          ).pop();
        }

        /// hide co-host end request dialog
        if (hostManager.connectManager?.isEndCoHostDialogVisible ?? false) {
          hostManager.connectManager!.isEndCoHostDialogVisible = false;
          Navigator.of(
            contextQuery!(),
            rootNavigator: config.rootNavigator,
          ).pop();
        }
        // cancel audience's co-host request
        if (ZegoLiveStreamingAudienceConnectState.connecting ==
            hostManager
                .connectManager?.audienceLocalConnectStateNotifier.value) {
          hostManager.connectManager?.updateAudienceConnectState(
              ZegoLiveStreamingAudienceConnectState.idle);
          ZegoUIKit().getSignalingPlugin().cancelInvitation(
              invitees: [hostManager.notifier.value?.id ?? hostID], data: '');
        } else if (ZegoLiveStreamingAudienceConnectState.connected ==
            hostManager
                .connectManager?.audienceLocalConnectStateNotifier.value) {
          hostManager.connectManager?.updateAudienceConnectState(
              ZegoLiveStreamingAudienceConnectState.idle);

          final dialogInfo = innerText.coHostEndCauseByHostStartPK;
          showLiveDialog(
            context: context,
            rootNavigator: config.rootNavigator,
            title: dialogInfo.title,
            content: dialogInfo.message,
            rightButtonText: dialogInfo.confirmButtonName,
          );
        }

        assert(streamCreator == null);
        streamCreator ??= ZegoLiveStreamingPKBattleStreamCreator(
          anotherHostLiveID: anotherHostLiveID,
          anotherHostUserID: anotherHostUserID,
          anotherHostUserName: anotherHostUserName,
        );

        await ZegoUIKit().startPlayMixAudioVideo(
          streamCreator!.mixerID,
          [
            hostManager.notifier.value ?? ZegoUIKit().getUser(hostID),
            ZegoUIKitUser(id: anotherHostUserID, name: anotherHostUserName),
          ],
          {hostID: 0, anotherHostUserID: 1},
        );

        final mixAudioVideoLoaded =
            ZegoUIKit().getMixAudioVideoLoadedNotifier(streamCreator!.mixerID);
        if (mixAudioVideoLoaded.value) {
          state.value = ZegoLiveStreamingPKBattleState.inPKBattle;
          ZegoUIKit().muteUserAudioVideo(
              hostManager.notifier.value?.id ?? hostID, true);
        } else {
          state.value = ZegoLiveStreamingPKBattleState.loading;
        }

        void onMixAudioVideoLoadStatusChanged() {
          if (mixAudioVideoLoaded.value) {
            state.value = ZegoLiveStreamingPKBattleState.inPKBattle;
            ZegoUIKit().muteUserAudioVideo(
                hostManager.notifier.value?.id ?? hostID, true);
          }
          mixAudioVideoLoaded.removeListener(onMixAudioVideoLoadStatusChanged);
        }

        mixAudioVideoLoaded.addListener(onMixAudioVideoLoadStatusChanged);

        config.onLiveStreamingStateUpdate
            ?.call(ZegoLiveStreamingState.inPKBattle);
      }
    }
  }

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  factory ZegoLiveStreamingPKBattleManager() => _instance;
  static final ZegoLiveStreamingPKBattleManager _instance =
      ZegoLiveStreamingPKBattleManager._();

  ZegoLiveStreamingPKBattleManager._();
}

enum ZegoLiveStreamingPKBattleState {
  idle,
  waitingAnotherHostResponse,
  waitingMyResponse,
  loading,
  inPKBattle,
}

class ZegoLiveStreamingPKBattleStreamCreator {
  String anotherHostLiveID;
  String anotherHostUserID;
  String anotherHostUserName;
  late ZegoMixerTask task;

  ZegoLiveStreamingPKBattleStreamCreator({
    required this.anotherHostLiveID,
    required this.anotherHostUserID,
    required this.anotherHostUserName,
  }) {
    task = generateMixerTask();
  }

  void mute(bool mute) {
    task.inputList[1].contentType = mute
        ? ZegoMixerInputContentType.VideoOnly
        : ZegoMixerInputContentType.Video;
  }

  final String mixerID = '${ZegoUIKit().getRoom().id}__mix';

  String get anotherHostStreamID =>
      '${anotherHostLiveID}_${anotherHostUserID}_main';

  ZegoMixerTask generateMixerTask() {
    return ZegoMixerTask(mixerID)
      ..videoConfig.width = 360 * 2
      ..videoConfig.bitrate = 1500
      ..enableSoundLevel = true
      ..inputList = [
        // My Stream
        ZegoMixerInput.defaultConfig()
          ..streamID =
              '${ZegoUIKit().getRoom().id}_${ZegoUIKit().getLocalUser().id}_main'
          ..contentType = ZegoMixerInputContentType.Video
          ..layout = const Rect.fromLTWH(0, 0, 360, 640)
          ..soundLevelID = 0
          ..volume = 100
          ..renderMode = ZegoMixRenderMode.Fill,

        // Another Host Stream
        ZegoMixerInput.defaultConfig()
          ..streamID = anotherHostStreamID
          ..contentType = ZegoMixerInputContentType.Video
          ..layout = const Rect.fromLTWH(360, 0, 360, 640)
          ..soundLevelID = 1
          ..volume = 100
          ..renderMode = ZegoMixRenderMode.Fill
      ]
      ..outputList = [ZegoMixerOutput(mixerID)];
  }

  Map<String, String> get toRoomAttributes => {
        'host': ZegoUIKit().getLocalUser().id,
        'pk_room': anotherHostLiveID,
        'pk_user_id': anotherHostUserID,
        'pk_user_name': anotherHostUserName,
      };

  static List<String> get roomAttributesKeys => [
        'host',
        'pk_room',
        'pk_user_id',
        'pk_user_name',
      ];
}
