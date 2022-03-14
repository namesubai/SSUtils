//
//  EmptyView.swift
//  
//
//  Created by yangsq on 2020/11/6.
//

import UIKit
import SnapKit

open class EmptyView: UIView {
    
    public typealias HideCompletion = (() -> Void)
    
    public var hideCompletion: HideCompletion?
    public lazy var button: GradientButton = {
        let button = GradientButton.makeButton(type:.system)
        button.contentEdgeInsets = UIEdgeInsets(top: 13, left: 27, bottom: 13, right: 27).wScale
        button.gradientLayer.colors = [UIColor.hex(0x51E5E8)?.cgColor, UIColor.hex(0x32A6F9)?.cgColor]
        button.autoCornerRadious = true
        return button
    }()
    public lazy var titleLabel: UILabel = {
        let label = UILabel.makeLabel(text: text,
                                      numberOfLines: 0,
                                      alignment: .center)
        label.preferredMaxLayoutWidth = App.width - 120.wScale
        return label
    }()
    public lazy var imageView: UIImageView = {
        let imageV = UIImageView()
        imageV.image = image
        return imageV
    }()
    public private(set) var buttonCustomView: UIView?
    public private(set) var contenView: UIView?
    public var text: String?
    public var textFont: UIFont?
    public var textColor: UIColor?
    public var buttonTitle: String?
    public var buttonTitleFont: UIFont?
    public var buttonTitleColor: UIColor?
    public var image: UIImage?

    private var centerXConstraint: Constraint?
    private var centerYConstraint: Constraint?
    private var buttonTrigger: (() -> Void)? = nil
    var centerOffset: CGPoint = .zero {
        didSet {
            centerXConstraint?.update(offset: centerOffset.x)
            centerYConstraint?.update(offset: centerOffset.y)

        }
    }
    
    public func refreshLayout() {
        var topMargin: CGFloat = 0
        var totalHeight: CGFloat = 0
        contenView?.removAllSubviews()
        if let image = image {
            imageView.image = image
            contenView?.addSubview(imageView)
            imageView.snp.remakeConstraints { (make) in
                make.top.equalTo(topMargin)
                make.centerX.equalToSuperview()
                make.size.equalTo(image.size.wScale)
            }
            let imageSize  = image.size.wScale
            topMargin += imageSize.height + 18.wScale
            totalHeight = imageSize.height
        }
        
        if let text = text {
            titleLabel.text = text
            titleLabel.font = textFont
            titleLabel.textColor = textColor
            contenView?.addSubview(titleLabel)
            titleLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(topMargin)
                make.centerX.equalToSuperview()
                make.width.equalTo(App.width - 120.wScale)
            }
            let labelHeight = titleLabel.systemLayoutSizeFitting(CGSize(width: App.width - 120.wScale, height: CGFloat(MAXFLOAT))).height
            topMargin += labelHeight + 15.wScale
            totalHeight += labelHeight + 18.wScale
        }
        
        if let buttonTitle = buttonTitle {
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(buttonTitleColor, for: .normal)
            button.titleLabel?.font = buttonTitleFont
            contenView?.addSubview(button)

            button.snp.remakeConstraints { (make) in
                make.top.equalTo(topMargin)
                make.centerX.equalToSuperview()
            }
            let size = button.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
            topMargin += size.height
            totalHeight += size.height + 15.wScale
            button.rx.tap().subscribe(onNext: {
                [weak self] in guard let self = self else { return }
                if let buttonTrigger = self.buttonTrigger {
                    buttonTrigger()
                }
            }).disposed(by: button.rx.disposeBag)
        }
        
        if let buttonCustomView = buttonCustomView {
            contenView?.addSubview(buttonCustomView)
            if buttonCustomView.ss_size != .zero {
                buttonCustomView.snp.remakeConstraints { (make) in
                    make.top.equalTo(topMargin)
                    make.centerX.equalToSuperview()
                    make.size.equalTo(buttonCustomView.ss_size)
                }
            } else {
                buttonCustomView.snp.makeConstraints { (make) in
                    make.top.equalTo(topMargin)
                    make.centerX.equalToSuperview()
                }
            }
            
            let size = buttonCustomView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
            topMargin += size.height
            totalHeight += size.height + 15.wScale
            
            if let button = buttonCustomView as? UIButton {
                button.rx.tap.subscribe(onNext: {
                    [weak self] in guard let self = self else { return }
                    if let buttonTrigger = self.buttonTrigger {
                        buttonTrigger()
                    }
                }).disposed(by: button.rx.disposeBag)
            } else {
                button.rx.tap().subscribe(onNext: {
                    [weak self] in guard let self = self else { return }
                    if let buttonTrigger = self.buttonTrigger {
                        buttonTrigger()
                    }
                }).disposed(by: button.rx.disposeBag)
            }
        }
        
        contenView?.snp.remakeConstraints { (make) in
//            make.center.equalToSuperview()
            make.width.equalTo(App.width)
            make.height.equalTo(totalHeight)
            make.edges.equalToSuperview()
        }

    }
    
    public init(image: UIImage?,
         text: String?,
         textFont: UIFont?,
         textColor: UIColor?,
         buttonTitle:String?,
         buttonTitleFont: UIFont?,
         buttonTitleColor: UIColor?,
         buttonCustomView: UIView? = nil,
         buttonTrigger:(() -> Void)?) {
        self.image = image
        self.text = text
        self.textFont = textFont
        self.textColor = textColor
        self.buttonTitle = buttonTitle
        self.buttonTitleFont = buttonTitleFont
        self.buttonTitleColor = buttonTitleColor
        self.buttonCustomView = buttonCustomView
        self.buttonTrigger = buttonTrigger
        super.init(frame: .zero)
        let contenView = UIView()
        addSubview(contenView)
        self.contenView = contenView
        refreshLayout()
  
    }
    
    public func showEmptyView(_ onView: UIView) {
        onView.addSubview(self)
        self.snp.makeConstraints { (make) in
            centerXConstraint = make.centerX.equalToSuperview().constraint
            centerYConstraint = make.centerY.equalToSuperview().offset(-(App.navAndStatusBarHeight)).constraint
//            make.edges.equalToSuperview()
        }
    }
    
    public func hide() {
        self.removeFromSuperview()
        if  let hideCompletion = hideCompletion {
            hideCompletion()
        }
    }
    
    public func observerHideCompletion(completion: @escaping HideCompletion) {
        hideCompletion = completion
    }
    
    required public init?(coder: NSCoder) {
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

private var emptyViewKey: Int8 = 0
private var networkErrorEmptyView: Int8 = 0

public extension UIView {
    
//
    
    var notNetworkEmptyView: EmptyView? {
        objc_getAssociatedObject(self, &networkErrorEmptyView) as? EmptyView
    }
    
    @discardableResult func showNetworkErrorEmptyView( retry: (() -> Void)? = nil ) -> EmptyView? {
        if let emptyView = objc_getAssociatedObject(self, &networkErrorEmptyView) as? EmptyView {
            return emptyView
        } else {
            let image = App.emptyNotNetworkImage ?? image("notNetwork")
            let text = App.emptyNotNetworkText ?? localized(name: "noInternetAccess")
            let emptyView = EmptyView(image: image,
                                      text: text,
                                      textFont: App.emptyTitleFont ?? UIFont.systemFont(ofSize: 16),
                                      textColor: App.emptyTitleColor ?? UIColor.hex(0xcccccc),
                                      buttonTitle: App.emptyNotNetworkButtonCustomView == nil ? localized(name: "refresh") : nil,
                                      buttonTitleFont: App.emptyButtonTitleFont ?? UIFont.systemFont(ofSize: 16),
                                      buttonTitleColor: App.emptyButtonTitleColor ?? UIColor.hex(0xcccccc),
                                      buttonCustomView: App.emptyNotNetworkButtonCustomView ?? nil,
                                      buttonTrigger: retry)
            objc_setAssociatedObject(self, &networkErrorEmptyView, emptyView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            emptyView.observerHideCompletion(completion: {
                objc_setAssociatedObject(self, &networkErrorEmptyView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            })
            emptyView.showEmptyView(self)
            return emptyView
        }
        
    }
    
    func hideNetworkErrorEmptyView() {
        if let emptyView = objc_getAssociatedObject(self, &networkErrorEmptyView) as? EmptyView {
            emptyView.hide()
        }
    }
    
    @discardableResult func showEmptyView(image: UIImage? = nil,
                                          title: String? = nil,
                                          titleFont: UIFont? = nil,
                                          titleColor: UIColor? = nil,
                                          buttonTitle: String? = nil,
                                          buttonTitleFont: UIFont? = nil,
                                          buttonTitleColor: UIColor? = nil,
                                          buttonCustomView: UIView? = nil,
                                          buttonTrigger: (() -> Void)? = nil ) -> EmptyView? {
        if let emptyView = objc_getAssociatedObject(self, &emptyViewKey) as? EmptyView {
            return emptyView
        } else {
            let emptyView = EmptyView(image: image,
                                      text: title,
                                      textFont: titleFont ?? App.emptyTitleFont,
                                      textColor: titleColor ?? App.emptyTitleColor,
                                      buttonTitle: buttonTitle,
                                      buttonTitleFont: buttonTitleFont ?? App.emptyButtonTitleFont,
                                      buttonTitleColor: buttonTitleColor ?? App.emptyButtonTitleColor,
                                      buttonCustomView: buttonCustomView,
                                      buttonTrigger: buttonTrigger)
            objc_setAssociatedObject(self, &emptyViewKey, emptyView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            emptyView.observerHideCompletion(completion: {
                objc_setAssociatedObject(self, &emptyViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            })
            emptyView.showEmptyView(self)
            return emptyView
        }
    }
    
    var currentEmptyView: EmptyView? {
        return objc_getAssociatedObject(self, &emptyViewKey) as? EmptyView
    }
    
    func hideEmptyView() {
        if let emptyView = objc_getAssociatedObject(self, &emptyViewKey) as? EmptyView {
            emptyView.hide()
        }
    }
}
