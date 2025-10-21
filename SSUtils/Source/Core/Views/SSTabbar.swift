//
//  Tabbar.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit

open class SSTabbar: UITabBar {

    public var cornerRadious: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private var bageViews = [SSBageView]()
    
    public var bageTextFont: UIFont? {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = SSColors.line
        view.isHidden = true
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        addSubview(lineView)
    }
    
    open override var standardAppearance: UITabBarAppearance {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        items?.forEach({ item in
            let appearance = self.standardAppearance
            let tabBarItemAppearance = UITabBarItemAppearance()
            tabBarItemAppearance.normal.titleTextAttributes = item.titleTextAttributes(for: .normal) ?? [NSAttributedString.Key : Any]()
            tabBarItemAppearance.selected.titleTextAttributes = item.titleTextAttributes(for: .selected) ?? [NSAttributedString.Key : Any]()
            appearance.stackedLayoutAppearance = tabBarItemAppearance
            
            item.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                item.scrollEdgeAppearance = appearance
            } 
        })
        addCorner(radious: cornerRadious)
        lineView.frame = CGRect(x: cornerRadious, y: 0, width: ss_w - cornerRadious * 2, height: 0.5)
        if bageViews.count != items?.count || bageViews.first?.superview == nil {
            bageViews.forEach({
                view in
                view.removeFromSuperview()
            })
            bageViews.removeAll()
            subviews.forEach({
                tabBarButton in
                if NSStringFromClass(tabBarButton.classForCoder) == "UITabBarButton" {
                    if let imageV = self.findTabbarItemImageV(onView: tabBarButton) {
                        let bageView = SSBageView()
                        bageView.bageLab.font = bageTextFont
                        bageView.layer.zPosition = 2
                        bageView.isUserInteractionEnabled = false
                        imageV.superview?.addSubview(bageView)
                        bageView.refrehFrame()
                        let imageHeight = imageV.image?.size.height ?? 0
                        let imageWith = imageV.image?.size.width ?? 0
                        bageView.snp.makeConstraints { make in
                            make.left.equalTo(imageV.snp.centerX).offset(imageWith / 4 - 3)
                            make.centerY.equalTo(imageV.snp.centerY).offset(-imageHeight / 2 + 4)
                        }
                        bageView.isHidden = true
                        bageViews.append(bageView)
                    }
                }
            })
        } else {
            bageViews.forEach({
                view in
                view.bageLab.font = bageTextFont
            })
        }
        
        
    }
    
    public func setBageValue(_ bageValue: String?, index: Int) {
        if bageViews.count > index {
            let bageView = bageViews[index]
            if bageValue?.isLength != true {
                bageView.isHidden = true
            } else {
                bageView.isHidden = false
                bageView.bageLab.text = bageValue
                bageView.refrehFrame()
            }
        }
    }
    
    
    
    func findTabbarItemImageV(onView: UIView) -> UIImageView? {
        
        for view in onView.subviews {
            if let imageV = view as? UIImageView, NSStringFromClass(view.classForCoder) == "UITabBarSwappableImageView"  {
                return imageV
            } else {
                let imageV = findTabbarItemImageV(onView: view)
                if imageV != nil {
                    return imageV
                }
            }
        }
        return nil
    }
    
    public required init?(coder: NSCoder) {
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
