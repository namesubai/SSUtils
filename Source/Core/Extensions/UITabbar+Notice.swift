//
//  UITabbar+Notice.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/7/6.
//

import Foundation

public extension UITabBar {
    func showAndHideRedPoin(index: Int, isShow: Bool) {
        var buttons = [UIView]()
        for view in self.subviews {
            if NSStringFromClass(view.classForCoder) == "UITabBarButton" {
                buttons.append(view)
            }
        }
        
        level1:  for i in 0..<buttons.count {
            let view = buttons[i]
            if i == index {
                for subView in view.subviews {
                    if NSStringFromClass(subView.classForCoder) == "UITabBarSwappableImageView" {
                        if let redPointView = view.viewWithTag(1000 + index) {
                            redPointView.isHidden = !isShow
                            break level1
                        } else {
                            let redpointView = UIView()
                            redpointView.backgroundColor = UIColor.hex(0xFF004C)
                            redpointView.layer.cornerRadius = 7 / 2
                            redpointView.layer.masksToBounds = true
                            redpointView.tag = 1000 + index
                            view.addSubview(redpointView)
                            redpointView.snp.makeConstraints { make in
                                make.left.equalTo(subView.snp.right).offset(4)
                                make.top.equalTo(subView).offset(0)
                                make.size.equalTo(CGSize(width: 7, height: 7))
                            }
                            redpointView.isHidden = !isShow
                            break level1
                        }
                       
                    }
                }
            }
            
        }
    }
}
