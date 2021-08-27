//
//  UIButton+.swift
//  
//
//  Created by yangsq on 2020/10/22.
//

import Foundation

public extension UIButton {
    @discardableResult static func makeButton(type: ButtonType = .system,
                                              title: String? = "",
                                              titleColor: UIColor? = .black,
                                              font: UIFont? = UIFont.systemFont(ofSize: 15),
                                              cornerRadius: CGFloat = 0,
                                              masksToBounds: Bool = false,
                                              backgroudColor: UIColor? = nil) -> Self {
        let button = Self.init(type: type)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        if let font = font {
            button.titleLabel?.font = font
        }
        if cornerRadius > 0 {
            button.layer.cornerRadius = cornerRadius
        }
        
        if masksToBounds {
            button.layer.masksToBounds = masksToBounds
        }
        
        if backgroudColor != nil{
            button.backgroundColor = backgroudColor
        }
        
        return button
    }
}
