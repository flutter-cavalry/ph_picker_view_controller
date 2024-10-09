import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ph_picker_view_controller/ph_picker_view_controller.dart';

import 'ph_picker_view_controller_platform_interface.dart';

/// An implementation of [PhPickerViewControllerPlatform] that uses method channels.
class MethodChannelPhPickerViewController
    extends PhPickerViewControllerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ph_picker_view_controller');

  @override
  Future<List<PHPickerResult>?> pick({
    Map<String, List<String>>? filter,
    int? selectionLimit,
    PHPickerAssetRepresentationMode? preferredAssetRepresentationMode,
    PHPickerSelection? selection,
    String? fileRepresentation,
    bool? appendLiveVideos,
  }) async {
    var rawList = await methodChannel.invokeMethod<List<dynamic>>('pick', {
      'filter': filter,
      'selectionLimit': selectionLimit,
      'preferredAssetRepresentationMode':
          preferredAssetRepresentationMode?.name,
      'selection': selection?.name,
      'fileRepresentation': fileRepresentation,
      'appendLiveVideos': appendLiveVideos,
    });
    if (rawList == null) {
      return null;
    }
    return rawList.map((e) => PHPickerResult.fromMap(e)).toList();
  }

  @override
  Future<bool> delete(List<String> ids) async {
    return (await methodChannel.invokeMethod<bool>('delete', {"ids": ids})) ??
        false;
  }
}
