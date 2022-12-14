//
//  TextField.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/1.
//

import UIKit
import RxCocoa
import RxSwift

extension TextField {
    public enum CustomStringType {
        case number
        
        func vaild(string: String) -> Bool {
            switch self {
                case .number:
                  return string.isNum
            }
        }
    }
    
}

open class TextField: UITextField {
    open var padding: UIEdgeInsets = .zero
    public var wordLength: Int = 0
    public var isTrimPrefix: Bool = false
    public var firstWordIsCannotSapce = false {
        didSet {
            cannotShowFirstWords = firstWordIsCannotSapce ? " " : nil
        }
    }
    public var cannotShowFirstWords: String?
    public var defaultText: String?
    public var minNum: Int?
    public var maxNum: Int?
    public var minNumToast: String?
    public var customStringType: CustomStringType?
    public var placeholderColor: UIColor? {
        didSet {
            if let placeholderColor = placeholderColor, let placeholder = placeholder  {
                let attr = NSMutableAttributedString(string: placeholder)
                attr.addAttribute(.foregroundColor, value: placeholderColor, range: NSMakeRange(0, placeholder.count))
                attributedPlaceholder = attr
            }
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        rx.realText.subscribe(onNext: {
            [weak self]
            txt in guard let self = self else { return }
            if let selectedRange = self.markedTextRange {
                let position = self.position(from: selectedRange.start, offset: 0)
                guard position == nil else { return }
            }
            var text = txt
            if let cannotShowFirstWords = self.cannotShowFirstWords, var _text = text , _text.count > 0 {
                for c in _text {
                    if String(c) == cannotShowFirstWords {
                        _text.removeFirst()
                    } else {
                        break
                    }
                }
                text = _text
            }
            if let customStringType = self.customStringType, var _text = text , _text.count > 0  {
                for c in _text {
                    if !customStringType.vaild(string: String(c)) {
                        _text = _text.replacingOccurrences(of: String(c), with: "")
                    }
                }
                text = _text
            }
            
            if var _text = text, self.wordLength > 0, _text.count > self.wordLength {
                if self.isTrimPrefix {
                    text = String(_text.suffix(self.wordLength))
                }else {
                    text = String(_text.prefix(self.wordLength))
                }
            }
            
            if let maxNum = self.maxNum, Int(self.text ?? "0") ?? 0 > maxNum {
                self.text = "\(maxNum)"
            }
            
            if text != txt {
                self.text = text
            }
            
        }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(UITextField.textDidEndEditingNotification).subscribe(with: self, onNext: {
            (self, _) in
            if let defaultText = self.defaultText, self.text?.isLength != true {
                self.text = defaultText
            }
            if let minNum = self.minNum, Int(self.text ?? "0") ?? 0 < minNum {
                self.text = "\(minNum)"
                if let minNumToast = self.minNumToast {
                    App.keyWindow?.showTextHUD(minNumToast)
                }
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
        if super.clearButtonRect(forBounds: bounds).width > 0 && clearButtonMode != .never  {
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
        if super.clearButtonRect(forBounds: bounds).width > 0 && clearButtonMode != .never {
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
