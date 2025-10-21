//
//  SSGradientButton.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/11.
//

import UIKit

open class SSGradientButton: UIButton {

    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    open var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    public var autoCornerRadious: Bool = false
    public var enabledBGView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex(0xffffff).withAlphaComponent(0.6)
        return view
    }()

    open override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                addSubview(enabledBGView)
                enabledBGView.snp.remakeConstraints { make in
                    make.edges.equalTo(0)
                }
//                alpha = 0.7
            } else {
                enabledBGView.removeFromSuperview()
//                alpha = 1
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.hex(0x2D8BFF).cgColor, UIColor.hex(0x2080FF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.drawsAsynchronously = true

    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if autoCornerRadious {
            layer.masksToBounds = true
            layer.cornerRadius = ss_h / 2
        }
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
