//
//  GradientTextLabel.swift
//  SSUtils
//
//  Created by yangsq on 2022/2/10.
//

import UIKit

public class GradientTextLabel: UILabel {

    open var titleLabelGradientColors: [CGColor] = [] {
        didSet {
            if titleLabelGradientColors.count > 0 {
                setNeedsDisplay()
                layoutIfNeeded()
            }

        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if titleLabelGradientColors.count > 0 {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
            let context = UIGraphicsGetCurrentContext()
            let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
            let gradientRef = CGGradient.init(colorsSpace: colorSpaceRef, colors: titleLabelGradientColors as CFArray, locations: nil)
            let startPoint = CGPoint(x: bounds.width  * titleLabelGradientStartPoint.x, y: bounds.height * titleLabelGradientStartPoint.y)
            let endPoint = CGPoint(x: bounds.width  * titleLabelGradientEndPoint.x, y: bounds.height * titleLabelGradientEndPoint.y)
            context?.drawLinearGradient(gradientRef!, start: startPoint, end: endPoint, options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
            let graientImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if graientImage != nil {
                let color = UIColor(patternImage: graientImage!)
                textColor = color
            }
            
        }
    }
    
    open var titleLabelGradientStartPoint: CGPoint = .zero
    
    open var titleLabelGradientEndPoint: CGPoint = CGPoint(x: 1, y: 1)

}
