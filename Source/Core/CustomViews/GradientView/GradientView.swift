//
//  GradientView.swift
//  
//
//  Created by yangsq on 2020/10/22.
//

import UIKit


class GradientView: UIView {

    var gradientLayer: CAGradientLayer!
    var customView: UIView?
    var corners: UIRectCorner = .allCorners
    var cornerRadiusSize: CGFloat = 0
    ///高度一边圆角
    var isAutoCornerRadius: Bool = false {
        didSet {
            refreshLayout()
        }
    }
    var isAutoSize: Bool = false {
        didSet {
            refreshLayout()
        }
    }
    var customViewInsets: UIEdgeInsets = .zero {
        didSet {
            refreshLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            guard let customView = self.customView else {
                return super.intrinsicContentSize
            }
            if self.isAutoSize {
                let size = customView.intrinsicContentSize
                return CGSize(width: size.width + customViewInsets.left + customViewInsets.right, height: size.height + customViewInsets.top + customViewInsets.bottom)
            }
            return super.intrinsicContentSize
        }
    }
    
    
    init(colors: [CGColor] = Colors.gradientColors,
         size: CGSize = .zero,
         customView: UIView? = nil,
         cornerRadius: CGFloat = 0) {
        
        super.init(frame: .zero)
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.locations = [0,1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = cornerRadius
        cornerRadiusSize = cornerRadius
        self.layer.masksToBounds = true
        self.layer.addSublayer(gradientLayer)
        self.customView = customView
        if let customView = customView {
            self.addSubview(customView)
        }
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.isAutoSize {
            guard let customView = self.customView else {
                return
            }
            let size = customView.intrinsicContentSize
            customView.frame = CGRect(x: customViewInsets.left, y: customViewInsets.top, width: size.width, height: size.height)
//            self.size = CGSize(width: size.width + customViewInsets.left + customViewInsets.right, height: size.height + customViewInsets.top + customViewInsets.bottom)
        }else {
            
            self.customView?.frame = CGRect(x: customViewInsets.left, y: customViewInsets.top, width: self.bounds.width - customViewInsets.left - customViewInsets.right, height: self.bounds.height - customViewInsets.top - customViewInsets.bottom)
        }
//        print("=====\(self.bounds.width)")
        self.gradientLayer.frame = self.bounds
        if self.isAutoCornerRadius {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: self.corners, cornerRadii: CGSize(width: self.bounds.height / 2, height: self.bounds.height / 2))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            self.layer.mask = shapeLayer
        }
        
       
        

    }
    
    func refreshLayout() {
        setNeedsDisplay()
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    required init?(coder: NSCoder) {
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

