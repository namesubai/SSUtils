//
//  TextField.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/24.
//

import UIKit

open class AutoWidthTextField: UITextField {
    
    open var contentLeftMargin: CGFloat = 10.wScale
    open var contentRightMargin: CGFloat = 13.wScale
    open var space: CGFloat = 4.wScale
    open var maxContentWidth = 224.wScale
    open var customIntrinsicContentSize: CGSize = CGSize(width: 130.wScale, height: 26.wScale)
    
    open override var intrinsicContentSize: CGSize {
        return customIntrinsicContentSize
    }
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        var origin = rect.origin
        origin.x = contentLeftMargin
        rect.origin = origin
        return rect
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        if let leftView = leftView {
            var origin = rect.origin
            var size = rect.size
            origin.x = leftView.frame.maxX + space
            size.width = bounds.width - origin.x - contentRightMargin
            rect.origin = origin
            rect.size = size
        }
        return rect
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.placeholderRect(forBounds: bounds)
        if let leftView = leftView {
            var origin = rect.origin
            var size = rect.size
            origin.x = leftView.frame.maxX + space
            size.width = bounds.width - origin.x - contentRightMargin
            rect.origin = origin
            rect.size = size
        }
        return rect
    }
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        if let leftView = leftView {
            var origin = rect.origin
            var size = rect.size
            origin.x = leftView.frame.maxX + space
            size.width = bounds.width - origin.x - contentRightMargin
            rect.origin = origin
            rect.size = size
            
//            customIntrinsicContentSize.width = size.width
//            invalidateIntrinsicContentSize()
        }
        return rect
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
        var size =  sizeThatFits(CGSize(width: CGFloat(MAXFLOAT), height: 26.wScale))
        if size.width > maxContentWidth {
            size.width = maxContentWidth
        }
        customIntrinsicContentSize.width = size.width
        invalidateIntrinsicContentSize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        layer.cornerRadius = intrinsicContentSize.height / 2
//        layer.masksToBounds = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

//extension SSAutoWidthTextField: UITextFieldDelegate {
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if let text = textField.text, text.count > 0 {
//
//        }
//    }
//}
