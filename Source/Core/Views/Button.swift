//
//  Button.swift
//  
//
//  Created by yangsq on 2020/10/21.
//

import UIKit
import RxSwift
import RxCocoa

open class Button: UIButton {
    open var isOpenFeedbackGenerateImpact = false
    open override var isSelected: Bool {
        didSet{
            if isSelected {
                if selectedBorderColor != nil {
                    self.layer.borderColor = selectedBorderColor!.cgColor
                }
            }else {
                
                if normalBorderColor != nil {
                    self.layer.borderColor = normalBorderColor!.cgColor
                }
            }
            
        }
    }
    
    open var selectedBorderColor: UIColor? {
        didSet{
            if isSelected {
                if selectedBorderColor != nil {
                    self.layer.borderColor = selectedBorderColor!.cgColor
                }
            }else {
                if normalBorderColor != nil {
                    self.layer.borderColor = normalBorderColor!.cgColor
                }
            }
        }
    }
    
    open var normalBorderColor: UIColor? {
        didSet{
            if !isSelected {
                if normalBorderColor != nil {
                    self.layer.borderColor = normalBorderColor!.cgColor
                }
            }else {
                if selectedBorderColor != nil {
                    self.layer.borderColor = selectedBorderColor!.cgColor
                }
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if isOpenFeedbackGenerateImpact {
            App.feedbackGenerateImpact()
        }
        return super.beginTracking(touch, with: event)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

public extension Reactive where Base: Button {

    var selectedBorderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            guard let attr = attr else { return }
            view.selectedBorderColor = attr
        }
    }
    
    var normalBorderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            guard let attr = attr else { return }
            view.normalBorderColor = attr
        }
    }
}
