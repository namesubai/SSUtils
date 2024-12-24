//
//  UIImageView+Add.swift
//  SSUtils
//
//  Created by yangsq on 2022/3/29.
//

import UIKit
import Kingfisher

public extension UIImageView {
    public enum ResizeMode: String {
        case lfit
        case fill
    }
}

public extension UIImageView {
    
    @discardableResult
    static func makeImageView(image: UIImage? = nil,
                              contentMode: ContentMode = .scaleAspectFill,
                              backgroundColor: UIColor? = nil,
                              cornerRadius: CGFloat = 0,
                              masksToBounds: Bool = false) -> Self {
        let imageV = Self()
        imageV.image = image
        imageV.backgroundColor = backgroundColor
        imageV.layer.cornerRadius = cornerRadius
        imageV.layer.masksToBounds = masksToBounds
        return imageV
    }
    
    func setUrl(_ string: String?,
                placeholder: UIImage? = nil,
                resize size: CGSize? = nil,
                resizeMode: ResizeMode = .lfit,
                showLoading: Bool = false,
                options: KingfisherOptionsInfo? = nil) {
        
        guard var string = string else {
            image = placeholder
            return
        }
        
        var options: KingfisherOptionsInfo? = options
        
        if let size = size {
            let scale = UIScreen.main.scale
            string += "?x-oss-process=image/resize,w_\(Int(round(size.width * scale))),h_\(Int(round(size.height * scale))),m_\(resizeMode.rawValue)"
            if options == nil {
                options = [.scaleFactor(scale)]
            } else {
                options!.append(.scaleFactor(scale))
            }
        }
        
        if showLoading {
            kf.indicatorType = .activity
        }
        
        kf.setImage(with: URL(string: string), placeholder: placeholder, options: options)
    }
  
    func downloadImageData(URL: URL?) {
        guard let Url = URL  else { return }
        DispatchQueue.global().async {
            var image: UIImage?
            if let data = try? Data(contentsOf: Url) {
                image = UIImage(data: data)
            }
            DispatchQueue.main.async {
                [weak self] in guard let self = self else { return }
                self.image = image
            }
        }
    }
}

public extension String {
    func sizeUrl(size: CGSize, resizeMode: UIImageView.ResizeMode = .lfit) -> String {
        let scale = UIScreen.main.scale
        var string = self
        string += "?x-oss-process=image/resize,limit_0,w_\(Int(round(size.width * scale))),h_\(Int(round(size.height * scale))),m_\(resizeMode.rawValue)"
        return string
    }
    
}

