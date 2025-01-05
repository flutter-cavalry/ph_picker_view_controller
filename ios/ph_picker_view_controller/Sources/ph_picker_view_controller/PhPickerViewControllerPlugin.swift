import Flutter
import PhotosUI
import UIKit

class PluginArgumentError: NSObject, LocalizedError {
  var msg = ""
  init(_ msg: String) {
    self.msg = msg
  }

  override var description: String {
    return "PluginArgumentError: \(msg)"
  }

  var errorDescription: String? {
    return self.description
  }
}

class ResultContext {
  let flutterRes: FlutterResult
  let fileRepresentation: String
  let appendLiveVideos: Bool

  var totalCount: Int = -1
  var completedTasksCounter = 0
  var files: [[String: Any?]] = []

  init(flutterRes: @escaping FlutterResult, fileRepresentation: String, appendLiveVideos: Bool) {
    self.flutterRes = flutterRes
    self.fileRepresentation = fileRepresentation
    self.appendLiveVideos = appendLiveVideos
  }
}

public class PhPickerViewControllerPlugin: NSObject, FlutterPlugin {

  let resultContextQueue = DispatchQueue(label: "ph_picker_view_controller_task_queue")
  var resultContext: ResultContext?

  func currentViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.findKeyWindow()
    var topController = keyWindow?.rootViewController
    while topController?.presentedViewController != nil {
      topController = topController?.presentedViewController
    }
    return topController
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "ph_picker_view_controller", binaryMessenger: registrar.messenger())
    let instance = PhPickerViewControllerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      DispatchQueue.main.async {
        result(FlutterError(code: "InvalidArgsType", message: "Invalid args type", details: nil))
      }
      return
    }
    switch call.method {
    case "pick":
      do {
        // Arguments are enforced on dart side.
        let filterMap = args["filter"] as? [String: [String]]
        let selectionLimit = args["selectionLimit"] as? Int
        let preferredAssetRepresentationMode = args["preferredAssetRepresentationMode"] as? String
        let selection = args["selection"] as? String
        let fileRepresentation = args["fileRepresentation"] as? String ?? UTType.data.identifier
        let appendLiveVideos = args["appendLiveVideos"] as? Bool ?? false

        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        if let filter = filterMap?.first {
          configuration.filter = try filterFromMap(name: filter.key, filterNames: filter.value)
        }
        if let preferredAssetRepresentationMode = preferredAssetRepresentationMode {
          configuration.preferredAssetRepresentationMode = try parseRepresentationMode(
            s: preferredAssetRepresentationMode)
        }
        if let selection = selection {
          if #available(iOS 15.0, *) {
            configuration.selection = try parseSelection(s: selection)
          }
        }
        if let selectionLimit = selectionLimit {
          configuration.selectionLimit = selectionLimit
        }
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.presentationController?.delegate = self

        resultContext = ResultContext(
          flutterRes: result, fileRepresentation: fileRepresentation,
          appendLiveVideos: appendLiveVideos)
        currentViewController()?.present(picker, animated: true)
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(code: "PluginError", message: error.localizedDescription, details: nil))
        }
      }

    case "delete":
      // Arguments are enforced on dart side.
      guard let ids = args["ids"] as? [String] else {
        DispatchQueue.main.async {
          result(false)
        }
        return
      }

      let assets = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: nil)

      PHPhotoLibrary.shared().performChanges {
        PHAssetChangeRequest.deleteAssets(assets)
      } completionHandler: { success, error in
        if success {
          DispatchQueue.main.async {
            result(true)
          }
        } else {
          DispatchQueue.main.async {
            result(
              FlutterError(code: "DeleteFailed", message: error?.localizedDescription, details: nil)
            )
          }
        }
      }

    default:
      DispatchQueue.main.async {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func filterFromMap(name: String, filterNames: [String]) throws -> PHPickerFilter {
    let filters = try filterNames.map({ filter in
      return try filterFromString(s: filter)
    })
    switch name {
    case "any":
      return PHPickerFilter.any(of: filters)
    case "not":
      if #available(iOS 15.0, *) {
        return PHPickerFilter.not(filters[0])
      } else {
        throw PluginArgumentError("not filter requires iOS 15.0")
      }
    case "all":
      if #available(iOS 15.0, *) {
        return PHPickerFilter.all(of: filters)
      } else {
        throw PluginArgumentError("all filter requires iOS 15.0")
      }
    default:
      throw PluginArgumentError("Unknown filter name \(name)")
    }
  }
}

extension PhPickerViewControllerPlugin: PHPickerViewControllerDelegate {
  private func sendResultsToFlutter(results: Any?) {
    DispatchQueue.main.async {
      self.resultContext?.flutterRes(results)
      self.resultContext = nil
    }
  }

  public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)
    guard let resultContext = resultContext else {
      return
    }

    // User cancelled.
    if results.isEmpty {
      sendResultsToFlutter(results: nil)
      return
    }

    // Update context file count.
    resultContext.totalCount = results.count
    let tmpDir = createTmpDir()

    for (_, pickerRes) in results.enumerated() {
      let ip = pickerRes.itemProvider
      let assetIdentifier = pickerRes.assetIdentifier

      if resultContext.appendLiveVideos && ip.canLoadObject(ofClass: PHLivePhoto.self) {
        // Live photo.
        ip.loadObject(ofClass: PHLivePhoto.self) { livePhoto, err in
          if let err = err {
            self.completeSingleFile(
              err: err.localizedDescription, assetID: assetIdentifier, url: nil, liveVideo: nil)
            return
          }
          guard let livePhoto = livePhoto as? PHLivePhoto else {
            self.completeSingleFile(
              err: "Unexpected nil live photo data", assetID: assetIdentifier, url: nil,
              liveVideo: nil)
            return
          }
          self.handleLivePhto(pickerRes: pickerRes, tmpDir: tmpDir, livePhoto: livePhoto)
        }
      } else if ip.hasRepresentationConforming(toTypeIdentifier: resultContext.fileRepresentation) {
        ip.loadFileRepresentation(forTypeIdentifier: resultContext.fileRepresentation) { url, err in
          if let err = err {
            self.completeSingleFile(
              err: err.localizedDescription, assetID: assetIdentifier, url: nil, liveVideo: nil)
            return
          }
          guard let url = url else {
            self.completeSingleFile(
              err: "URL not supported on this representation", assetID: assetIdentifier, url: url,
              liveVideo: nil)
            return
          }
          self.handleDefaultFile(pickerRes: pickerRes, tmpDir: tmpDir, url: url)
        }
      } else {
        completeSingleFile(
          err: "Representation not supported", assetID: pickerRes.assetIdentifier, url: nil,
          liveVideo: nil)
      }
    }
  }

  // Callback from `loadFileRepresentation` is in a worker thread.
  private func handleDefaultFile(pickerRes: PHPickerResult, tmpDir: URL, url: URL) {
    let id = pickerRes.assetIdentifier
    do {
      // https://developer.apple.com/documentation/photokit/selecting_photos_and_videos_in_ios
      let localURL = tmpDir.appendingPathComponent(url.lastPathComponent)
      try FileManager.default.copyItem(at: url, to: localURL)
      completeSingleFile(err: nil, assetID: id, url: localURL, liveVideo: nil)
    } catch {
      completeSingleFile(err: error.localizedDescription, assetID: id, url: nil, liveVideo: nil)
    }
  }

  // Callback from `loadFileRepresentation` is in a worker thread.
  private func handleLivePhto(pickerRes: PHPickerResult, tmpDir: URL, livePhoto: PHLivePhoto) {
    let id = pickerRes.assetIdentifier
    saveLivePhotoComponents(livePhoto: livePhoto, tmpDir: tmpDir) {
      (result: Result<(imageURL: URL, videoURL: URL), any Error>) in
      switch result {
      case .success(let (imageURL, videoURL)):
        self.completeSingleFile(err: nil, assetID: id, url: imageURL, liveVideo: videoURL)
      case .failure(let innerErr):
        self.completeSingleFile(
          err: innerErr.localizedDescription, assetID: id, url: nil, liveVideo: nil)
      }
    }
  }

  private func completeSingleFile(err: String?, assetID: String?, url: URL?, liveVideo: URL?) {
    self.resultContextQueue.async {
      guard let resultContext = self.resultContext else {
        return
      }
      resultContext.completedTasksCounter += 1

      let map: [String: Any?] = [
        "id": assetID,
        "url": url?.absoluteString,
        "path": url?.path,
        "liveVideoUrl": liveVideo?.absoluteString,
        "liveVideoPath": liveVideo?.path,
        "error": err,
      ]
      resultContext.files.append(map)

      if resultContext.completedTasksCounter >= resultContext.totalCount {
        self.sendResultsToFlutter(results: resultContext.files)
        return
      }
    }
  }

  private func createTmpDir() -> URL {
    let dirName = "_FLT_PH_\(Date().timeIntervalSince1970)"
    let dirUrl = FileManager.default.temporaryDirectory.appendingPathComponent(dirName)
    try? FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true)
    return dirUrl
  }

  private func saveLivePhotoComponents(
    livePhoto: PHLivePhoto,
    tmpDir: URL,
    completionHandler: @escaping (Result<(imageURL: URL, videoURL: URL), Error>) -> Void
  ) {

    let livePhotoResources = PHAssetResource.assetResources(for: livePhoto)
    // Identify photo and video resources
    var imageResource: PHAssetResource?
    var videoResource: PHAssetResource?

    for resource in livePhotoResources {
      if resource.type == .photo {
        imageResource = resource
      } else if resource.type == .pairedVideo {
        videoResource = resource
      }
    }

    guard let imageResource = imageResource, let videoResource = videoResource else {
      let error = NSError(
        domain: "PHLivePhotoErrorDomain", code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Could not find both image and video resources."])
      completionHandler(.failure(error))
      return
    }

    let imageFileName = imageResource.originalFilename
    let videoFileName = videoResource.originalFilename

    let imageFileURL = tmpDir.appendingPathComponent(imageFileName)
    let videoFileURL = tmpDir.appendingPathComponent(videoFileName)

    let resourceManager = PHAssetResourceManager.default()
    var imageSaved = false
    var videoSaved = false

    // Helper function to check if both resources are saved
    func checkCompletion() {
      if imageSaved && videoSaved {
        completionHandler(.success((imageFileURL, videoFileURL)))
      }
    }

    // Request to save the image
    resourceManager.writeData(for: imageResource, toFile: imageFileURL, options: nil) { error in
      if let error = error {
        completionHandler(.failure(error))
        return
      } else {
        imageSaved = true
        checkCompletion()
      }
    }

    // Request to save the video
    resourceManager.writeData(for: videoResource, toFile: videoFileURL, options: nil) { error in
      if let error = error {
        completionHandler(.failure(error))
        return
      } else {
        videoSaved = true
        checkCompletion()
      }
    }
  }
}

extension PhPickerViewControllerPlugin: UIAdaptivePresentationControllerDelegate {
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    sendResultsToFlutter(results: nil)
  }
}

// Parsing logic.
extension PhPickerViewControllerPlugin {
  func filterFromString(s: String) throws -> PHPickerFilter {
    switch s {
    case "bursts":
      if #available(iOS 16.0, *) {
        return PHPickerFilter.bursts
      } else {
        throw PluginArgumentError("bursts filter requires iOS 16.0")
      }
    case "cinematicVideos":
      if #available(iOS 16.0, *) {
        return PHPickerFilter.cinematicVideos
      } else {
        throw PluginArgumentError("cinematicVideos filter requires iOS 16.0")
      }
    case "depthEffectPhotos":
      if #available(iOS 16.0, *) {
        return PHPickerFilter.depthEffectPhotos
      } else {
        throw PluginArgumentError("depthEffectPhotos filter requires iOS 16.0")
      }
    case "images":
      return PHPickerFilter.images
    case "livePhotos":
      return PHPickerFilter.livePhotos
    case "panoramas":
      if #available(iOS 15.0, *) {
        return PHPickerFilter.panoramas
      } else {
        throw PluginArgumentError("panoramas filter requires iOS 15.0")
      }
    case "screenRecordings":
      if #available(iOS 15.0, *) {
        return PHPickerFilter.screenRecordings
      } else {
        throw PluginArgumentError("screenRecordings filter requires iOS 15.0")
      }
    case "screenshots":
      if #available(iOS 15.0, *) {
        return PHPickerFilter.screenshots
      } else {
        throw PluginArgumentError("screenshots filter requires iOS 15.0")
      }
    case "slomoVideos":
      if #available(iOS 15.0, *) {
        return PHPickerFilter.slomoVideos
      } else {
        throw PluginArgumentError("slomoVideos filter requires iOS 15.0")
      }
    case "timelapseVideos":
      if #available(iOS 15.0, *) {
        return PHPickerFilter.timelapseVideos
      } else {
        throw PluginArgumentError("timelapseVideos filter requires iOS 15.0")
      }
    case "videos":
      return PHPickerFilter.videos
    default:
      throw PluginArgumentError("Unknown filter name \(s)")
    }
  }

  func parseRepresentationMode(s: String) throws -> PHPickerConfiguration.AssetRepresentationMode {
    switch s {
    case "automatic":
      return .automatic
    case "compatible":
      return .compatible
    case "current":
      return .current
    default:
      throw PluginArgumentError(
        "Unknown enum value for PHPickerConfigurationAssetRepresentationMode: \(s)")
    }
  }

  @available(iOS 15.0, *)
  func parseSelection(s: String) throws -> PHPickerConfiguration.Selection {
    switch s {
    case "def":
      return .default
    case "ordered":
      return .ordered
    default:
      throw PluginArgumentError("Unknown enum value for Selection: \(s)")
    }
  }
}

extension UIApplication {
  func findKeyWindow() -> UIWindow? {
    if #available(iOS 15.0, *) {
      return UIApplication
        .shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .last
    } else if #available(iOS 13.0, *) {
      return UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .last { $0.isKeyWindow }
    } else {
      return UIApplication.shared.windows.last { $0.isKeyWindow }
    }
  }
}
