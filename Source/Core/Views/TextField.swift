//
//  TextField.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/1.
//

import UIKit

open class TextField: UITextField {
    open var padding: UIEdgeInsets = .zero
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        var origin = rect.origin
        var size = rect.size
        origin.x = leftView?.frame.maxX ?? 0 + padding.left
        origin.y = padding.top
        var rightMargin = padding.right
        if super.clearButtonRect(forBounds: bounds).width > 0 {
            rightMargin = bounds.width - self.clearButtonRect(forBounds: bounds).minX
        }
        size.width = bounds.width - origin.x - rightMargin
        size.height = bounds.height - padding.top - padding.bottom
        rect.origin = origin
        rect.size = size
        return rect
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        var origin = rect.origin
        var size = rect.size
        origin.x = leftView?.frame.maxX ?? 0 + padding.left
        origin.y = padding.top
        var rightMargin = padding.right
        if super.clearButtonRect(forBounds: bounds).width > 0 {
            rightMargin = bounds.width - self.clearButtonRect(forBounds: bounds).minX
        }
        size.width = bounds.width - origin.x - rightMargin
        size.height = bounds.height - padding.top - padding.bottom
        rect.origin = origin
        rect.size = size
        return rect
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        var origin = rect.origin
        origin.x = origin.x - (padding.right - (bounds.width - rect.maxX))
        rect.origin = origin
        return rect
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
