import 'ph_picker_view_controller_platform_interface.dart';

/// [PHPickerConfiguration.AssetRepresentationMode](https://developer.apple.com/documentation/photokit/phpickerconfiguration/assetrepresentationmode).
enum AssetRepresentationMode { automatic, compatible, current }

/// [PHPickerConfiguration.Selection](https://developer.apple.com/documentation/photokit/phpickerconfiguration/selection).
enum Selection { def, ordered }

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

  final String? error;
  PHPickerResult(this.id, this.url, this.path, this.liveVideoUrl,
      this.liveVideoPath, this.error);

  static PHPickerResult fromMap(Map<dynamic, dynamic> map) {
    return PHPickerResult(
      map['id'],
      map['url'],
      map['path'],
      map['liveVideoUrl'],
      map['liveVideoPath'],
      map['error'],
    );
  }

  @override
  String toString() {
    var res = 'id: $id';
    if (url != null) {
      res += '\nurl: $url';
    }
    if (path != null) {
      res += '\npath: $path';
    }
    if (liveVideoUrl != null) {
      res += '\nliveVideoUrl: $liveVideoUrl';
    }
    if (liveVideoPath != null) {
      res += '\nliveVideoPath: $liveVideoPath';
    }
    if (error != null) {
      res += '\nerror: $error';
    }
    return res;
  }
}

class PhPickerViewController {
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
  Future<List<PHPickerResult>?> pick({
    Map<String, List<String>>? filter,
    int? selectionLimit,
    AssetRepresentationMode? preferredAssetRepresentationMode,
    Selection? selection,
    String? fileRepresentation,
    bool? appendLiveVideos,
  }) {
    return PhPickerViewControllerPlatform.instance.pick(
        filter: filter,
        selectionLimit: selectionLimit,
        preferredAssetRepresentationMode: preferredAssetRepresentationMode,
        selection: selection,
        fileRepresentation: fileRepresentation,
        appendLiveVideos: appendLiveVideos);
  }

  Future<bool> delete(List<String> ids) {
    return PhPickerViewControllerPlatform.instance.delete(ids);
  }
}
