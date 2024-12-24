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
    
    func clipImage(rect: CGRect, superSize: CGSize? = nil) -> UIImage? {
        
        let sourceImageRef = cgImage!
        let scale = size.width / (superSize?.width ?? App.width)
        let hScale = size.height / (superSize?.height ?? App.height)
        let rect = CGRect(x: rect.minX * scale, y: rect.minY * hScale, width: rect.width * scale, height: rect.height * hScale)
        if let newImageRef = sourceImageRef.cropping(to: rect) {
            let newImage = UIImage(cgImage: newImageRef)
            return newImage
        }
       
        return nil
    }
    
    func scaleClipImage(rect: CGRect, superSize: CGSize) -> UIImage? {
        
        let sourceImageRef = cgImage!
        let x = size.width * (rect.minX / superSize.width)
        let y = size.height * (rect.minY / superSize.height)
        let w = size.width * (rect.width / superSize.width)
        let h = size.height * (rect.height / superSize.height)
        let rect = CGRect(x: x, y: y, width: w, height:h)
        if let newImageRef = sourceImageRef.cropping(to: rect) {
            let newImage = UIImage(cgImage: newImageRef)
            return newImage
        }
        
        return nil
    }
    
    func bitClipImage(rect: CGRect, superSize: CGSize) -> UIImage {
        let x = size.width * (rect.minX / superSize.width)
        let y = size.height * (rect.minY / superSize.height)
        let w = size.width * (rect.width / superSize.width)
        let h = size.height * (rect.height / superSize.height)
        let rect = CGRect(x: x, y: y, width: w, height: h)
        if size.width == 0 || size.height == 0 { return self }
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: -rect.minX, y: -rect.minY)
        draw(at: .zero)
        let croppedIamge = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedIamge ?? self
        
    }
    
    
    func cropped(to rect: CGRect) -> UIImage {
        guard rect.size.width <= size.width && rect.size.height <= size.height else { return self }
        var scaledRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        scaledRect = CGRect(x: scaledRect.origin.x.rounded(), y: scaledRect.origin.y.rounded(),
                            width: scaledRect.size.width.rounded(), height: scaledRect.size.height.rounded())
        guard let image = cgImage?.cropping(to: scaledRect) else { return self }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
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
    
    /// 渐变图片（基于frame）
    static func gradient(size: CGSize,
                         startColor: UIColor, endColor: UIColor,
                         startPoint: CGPoint, endPoint: CGPoint) -> UIImage {
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradientLocations: [CGFloat] = [0.0, 1.0]
        let colors: CFArray = [startColor.cgColor, endColor.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: colorspace, colors: colors, locations: gradientLocations)
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        
        let render = UIGraphicsImageRenderer(bounds: .init(origin: .zero, size: size), format: format)
        
        let image = render.image { context in
            context.cgContext.drawLinearGradient(gradient!,
                                                 start: CGPoint(x: size.width * startPoint.x, y: size.height * startPoint.y),
                                                 end: CGPoint(x: size.width * endPoint.x, y: size.height * endPoint.y),
                                                 options: .drawsAfterEndLocation)
        }
        
        return image
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

public extension Array where Element: UIImage {
    
    /// 多张图片水平拼接，高度以第一张为准，向上对齐
    func mergedHorizontally() -> UIImage? {
        let images: [UIImage] = self
        if images.isEmpty { return nil }
        let height: CGFloat = images[0].size.height
        let width: CGFloat = images.reduce(0) { $0 + $1.size.width }
        UIGraphicsBeginImageContext(.init(width: width, height: height))
        defer { UIGraphicsEndImageContext() }
        var x: CGFloat = 0
        images.forEach { image in
            image.draw(in: .init(origin: .init(x: x, y: 0), size: image.size))
            x += image.size.width
        }
        return UIGraphicsGetImageFromCurrentImageContext()
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
    
    /// 上下合成
    static func mergeImages(_ images: [UIImage]) -> UIImage? {
        guard images.count > 0 else {
            return nil
        }
        
        let firstImag = images.first!
        let contentSize = firstImag.size.scale(firstImag.scale)
        
        UIGraphicsBeginImageContext(CGSize(width: contentSize.width, height: contentSize.height))
        images.forEach { image in
            let size = image.size.scale(image.scale)
            image.draw(in: CGRect(x: (contentSize.width - size.width) / 2, y: (contentSize.height - size.height) / 2, width: size.width, height: size.height))
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
                    DispatchQueue.main.async {
                        if let success = success {
                            success()
                        }
                    }
                    
                default:
                    DispatchQueue.main.async {
                        if let notAuthorized = notAuthorized {
                            notAuthorized()
                        }
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


public extension UIImage {
    func scaled(toHeight: CGFloat, opaque: Bool = false) -> UIImage? {
        let scale = toHeight / size.height
        let newWidth = size.width * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: toHeight), opaque, self.scale)
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: toHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// SwifterSwift: UIImage scaled to width with respect to aspect ratio.
    ///
    /// - Parameters:
    ///   - toWidth: new width.
    ///   - opaque: flag indicating whether the bitmap is opaque.
    /// - Returns: optional scaled UIImage (if applicable).
    func scaled(toWidth: CGFloat, opaque: Bool = false) -> UIImage? {
        let scale = toWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: toWidth, height: newHeight), opaque, self.scale)
        draw(in: CGRect(x: 0, y: 0, width: toWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func rotated(by radians: CGFloat) -> UIImage? {
        let destRect = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(),
                                     y: destRect.origin.y.rounded(),
                                     width: destRect.width.rounded(),
                                     height: destRect.height.rounded())
        
        UIGraphicsBeginImageContext(roundedDestRect.size)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }
        
        contextRef.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        contextRef.rotate(by: radians)
        
        draw(in: CGRect(origin: CGPoint(x: -size.width / 2,
                                        y: -size.height / 2),
                        size: size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func scaled(ratio: CGFloat, opaque: Bool = false) -> UIImage? {
        let targetSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(targetSize, opaque, scale)
        draw(in: CGRect(origin: .zero, size: targetSize))
        let new = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new
    }
}

extension UIImage {
    
    // MARK: 图片翻转(base)
    /// 图片翻转(base)
    /// - Parameter orientation: 翻转类型
    /// - Returns: 翻转后的图片
    public func rotate(orientation: UIImage.Orientation) -> UIImage? {
        guard let imageRef = self.cgImage else {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: imageRef.width, height: imageRef.height)
        var bounds = rect
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch orientation {
        case .up:
            return self
        case .upMirrored:
            // 图片左平移width个像素
            transform = CGAffineTransform(translationX: rect.size.width, y: 0)
            // 缩放
            transform = transform.scaledBy(x: -1, y: 1)
        case .down:
            transform = CGAffineTransform(translationX: rect.size.width, y: rect.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: rect.size.height)
            transform = transform.scaledBy(x: 1, y: -1)
        case .left:
            swapWidthAndHeight(rect: &bounds)
            transform = CGAffineTransform(translationX:0 , y: rect.size.width)
            transform = transform.rotated(by: CGFloat(Double.pi * 1.5))
        case .leftMirrored:
            swapWidthAndHeight(rect: &bounds)
            transform = CGAffineTransform(translationX:rect.size.height , y: rect.size.width)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat(Double.pi * 1.5))
        case .right:
            swapWidthAndHeight(rect: &bounds)
            transform = CGAffineTransform(translationX:rect.size.height , y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        case .rightMirrored:
            swapWidthAndHeight(rect: &bounds)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        default:
            return nil
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        //图片绘制时进行图片修正
        switch orientation {
        case .left:
            fallthrough
        case .leftMirrored:
            fallthrough
        case .right:
            fallthrough
        case .rightMirrored:
            context.scaleBy(x: -1.0, y: 1.0)
            context.translateBy(x: -bounds.size.width, y: 0.0)
        default:
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0.0, y: -rect.size.height)
        }
        context.concatenate(transform)
        context.draw(imageRef, in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 交换宽高
    /// - Parameter rect: image 的 frame
    private func swapWidthAndHeight(rect: inout CGRect) {
        let swap = rect.size.width
        rect.size.width = rect.size.height
        rect.size.height = swap
    }
}


extension UIImage {
    
    
    public func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
   
    public func compress(to kb: Int, clipSize: CGSize? = nil) -> UIImage? {
        guard let imageData = pngData() else { return self }
        var currentImage: UIImage?
        if let compressImageData = try? ImageCompress.compressImageData(imageData, limitDataSize: kb * 1024) {
            currentImage = UIImage(data: compressImageData)
            logDebug("压缩后图片大小：\(compressImageData.count.sizeFromByte()), \(currentImage?.size ?? .zero)")
        }
        if let clipSize = clipSize {
            if let compressImageData = try? ImageCompress.compressImageData(imageData, limitLongWidth: clipSize.width)  {
                currentImage = UIImage(data: compressImageData)
                logDebug("加上size,压缩后图片大小：\(compressImageData.count.sizeFromByte()), \(currentImage?.size ?? .zero)")
            }
        }
        return currentImage ?? self
        
//        let bytes = kb * 1024
//        var compression: CGFloat = 1.0
//        guard var currentData = compressImageData(compression: compression) else { return self }
//        if currentData.count <= bytes { return  self}
//        var max: CGFloat = 1
//        var min: CGFloat = 0
//        var complete = false
//        let step: CGFloat = step
//        while !complete {
//            compression -= step
//            if compression < 0 {
//                /// 如果压缩比例小于0退出
//                complete = true
//            } else {
//
//                if let compressData = compressImageData(compression: compression) {
//                    if compressData.count >= currentData.count {
//                        /// 如果检查到相等或者大于，证明压缩不下去了
//                        complete = true
//                    } else {
//                        if compressData.count <= bytes {
//                            complete = true
//                        }
//                    }
//                    currentData = compressData
//
//                } else {
//                    complete = true
//                }
//            }
//
//        }
//
//        var currentImage = UIImage(data: currentData)
//
//        if let clipSize = clipSize, clipSize.width > 0 {
//            if let image = currentImage, image.size.width > 0  {
//                let reSizeImage = image.resized(withPercentage: clipSize.width / image.size.width)
//                currentImage = reSizeImage
//            }
//        } else {
//            if autoResize {
//                if currentData.count > bytes {
//                    /// 如果还是小于给的大小，试下图片尺寸压缩
//                    var lastDataLength = currentData.count
//                    var ratio: CGFloat = 1
//                    while lastDataLength > bytes {
//                        ratio = ratio - step
//                        if ratio < 0 {
//                            /// 如果尺寸压缩比例小于0退出
//                            lastDataLength = bytes
//                        } else {
//                            if let reSizeImage = currentImage?.resized(withPercentage: ratio) {
//                                currentImage = reSizeImage
//                                currentData == currentImage?.compressImageData(compression: 1)
//                                lastDataLength = currentData.count
//                            } else {
//                                /// 如果尺寸压缩失败直接退出循环
//                                lastDataLength = bytes
//                            }
//                        }
//
//                    }
//                }
//
//            }
//        }
//
//        return currentImage
    }
    
    /// jpeg压缩后透明背景会变成白色，添加白色透明通道。jpeg不支持透明背景
    /// 把图片白色变透明
    func imageByMakingWhiteBackgroundTransparent() -> UIImage? {
        
        let image = UIImage(data: self.jpegData(compressionQuality: 1.0)!)!
        let rawImageRef: CGImage = image.cgImage!
        
        let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]
        UIGraphicsBeginImageContext(image.size);
        
        let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking)
        UIGraphicsGetCurrentContext()?.translateBy(x: 0.0,y: image.size.height)
        UIGraphicsGetCurrentContext()?.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsGetCurrentContext()?.draw(maskedImageRef!, in: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return result
        
    }
    
//    func compressImageData(compression:Double) -> Data? {
//        guard let rawData = pngData() else { return nil }
//
//        guard let imageSource = CGImageSourceCreateWithData(rawData as CFData, [kCGImageSourceShouldCache: false, kCGImageSourceTypeIdentifierHint : UTType.png.identifier] as CFDictionary),
//              let writeData = CFDataCreateMutable(nil, 0),
//              let imageType = CGImageSourceGetType(imageSource),
//              let imageDestination = CGImageDestinationCreateWithData(writeData, imageType, 1, nil) else {
//            return nil
//        }
//
//        let frameProperties = [kCGImageDestinationLossyCompressionQuality: compression] as CFDictionary
//        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, frameProperties)
//        guard CGImageDestinationFinalize(imageDestination) else {
//            return nil
//        }
//        return writeData as Data
//    }
    
    

}

extension UIImage {
    public static func getVideoFirstFrameImage(url: String) -> UIImage? {
        guard let Url = URL(string: url) else { return nil }
        let avAsset = AVURLAsset(url: Url)
        let imageGenerator = AVAssetImageGenerator(asset: avAsset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let image = try UIImage(cgImage: imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil))
            return image
        } catch let e as NSError {
            return nil
        }
    }
}
