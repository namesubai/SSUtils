//
//  UIView+.swift
//  
//
//  Created by yangsq on 2020/10/21.
//

import UIKit

public class DashPatternView: UIView {
    public lazy var dashPatternLayer: CAShapeLayer = {
        return self.layer as! CAShapeLayer
    }()
    
    public override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
 
    public override init(frame: CGRect) {
        super.init(frame: frame)
        dashPatternLayer.fillColor = UIColor.clear.cgColor
        dashPatternLayer.lineJoin = CAShapeLayerLineJoin.round
        dashPatternLayer.lineDashPhase = 0
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: ss_h / 2))
        path.addLine(to: CGPoint(x: ss_w, y: ss_h / 2))
        dashPatternLayer.path = path.cgPath
        dashPatternLayer.lineWidth = ss_h
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension UIView {
    enum Line {
        case top,left,bottom,right
    }
    @discardableResult func addLine(line: Line,
                                    size: CGFloat = 0.5,
                                    color: UIColor = Colors.line,
                                    insets: UIEdgeInsets = .zero) -> UIView {
        let lineView = UIView()
        lineView.backgroundColor = color
        addSubview(lineView)
        switch line {
        case .top:
            lineView.snp.makeConstraints { (make) in
                make.left.equalTo(insets.left).priority(.low)
                make.top.equalTo(insets.top).priority(.low)
                make.right.equalTo(-insets.right).priority(.low)
                make.height.equalTo(size).priority(.low)
            }
        case .left:
            lineView.snp.makeConstraints { (make) in
                make.left.equalTo(insets.left).priority(.low)
                make.top.equalTo(insets.top).priority(.low)
                make.bottom.equalTo(-insets.bottom).priority(.low)
                make.width.equalTo(size).priority(.low)
            }
        case .bottom:
            lineView.snp.makeConstraints { (make) in
                make.left.equalTo(insets.left).priority(.low)
                make.right.equalTo(-insets.right).priority(.low)
                make.bottom.equalTo(-insets.bottom).priority(.low)
                make.height.equalTo(size).priority(.low)
            }
            
        case .right:
            lineView.snp.makeConstraints { (make) in
                make.right.equalTo(-insets.right).priority(.low)
                make.top.equalTo(insets.top).priority(.low)
                make.bottom.equalTo(-insets.bottom).priority(.low)
                make.width.equalTo(size).priority(.low)
            }
        }
        return lineView
    }
    
    func addCorner(size: CGSize = .zero, roundingCorners: UIRectCorner, cornerSize: CGSize) {
        let frame = size == .zero ? bounds : CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: frame, byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
        let cornerLayer = CAShapeLayer()
        cornerLayer.frame = frame
        cornerLayer.path = path.cgPath
        cornerLayer.shouldRasterize = true
        cornerLayer.rasterizationScale = UIScreen.main.scale
        cornerLayer.masksToBounds = true
        layer.mask = cornerLayer
    }
}


public extension UIView {
    func startRotate(duration: TimeInterval = 2) {
        if let _ = layer.animation(forKey: "rotate") {
            let time = layer.timeOffset
            layer.speed = 1.0
            layer.timeOffset = 0
            layer.beginTime = 0
            let timeSinceTime = layer.convertTime(CACurrentMediaTime(), from: nil) - time
            layer.beginTime = timeSinceTime
        } else {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = Double.pi * 2
            animation.duration = duration
            animation.repeatCount = MAXFLOAT
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            layer.add(animation, forKey: "rotate")
        }
    }
    
    func stopRotate(goBack: Bool = false) {
        if let animation = layer.animation(forKey: "rotate") {
            
            
            if goBack {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
                    let pausedTime = self.layer.convertTime(CACurrentMediaTime(), from: nil)
                    self.layer.speed = 0.0
                    self.layer.timeOffset = pausedTime
                }
            } else {
                let pausedTime = self.layer.convertTime(CACurrentMediaTime(), from: nil)
                self.layer.speed = 0.0
                self.layer.timeOffset = pausedTime
            }
        }

        
    }
}


public extension UIView {
    enum ShakeDirection {
        /// SwifterSwift: Shake left and right.
        case horizontal

        /// SwifterSwift: Shake up and down.
        case vertical
    }
    
    enum ShakeAnimationType {
        /// SwifterSwift: linear animation.
        case linear

        /// SwifterSwift: easeIn animation.
        case easeIn

        /// SwifterSwift: easeOut animation.
        case easeOut

        /// SwifterSwift: easeInOut animation.
        case easeInOut
    }
    
    func startShake(direction: ShakeDirection = .horizontal, duration: TimeInterval = 1, animationType: ShakeAnimationType = .easeOut, isRepeat: Bool = false, completion:(() -> Void)? = nil) {
        CATransaction.begin()
        let animation: CAKeyframeAnimation
        switch direction {
        case .horizontal:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        case .vertical:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        }
        switch animationType {
        case .linear:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        case .easeIn:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        }
        CATransaction.setCompletionBlock(completion)
        animation.duration = duration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        if isRepeat {
            animation.repeatCount = MAXFLOAT
        }
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
    
    func leftRightShakeRotate(num: Double = 10, duration: TimeInterval = 1, isRepeat: Bool = true) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.duration = duration
        animation.values = [-num / 180 * Double.pi, num / 180 * Double.pi, -num / 180 * Double.pi, num / 180 * Double.pi, -num / 180 * Double.pi]
        animation.fillMode = .forwards
        animation.repeatCount = isRepeat ? MAXFLOAT : 1
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "shakeRotate")
    }
}

public extension UIView {
    func removAllSubviews() {
        subviews.forEach({
            view in
            view.removeFromSuperview()
        })
    }
}
public extension UIStackView {
    func removAllarrangedSubviews() {
        arrangedSubviews.forEach({
            view in
            removeArrangedSubview(view)
            view.removeFromSuperview()
            view.isHidden = true
        })
    }
}

public extension UIView {
    func screenshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public extension UIScrollView {
    func screenshotScrollImage(needSetLayout: () -> Void) -> UIImage? {
        let orignalFrame = layer.frame
        let orignalContentOffset = contentOffset
        let orignalSuperView = superview
        let orignalSubIndex = superview?.subviews.firstIndex(where: {$0 == self})
        let orignalConstraints = constraints
        let orignalShowsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        let orignalShowsVerticalScrollIndicator = showsVerticalScrollIndicator

        let size = contentSize
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let contentFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let tempView = UIView(frame: contentFrame)
        frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        tempView.addSubview(self)
        contentOffset = .zero
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        tempView.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        frame = orignalFrame
        contentOffset = orignalContentOffset
        showsHorizontalScrollIndicator = orignalShowsHorizontalScrollIndicator
        showsVerticalScrollIndicator = orignalShowsVerticalScrollIndicator
        if let orignalSuperView = orignalSuperView {
            orignalSuperView.addSubview(self)
            orignalSuperView.insertSubview(self, at: orignalSubIndex!)
            needSetLayout()
        }
        UIGraphicsEndImageContext()

        return image
    }
}



public extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}

private var RedPointViewKey: Int8 = 0
public extension UIView {
    
    @discardableResult func showRedPointView(point: CGPoint, size: CGSize = CGSize(width: 7, height: 7)) -> UIView {
        addSubview(redPointView)
        redPointView.ss_size = size
        redPointView.ss_center = point
        redPointView.layer.cornerRadius = size.height / 2
        return redPointView
    }
    
    func hideRedPointView() {
        redPointView.isHidden = true
        objc_setAssociatedObject(self, &RedPointViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        redPointView.removeFromSuperview()
    }
    
    var redPointView: UIView {
        let view = objc_getAssociatedObject(self, &RedPointViewKey) as? UIView
        if let view = view {
            return view
        } else {
            let redPointView = UIView()
            redPointView.backgroundColor = UIColor.hex(0xFF4487)
            objc_setAssociatedObject(self, &RedPointViewKey, redPointView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return redPointView
        }
    }
}
