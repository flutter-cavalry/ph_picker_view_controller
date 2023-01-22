[![pub package](https://img.shields.io/pub/v/ph_picker_view_controller.svg)](https://pub.dev/packages/ph_picker_view_controller)

# ph_picker_view_controller

A wrapper around iOS `PHPickerViewController` API. (iOS 14+).

## Usage

`PhPickerViewController.pick`:

```dart
final _plugin = PhPickerViewController();

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
await _plugin.pick(
        filter: {
          'any': ['livePhotos', 'videos'],
        },
        preferredAssetRepresentationMode: AssetRepresentationMode.current,
        selection: Selection.ordered,
        selectionLimit: 3,
        fetchURL: true,
      );
```

`PHPickerResult`:

```dart
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
```
