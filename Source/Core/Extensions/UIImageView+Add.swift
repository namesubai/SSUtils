//
//  UIImageView+Add.swift
//  SSUtils
//
//  Created by yangsq on 2022/3/29.
//

import UIKit
import Kingfisher

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
    
    func setUrl(_ string: String?, placeholder: UIImage? = nil, resize size: CGSize? = nil) {
        guard var string = string else {
            image = placeholder
            return
        }
        var options: KingfisherOptionsInfo?
        if let size = size {
            let scale = UIScreen.main.scale
            string += "?x-oss-process=image/resize,w_\(Int(round(size.width * scale))),h_\(Int(round(size.height * scale))),m_lfit"
            options = [.scaleFactor(scale)]
        }
        kf.setImage(with: URL(string: string), placeholder: placeholder, options: options)
    }
}
