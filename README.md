[![pub package](https://img.shields.io/pub/v/ph_picker_view_controller.svg)](https://pub.dev/packages/ph_picker_view_controller)

# ph_picker_view_controller

A wrapper around iOS `PHPickerViewController` API. (iOS 14+).

## Usage

```dart
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
  });

///
/// The result type returned by [pick] function.
///
/// [id] asset ID.
/// [url] asset file URL.
class PHPickerResult {
  final String id;
  final String? url;
  PHPickerResult(this.id, this.url);
}
```
