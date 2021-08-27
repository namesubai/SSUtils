//
//  FreeEarsBook+Rx.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/18.
//

import Foundation
import RxSwift

extension Reactive where Base: UILabel {
    var textColor: Binder<UIColor?> {
        return Binder(self.base, binding: { (label, color) in
            label.textColor = color
        })
    }
}
