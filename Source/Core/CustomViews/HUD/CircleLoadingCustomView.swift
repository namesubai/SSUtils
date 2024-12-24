//
//  CircleLoadingCustomView.swift
//  SSUtils
//
//  Created by yangsq on 2021/10/13.
//

import UIKit

public class CircleLoadingCustomView: SSProgressCustomView {
    
    public enum LoadingType {
        case loading
        case progress
    }
    
    public var text: String? = nil
    
    public var textColor: UIColor? = nil {
        didSet {
            progressLabel.textColor = textColor
        }
    }
    
    public var textFont: UIFont? = nil {
        didSet {
            progressLabel.font = textFont
        }
    }
    
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
                progressLabel.text = "\(Int((progress / 1) * 100.0))%"
                layoutIfNeeded()
            }
        }
        get {
            _progress
        }
    }
    
    public var loadingType: LoadingType
    private var progressShapLayer: CAShapeLayer!
    public var normalColor: UIColor? {
        didSet {
            bgShapLayer.strokeColor = normalColor?.cgColor
        }
    }
    public var trackColor: UIColor? {
        didSet {
            progressShapLayer.strokeColor = trackColor?.cgColor
        }
    }
    public var progreLineWidth: CGFloat = 3 {
        didSet {
            progressShapLayer.lineWidth = progreLineWidth
        }
    }
    
    private var bgShapLayer: CAShapeLayer!
    private var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    public init(type: LoadingType) {
        self.loadingType = type
        super.init(frame: .zero)
        bgShapLayer = CAShapeLayer()
        bgShapLayer.frame = CGRect(x: 0, y: 0, width: customSize.width, height: customSize.height)
        bgShapLayer.lineWidth = 3
        bgShapLayer.fillColor = UIColor.clear.cgColor
        self.normalColor = UIColor.hex(0xffffff)?.withAlphaComponent(0.4)
        
        let center = CGPoint.init(x: customSize.width/2, y: customSize.height/2)
        let bezierPath = UIBezierPath.init(arcCenter: center, radius: customSize.width / 2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
        bgShapLayer.path = bezierPath.cgPath
        self.layer.addSublayer(bgShapLayer)

        progressShapLayer = CAShapeLayer()
        progressShapLayer.frame = CGRect(x: 0, y: 0, width: customSize.width, height: customSize.height)
        self.progreLineWidth = 3
        progressShapLayer.fillColor = UIColor.clear.cgColor
        self.trackColor = UIColor.hex(0xffffff)
        progressShapLayer.lineCap = .round
        
        self.layer.addSublayer(progressShapLayer)
        if type == .loading {
            let progressBezierPath = UIBezierPath.init(arcCenter: center, radius: customSize.width / 2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(0 * Double.pi), clockwise: true).reversing()
            progressShapLayer.path = progressBezierPath.cgPath
            startRotate(duration: 1)
        } 
        if type == .progress {
            addSubview(progressLabel)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.loadingType == .progress {
            progressLabel.frame = CGRect(x: progreLineWidth, y: progreLineWidth, width: ss_w - progreLineWidth * 2, height: ss_h - progreLineWidth * 2)
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
