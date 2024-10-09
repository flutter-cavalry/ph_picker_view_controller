# ph_picker_view_controller

[![pub package](https://img.shields.io/pub/v/ph_picker_view_controller.svg)](https://pub.dev/packages/ph_picker_view_controller)

A wrapper around iOS `PHPickerViewController` API. (iOS 14+).

## Usage

### `pick`

```dart
final _plugin = PhPickerViewController();

/// Shows an asset picker backed by `PHPickerViewController`.
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
///
/// [fileRepresentation] same as `PHPickerViewController.fileRepresentation`.
/// Defaults to `UTType.data.identifier`.
///
/// [appendLiveVideos] If true, appends Live Photo video assets to the results.
/// Use [PHPickerResult.liveVideoUrl] and [PHPickerResult.liveVideoPath] to access them.
await _plugin.pick(
        filter: {
          'any': ['livePhotos', 'videos'],
        },
        preferredAssetRepresentationMode: AssetRepresentationMode.current,
        selection: Selection.ordered,
        selectionLimit: 3,
      );
```

`PHPickerResult`:

```dart
/// The result type returned from [pick] function.
///
/// [id] asset ID.
/// [url] asset local URL.
/// [path] asset local path.
/// [liveVideoUrl] live video local URL.
/// [liveVideoPath] live video local path.
/// [error] error message.
class PHPickerResult {
  final String id;
  final String? url;
  final String? path;
  final String? liveVideoUrl;
  final String? liveVideoPath;
}
```

### `delete`

```dart
final _plugin = PhPickerViewController();

final deleted = await _plugin.delete(
  ids: ['assetID1', 'assetID2'],
);
```
