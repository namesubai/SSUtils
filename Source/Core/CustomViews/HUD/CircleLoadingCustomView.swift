//
//  CircleLoadingCustomView.swift
//  SSUtils
//
//  Created by yangsq on 2021/10/13.
//

import UIKit

public class CircleLoadingCustomView: UIView, SSProgressCustom {
    
    public enum LoadingType {
        case loading
        case progress
    }
    
    public var text: String? = nil
    
    public var textColor: UIColor? = nil
    
    public var textFont: UIFont? = nil
    
    public var customSize: CGSize  = CGSize(width: 30, height: 30)
    
    public var image: UIImage? = nil
    
    private var _progress: CGFloat?
    public var progress: CGFloat? {
        
        set {
            if var progress = newValue {
                _progress = progress
                if progress < 0 {
                    progress = 0
                }
                if progress > 1 {
                    progress = 1
                }
                let progressBezierPath = UIBezierPath.init(arcCenter: CGPoint(x: customSize.width / 2, y: customSize.height / 2), radius: customSize.width / 2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(-0.5 * Double.pi) + CGFloat(2 * Double.pi) * progress, clockwise: true)

                progressShapLayer.path = progressBezierPath.cgPath
            }
        }
        get {
            _progress
        }
    }
    
    public var loadingType: LoadingType
    private var progressShapLayer: CAShapeLayer!
    
    public init(type: LoadingType) {
        self.loadingType = type
        super.init(frame: .zero)
        let bgShapLayer = CAShapeLayer()
        bgShapLayer.frame = CGRect(x: 0, y: 0, width: customSize.width, height: customSize.height)
        bgShapLayer.lineWidth = 3
        bgShapLayer.fillColor = UIColor.clear.cgColor
        bgShapLayer.strokeColor = UIColor.hex(0xffffff)?.withAlphaComponent(0.4).cgColor
        
        let center = CGPoint.init(x: customSize.width/2, y: customSize.height/2)
        let bezierPath = UIBezierPath.init(arcCenter: center, radius: customSize.width / 2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
        bgShapLayer.path = bezierPath.cgPath
        self.layer.addSublayer(bgShapLayer)

        progressShapLayer = CAShapeLayer()
        progressShapLayer.frame = CGRect(x: 0, y: 0, width: customSize.width, height: customSize.height)
        progressShapLayer.lineWidth = 3
        progressShapLayer.fillColor = UIColor.clear.cgColor
        progressShapLayer.strokeColor = UIColor.hex(0xffffff)?.cgColor
        progressShapLayer.lineCap = .round
        
        self.layer.addSublayer(progressShapLayer)
        if type == .loading {
            let progressBezierPath = UIBezierPath.init(arcCenter: center, radius: customSize.width / 2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(0 * Double.pi), clockwise: true).reversing()
            progressShapLayer.path = progressBezierPath.cgPath
            startRotate(duration: 1)
        } 
        
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
