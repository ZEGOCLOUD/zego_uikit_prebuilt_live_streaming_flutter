# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ZegoUIKitPrebuiltLiveStreaming is a Flutter plugin providing a prebuilt live streaming UI kit. It includes native platform implementations for Android and iOS, offering features like co-hosting, PK battles, beauty filters, screen sharing, and real-time chat.

**SDK Requirements:** Flutter 3.0.0+, Dart 3.0.0+

## Common Commands

```bash
# Install dependencies
flutter pub get

# Sort imports (required before committing)
flutter pub run import_sorter:main

# Run static analysis
flutter analyze

# Build Android
flutter build apk --debug
flutter build apk --release

# Build iOS
flutter build ios --debug
flutter build ios --release
```

## Architecture

### Directory Structure

```
lib/src/
├── [root]           # Core files: config.dart, controller.dart, events.dart
├── components/      # UI widgets (top_bar, bottom_bar, message/, member/)
├── core/           # Business logic managers (host_manager, connect_manager)
├── modules/        # Feature modules (hall/, pk/, minimization/, swiping/)
├── lifecycle/      # State machine lifecycle management
├── controller/     # Controller mixins and parts
└── internal/       # Internal utilities (reporter, events)
```

### Key Entry Points

- **Main widget:** `ZegoUIKitPrebuiltLiveStreaming` in `lib/src/live_streaming.dart`
- **Configuration:** `ZegoUIKitPrebuiltLiveStreamingConfig` in `lib/src/config.dart`
- **Controller:** `ZegoUIKitPrebuiltLiveStreamingController` singleton

### Core Patterns

**Manager Pattern:** `core/core_managers.dart` orchestrates multiple managers (`HostManager`, `ConnectManager`, `LiveStatusManager`) that handle business logic.

**Module Pattern:** Feature modules (`pk/`, `hall/`, `minimization/`, `swiping/`) are self-contained with their own controllers and defines.

**Configuration Pattern:** `ZegoUIKitPrebuiltLiveStreamingConfig` uses nested configs for different UI areas (`topMenuBar`, `bottomMenuBar`, `audioVideoView`, `pkBattle`, etc.).

**Event Pattern:** `ZegoUIKitPrebuiltLiveStreamingEvents` provides callbacks organized by feature (`room`, `pk`, `beauty`, `duration`).

### Dependency Management

This package is part of a monorepo. Local path overrides in `pubspec_overrides.yaml` reference sibling packages:
- `zego_uikit`
- `zego_uikit_signaling_plugin`
- `zego_plugin_adapter`

## Conventions

**Import ordering:** Use `// Dart imports:`, `// Flutter imports:`, `// Package imports:`, `// Project imports:` comment blocks, then run `flutter pub run import_sorter:main`

**Documentation:** `{@category}` tags categorize APIs, Events, Configs, and Components. `public_member_api_docs: true` lint rule requires documentation for all public members.

**Logging:** Use `ZegoLoggerService` for structured logging and `ZegoUIKit().reporter()` for analytics.

**Deprecated APIs:** Located in `lib/src/deprecated/` with version-specific migration guides.

## Localization

Default strings in `inner_text.dart`; Chinese translations in `inner_text_zh_cn.dart`, Hindi in `inner_text_hi.dart`.

## Native Code

- Android: `android/src/main/java/com/zegocloud/uikit/prebuilt_live_streaming/`
- iOS: `ios/Classes/`
