//
//  SSCountLabel.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/7/7.
//

import UIKit

open class CountLabel: UILabel {
    private var currentNumber = 0.0
    open var number: Int = 0 {
        didSet {
            let countDuration = Double(number / 10) * 0.5
            if countDuration > 1 {
                duration = 1
            }
            else if countDuration < 0.5 {
                duration = 0.5
            }
            else {
                duration = countDuration
            }
        }
    }
    
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(displayAction(diplayLink:)))
        displayLink.add(to: RunLoop.current, forMode: .common)
//        displayLink.preferredFramesPerSecond = 1
        return displayLink
    }()
    
    open var duration: TimeInterval = 1
    public override init(frame: CGRect) {
        super.init(frame: frame)
        text = "0"
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc
    open func displayAction(diplayLink: CADisplayLink) {
        if currentNumber >= Double(number) {
            currentNumber = Double(number)
            stopAnimation()
            text = "\(number)"
        } else {
            let num = Double(number) / (duration / displayLink.duration)
            currentNumber += num
            text = "\(Int(currentNumber))"
        }
    }
    
    open func startAnimation() {
        displayLink.isPaused = false
    }
    
    open func stopAnimation() {
        displayLink.isPaused = true
        displayLink.invalidate()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
