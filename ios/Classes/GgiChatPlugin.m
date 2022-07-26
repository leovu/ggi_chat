#import "GgiChatPlugin.h"
#if __has_include(<ggi_chat/ggi_chat-Swift.h>)
#import <ggi_chat/ggi_chat-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ggi_chat-Swift.h"
#endif

@implementation GgiChatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGgiChatPlugin registerWithRegistrar:registrar];
}
@end
