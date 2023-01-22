#import "PhPickerViewControllerPlugin.h"
#if __has_include(<ph_picker_view_controller/ph_picker_view_controller-Swift.h>)
#import <ph_picker_view_controller/ph_picker_view_controller-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ph_picker_view_controller-Swift.h"
#endif

@implementation PhPickerViewControllerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPhPickerViewControllerPlugin registerWithRegistrar:registrar];
}
@end
