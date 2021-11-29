//
//  UIImage+.swift
//  
//
//  Created by yangsq on 2020/10/28.
//

import Foundation
import PhotosUI

public extension UIImage {
    /**
     设置是否是圆角
     - parameter radius: 圆角大小
     - parameter size:   图片大小
     - returns: 圆角图片
     */
    func roundCorner(radius: CGFloat, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        // 开始图形上下文
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        // 绘制路线
        UIGraphicsGetCurrentContext()!.addPath(UIBezierPath(roundedRect: rect,
                                      byRoundingCorners: UIRectCorner.allCorners,
                                      cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        // 裁剪
        UIGraphicsGetCurrentContext()!.clip()
        // 将原图片画到图形上下文
        self.draw(in: rect)
        UIGraphicsGetCurrentContext()!.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        // 关闭上下文
        UIGraphicsEndImageContext()
        return output!
    }
    /**
     设置圆形图片
     - returns: 圆形图片
     */
    func circleImage() -> UIImage {
        // 开始图形上下文
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        // 获取图形上下文
        let contentRef: CGContext = UIGraphicsGetCurrentContext()!
        // 设置圆形
        let rect = CGRect(origin: .zero, size: self.size)
        // 根据 rect 创建一个椭圆
        contentRef.addEllipse(in: rect)
        // 裁剪
        contentRef.clip()
        // 将原图片画到图形上下文
        self.draw(in: rect)
        // 从上下文获取裁剪后的图片
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        // 关闭上下文
        UIGraphicsEndImageContext()
        return newImage
    }
}
// MARK: 图片设置圆角
public extension UIImage {
    
    public func roundImage(byRoundingCorners: UIRectCorner = UIRectCorner.allCorners, cornerRadi: CGFloat) -> UIImage? {
        return roundImage(byRoundingCorners: byRoundingCorners, cornerRadii: CGSize(width: cornerRadi, height: cornerRadi))
    }
    
    public func roundImage(byRoundingCorners: UIRectCorner = UIRectCorner.allCorners, cornerRadii: CGSize) -> UIImage? {
        
        let imageRect = CGRect(origin: CGPoint.zero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        guard context != nil else {
            return nil
        }
        context?.setShouldAntialias(true)
        let bezierPath = UIBezierPath(roundedRect: imageRect,
                                      byRoundingCorners: byRoundingCorners,
                                      cornerRadii: cornerRadii)
        bezierPath.close()
        bezierPath.addClip()
        self.draw(in: imageRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


public extension UIImage {
    func colorImage(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        color.set()
        UIRectFill(rect)
        draw(at: .zero, blendMode: .destinationIn, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

public extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)

        defer {
            UIGraphicsEndImageContext()
        }

        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }

        self.init(cgImage: aCgImage)
    }
}

public extension UIImage {
    
    func gaussianBlur(value: Int = 20, completion: ((UIImage?) -> Void)? = nil) {
        DispatchQueue.global().async {
            [weak self] in guard let self = self else { return }
            let image = self.gaussianBlur(value: value)
            DispatchQueue.main.async {
                if let completion = completion {
                    completion(image)
                }
            }
        }
    }
    
    func gaussianBlur(value: Int = 20) -> UIImage? {
        guard self != nil else {
            return nil
        }
        /*
         CIBokehBlur

             CIBoxBlur

             CIDepthBlurEffect

             CIDiscBlur

             CIGaussianBlur

             CIMaskedVariableBlur

             CIMedianFilter

             CIMorphologyGradient

             CIMorphologyMaximum

             CIMorphologyMinimum

             CIMotionBlur

             CINoiseReduction

             CIZoomBlur

         */
        let inputImage = CIImage(cgImage: self.cgImage!)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setDefaults()
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(value, forKey: kCIInputRadiusKey)

        if let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let context = CIContext()
            if let outImg = context.createCGImage(result, from: inputImage.extent) {
                let blurImage = UIImage(cgImage: outImg)
                return blurImage
            }
        }
        return nil
    }
}

public extension UIImage {
    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


public extension UIImage {
    /// 垂直合并图片
    static func mergeWidthScaleImages(_ images: [UIImage]) -> UIImage? {
        guard images.count > 0 else {
            return nil
        }
        let toalHeight = images.reduce(0.0) { result, image in
            result + image.size.height
        }
        let firstImag = images.first!
        UIGraphicsBeginImageContext(CGSize(width: firstImag.size.width, height: toalHeight))
        var topY: CGFloat = 0
        images.forEach { image in
            image.draw(in: CGRect(x: 0, y: topY, width: image.size.width, height: image.size.height))
            topY += image.size.height
        }
        let resultImag = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImag
    }
    
}

public extension UIImage {
    func saveLibrary(notAuthorized: (() -> Void)? = nil, success: (() -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
                if let success = success {
                    success()
                }
            default:
                if let notAuthorized = notAuthorized {
                    notAuthorized()
                }
                break
            }
        }
    }
}

public extension UIImage {
    // MARK: - UIImage+Resize

    func scaleImageWithAspectToWidth(toWidth:CGFloat) -> UIImage? {
        let oldWidth:CGFloat = size.width
        let scaleFactor:CGFloat = toWidth / oldWidth
        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor;
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
