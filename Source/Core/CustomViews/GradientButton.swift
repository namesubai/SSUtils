//
//  GradientButton.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/11.
//

import UIKit

open class GradientButton: UIButton {

    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    open var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }

    open override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                alpha = 0.7
            } else {
                alpha = 1
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.hex(0x2D8BFF).cgColor, UIColor.hex(0x2080FF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
    
    public required init?(coder: NSCoder) {
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
