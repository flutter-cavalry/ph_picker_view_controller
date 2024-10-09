import 'package:ph_picker_view_controller/ph_picker_view_controller.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ph_picker_view_controller_method_channel.dart';

abstract class PhPickerViewControllerPlatform extends PlatformInterface {
  /// Constructs a PhPickerViewControllerPlatform.
  PhPickerViewControllerPlatform() : super(token: _token);

  static final Object _token = Object();

  static PhPickerViewControllerPlatform _instance =
      MethodChannelPhPickerViewController();

  /// The default instance of [PhPickerViewControllerPlatform] to use.
  ///
  /// Defaults to [MethodChannelPhPickerViewController].
  static PhPickerViewControllerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PhPickerViewControllerPlatform] when
  /// they register themselves.
  static set instance(PhPickerViewControllerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<PHPickerResult>?> pick({
    Map<String, List<String>>? filter,
    int? selectionLimit,
    PHPickerAssetRepresentationMode? preferredAssetRepresentationMode,
    PHPickerSelection? selection,
    String? fileRepresentation,
    bool? appendLiveVideos,
  }) {
    throw UnimplementedError('pick() has not been implemented.');
  }

  Future<bool> delete(List<String> ids) {
    throw UnimplementedError('delete() has not been implemented.');
  }
}
