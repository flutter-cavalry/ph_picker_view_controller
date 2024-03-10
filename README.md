[![pub package](https://img.shields.io/pub/v/ph_picker_view_controller.svg)](https://pub.dev/packages/ph_picker_view_controller)

# ph_picker_view_controller

A wrapper around iOS `PHPickerViewController` API. (iOS 14+).

## Usage

### `pick`

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
/// [fileRepresentation] defaults to `UTType.item.identifier`. Use this to
/// specify the file representation of the picked assets.
/// For example, live photos are represented as MOV files. To get GIF files,
/// pass `public.image` instead.
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
/// [url] asset local URL.
/// [path] asset local path.
/// [error] error message.
class PHPickerResult {
  final String id;
  final String? url;
  final String? error;
  PHPickerResult(this.id, this.url, this.error);
}
```

### `delete`

```dart
final _plugin = PhPickerViewController();

final deleted = await _plugin.delete(
  ids: ['assetID1', 'assetID2'],
);
```
