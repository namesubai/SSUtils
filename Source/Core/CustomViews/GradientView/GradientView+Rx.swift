//
//  GradientView+Rx.swift
//  
//
//  Created by yangsq on 2020/12/10.
//

import Foundation
import RxCocoa
import RxSwift

public extension Reactive where Base: GradientView {
   
    var isEnable: Binder<Bool> {
       return Binder(self.base) { (view, isEnable) in
         view.alpha = isEnable ? 1 : 0.5
       }
   }
    
    var changeColorAndEnalbel: Binder<UIColor?> {
       return Binder(self.base) { (view, color) in
        if color == nil {
            view.backgroundColor = nil
            view.gradientLayer.isHidden = false
        }else{
            view.backgroundColor = color!
            view.gradientLayer.isHidden = true
        }
        
       }
   }
}
