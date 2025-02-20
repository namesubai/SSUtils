//
//  GradientMarginLabel.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/7/5.
//

import UIKit
import RxCocoa
import RxSwift

public extension Reactive where Base: GradientMarginLabel {
    var colors: Binder<[CGColor]> {
        return Binder(self.base, binding: { (view, colors) in
            view.gradientLayer.colors = colors
            view.refreshLayout()
        })
    }
}

open class GradientMarginLabel: MarginLabel {
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    open var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.hex(0x2D8BFF).cgColor, UIColor.hex(0x2080FF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
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
