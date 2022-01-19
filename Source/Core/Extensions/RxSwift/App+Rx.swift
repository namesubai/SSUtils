//
//  FreeEarsBook+Rx.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/18.
//

import Foundation
import RxSwift
import YYText
import UIKit

public extension Reactive where Base: UILabel {
    var textColor: Binder<UIColor?> {
        return Binder(self.base, binding: { (label, color) in
            label.textColor = color
        })
    }
}


public extension Reactive where Base: YYLabel {
    var textColor: Binder<UIColor?> {
        return Binder(self.base, binding: { (label, color) in
            label.textColor = color
        })
    }
    
    var text: Binder<String?> {
        return Binder(self.base, binding: { (label, text) in
            label.text = text
        })
    }
    
    var attributedText: Binder<NSAttributedString?> {
        return Binder(self.base, binding: { (label, text) in
            label.attributedText = text
        })
    }
}


extension Reactive where Base: UIButton {
    /// Reactive wrapper for `setTitle(_:for:)`
    public func titleColor(for controlState: UIControl.State = []) -> Binder<UIColor?> {
        Binder(self.base) { button, title in
            button.setTitleColor(title, for: controlState)
        }
    }
}
