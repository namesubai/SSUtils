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

public extension CGRect {
    func rounded(_ rule: FloatingPointRoundingRule) -> CGRect {
        CGRect(x: origin.x.rounded(rule), y: origin.y.rounded(rule), width: size.width.rounded(rule), height: size.height.rounded(rule))
    }
    
    func rounded() -> CGRect {
        CGRect(x: origin.x.rounded(), y: origin.y.rounded(), width: size.width.rounded(), height: size.height.rounded())
    }
}
