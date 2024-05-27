// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

const deprecatedTipsV300 = ', '
    'deprecated since 3.0.0, '
    'will be removed after 3.10.0'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/topics/Migration_v3.0-topic.html';

@Deprecated(
    'use ZegoUIKitPrebuiltLiveStreamingController().minimize instead$deprecatedTipsV300')
class ZegoUIKitPrebuiltLiveStreamingMiniOverlayMachine {
  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.state instead$deprecatedTipsV300')
  PrebuiltLiveStreamingMiniOverlayPageState get state =>
      ZegoUIKitPrebuiltLiveStreamingController().minimize.state;

  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing instead$deprecatedTipsV300')
  bool get isMinimizing =>
      ZegoUIKitPrebuiltLiveStreamingController().minimize.isMinimizing;

  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.restore instead$deprecatedTipsV300')
  bool restoreFromMinimize(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  }) {
    return ZegoUIKitPrebuiltLiveStreamingController().minimize.restore(
          context,
          rootNavigator: rootNavigator,
          withSafeArea: withSafeArea,
        );
  }

  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize instead$deprecatedTipsV300')
  bool minimize(
    BuildContext context, {
    bool rootNavigator = true,
  }) {
    return ZegoUIKitPrebuiltLiveStreamingController().minimize.minimize(
          context,
          rootNavigator: rootNavigator,
        );
  }

  @Deprecated(
      'use ZegoUIKitPrebuiltLiveStreamingController().minimize.hide instead$deprecatedTipsV300')
  void resetInLiving() {
    ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
  }
}

@Deprecated(
    'use ZegoLiveStreamingMiniOverlayPageState().minimize instead$deprecatedTipsV300')
typedef PrebuiltLiveStreamingMiniOverlayPageState
    = ZegoLiveStreamingMiniOverlayPageState;
@Deprecated(
    'use ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage instead$deprecatedTipsV300')
typedef ZegoMiniOverlayPage = ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage;

@Deprecated('Use ZegoInnerText instead$deprecatedTipsV300')
typedef ZegoTranslationText = ZegoInnerText;

@Deprecated(
    'Use ZegoLiveStreamingAudioVideoViewConfig instead$deprecatedTipsV300')
typedef ZegoPrebuiltAudioVideoViewConfig
    = ZegoLiveStreamingAudioVideoViewConfig;

@Deprecated('Use ZegoLiveStreamingTopMenuBarConfig instead$deprecatedTipsV300')
typedef ZegoTopMenuBarConfig = ZegoLiveStreamingTopMenuBarConfig;

@Deprecated(
    'Use ZegoLiveStreamingBottomMenuBarConfig instead$deprecatedTipsV300')
typedef ZegoBottomMenuBarConfig = ZegoLiveStreamingBottomMenuBarConfig;

@Deprecated(
    'Use ZegoLiveStreamingMenuBarExtendButton instead$deprecatedTipsV300')
typedef ZegoMenuBarExtendButton = ZegoLiveStreamingMenuBarExtendButton;

@Deprecated(
    'use ZegoLiveStreamingBottomMenuBarButtonStyle instead$deprecatedTipsV300')
typedef ZegoBottomMenuBarButtonStyle
    = ZegoLiveStreamingBottomMenuBarButtonStyle;

@Deprecated(
    'Use ZegoLiveStreamingMemberButtonConfig instead$deprecatedTipsV300')
typedef ZegoMemberButtonConfig = ZegoLiveStreamingMemberButtonConfig;

@Deprecated('Use ZegoLiveStreamingMemberListConfig instead$deprecatedTipsV300')
typedef ZegoMemberListConfig = ZegoLiveStreamingMemberListConfig;

@Deprecated(
    'Use ZegoLiveStreamingInRoomMessageConfig instead$deprecatedTipsV300')
typedef ZegoInRoomMessageConfig = ZegoLiveStreamingInRoomMessageConfig;
@Deprecated(
    'Use ZegoLiveStreamingInRoomMessageConfig instead$deprecatedTipsV300')
typedef ZegoInRoomMessageViewConfig = ZegoLiveStreamingInRoomMessageConfig;

@Deprecated('Use ZegoLiveStreamingEffectConfig instead$deprecatedTipsV300')
typedef ZegoEffectConfig = ZegoLiveStreamingEffectConfig;

@Deprecated('Use ZegoLiveStreamingPKBattleConfig instead$deprecatedTipsV300')
typedef ZegoLiveStreamingPKBattleV2Config = ZegoLiveStreamingPKBattleConfig;

@Deprecated('Use ZegoLiveStreamingDurationConfig instead$deprecatedTipsV300')
typedef ZegoLiveDurationConfig = ZegoLiveStreamingDurationConfig;

@Deprecated('Use ZegoLiveStreamingMediaPlayerConfig instead$deprecatedTipsV300')
typedef ZegoMediaPlayerConfig = ZegoLiveStreamingMediaPlayerConfig;

@Deprecated('Use ZegoLiveStreamingCoHostHostEvents instead$deprecatedTipsV300')
typedef ZegoUIKitPrebuiltLiveStreamingHostEvents
    = ZegoLiveStreamingCoHostHostEvents;

@Deprecated(
    'Use ZegoLiveStreamingCoHostAudienceEvents instead$deprecatedTipsV300')
typedef ZegoUIKitPrebuiltLiveStreamingAudienceEvents
    = ZegoLiveStreamingCoHostAudienceEvents;

@Deprecated('Use ZegoPKMixerLayout instead$deprecatedTipsV300')
typedef ZegoPKV2MixerLayout = ZegoLiveStreamingPKMixerLayout;

@Deprecated('Use ZegoLiveStreamingPKUser instead$deprecatedTipsV300')
typedef ZegoUIKitPrebuiltLiveStreamingPKUser = ZegoLiveStreamingPKUser;

@Deprecated('Use ZegoLiveStreamingPKController instead$deprecatedTipsV300')
typedef ZegoLiveStreamingPKControllerV2 = ZegoLiveStreamingPKController;

@Deprecated('Use ZegoLiveStreamingPKEvents instead$deprecatedTipsV300')
typedef ZegoUIKitPrebuiltLiveStreamingPKV2Events = ZegoLiveStreamingPKEvents;

@Deprecated(
    'Use ZegoIncomingPKBattleRequestReceivedEvent instead$deprecatedTipsV300')
typedef ZegoIncomingPKBattleRequestReceivedEventV2
    = ZegoIncomingPKBattleRequestReceivedEvent;

@Deprecated(
    'Use ZegoIncomingPKBattleRequestCancelledEvent instead$deprecatedTipsV300')
typedef ZegoIncomingPKBattleRequestCancelledEventV2
    = ZegoIncomingPKBattleRequestCancelledEvent;

@Deprecated(
    'Use ZegoIncomingPKBattleRequestTimeoutEvent instead$deprecatedTipsV300')
typedef ZegoIncomingPKBattleRequestTimeoutEventV2
    = ZegoIncomingPKBattleRequestTimeoutEvent;

@Deprecated(
    'Use ZegoOutgoingPKBattleRequestAcceptedEvent instead$deprecatedTipsV300')
typedef ZegoOutgoingPKBattleRequestAcceptedEventV2
    = ZegoOutgoingPKBattleRequestAcceptedEvent;

@Deprecated(
    'Use ZegoOutgoingPKBattleRequestRejectedEvent instead$deprecatedTipsV300')
typedef ZegoOutgoingPKBattleRequestRejectedEventV2
    = ZegoOutgoingPKBattleRequestRejectedEvent;

@Deprecated(
    'Use ZegoOutgoingPKBattleRequestTimeoutEvent instead$deprecatedTipsV300')
typedef ZegoOutgoingPKBattleRequestTimeoutEventV2
    = ZegoOutgoingPKBattleRequestTimeoutEvent;

@Deprecated('Use ZegoPKBattleEndedEvent instead$deprecatedTipsV300')
typedef ZegoPKBattleEndedEventV2 = ZegoPKBattleEndedEvent;

@Deprecated('Use ZegoPKBattleUserOfflineEvent instead$deprecatedTipsV300')
typedef ZegoPKBattleUserOfflineEventV2 = ZegoPKBattleUserOfflineEvent;

@Deprecated('Use ZegoPKBattleUserQuitEvent instead$deprecatedTipsV300')
typedef ZegoPKBattleUserQuitEventV2 = ZegoPKBattleUserQuitEvent;

@Deprecated('Use ZegoLiveStreamingPKBattleState instead$deprecatedTipsV300')
typedef ZegoLiveStreamingPKBattleStateV2 = ZegoLiveStreamingPKBattleState;

extension ZegoLiveStreamingConfigDeprecated
    on ZegoUIKitPrebuiltLiveStreamingConfig {
  @Deprecated('Use mediaPlayer instead$deprecatedTipsV300')
  ZegoMediaPlayerConfig get mediaPlayerConfig => mediaPlayer;

  @Deprecated('Use mediaPlayer instead$deprecatedTipsV300')
  set mediaPlayerConfig(ZegoMediaPlayerConfig config) => mediaPlayer = config;

  @Deprecated('Use video instead$deprecatedTipsV300')
  ZegoUIKitVideoConfig get videoConfig => video;

  @Deprecated('Use video instead$deprecatedTipsV300')
  set videoConfig(ZegoUIKitVideoConfig config) => videoConfig = config;

  @Deprecated('Use audioVideoView instead$deprecatedTipsV300')
  ZegoPrebuiltAudioVideoViewConfig get audioVideoViewConfig => audioVideoView;

  @Deprecated('Use audioVideoView instead$deprecatedTipsV300')
  set audioVideoViewConfig(ZegoPrebuiltAudioVideoViewConfig config) =>
      audioVideoView = config;

  @Deprecated('Use topMenuBar instead$deprecatedTipsV300')
  ZegoTopMenuBarConfig get topMenuBarConfig => topMenuBar;

  @Deprecated('Use topMenuBar instead$deprecatedTipsV300')
  set topMenuBarConfig(ZegoTopMenuBarConfig config) => topMenuBar = config;

  @Deprecated('Use bottomMenuBar instead$deprecatedTipsV300')
  ZegoBottomMenuBarConfig get bottomMenuBarConfig => bottomMenuBar;

  @Deprecated('Use bottomMenuBar instead$deprecatedTipsV300')
  set bottomMenuBarConfig(ZegoBottomMenuBarConfig config) =>
      bottomMenuBar = config;

  @Deprecated('Use memberButton instead$deprecatedTipsV300')
  ZegoMemberButtonConfig get memberButtonConfig => memberButton;

  @Deprecated('Use memberButton instead$deprecatedTipsV300')
  set memberButtonConfig(ZegoMemberButtonConfig config) =>
      memberButton = config;

  @Deprecated('Use memberList instead$deprecatedTipsV300')
  ZegoMemberListConfig get memberListConfig => memberList;

  @Deprecated('Use memberList instead$deprecatedTipsV300')
  set memberListConfig(ZegoMemberListConfig config) => memberList = config;

  @Deprecated('Use inRoomMessage instead$deprecatedTipsV300')
  ZegoInRoomMessageConfig get inRoomMessageConfig => inRoomMessage;

  @Deprecated('Use inRoomMessage instead$deprecatedTipsV300')
  ZegoInRoomMessageViewConfig get inRoomMessageViewConfig => inRoomMessage;

  @Deprecated('Use inRoomMessage instead$deprecatedTipsV300')
  set inRoomMessageConfig(ZegoInRoomMessageConfig config) =>
      inRoomMessage = config;

  @Deprecated('Use inRoomMessage instead$deprecatedTipsV300')
  set inRoomMessageViewConfig(ZegoInRoomMessageViewConfig config) =>
      inRoomMessage = config;

  @Deprecated('Use effect instead$deprecatedTipsV300')
  ZegoEffectConfig get effectConfig => effect;

  @Deprecated('Use effect instead$deprecatedTipsV300')
  set effectConfig(ZegoEffectConfig config) => effect = config;

  @Deprecated('Use beauty instead$deprecatedTipsV300')
  ZegoBeautyPluginConfig? get beautyConfig => beauty;

  @Deprecated('Use beauty instead$deprecatedTipsV300')
  set beautyConfig(ZegoBeautyPluginConfig? config) => beauty = config;

  @Deprecated('Use preview instead$deprecatedTipsV300')
  ZegoLiveStreamingPreviewConfig get previewConfig => preview;

  @Deprecated('Use preview instead$deprecatedTipsV300')
  set previewConfig(ZegoLiveStreamingPreviewConfig config) => preview = config;

  @Deprecated('Use pkBattle instead$deprecatedTipsV300')
  ZegoLiveStreamingPKBattleV2Config get pkBattleV2Config => pkBattle;

  @Deprecated('Use pkBattle instead$deprecatedTipsV300')
  set pkBattleV2Config(ZegoLiveStreamingPKBattleV2Config config) =>
      pkBattle = config;

  @Deprecated('Use duration instead$deprecatedTipsV300')
  ZegoLiveDurationConfig get durationConfig => duration;

  @Deprecated('Use duration instead$deprecatedTipsV300')
  set durationConfig(ZegoLiveDurationConfig config) => duration = config;

  @Deprecated('Use preview.startLiveButtonBuilder instead$deprecatedTipsV300')
  ZegoStartLiveButtonBuilder? get startLiveButtonBuilder =>
      preview.startLiveButtonBuilder;

  @Deprecated('Use preview.startLiveButtonBuilder instead$deprecatedTipsV300')
  set startLiveButtonBuilder(ZegoStartLiveButtonBuilder? value) =>
      preview.startLiveButtonBuilder = value;

  @Deprecated('Use innerText instead$deprecatedTipsV300')
  ZegoTranslationText get translationText => innerText;

  @Deprecated('Use innerText instead$deprecatedTipsV300')
  set translationText(ZegoTranslationText text) => innerText = text;
}

extension ZegoLiveStreamingControllerDeprecated
    on ZegoUIKitPrebuiltLiveStreamingController {
  @Deprecated('Use coHost instead$deprecatedTipsV300')
  ZegoLiveStreamingControllerCoHostImpl get connect => coHost;

  @Deprecated('Use coHost instead$deprecatedTipsV300')
  ZegoLiveStreamingControllerCoHostImpl get connectInvite => coHost;

  @Deprecated('Use pk instead$deprecatedTipsV300')
  ZegoLiveStreamingPKControllerV2 get pkV2 => pk;
}

extension ZegoLiveStreamingEventsDeprecated
    on ZegoUIKitPrebuiltLiveStreamingEvents {
  @Deprecated('Use coHost.onMaxCountReached instead$deprecatedTipsV300')
  void Function(int count)? get onMaxCoHostReached => coHost.onMaxCountReached;

  @Deprecated('Use coHost.onMaxCountReached instead$deprecatedTipsV300')
  set onMaxCoHostReached(void Function(int count)? value) =>
      coHost.onMaxCountReached = value;

  @Deprecated('Use coHost.onUpdated instead$deprecatedTipsV300')
  Function(List<ZegoUIKitUser> coHosts)? get onCoHostsUpdated =>
      coHost.onUpdated;

  @Deprecated('Use coHost.onUpdated instead$deprecatedTipsV300')
  set onCoHostsUpdated(Function(List<ZegoUIKitUser> coHosts)? value) =>
      coHost.onUpdated = value;

  @Deprecated('Use coHost.host instead$deprecatedTipsV300')
  ZegoUIKitPrebuiltLiveStreamingHostEvents get hostEvents => coHost.host;

  @Deprecated('Use coHost.host instead$deprecatedTipsV300')
  set hostEvents(ZegoUIKitPrebuiltLiveStreamingHostEvents value) =>
      coHost.host = value;

  @Deprecated('Use coHost.audience instead$deprecatedTipsV300')
  ZegoUIKitPrebuiltLiveStreamingAudienceEvents get audienceEvents =>
      coHost.audience;

  @Deprecated('Use coHost.audience instead$deprecatedTipsV300')
  set audienceEvents(ZegoUIKitPrebuiltLiveStreamingAudienceEvents value) =>
      coHost.audience = value;

  @Deprecated('Use pk instead$deprecatedTipsV300')
  ZegoUIKitPrebuiltLiveStreamingPKV2Events get pkV2Events => pk;

  @Deprecated('Use pk instead$deprecatedTipsV300')
  set pkV2Events(ZegoUIKitPrebuiltLiveStreamingPKV2Events value) => pk = value;
}

@Deprecated(
    'Use ZegoUIKitPrebuiltLiveStreamingHostEvents instead$deprecatedTipsV300')
extension ZegoLiveStreamingHostEventsExtension
    on ZegoUIKitPrebuiltLiveStreamingHostEvents {
  @Deprecated('Use onRequestReceived instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostHostEventRequestReceivedData)?
      get onCoHostRequestReceived => onRequestReceived;

  @Deprecated('Use onRequestReceived instead$deprecatedTipsV300')
  set onCoHostRequestReceived(
          Function(ZegoLiveStreamingCoHostHostEventRequestReceivedData)?
              value) =>
      onRequestReceived = value;

  @Deprecated('Use onRequestCanceled instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostHostEventRequestCanceledData)?
      get onCoHostRequestCanceled => onRequestCanceled;

  @Deprecated('Use onRequestCanceled instead$deprecatedTipsV300')
  set onCoHostRequestCanceled(
          Function(ZegoLiveStreamingCoHostHostEventRequestCanceledData)?
              value) =>
      onRequestCanceled = value;

  @Deprecated('Use onRequestTimeout instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostHostEventRequestTimeoutData)?
      get onCoHostRequestTimeout => onRequestTimeout;

  @Deprecated('Use onRequestTimeout instead$deprecatedTipsV300')
  set onCoHostRequestTimeout(
          Function(ZegoLiveStreamingCoHostHostEventRequestTimeoutData)?
              value) =>
      onRequestTimeout = value;

  @Deprecated('Use onActionAcceptRequest instead$deprecatedTipsV300')
  Function()? get onActionAcceptCoHostRequest => onActionAcceptRequest;

  @Deprecated('Use onActionAcceptRequest instead$deprecatedTipsV300')
  set onActionAcceptCoHostRequest(Function()? value) =>
      onActionAcceptRequest = value;

  @Deprecated('Use onActionRefuseRequest instead$deprecatedTipsV300')
  Function()? get onActionRefuseCoHostRequest => onActionRefuseRequest;

  @Deprecated('Use onActionRefuseRequest instead$deprecatedTipsV300')
  set onActionRefuseCoHostRequest(Function()? value) =>
      onActionRefuseRequest = value;

  @Deprecated('Use onInvitationSent instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostHostEventInvitationSentData)?
      get onCoHostInvitationSent => onInvitationSent;

  @Deprecated('Use onInvitationSent instead$deprecatedTipsV300')
  set onCoHostInvitationSent(
          Function(ZegoLiveStreamingCoHostHostEventInvitationSentData)?
              value) =>
      onInvitationSent = value;

  @Deprecated('Use onInvitationTimeout instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostHostEventInvitationTimeoutData)?
      get onCoHostInvitationTimeout => onInvitationTimeout;

  @Deprecated('Use onInvitationTimeout instead$deprecatedTipsV300')
  set onCoHostInvitationTimeout(
          Function(ZegoLiveStreamingCoHostHostEventInvitationTimeoutData)?
              value) =>
      onInvitationTimeout = value;

  @Deprecated('Use onInvitationAccepted instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostHostEventInvitationAcceptedData)?
      get onCoHostInvitationAccepted => onInvitationAccepted;

  @Deprecated('Use onInvitationAccepted instead$deprecatedTipsV300')
  set onCoHostInvitationAccepted(
          Function(ZegoLiveStreamingCoHostHostEventInvitationAcceptedData)?
              value) =>
      onInvitationAccepted = value;

  @Deprecated('Use onInvitationRefused instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostHostEventInvitationRefusedData)?
      get onCoHostInvitationRefused => onInvitationRefused;

  @Deprecated('Use onInvitationRefused instead$deprecatedTipsV300')
  set onCoHostInvitationRefused(
          Function(ZegoLiveStreamingCoHostHostEventInvitationRefusedData)?
              value) =>
      onInvitationRefused = value;
}

@Deprecated(
    'Use ZegoUIKitPrebuiltLiveStreamingAudienceEvents instead$deprecatedTipsV300')
extension ZegoLiveStreamingAudienceEventsExtension
    on ZegoUIKitPrebuiltLiveStreamingAudienceEvents {
  @Deprecated('Use onRequestSent instead$deprecatedTipsV300')
  Function()? get onCoHostRequestSent => onRequestSent;

  @Deprecated('Use onRequestSent instead$deprecatedTipsV300')
  set onCoHostRequestSent(Function()? value) => onRequestSent = value;

  @Deprecated('Use onActionCancelRequest instead$deprecatedTipsV300')
  Function()? get onActionCancelCoHostRequest => onActionCancelRequest;

  @Deprecated('Use onActionCancelRequest instead$deprecatedTipsV300')
  set onActionCancelCoHostRequest(Function()? value) =>
      onActionCancelRequest = value;

  @Deprecated('Use onRequestTimeout instead$deprecatedTipsV300')
  Function()? get onCoHostRequestTimeout => onRequestTimeout;

  @Deprecated('Use onRequestTimeout instead$deprecatedTipsV300')
  set onCoHostRequestTimeout(Function()? value) => onRequestTimeout = value;

  @Deprecated('Use onRequestAccepted instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData)?
      get onCoHostRequestAccepted => onRequestAccepted;

  @Deprecated('Use onRequestAccepted instead$deprecatedTipsV300')
  set onCoHostRequestAccepted(
          Function(ZegoLiveStreamingCoHostAudienceEventRequestAcceptedData)?
              value) =>
      onRequestAccepted = value;

  @Deprecated('Use onRequestRefused instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostAudienceEventRequestRefusedData)?
      get onCoHostRequestRefused => onRequestRefused;

  @Deprecated('Use onRequestRefused instead$deprecatedTipsV300')
  set onCoHostRequestRefused(
          Function(ZegoLiveStreamingCoHostAudienceEventRequestRefusedData)?
              value) =>
      onRequestRefused = value;

  @Deprecated('Use onInvitationReceived instead$deprecatedTipsV300')
  Function(ZegoLiveStreamingCoHostAudienceEventRequestReceivedData)?
      get onCoHostInvitationReceived => onInvitationReceived;

  @Deprecated('Use onInvitationReceived instead$deprecatedTipsV300')
  set onCoHostInvitationReceived(
          void Function(
                  ZegoLiveStreamingCoHostAudienceEventRequestReceivedData)?
              value) =>
      onInvitationReceived = value;

  @Deprecated('Use onInvitationTimeout instead$deprecatedTipsV300')
  Function()? get onCoHostInvitationTimeout => onInvitationTimeout;

  @Deprecated('Use onInvitationTimeout instead$deprecatedTipsV300')
  set onCoHostInvitationTimeout(Function()? value) =>
      onInvitationTimeout = value;

  @Deprecated('Use onActionAcceptInvitation instead$deprecatedTipsV300')
  Function()? get onActionAcceptCoHostInvitation => onActionAcceptInvitation;

  @Deprecated('Use onActionAcceptInvitation instead$deprecatedTipsV300')
  set onActionAcceptCoHostInvitation(Function()? value) =>
      onActionAcceptInvitation = value;

  @Deprecated('Use onActionRefuseInvitation instead$deprecatedTipsV300')
  Function()? get onActionRefuseCoHostInvitation => onActionRefuseInvitation;

  @Deprecated('Use onActionRefuseInvitation instead$deprecatedTipsV300')
  set onActionRefuseCoHostInvitation(Function()? value) =>
      onActionRefuseInvitation = value;
}

@Deprecated('Use ZegoLiveStreamingPKEvents instead$deprecatedTipsV300')
extension ZegoLiveStreamingPKEventsExtension on ZegoLiveStreamingPKEvents {
  @Deprecated('Use onIncomingRequestReceived instead')
  void Function(
    ZegoIncomingPKBattleRequestReceivedEvent event,
    VoidCallback defaultAction,
  )? get onIncomingPKBattleRequestReceived => onIncomingRequestReceived;

  @Deprecated('Use onIncomingRequestReceived instead')
  set onIncomingPKBattleRequestReceived(
          void Function(
            ZegoIncomingPKBattleRequestReceivedEvent event,
            VoidCallback defaultAction,
          )? value) =>
      onIncomingRequestReceived = value;

  @Deprecated('Use onIncomingRequestCancelled instead$deprecatedTipsV300')
  Function(
    ZegoIncomingPKBattleRequestCancelledEventV2 event,
    VoidCallback defaultAction,
  )? get onIncomingPKBattleRequestCancelled => onIncomingRequestCancelled;

  @Deprecated('Use onIncomingRequestCancelled instead$deprecatedTipsV300')
  set onIncomingPKBattleRequestCancelled(
          Function(
            ZegoIncomingPKBattleRequestCancelledEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onIncomingRequestCancelled = value;

  @Deprecated('Use onIncomingRequestTimeout instead$deprecatedTipsV300')
  void Function(
    ZegoIncomingPKBattleRequestTimeoutEventV2 event,
    VoidCallback defaultAction,
  )? get onIncomingPKBattleRequestTimeout => onIncomingRequestTimeout;

  @Deprecated('Use onIncomingRequestTimeout instead$deprecatedTipsV300')
  set onIncomingPKBattleRequestTimeout(
          void Function(
            ZegoIncomingPKBattleRequestTimeoutEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onIncomingRequestTimeout = value;

  @Deprecated('Use onOutgoingRequestAccepted instead$deprecatedTipsV300')
  void Function(
    ZegoOutgoingPKBattleRequestAcceptedEventV2 event,
    VoidCallback defaultAction,
  )? get onOutgoingPKBattleRequestAccepted => onOutgoingRequestAccepted;

  @Deprecated('Use onOutgoingRequestAccepted instead$deprecatedTipsV300')
  set onOutgoingPKBattleRequestAccepted(
          void Function(
            ZegoOutgoingPKBattleRequestAcceptedEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onOutgoingRequestAccepted = value;

  @Deprecated('Use onOutgoingRequestRejected instead$deprecatedTipsV300')
  void Function(
    ZegoOutgoingPKBattleRequestRejectedEventV2 event,
    VoidCallback defaultAction,
  )? get onOutgoingPKBattleRequestRejected => onOutgoingRequestRejected;

  @Deprecated('Use onOutgoingRequestRejected instead$deprecatedTipsV300')
  set onOutgoingPKBattleRequestRejected(
          void Function(
            ZegoOutgoingPKBattleRequestRejectedEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onOutgoingRequestRejected = value;

  @Deprecated('Use onOutgoingRequestTimeout instead$deprecatedTipsV300')
  void Function(
    ZegoOutgoingPKBattleRequestTimeoutEventV2 event,
    VoidCallback defaultAction,
  )? get onOutgoingPKBattleRequestTimeout => onOutgoingRequestTimeout;

  @Deprecated('Use onOutgoingRequestTimeout instead$deprecatedTipsV300')
  set onOutgoingPKBattleRequestTimeout(
          void Function(
            ZegoOutgoingPKBattleRequestTimeoutEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onOutgoingRequestTimeout = value;

  @Deprecated('Use onEnded instead$deprecatedTipsV300')
  void Function(
    ZegoPKBattleEndedEventV2 event,
    VoidCallback defaultAction,
  )? get onPKBattleEnded => onEnded;

  @Deprecated('Use onEnded instead$deprecatedTipsV300')
  set onPKBattleEnded(
          void Function(
            ZegoPKBattleEndedEventV2 event,
            VoidCallback defaultAction,
          )? value) =>
      onEnded = value;
}
