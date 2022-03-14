//
//  NSObject+Add.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/10.
//

import Foundation
//import StoreKit
private let defaulAppStoreID = App.defaulAppStoreID
public extension NSObject {
    static var className: String {
        return NSStringFromClass(self)
    }
    
    func jumpToAppStore(_ url: String?) {
        var appUrl: String = "itms-apps://itunes.apple.com/app/id\(defaulAppStoreID)"
        if url != nil {
            appUrl = url!
        }
        
        let  appURL = URL(string: appUrl)
        
        // 注意: 跳转之前, 可以使用 canOpenURL: 判断是否可以跳转
        if !UIApplication.shared.canOpenURL(appURL!) {
            // 不能跳转就不要往下执行了
            return
        }

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
}

