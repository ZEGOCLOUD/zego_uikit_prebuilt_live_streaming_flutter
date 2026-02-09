> This document aims to help users understand the APIs changes and feature improvements, and provide a migration guide for the upgrade process.
>
> It is an `incompatible change` if marked with `breaking changes`.
> You can run this command in `the root directory of your project` to output warnings and partial error prompts to assist you in finding deprecated parameters/functions or errors after upgrading.
> 
> ```shell
> dart analyze | grep zego
> ```
>
> 
> Versions
> - 4.0.0  (💥 breaking changes)
>
> 
> # 4.0.0
> ---
>
> # Introduction
>
> 4.0 aligns with `zego_uikit 3.0`, removes 3.x deprecated APIs, consolidates controller namespaces, and refactors PK/co-host modules for consistency.
>
> # Major Interface Changes
>
> - Dependencies
>   - require `zego_uikit: ^3.0.0`
>
> - Controller namespace consolidation
>   - use `ZegoUIKitPrebuiltLiveStreamingController()` singleton
>   - minimization APIs: `controller.minimize.{state,isMinimizing,restore,minimize,hide}`
>   - audio/video: `controller.audioVideo.{camera,microphone,audioOutput}`
>   - co-host: `controller.coHost.*`
>   - PK: `controller.pk.*`
>   - screen: `controller.screen.*` and `controller.pip.*`
>
> - Config updates
  - `audioVideoView`: type changed from `ZegoPrebuiltAudioVideoViewConfig` to `ZegoLiveStreamingAudioVideoViewConfig`
  - `topMenuBar`: type changed from `ZegoTopMenuBarConfig` to `ZegoLiveStreamingTopMenuBarConfig`
  - `bottomMenuBar`: type changed from `ZegoBottomMenuBarConfig` to `ZegoLiveStreamingBottomMenuBarConfig`
  - `inRoomMessage`: type changed from `ZegoInRoomMessageConfig` to `ZegoLiveStreamingInRoomMessageConfig`
  - `memberList`: type changed from `ZegoMemberListConfig` to `ZegoLiveStreamingMemberListConfig`
  - `audioEffect`: type changed from `ZegoAudioEffectConfig` to `ZegoLiveStreamingAudioEffectConfig`
  - `duration`: type changed from `ZegoLiveDurationConfig` to `ZegoLiveStreamingDurationConfig`
  - `mediaPlayer`: type changed from `ZegoMediaPlayerConfig` to `ZegoLiveStreamingMediaPlayerConfig`
  - `backgroundMedia`: type changed from `ZegoBackgroundMediaConfig` to `ZegoLiveStreamingBackgroundMediaConfig`

- Events renames
>   - host/audience events consolidated under `ZegoLiveStreamingCoHost{Host|Audience}Events`
>   - PK events unified as `ZegoLiveStreamingPKEvents` with specific event data types
>
> ## Deprecated → New API Mapping (from 3.x)
> - typedefs:
>   - ZegoTranslationText → ZegoInnerText
>   - ZegoUIKitPrebuiltLiveStreamingPKUser → ZegoLiveStreamingPKUser
>   - ZegoLiveStreamingPKControllerV2 → ZegoLiveStreamingPKController
>   - ZegoUIKitPrebuiltLiveStreamingPKV2Events → ZegoLiveStreamingPKEvents
>
> - controller extensions:
>   - `connect / connectInvite` → `coHost`
>   - `pkV2` → `pk`
>
> - config extensions:
>   - `topMenuBarConfig` → `topMenuBar`
>   - `bottomMenuBarConfig` → `bottomMenuBar`
>   - `inRoomMessageConfig / inRoomMessageViewConfig` → `inRoomMessage`
>   - `memberListConfig` → `memberList`
>   - `audioEffectConfig` → `audioEffect`
>   - `durationConfig` → `duration`
>   - `mediaPlayerConfig` → `mediaPlayer`
>   - `backgroundMediaConfig` → `backgroundMedia`
>
> ### Migration Guide
>
> 3.x Version Code:
> ```dart
> config
>   ..audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig()
>   ..topMenuBarConfig = ZegoTopMenuBarConfig()
>   ..inRoomMessageConfig = ZegoInRoomMessageConfig();
> 
> final controller = ZegoUIKitPrebuiltLiveStreamingController();
> controller.connectInvite.sendRequest(...);
> controller.pkV2.start(...);
> ```
>
> 4.0.0 Version Code:
> ```dart
> config
>   ..audioVideoView = ZegoLiveStreamingAudioVideoViewConfig()
>   ..topMenuBar = ZegoTopMenuBarConfig()
>   ..inRoomMessage = ZegoLiveStreamingInRoomMessageConfig();
> 
> final controller = ZegoUIKitPrebuiltLiveStreamingController();
> controller.coHost.sendRequest(...);
> controller.pk.start(...);
> ```
>
> ### Compatibility Notes
> - All 3.x `@Deprecated` symbols are removed in 4.0.
> - If analyzer still reports errors, run:
> ```shell
> dart analyze | grep zego
> ```
>
