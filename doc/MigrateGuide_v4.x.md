> This document aims to help users understand the APIs changes and feature improvements, and provide a migration guide for the upgrade process.
>
> It is an `incompatible change` if marked with `breaking changes`.
> You can run this command in `the root directory of your project` to output warnings and partial error prompts to assist you in finding deprecated parameters/functions or errors after upgrading.
>
> ```shell
> dart analyze | grep zego
> ```

<br />
<br />

# Versions

- [4.0.0](#400)  **(💥 breaking changes)**

<br />
<br />

# 4.0.0
---

## Introduction

This version introduces module reorganization and new localization support. The main changes involve updating import paths for existing modules and adding new localization options.

---

## Breaking Changes

### Package Re-export Removed

**Before:**
```dart
// This worked because zego_uikit was re-exported
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
ZegoUIKitUser user;  // Worked via transitive import
```

**After:**
```dart
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit/zego_uikit.dart';  // Now required
ZegoUIKitUser user;
```

---

## New Features

### 1. Localization Support

Added direct export support for localization text classes:

| Class | Description |
|-------|-------------|
| `ZegoUIKitPrebuiltLiveStreamingInnerTextHi` | Hindi localization |
| `ZegoUIKitPrebuiltLiveStreamingInnerTextZhCN` | Chinese localization |

```dart
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

// Use localized text
final hindiText = ZegoUIKitPrebuiltLiveStreamingInnerTextHi();
final chineseText = ZegoUIKitPrebuiltLiveStreamingInnerTextZhCN();
```

---

## Summary

1. **Update import paths** - Modules are now under `modules/` directory
2. **Add explicit zego_uikit import** - If you use types from `zego_uikit` package
3. **Use new localization** - Hindi and Chinese text classes are now directly exported
