import 'ph_picker_view_controller_platform_interface.dart';

/// [PHPickerConfiguration.AssetRepresentationMode](https://developer.apple.com/documentation/photokit/phpickerconfiguration/assetrepresentationmode).
enum AssetRepresentationMode { automatic, compatible, current }

/// [PHPickerConfiguration.Selection](https://developer.apple.com/documentation/photokit/phpickerconfiguration/selection).
enum Selection { def, ordered }

///
/// The result type returned by [pick] function.
///
/// [id] asset ID.
/// [url] asset local URL.
/// [path] asset local path.
/// [error] error message.
class PHPickerResult {
  final String id;
  final String? url;
  final String? path;
  final String? error;
  PHPickerResult(this.id, this.url, this.path, this.error);

  @override
  String toString() {
    var res = 'id: $id';
    if (url != null) {
      res += ', url: $url';
    }
    if (path != null) {
      res += ', path: $path';
    }
    if (error != null) {
      res += ', error: $error';
    }
    return res;
  }
}

///
/// Shows an asset picker backed by `PHPickerViewController`.
///
/// [fetchURL] fetches file URLs. By default, only asset IDs are returned.
///
/// [filter] same as `PHPickerViewController.filter`.
/// Example:
/// `{'any': ['livePhotos', 'videos']}` is equivalent to
/// `PHPickerFilter.any(of: [.livePhotos, .videos])`.
///
/// [selectionLimit] same as `PHPickerViewController.selectionLimit`.
///
/// [preferredAssetRepresentationMode] same as `PHPickerViewController.preferredAssetRepresentationMode`.
///
/// [selection] same as `PHPickerViewController.selection`.
class PhPickerViewController {
  Future<List<PHPickerResult>?> pick({
    Map<String, List<String>>? filter,
    int? selectionLimit,
    AssetRepresentationMode? preferredAssetRepresentationMode,
    Selection? selection,
    bool? fetchURL,
  }) {
    return PhPickerViewControllerPlatform.instance.pick(
        filter: filter,
        selectionLimit: selectionLimit,
        preferredAssetRepresentationMode: preferredAssetRepresentationMode,
        selection: selection,
        fetchURL: fetchURL);
  }
}
