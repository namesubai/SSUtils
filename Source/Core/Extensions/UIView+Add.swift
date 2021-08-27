//
//  UIView+.swift
//  
//
//  Created by yangsq on 2020/10/21.
//

import UIKit

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
    
    func addCorner(roundingCorners: UIRectCorner, cornerSize: CGSize) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
        let cornerLayer = CAShapeLayer()
        cornerLayer.frame = bounds
        cornerLayer.path = path.cgPath
        cornerLayer.shouldRasterize = true
        cornerLayer.rasterizationScale = UIScreen.main.scale
        layer.mask = cornerLayer
    }
}


public extension UIView {
    func startRotate() {
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
            animation.duration = 10
            animation.repeatCount = MAXFLOAT
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            layer.add(animation, forKey: "rotate")
        }
    }
    
    func stopRotate() {
        if let _ = layer.animation(forKey: "rotate") {
            let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.speed = 0.0
            layer.timeOffset = pausedTime
        }
    }
}
