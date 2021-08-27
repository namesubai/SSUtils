//
//  EmptyView.swift
//  
//
//  Created by yangsq on 2020/11/6.
//

import UIKit

open class EmptyView: UIView {
    
    public typealias HideCompletion = (() -> Void)
    
    public var hideCompletion: HideCompletion?
    
    public init(imageName: String?,
         text: String?,
         buttonTitle:String?,
         buttonTrigger:(() -> Void)?) {
        super.init(frame: .zero)
        let contenView = UIView()
        addSubview(contenView)
        
        var topMargin: CGFloat = 0
        var totalHeight: CGFloat = 0
        if let imageName = imageName {
            let imageV = UIImageView()
            imageV.image = UIImage(named: imageName)
            contenView.addSubview(imageV)
            imageV.snp.makeConstraints { (make) in
                make.top.equalTo(topMargin)
                make.centerX.equalToSuperview()
            }
            let imageSize  = imageV.image!.size
            topMargin += imageSize.height + 22
            totalHeight = imageSize.height
        }
        if let text = text {
            let label = UILabel.makeLabel(text: text,
                                          textColor: UIColor.hex(0xB5B5BA),
                                          font: UIFont.systemFont(ofSize: 15),
                                          alignment: .center)
            label.preferredMaxLayoutWidth = App.width - 80
            contenView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(topMargin)
                make.centerX.equalToSuperview()
            }
            let labelHeight = label.systemLayoutSizeFitting(CGSize(width: App.width - 80, height: CGFloat(MAXFLOAT))).height
            topMargin += labelHeight + 15
            totalHeight += labelHeight + 22

        }
        
        if let buttonTitle = buttonTitle {
            let button = UIButton.makeButton(type:.system,
                                             title: buttonTitle,
                                             titleColor: .black,
                                             font: UIFont.boldSystemFont(ofSize: 14),
                                             cornerRadius: 30/2)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 22, bottom: 8, right: 22)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            contenView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(topMargin)
                make.centerX.equalToSuperview()
                make.height.equalTo(30)
            }
            button.rx.tap.subscribe(onNext: {
                if let buttonTrigger = buttonTrigger {
                    buttonTrigger()
                }
            }).disposed(by: rx.disposeBag)
            
            topMargin += 30
            totalHeight += 30 + 15
            
        }
        
        contenView.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
            make.width.equalTo(App.width)
            make.height.equalTo(totalHeight)
            make.edges.equalToSuperview()
        }

    }
    
    public func showEmptyView(_ onView: UIView) {
        onView.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-(App.navAndStatusBarHeight))
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

extension UIView {
    
//
    
//    var emptyView: EmptyView? {
//        get {
//            if let emptyView = objc_getAssociatedObject(self, &EmptyViewKey) as? EmptyView {
//                return emptyView
//            }
//            return nil
//        }
//        set {
//
//            objc_setAssociatedObject(self, &EmptyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
    
    @discardableResult func showNetworkErrorEmptyView(retry: (() -> Void)? = nil ) -> EmptyView? {
        if let emptyView = objc_getAssociatedObject(self, &networkErrorEmptyView) as? EmptyView {
            return emptyView
        } else {
            let emptyView = EmptyView(imageName: "",
                                      text: "No internet access",
                                      buttonTitle: nil,
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
    
    @discardableResult func showEmptyView(imageName: String? = nil,
                                          title: String? = nil,
                                          buttonTitle:String? = nil,
                                          buttonTrigger: (() -> Void)? = nil ) -> EmptyView? {
        if let emptyView = objc_getAssociatedObject(self, &emptyViewKey) as? EmptyView {
            return emptyView
        } else {
            let emptyView = EmptyView(imageName: imageName,
                                      text: title,
                                      buttonTitle: buttonTitle,
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
