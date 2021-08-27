//
//  ClickGradientView.swift
//  
//
//  Created by yangsq on 2020/11/16.
//

import UIKit
import RxCocoa
import RxSwift

class ClickGradientView: GradientView,EventTrigger {

    let rxEvent = PublishSubject<Event>()
    
    enum Event {
        case begin
        case end
        case click
    }
    
    override init(colors: [CGColor] = Colors.gradientColors, size: CGSize = .zero, customView: UIView? = nil, cornerRadius: CGFloat = 0) {
        super.init(colors: colors, size: size, customView: customView, cornerRadius: cornerRadius)
        self.gradientLayer.opacity = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gradientLayer.opacity = 1
        rxEvent.onNext(.begin)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.gradientLayer.opacity = 0
        if let triggerEvent = self.triggerEvent {
            triggerEvent(.click)
        }
        rxEvent.onNext(.end)
        rxEvent.onNext(.click)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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
