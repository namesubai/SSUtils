//
//  NSObject+Add.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/10.
//

import Foundation
import Photos
import RxCocoa
import RxSwift

public extension NSObject {
    static var className: String {
        return NSStringFromClass(self)
    }
    
    var className: String {
        NSStringFromClass(classForCoder)
    }
    
    func jumpToAppStore(_ url: String?) {
        var appUrl: String = "itms-apps://itunes.apple.com/app/id\(App.defaulAppStoreID)"
        if url != nil {
            appUrl = url!
        }
        
        let  appURL = URL(string: appUrl)
        
//        // 注意: 跳转之前, 可以使用 canOpenURL: 判断是否可以跳转
//        if !UIApplication.shared.canOpenURL(appURL!) {
//            // 不能跳转就不要往下执行了
//            return
//        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL!, options: [:]) { (success) in
                if (success) {
                    print("10以后可以跳转url")
                }else{
                    print("10以后不能完成跳转")
                }
            }
         } else {
            // Fallback on earlier versions
            let success = UIApplication.shared.openURL(appURL!)
            if (success) {
                print("10以下可以跳转")
            }else{
                print("10以下不能完成跳转")
            }
         }
    }
    
//    func jumpToAppStoreInApp() {
//        let storeProductVC = StoreKit.SKStoreProductViewController()
//          storeProductVC.delegate = self
//          let dict = [SKStoreProductParameterITunesItemIdentifier: "1142110895"]
//          storeProductVC.loadProduct(withParameters: dict) { (result, error) in
//             guard error == nil else {
//                  return
//             }
//           }
//           present(storeProductVC, animated: true, completion: nil)
//    }
    
    func generateQRCode(string: String, size: CGFloat = 200) -> UIImage? {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = string.data(using: .utf8)
        filter?.setValue(data, forKey: "inputMessage")
        if let outputImage = filter?.outputImage {
            return createUIImageFromCIImage(image: outputImage, size: size)
        }
        return nil
    }
    
    func createUIImageFromCIImage(image: CIImage, size: CGFloat) -> UIImage {
            let extent = image.extent.integral
            let scale = min(size / extent.width, size / extent.height)
                
            /// Create bitmap
            let width: size_t = size_t(extent.width * scale)
            let height: size_t = size_t(extent.height * scale)
            let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
            let bitmap: CGContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 1)!
           
            ///
            let context = CIContext.init()
            let bitmapImage = context.createCGImage(image, from: extent)
            bitmap.interpolationQuality = .none
            bitmap.scaleBy(x: scale, y: scale)
            bitmap.draw(bitmapImage!, in: extent)
                
            let scaledImage = bitmap.makeImage()
            return UIImage.init(cgImage: scaledImage!)
        }
    
    func changeTabBarSelected(index: Int, completion: (() -> Void)? = nil) {
        guard let tabbarVC = App.mainWindow?.rootViewController as? UITabBarController, tabbarVC.tabBar.items?.count ?? 0 > index else {
            return
        }
        func switchToHome() {
            
            if tabbarVC.selectedIndex != index {
                tabbarVC.selectedIndex = index
            }
            completion?()

        }
        
        func popToRoot() {
            if let nav = tabbarVC.selectedViewController as? UINavigationController, nav.viewControllers.count > 1 {
                nav.popRootViewController() {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                        switchToHome()
                    }
                }
                
            } else {
                switchToHome()
            }
        }
        
        if let presentingViewController =  UIViewController.getCurrentViewController()?.presentingViewController {
            presentingViewController.dismiss(animated: false) {
                popToRoot()
            }
        } else {
            popToRoot()
        }
    }
    
    func videoTransformVoice(videoURL: URL, outputURL: URL, timeout: Int? = nil) -> Observable<(URL?, CMTime?)> {
        var r = Observable<(URL?, CMTime?)>.create { [weak self] observer in guard let self = self else {
            observer.onNext((nil, nil))
            observer.onCompleted()
            return Disposables.create {
            }
        }
            self.videoTransformVoice(videoURL: videoURL, outputURL: outputURL) { outputurl, duration, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext((outputurl, duration))
                    observer.onCompleted()
                }
            }
            return Disposables.create {
            }
        }
        if let timeout = timeout {
            r = r.timeout(.seconds(timeout), scheduler: MainScheduler.instance)
        }
        return r
    }
    
    func videoTransformVoice(videoURL: URL, outputURL: URL, completion: @escaping(URL?, CMTime?, Error?) -> Void) {
        let videoAsset = AVAsset(url: videoURL)
        let composition = AVMutableComposition()
        /// 创建轨道
        if let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid), let track = videoAsset.tracks(withMediaType: .audio).first {
            /// 获取音频轨道
            do {
                try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: track, at: .zero)
                if let extporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) {
                    extporter.outputURL = outputURL
                    extporter.outputFileType = AVFileType.m4a
                    extporter.shouldOptimizeForNetworkUse = true
                    extporter.exportAsynchronously(completionHandler: {
                        DispatchQueue.main.async {
                            if extporter.status == .completed {
                                completion(outputURL, videoAsset.duration, nil)
                            } else  {
                                let error = extporter.error
                                completion(nil, nil, error)
                            }
                        }
                    })
                } else {
                    let error = NSError(domain: "videoTransformVoice.Error", code: -112121)
                    completion(nil, nil, error)
                }
                
            } catch  {
                let error = NSError(domain: "videoTransformVoice.Error", code: -112121)
                completion(nil, nil, error)
            }
        } else {
            let error = NSError(domain: "videoTransformVoice.Error", code: -112121)
            completion(nil, nil, error)
        }
    }
}

