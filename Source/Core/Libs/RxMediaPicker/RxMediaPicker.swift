import AVFoundation
import Foundation
import MobileCoreServices
import RxSwift
import UIKit
import PhotosUI

enum RxMediaPickerAction {
    case photo(observer: AnyObserver<(UIImage, UIImage?)>)
    case video(observer: AnyObserver<URL>, maxDuration: TimeInterval)
}

public enum RxMediaPickerError: Error {
    case generalError
    case canceled
    case videoMaximumDurationExceeded
}

@objc public protocol RxMediaPickerDelegate {
    func present(picker: UIViewController)
    func dismiss(picker: UIViewController)
}

@objc open class RxMediaPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    weak var delegate: RxMediaPickerDelegate?

    fileprivate var currentAction: RxMediaPickerAction?

    open var deviceHasCamera: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    public init(delegate: RxMediaPickerDelegate) {
        self.delegate = delegate
    }

    open func recordVideo(device: UIImagePickerController.CameraDevice = .rear,
                          quality: UIImagePickerController.QualityType = .typeMedium,
                          maximumDuration: TimeInterval = 600, editable: Bool = false) -> Observable<URL> {
        return Observable.create { observer in
            self.currentAction = RxMediaPickerAction.video(observer: observer, maxDuration: maximumDuration)

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.videoMaximumDuration = maximumDuration
            picker.videoQuality = quality
            picker.allowsEditing = editable
            picker.delegate = self

            if UIImagePickerController.isCameraDeviceAvailable(device) {
                picker.cameraDevice = device
            }

            self.present(picker)

            return Disposables.create()
        }.observe(on: MainScheduler.instance)
    }

    open func selectVideo(source: UIImagePickerController.SourceType = .photoLibrary,
                          maximumDuration: TimeInterval = 600,
                          editable: Bool = false) -> Observable<URL> {
        return Observable.create { [unowned self] observer in
            self.currentAction = RxMediaPickerAction.video(observer: observer, maxDuration: maximumDuration)

            let picker = UIImagePickerController()
            picker.sourceType = source
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.allowsEditing = editable
            picker.delegate = self
            picker.videoMaximumDuration = maximumDuration
            self.present(picker)


            return Disposables.create()
        }.observe(on: MainScheduler.instance)
    }

    open func takePhoto(device: UIImagePickerController.CameraDevice = .rear,
                        flashMode: UIImagePickerController.CameraFlashMode = .auto,
                        editable: Bool = false) -> Observable<(UIImage, UIImage?)> {
        return Observable.create { [unowned self] observer in
            self.currentAction = RxMediaPickerAction.photo(observer: observer)

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = editable
            picker.delegate = self

            if UIImagePickerController.isCameraDeviceAvailable(device) {
                picker.cameraDevice = device
            }

            if UIImagePickerController.isFlashAvailable(for: picker.cameraDevice) {
                picker.cameraFlashMode = flashMode
            }

            self.present(picker)

            return Disposables.create()
        }.observe(on: MainScheduler.instance)
    }

    open func selectImage(source: UIImagePickerController.SourceType = .photoLibrary,
                          editable: Bool = false) -> Observable<(UIImage, UIImage?)> {
        return Observable.create { [unowned self] observer in
            self.currentAction = RxMediaPickerAction.photo(observer: observer)

            if #available(iOS 14, *) {
                var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                config.selectionLimit = 1
                config.filter = .images
                config.preferredAssetRepresentationMode = .current
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                self.present(picker)

            } else {
                let picker = UIImagePickerController()
                picker.sourceType = source
                picker.allowsEditing = editable
                picker.delegate = self
                self.present(picker)
            }


            return Disposables.create()
        }.observe(on: MainScheduler.instance)
    }

    func processPhoto(info: [UIImagePickerController.InfoKey: Any],
                      observer: AnyObserver<(UIImage, UIImage?)>) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            observer.on(.error(RxMediaPickerError.generalError))
            return
        }

        let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        observer.onNext((image, editedImage))
        observer.onCompleted()
    }

    func processVideo(ph_videoUrl: URL? = nil,
                      info: [UIImagePickerController.InfoKey: Any]? = nil,
                      observer: AnyObserver<URL>,
                      maxDuration: TimeInterval,
                      picker: Any) {
        
        var videoURL: URL?
        var editedStart: NSNumber?
        var editedEnd: NSNumber?
        if let info = info {
            videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            editedStart = info[UIImagePickerController.InfoKey(rawValue: "_UIImagePickerControllerVideoEditingStart")] as? NSNumber
            editedEnd = info[UIImagePickerController.InfoKey(rawValue: "_UIImagePickerControllerVideoEditingEnd")] as? NSNumber

        }
        
        if let ph_videoUrl = ph_videoUrl  {
            videoURL = ph_videoUrl
        }
        if let videoURL = videoURL  {
            
            let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
            let editedVideoURL = URL(fileURLWithPath: cachesDirectory).appendingPathComponent("\(UUID().uuidString).mov", isDirectory: false)
            let asset = AVURLAsset(url: videoURL)

            if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = editedVideoURL
                exportSession.outputFileType = AVFileType.mov
                if let editedStart = editedStart, let editedEnd = editedEnd {
                    let start = Int64(editedStart.doubleValue * 1000)
                    let end = Int64(editedEnd.doubleValue * 1000)
                    exportSession.timeRange = CMTimeRange(start: CMTime(value: start, timescale: 1000), duration: CMTime(value: end - start, timescale: 1000))
                }

                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed:
                        self.processVideo(url: editedVideoURL, observer: observer, maxDuration: maxDuration, picker: picker)
                    case .failed: fallthrough
                    case .cancelled:
                        observer.on(.error(RxMediaPickerError.generalError))
                        if let picker = picker as? UIImagePickerController  {
                            self.dismiss(picker)
                        }
                        
                        if #available(iOS 14, *) {
                            if let picker = picker as? PHPickerViewController  {
                                self.dismiss(picker)
                            }
                        }
                    default: break
                    }
                })
            }
        } else {
            observer.on(.error(RxMediaPickerError.generalError))
            if let picker = picker as? UIImagePickerController  {
                dismiss(picker)
            }
            
            if #available(iOS 14, *) {
                if let picker = picker as? PHPickerViewController  {
                    dismiss(picker)
                }
            }
        }

        
    }

    fileprivate func processVideo(url: URL,
                                  observer: AnyObserver<URL>,
                                  maxDuration: TimeInterval,
                                  picker: Any) {
        let asset = AVURLAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)

        if duration > maxDuration {
            observer.on(.error(RxMediaPickerError.videoMaximumDurationExceeded))
        } else {
            observer.on(.next(url))
            observer.on(.completed)
        }

        if let picker = picker as? UIImagePickerController  {
            self.dismiss(picker)
        }
        
        if #available(iOS 14, *) {
            if let picker = picker as? PHPickerViewController  {
                self.dismiss(picker)
            }
        }
    }

    fileprivate func present(_ picker: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.present(picker: picker)
        }
    }

    fileprivate func dismiss(_ picker: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.dismiss(picker: picker)
        }
    }
    

    // MARK: UIImagePickerControllerDelegate

    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let action = currentAction {
            switch action {
            case .photo(let observer):
                processPhoto(info: info, observer: observer)
                dismiss(picker)
            case .video(let observer, let maxDuration):
                processVideo(info: info, observer: observer, maxDuration: maxDuration, picker: picker)
            }
        }
    }

    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(picker)

        if let action = currentAction {
            switch action {
            case .photo(let observer): observer.on(.error(RxMediaPickerError.canceled))
            case .video(let observer, _): observer.on(.error(RxMediaPickerError.canceled))
            }
        }
    }
    
    @available(iOS 14, *)
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
            self.dismiss(picker)
            return
            
        }
            // request image urls
            let identifier = results.compactMap(\.assetIdentifier)
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifier, options: nil)
            var count = fetchResult.count
            fetchResult.enumerateObjects {(asset, index, stop) in
                PHAsset.getURL(ofPhotoWith: asset) {[weak self] (url, info) in
                    guard let self = self else { return }
                    if let url = url {
                      // got image url
                        if let image = try? UIImage(data: Data(contentsOf: url)) {
                            if let action = self.currentAction {
                                switch action {
                                case .photo(let observer):
                                    observer.onNext((image, image))
                                case .video(let observer, let maxDuration):
                                    self.processVideo(ph_videoUrl: url, observer: observer, maxDuration: maxDuration, picker: picker)
                                }
                            }
                        } else {
                            if let action = self.currentAction {
                                switch action {
                                case .photo(let observer): observer.on(.error(RxMediaPickerError.canceled))
                                case .video(let observer, _): observer.on(.error(RxMediaPickerError.canceled))
                                }
                            }
                        }
                       
                    } else {
                        if let action = self.currentAction {
                            switch action {
                            case .photo(let observer): observer.on(.error(RxMediaPickerError.canceled))
                            case .video(let observer, _): observer.on(.error(RxMediaPickerError.canceled))
                            }
                        }
                    }
                    self.dismiss(picker)
                }
            }
        }
    
        
}


extension PHAsset {
    static func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?, _ info: [AnyHashable : Any]?) -> Void)) {
        
        if mPhasset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            mPhasset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                if let fullSizeImageUrl = contentEditingInput?.fullSizeImageURL {
                    completionHandler(fullSizeImageUrl, info)
                } else {
                    completionHandler(nil, info)
                }
            })
        } else if mPhasset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl = urlAsset.url
                    completionHandler(localVideoUrl, info)
                } else {
                    completionHandler(nil, info)
                }
            })
        }
        
        
    }
    
    
}
