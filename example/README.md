# ph_picker_view_controller_example

## Getting Started

To run this example project locally.

- cd `example`
- `flutter run -d <your device>`

## Usage

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
