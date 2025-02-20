//
//  Slider.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/12.
//

import UIKit
import RxSwift
import RxCocoa

open class PlayerSlider: UISlider {
    
    public lazy var progressLabel: UILabel = {
        let label = UILabel.makeLabel(textColor: Colors.headline,
                                      font: Fonts.autoBold(18))
        label.alpha = 0
        self.addSubview(label)
        return label
    }()
    
    public let beginDragTrigger = PublishSubject<Void>()
    public let endDragTrigger = PublishSubject<Void>()
    public let endProgressTrigger = PublishSubject<Double>()
    private(set) var isMoving = false
    public var progressHeight: CGFloat = 3.wScale
    public var showProgreeLabel: Bool = true {
        didSet {
            progressLabel.isHidden = !showProgreeLabel
        }
    }

    open override func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    
    open override func maximumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        App.feedbackGenerateImpact()
        self.progressLabel.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.progressLabel.alpha = 1
        }
        return super.beginTracking(touch, with: event)
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.progressLabel.alpha = 1
        UIView.animate(withDuration: 0.2) {
            self.progressLabel.alpha = 0
        }
        super.endTracking(touch, with: event)
    }
    
    open override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        layer.cornerRadius = progressHeight/2
        return CGRect.init(x: rect.origin.x, y: (bounds.size.height-progressHeight)/2, width: bounds.size.width - progressHeight * 2, height: progressHeight)
    }
    
    open override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        self.progressLabel.center = CGPoint(x: bounds.width * CGFloat(value), y: -27.wScale)
        self.progressLabel.sizeToFit()
        return super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        beginDragTrigger.onNext(())
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endDragTrigger.onNext(())
        UIView.animate(withDuration: 0.2) {
            self.progressLabel.alpha = 0
        }
        touches.forEach { [weak self] (touch) in
            guard let self = self else { return }
            let point = touch.location(in: self)
            if self.bounds.contains(point) {
                if !isMoving {
                    self.value = Float(point.x / self.bounds.width)
                }
                self.endProgressTrigger.onNext(Double(self.value))

            } else {
                if (point.y < 0 && abs(point.y) <= 20) || (point.y > 0 && (point.y - self.bounds.height) <= 20) {
                    if !isMoving {
                        self.value = Float(point.x / self.bounds.width)
                    }
                    self.endProgressTrigger.onNext(Double(self.value))
                }
            }
       }
        isMoving = false

        super.touchesCancelled(touches, with: event)

    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = true
        super.touchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endDragTrigger.onNext(())
        UIView.animate(withDuration: 0.2) {
            self.progressLabel.alpha = 0
        }
        touches.forEach { [weak self] (touch) in
            guard let self = self else { return }
            let point = touch.location(in: self)
            if self.bounds.contains(point) {
                if !isMoving {
                    self.value = Float(point.x / self.bounds.width)
                }
                self.endProgressTrigger.onNext(Double(self.value))

            } else {
                if (point.y < 0 && abs(point.y) <= 20) || (point.y > 0 && (point.y - self.bounds.height) <= 20) {
                    if !isMoving {
                        self.value = Float(point.x / self.bounds.width)
                    }
                    self.endProgressTrigger.onNext(Double(self.value))

                }
            }
       }
        isMoving = false

        super.touchesEnded(touches, with: event)

    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.point(inside: point, with: event) {
            if self.bounds.contains(CGPoint(x: point.x, y: 0)) {
                if (point.y < 0 &&  abs(point.y) <= 20) || (point.y > 0 && (point.y - self.bounds.height) <= 20) {
                    return self
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
