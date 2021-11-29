//
//  GradientProgressRangeView.swift
//  SSUtils
//
//  Created by yangsq on 2021/10/9.
//

import UIKit
import SnapKit

open class GradientProgressRangeView: View, EventTrigger {
    public enum Event {
        case progressDidChange
        case beginSliderDrag
        case endSliderDrag
    }
    public var progressGradientColors: [CGColor] = Colors.gradientColors {
        didSet {
            progressView.gradientLayer.colors = progressGradientColors
        }
    }
    public var normalColors: [CGColor] = [UIColor.hex(0xf5f5f5).cgColor, UIColor.hex(0xf5f5f5).cgColor] {
        didSet {
            normalView.gradientLayer.colors = normalColors
        }
    }
    
    private lazy var normalView: GradientView = {
        let view = GradientView()
        return view
    }()
    
    private lazy var progressView: GradientView = {
        let view = GradientView()
        return view
    }()
    
    private var progressWidthConstraint: Constraint?
    
    private lazy var beginSlider: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage(color: UIColor.white, size: CGSize(width: 30, height: 30))
        imageV.layer.cornerRadius = 30 / 2
        imageV.layer.borderWidth = 0.5
        imageV.layer.masksToBounds = true
        return imageV
    }()
    
    private lazy var endSlider: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage(color: UIColor.white, size: CGSize(width: 30, height: 30))
        imageV.layer.cornerRadius = 30 / 2
        imageV.layer.borderWidth = 0.5
        imageV.layer.masksToBounds = true
        return imageV
    }()
    
    public var beginSliderImag: UIImage? {
        didSet {
            if beginSliderImag != nil {
                beginSlider.image = beginSliderImag
                beginSlider.layer.cornerRadius = 0
                beginSlider.layer.borderWidth = 0
                setNeedsLayout()
            }
        }
    }
    
    public var endSliderImag: UIImage? {
        didSet {
            if endSliderImag != nil {
                endSlider.image = endSliderImag
                endSlider.layer.cornerRadius = 0
                endSlider.layer.borderWidth = 0
                setNeedsLayout()
            }
        }
    }
    
    public var beginSliderSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var endSliderSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    
    public var beginProgress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    public var endProgress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    public var progressCornerRadius: CGFloat = 0 {
        didSet {
            normalView.layer.masksToBounds = true
            normalView.layer.cornerRadius = progressCornerRadius
            progressView.layer.masksToBounds = true
            progressView.layer.cornerRadius = progressCornerRadius
        }
    }
    
    public var safeSpacing: CGFloat?
    public var realBeginProgress: CGFloat = 0
    public var realEndProgress: CGFloat = 0

    open override func layoutSubviews() {
        super.layoutSubviews()
        var progress = endProgress - beginProgress
        if progress > 1 {
            progress = 1
        }
        if progress < 0 {
            progress =  0
        }
        normalView.frame = bounds
        let width = normalView.ss_w * progress
        progressView.ss_w = width
        
        let beginX = normalView.ss_w * beginProgress
        progressView.ss_x = beginX
        beginSlider.ss_size = beginSliderSize
        beginSlider.ss_center = CGPoint(x: beginX, y: normalView.ss_h / 2)
        let endX = normalView.ss_w * endProgress
        endSlider.ss_size = endSliderSize
        endSlider.ss_center = CGPoint(x: endX, y: normalView.ss_h / 2)

        let safeWidthProgress = safeSpacing != nil ? (safeSpacing! /  normalView.ss_w) : ((beginSliderSize.width / 2 + endSliderSize.width / 2) / normalView.ss_w)
        self.realBeginProgress = beginSlider.center.x / (normalView.ss_w * (1 - safeWidthProgress))
        self.realEndProgress = endSlider.center.x / (normalView.ss_w)
        if let trigger = self.triggerEvent {
            trigger(.progressDidChange)
        }
    }
    
    open override func make() {
        super.make()
        addSubview(normalView)
        addSubview(progressView)
        addSubview(beginSlider)
        addSubview(endSlider)
        
        normalView.gradientLayer.colors = normalColors
        progressView.gradientLayer.colors = progressGradientColors
        beginSliderSize = beginSlider.image?.size ?? .zero
        endSliderSize = endSlider.image?.size ?? .zero

//        normalView.snp.makeConstraints { make in
//            make.edges.equalTo(0)
//        }
        progressView.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(0)
            progressWidthConstraint = make.width.equalTo(0).constraint
        }
        
        beginSlider.isUserInteractionEnabled = true
        endSlider.isUserInteractionEnabled = true
        let pan1 = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        let pan2 = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))

        beginSlider.addGestureRecognizer(pan1)
        endSlider.addGestureRecognizer(pan2)
        
    }
    
    @objc func panAction(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            if pan.view == endSlider {
                if let trigger = self.triggerEvent {
                    trigger(.endSliderDrag)
                }
            }
            
            if pan.view == beginSlider {
                if let trigger = self.triggerEvent {
                    trigger(.beginSliderDrag)
                }
            }
        case .changed:
            let point = pan.location(in: normalView)
            var moveX: CGFloat = point.x
            if point.x < 0 {
                moveX = 0
            }
            if point.x > normalView.ss_w {
                moveX = normalView.ss_w
            }
            
            var progress = moveX / normalView.ss_w
            let safeWidthProgress = safeSpacing != nil ? (safeSpacing! /  normalView.ss_w) : ((beginSliderSize.width / 2 + endSliderSize.width / 2) / normalView.ss_w)
            var realProgress = moveX / (normalView.ss_w * (1 - safeWidthProgress))
            if realProgress > 1 {
                realProgress = 1
            }
            if realProgress < 0 {
                realProgress = 0
            }
//            print(progress)

            if pan.view == endSlider {
                if progress >= beginProgress + safeWidthProgress {
                    self.endProgress = progress
                    self.realEndProgress = realProgress
                } else {
                    self.endProgress = beginProgress + safeWidthProgress
                    self.realEndProgress = realBeginProgress
                }
                

            }
            if pan.view == beginSlider {
                if progress <= endProgress - safeWidthProgress {
                    self.beginProgress = progress
                    self.realBeginProgress = realProgress
                } else {
                    self.beginProgress = endProgress - safeWidthProgress
                    self.realBeginProgress = realEndProgress
                    
                }
               
            }
            if let trigger = self.triggerEvent {
                trigger(.progressDidChange)
            }
           
            
        default:
            break
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if !self.point(inside: point, with: event) {
        
            if endSlider.frame.contains(point) {
                return endSlider
            }
            
            if beginSlider.frame.contains(point) {
                return beginSlider
            }
        }
        
        return super.hitTest(point, with: event)
    }

}
