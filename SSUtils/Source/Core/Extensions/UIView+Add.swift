//
//  UIView+.swift
//  
//
//  Created by yangsq on 2020/10/21.
//

import UIKit

fileprivate class LineAnimationView: View {
    lazy var animationView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex(0xffffff)?.withAlphaComponent(0.5)
        return view
    }()
    lazy var animationImageV: UIImageView = {
        let imageV = UIImageView()
        imageV.image = self.animationImage
        return imageV
    }()
    var animationSize: CGSize
    var superSize: CGSize
    var animationImage: UIImage?
    var duration: CGFloat
    init(animationSize: CGSize, superSize: CGSize, duration: CGFloat = 0.8, animationImage: UIImage? = nil)  {
        self.duration = duration
        self.animationSize = animationSize
        self.animationImage = animationImage
        self.superSize = superSize
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func make() {
        super.make()
        isUserInteractionEnabled = false
        var animationView = self.animationView
        if let animationImage = self.animationImage {
            addSubview(animationImageV)
            animationView = animationImageV
        } else {
            addSubview(animationView)
        }
        
        animationView.ss_size = animationSize
        pow(animationSize.width / 2, 2)
        let distance = sqrt(pow(animationSize.width / 2, 2) / 2)
        animationView.ss_center = CGPoint(x: -distance, y: -distance)
        animationView.transform = CGAffineTransform.init(rotationAngle: Double.pi / 4)
//        animationView.ss_center = CGPoint(x: 30, y: 45)
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.fromValue = animationView.ss_center
        animation.toValue = CGPoint(x: superSize.width + distance, y: superSize.height + distance)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float(Double.infinity)
        animationView.layer.add(animation, forKey: "LineAnimationView.Animation")
    }
}

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
private var currentLayerKey: Int8 = 0
public extension UIView {
    enum Line {
        case top,left,bottom,right
    }
    @discardableResult func addLine(line: Line,
                                    size: CGFloat = App.pixel,
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
    
    private var currentLayer: CAShapeLayer? {
        set {
            objc_setAssociatedObject(self, &currentLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &currentLayerKey) as? CAShapeLayer
        }
    }
    
    func addCorner(size: CGSize = .zero, origin: CGPoint = .zero, roundingCorners: UIRectCorner, cornerSize: CGSize, borderColor: CGColor? = nil, borderWidth: CGFloat? = nil) {
        let frame = size == .zero ? bounds : CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: frame, byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
        if borderColor != nil, borderWidth != nil {
            let borderPath = UIBezierPath(roundedRect: CGRect(x: (borderWidth ?? 0) / 2, y:  (borderWidth ?? 0) / 2, width: frame.width - (borderWidth ?? 0), height: frame.height - (borderWidth ?? 0)), byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
            
            currentLayer?.removeFromSuperlayer()
            let borderLayer = CAShapeLayer()
            borderLayer.frame = frame
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.lineJoin = .round
            if let borderColor = borderColor {
                borderLayer.strokeColor = borderColor
            }
            if let borderWidth = borderWidth {
                borderLayer.lineWidth = borderWidth
            }
            borderLayer.path = borderPath.cgPath
            layer.addSublayer(borderLayer)
            currentLayer = borderLayer
        }
        
        let cornerLayer = CAShapeLayer()
        cornerLayer.lineJoin = .round
        cornerLayer.frame = frame
        cornerLayer.path = path.cgPath
        cornerLayer.shouldRasterize = true
        cornerLayer.rasterizationScale = UIScreen.main.scale
        cornerLayer.masksToBounds = true
        layer.mask = cornerLayer
    }
    
    func addGradientBorder(size: CGSize = .zero, opacity: Float = 1, colors: [UIColor], startPoint: CGPoint = .zero, endPoint: CGPoint = .init(x: 1, y: 1), borderWidth: CGFloat, cornerRadius: CGFloat) {
        let frame = CGRect(x: 0, y: 0, width: size.width ?? self.bounds.width, height: size.height ?? self.bounds.height)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.opacity = opacity
        gradientLayer.colors = colors.map({ $0.cgColor })
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        let maskFrame = CGRect(x: borderWidth / 2, y: borderWidth / 2, width: frame.width - borderWidth, height: frame.height - borderWidth)
        
        let maskLayer = CAShapeLayer()
        maskLayer.lineWidth = borderWidth
        maskLayer.path = UIBezierPath(roundedRect: maskFrame, cornerRadius: cornerRadius).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = maskLayer
        
        self.layer.addSublayer(gradientLayer)
    }
}


public extension UIView {
    func startRotate(duration: TimeInterval = 2) {
        if let _ = layer.animation(forKey: "rotate"), layer.speed == 0 {
            let time = layer.timeOffset
            layer.speed = 1.0
            layer.timeOffset = 0
//            layer.beginTime = 0
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
    
    func removeRotate() {
        layer.removeAnimation(forKey: "rotate")
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
    
    func rotate(angle: CGFloat) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = angle
        animation.duration = 0
        animation.repeatCount = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "rotateAngle")
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
    /// 方向移动
    func startShake(direction: ShakeDirection = .horizontal, duration: TimeInterval = 1, animationType: ShakeAnimationType = .easeInOut, values: [Any] = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0], isRepeat: Bool = false, completion:(() -> Void)? = nil) {
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
        animation.values = values
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        if isRepeat {
            animation.repeatCount = MAXFLOAT
        }
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
    // 抖动
    func leftRightShakeRotate(num: Double = 10, duration: TimeInterval = 1, isRepeat: Bool = true) {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        animation.duration = duration
        animation.values = [-num / 180 * Double.pi, num / 180 * Double.pi, -num / 180 * Double.pi, num / 180 * Double.pi, -num / 180 * Double.pi]
        animation.fillMode = .forwards
        animation.repeatCount = isRepeat ? MAXFLOAT : 1
        animation.isRemovedOnCompletion = true
        layer.add(animation, forKey: "shakeRotate")
    }
    
    func scaleAnimation(duration: TimeInterval = 1, minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.values = [minScale, maxScale, minScale]
        animation.fillMode = .forwards
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "scale")
    }
    
    func addLineAnimate(animateSize: CGSize, animationImage: UIImage? = nil, duration: CGFloat = 0.8, superSize: CGSize, cornerRadius: CGFloat = 0) {
        let animationView = LineAnimationView(animationSize: animateSize, superSize: superSize, duration: duration, animationImage: animationImage)
        animationView.layer.masksToBounds = true
        animationView.layer.cornerRadius = cornerRadius
        addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
}

public extension UIView {
    func removAllSubviews(andHide: Bool = false) {
        subviews.forEach({
            view in
            view.isHidden = andHide
            view.removeFromSuperview()
        })
    }
}
public extension UIStackView {
    func removAllarrangedSubviews(andHide: Bool = true) {
        arrangedSubviews.forEach({
            view in
            removeArrangedSubview(view)
            view.removeFromSuperview()
            view.isHidden = andHide
        })
    }
}

public extension UIView {
    
    func screenshotImage(rect: CGRect? = nil) -> UIImage? {

        
        /// 这个截图方法可以把blur的效果也截图到
        let frame = rect ?? bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        drawHierarchy(in: frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
       
        let cgIImage =  image?.cgImage?.cropping(to: CGRect(origin: CGPoint(x: frame.origin.x * UIScreen.main.scale  , y: frame.origin.y * UIScreen.main.scale), size: CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale)))
        var newImage: UIImage?
        if let cgIImage = cgIImage {
            newImage = UIImage(cgImage: cgIImage, scale: UIScreen.main.scale, orientation: UIImage.Orientation.up)
        }
        
//        (self.view.viewWithTag(90) as? UIImageView)?.image = newImage
        
        UIGraphicsEndImageContext()
        return newImage
    }
    /// 有毛玻璃的裁剪不了
    func screenshotImageIgnoreBlur(rect: CGRect? = nil) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.frame = rect ?? layer.frame
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func screenshotCorrectly() -> UIImage? {
        var width = layer.frame.size.width
        var height = layer.frame.size.height
        if transform.a != 0 { width = (width / transform.a).rounded() }
        if transform.d != 0 { height = (height / transform.d).rounded() }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func openglSnapshotImage() -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        let size = self.bounds.size
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, UIScreen.main.scale)
        let rect = self.frame
        drawHierarchy(in: rect, afterScreenUpdates: true)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
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
    
    @discardableResult func showRedPointView(point: CGPoint, size: CGSize = CGSize(width: 7, height: 7), color: UIColor? = nil) -> UIView {
        addSubview(redPointView)
        redPointView.ss_size = size
        redPointView.ss_center = point
        if let color = color {
            redPointView.backgroundColor = color
        }
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
