# CLAUDE.md

> **Note**: This library is part of the `zego_uikits` monorepo. See the root [CLAUDE.md](https://github.com/your-org/zego_uikits/blob/main/CLAUDE.md) for cross-library dependencies and architecture overview.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow Orchestration

### 1. Plan Node Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes - don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo.md`
6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimat Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

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
