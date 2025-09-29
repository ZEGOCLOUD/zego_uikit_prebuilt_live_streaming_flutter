#import "ZegoUIKitPrebuiltLiveStreamingPlugin.h"

@implementation ZegoUIKitPrebuiltLiveStreamingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"zego_uikit_prebuilt_live_streaming"
            binaryMessenger:[registrar messenger]];
  ZegoUIKitPrebuiltLiveStreamingPlugin* instance = [[ZegoUIKitPrebuiltLiveStreamingPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

@end
