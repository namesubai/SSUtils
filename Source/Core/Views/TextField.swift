//
//  TextField.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/1.
//

import UIKit

open class TextField: UITextField {
    open var padding: UIEdgeInsets = .zero
    public var wordLength: Int = 0
    public var firstWordIsCannotSapce = false
    public override init(frame: CGRect) {
        super.init(frame: frame)
        rx.text.subscribe(onNext: {
            [weak self]
            txt in guard let self = self else { return }
            if let text = txt, self.wordLength > 0, text.count > self.wordLength {
                self.text = String(text.suffix(self.wordLength))
            }
            if self.firstWordIsCannotSapce, var text = txt, text.count > 0 {
                for c in text {
                    if c == " " {
                        text.removeFirst()
                    } else {
                        break
                    }
                }
                self.text = text
            }
        }).disposed(by: rx.disposeBag)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
