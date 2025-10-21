//
//  ClickGradientView.swift
//  
//
//  Created by yangsq on 2020/11/16.
//

import UIKit
import RxCocoa
import RxSwift

open class SSClickGradientView: SSGradientView,SSEventTrigger {

    public let rxEvent = PublishSubject<Event>()
    
    public enum Event {
        case begin
        case end
        case click
    }
    
    public override init(colors: [CGColor] = SSColors.gradientColors, size: CGSize = .zero, customView: UIView? = nil, cornerRadius: CGFloat = 0) {
        super.init(colors: colors, size: size, customView: customView, cornerRadius: cornerRadius)
        self.gradientLayer.opacity = 0
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gradientLayer.opacity = 1
        rxEvent.onNext(.begin)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gradientLayer.opacity = 0
        if let triggerEvent = self.triggerEvent {
            triggerEvent(.click)
        }
        rxEvent.onNext(.end)
        rxEvent.onNext(.click)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gradientLayer.opacity = 0
        rxEvent.onNext(.end)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
