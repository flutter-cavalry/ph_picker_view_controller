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
    AssetRepresentationMode? preferredAssetRepresentationMode,
    Selection? selection,
    bool? fetchURL,
    String? fileRepresentation,
  }) async {
    var rawList = await methodChannel.invokeMethod<List<dynamic>>('pick', {
      'filter': filter,
      'selectionLimit': selectionLimit,
      'preferredAssetRepresentationMode':
          preferredAssetRepresentationMode?.name,
      'selection': selection?.name,
      'fetchURL': fetchURL,
      'fileRepresentation': fileRepresentation,
    });
    if (rawList == null) {
      return null;
    }
    return rawList
        .map((e) => PHPickerResult(e['id'], e['url'], e['path'], e['error']))
        .toList();
  }

  @override
  Future<bool> delete(List<String> ids) async {
    return (await methodChannel.invokeMethod<bool>('delete', {"ids": ids})) ??
        false;
  }
}
