#import "FlutterFundingChoicesPlugin.h"
#if __has_include(<flutter_funding_choices/flutter_funding_choices-Swift.h>)
#import <flutter_funding_choices/flutter_funding_choices-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_funding_choices-Swift.h"
#endif

@implementation FlutterFundingChoicesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterFundingChoicesPlugin registerWithRegistrar:registrar];
}
@end
