import 'ph_picker_view_controller_platform_interface.dart';

enum AssetRepresentationMode { automatic, compatible, current }

enum Selection { def, people, ordered }

///
/// The result type returned by [pick] function.
///
/// [id] asset ID.
/// [url] asset file URL.
/// [error] error message.
class PHPickerResult {
  final String id;
  final String? url;
  final String? error;
  PHPickerResult(this.id, this.url, this.error);
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
