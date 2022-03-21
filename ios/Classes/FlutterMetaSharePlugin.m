#import "FlutterMetaSharePlugin.h"
#if __has_include(<flutter_meta_share/flutter_meta_share-Swift.h>)
#import <flutter_meta_share/flutter_meta_share-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_meta_share-Swift.h"
#endif

@implementation FlutterMetaSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMetaSharePlugin registerWithRegistrar:registrar];
}
@end
