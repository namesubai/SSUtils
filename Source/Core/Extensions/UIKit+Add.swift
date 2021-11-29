//
//  UIKit+Add.swift
//  SSUtils
//
//  Created by yangsq on 2021/8/30.
//

import Foundation

public extension UIEdgeInsets {
    func scale(_ s: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: top * s, left: left * s, bottom: bottom * s, right: right * s)
    }
}
public extension CGSize {
    func scale(_ s: CGFloat) -> CGSize {
        CGSize(width: width * s, height: height * s)
    }
}
