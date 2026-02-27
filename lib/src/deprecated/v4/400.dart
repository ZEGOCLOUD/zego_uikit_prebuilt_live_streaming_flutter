// Project imports:

const deprecatedTipsV400 = ', '
    'deprecated since 4.0.0, '
    'will be removed in future versions'
    'Migrate Guide: https://pub.dev/documentation/zego_uikit_prebuilt_live_streaming/latest/topics/Migration_v4.x-topic.html';

// Re-export zego_uikit types for backward compatibility
//
// Note: This provides temporary backward compatibility.
// Users who relied on transitive imports from this package should import zego_uikit directly.
// This export will be removed in a future version.
//
// Migration example:
//
// Before (v3.x):
//   import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
//   ZegoUIKitUser user;
//
// After (v4.x):
//   import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
//   import 'package:zego_uikit/zego_uikit.dart';
//   ZegoUIKitUser user;
