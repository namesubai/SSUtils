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
    /// 是否自动设置selected的时候高亮，避免当按钮是selected状态，长按回是nomarl的情况
    public var isAutoSetSelectedHightLight = false
    /// 是否自动设置normal的时候高亮，避免当按钮是selected状态，长按回是nomarl的情况
    public var isAutoSetNormalHightLight = false
    
    private var isShowingRedCacheKey: String?
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
        if isShowingRedCacheKey != nil {
            UserDefaults.standard.set(true, forKey: isShowingRedCacheKey!)
            hideRedPointView()
        }
        return super.beginTracking(touch, with: event)
    }
    
    open override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        if state == .selected && isAutoSetSelectedHightLight {
            setImage(image, for: [.highlighted, .selected])
        }
        
        if state == .normal && isAutoSetNormalHightLight {
            setImage(image, for: [.highlighted, .normal])
        }
    }
    
    
    open override func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        super.setBackgroundImage(image, for: state)
        if state == .selected && isAutoSetSelectedHightLight {
            setBackgroundImage(image, for: [.highlighted, .selected])
        }
        
        if state == .normal && isAutoSetNormalHightLight {
            setBackgroundImage(image, for: [.highlighted, .normal])
        }
    }
    
    open override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        if state == .selected && isAutoSetSelectedHightLight {
            setTitle(title, for: [.highlighted, .selected])
        }
        
        if state == .normal && isAutoSetNormalHightLight {
            setTitle(title, for: [.highlighted, .normal])
        }
    }
    
    open override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        if state == .selected && isAutoSetSelectedHightLight {
            setTitleColor(color, for: [.highlighted, .selected])
        }
        
        if state == .normal && isAutoSetNormalHightLight {
            setTitleColor(color, for: [.highlighted, .normal])
        }
    }
    
    open override func setTitleShadowColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleShadowColor(color, for: state)
        if state == .selected && isAutoSetSelectedHightLight {
            setTitleShadowColor(color, for: [.highlighted, .selected])
        }
        
        if state == .normal && isAutoSetNormalHightLight {
            setTitleShadowColor(color, for: [.highlighted, .normal])
        }
    }
    
    public func showRedPoint(point: CGPoint, size: CGSize, cacheKey: String) {
        if UserDefaults.standard.bool(forKey: cacheKey) == false {
            self.isShowingRedCacheKey = cacheKey
            showRedPointView(point: point, size: size)
        }
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
