//
//  GradientView.swift
//  
//
//  Created by yangsq on 2020/10/22.
//

import UIKit


open class GradientView: View {

    public var customView: UIView?
    public var corners: UIRectCorner = .allCorners
    public var cornerRadiusSize: CGFloat = 0
    
    /// 高度一半圆角
    public var isAutoCornerRadius: Bool = false {
        didSet {
            refreshLayout()
        }
    }
    /// custom内容撑开
    public var isAutoSize: Bool = false {
        didSet {
            refreshLayout()
        }
    }
    public var customViewInsets: UIEdgeInsets = .zero {
        didSet {
            refreshLayout()
        }
    }
    
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    open var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    public override var intrinsicContentSize: CGSize {
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
    
    open var startPoint: CGPoint = .zero {
        didSet{
            gradientLayer.startPoint = startPoint
        }
    }
    
    open var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet{
            gradientLayer.endPoint = endPoint
        }
    }

    public init(colors: [CGColor] = Colors.gradientColors,
         size: CGSize = .zero,
         customView: UIView? = nil,
         cornerRadius: CGFloat = 0) {
        
        super.init(frame: .zero)
        gradientLayer.locations = [0,1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = colors
        cornerRadiusSize = cornerRadius
        self.layer.masksToBounds = true
        self.customView = customView
        if let customView = customView {
            self.addSubview(customView)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.isAutoSize {
            guard let customView = self.customView else {
                return
            }
            let size = customView.intrinsicContentSize
            customView.frame = CGRect(x: customViewInsets.left, y: customViewInsets.top, width: size.width, height: size.height)

        }else {
            
            self.customView?.frame = CGRect(x: customViewInsets.left, y: customViewInsets.top, width: self.bounds.width - customViewInsets.left - customViewInsets.right, height: self.bounds.height - customViewInsets.top - customViewInsets.bottom)
        }
        if self.isAutoCornerRadius {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: self.corners, cornerRadii: CGSize(width: self.bounds.height / 2, height: self.bounds.height / 2))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            self.layer.mask = shapeLayer
        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: self.corners, cornerRadii: CGSize(width: self.cornerRadiusSize, height: self.cornerRadiusSize))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            self.layer.mask = shapeLayer
        }

    }
    
    public func refreshLayout() {
        setNeedsDisplay()
        layoutIfNeeded()
        invalidateIntrinsicContentSize()
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

