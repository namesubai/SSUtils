//
//  FreeEarsBook+Rx.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/18.
//

import Foundation
import RxSwift
import YYText

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
