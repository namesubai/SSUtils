//
//  UIViewController+.swift
//  
//
//  Created by yangsq on 2020/10/22.
//

import Foundation
import NSObject_Rx

public extension UIViewController {
    enum ButtonItemType {
        case title(title: String, color: UIColor? = Colors.subTitle, font: UIFont = UIFont.systemFont(ofSize: 18))
        case image(name: String)
        case custom(customView: UIView)
    }
    
    var navigationBarHeight: CGFloat {
        if let navigationBar = self.navigationController?.navigationBar {
            return navigationBar.frame.height
        }
        return 0
    }
    
    var navigationBarAndStatusBarHeight: CGFloat {
        navigationBarHeight + App.statusBarHeight
    }
    
    var tabbarHeight: CGFloat {
        if let tabbar = self.tabBarController?.tabBar {
            return tabbar.frame.height
        }
        return 0
    }
    
    @discardableResult func setLeftBarButtonItem(itemType: ButtonItemType,animated: Bool = false, onTigger: (() -> Void)? = nil) -> UIBarButtonItem {
        switch itemType {
        case .title(let title, let color, let font):
            let barButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
            barButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor : color as Any], for: .normal)
            barButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor : color as Any], for: .highlighted)
            self.navigationItem.setLeftBarButtonItems([barButtonItem], animated: animated)
            barButtonItem.rx.tap.asObservable().subscribe(onNext:{
                if onTigger != nil {
                    onTigger!()
                }
            }).disposed(by: rx.disposeBag)
            return barButtonItem
        case .image(let name):
            let barButtonItem = UIBarButtonItem(image: UIImage(named: name)?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
            self.navigationItem.setLeftBarButtonItems([barButtonItem], animated: animated)
            barButtonItem.rx.tap.asObservable().subscribe(onNext:{
                if onTigger != nil {
                    onTigger!()
                }
            }).disposed(by: rx.disposeBag)
            return barButtonItem
        case .custom(let customView):
            let barButtonItem = UIBarButtonItem(customView: customView)
            self.navigationItem.setLeftBarButtonItems([barButtonItem], animated: animated)
            customView.rx.tap().subscribe(onNext:{_ in
                if onTigger != nil {
                    onTigger!()
                }
            }).disposed(by: rx.disposeBag)
            return barButtonItem
        }
    }
    
    @discardableResult func setRightBarButtonItem(itemType: ButtonItemType,animated: Bool = false, onTigger: (() -> Void)? = nil) -> UIBarButtonItem {
        switch itemType {
        case .title(let title, let color, let font):
            let barButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
            barButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor : color as Any], for: .normal)
            barButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor : color as Any], for: .highlighted)
            self.navigationItem.setRightBarButtonItems([barButtonItem], animated: animated)
            barButtonItem.rx.tap.asObservable().subscribe(onNext:{
                if onTigger != nil {
                    onTigger!()
                }
            }).disposed(by: rx.disposeBag)
            return barButtonItem
        case .image(let name):
            let barButtonItem = UIBarButtonItem(image: UIImage(named: name)?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
            self.navigationItem.setRightBarButtonItems([barButtonItem], animated: animated)
            barButtonItem.rx.tap.asObservable().subscribe(onNext:{
                if onTigger != nil {
                    onTigger!()
                }
            }).disposed(by: rx.disposeBag)
            return barButtonItem
        case .custom(let customView):
            let barButtonItem = UIBarButtonItem(customView: customView)
            self.navigationItem.setRightBarButtonItems([barButtonItem], animated: animated)
            customView.rx.tap().subscribe(onNext:{_ in
                if onTigger != nil {
                    onTigger!()
                }
            }).disposed(by: rx.disposeBag)
            return barButtonItem
        }
    }
    
    
}


public extension UIViewController {
    class func getRootViewController() -> UIViewController? {
        let window: UIWindow? = UIApplication.shared.keyWindow
        return window?.rootViewController
    }
    class func getCurrentViewController() -> UIViewController? {
        guard var currentViewController = UIViewController.getRootViewController() else {
            return nil
        }
        
        let runLoopFinish = true
        while runLoopFinish {
            if currentViewController.presentedViewController != nil {
                currentViewController = currentViewController.presentedViewController!
            } else if currentViewController.isKind(of: UINavigationController.self) {
                let naviC =  currentViewController as! UINavigationController
                currentViewController = naviC.children.last!
            } else if currentViewController.isKind(of: UITabBarController.self) {
                let tabC = currentViewController as! UITabBarController
                currentViewController = tabC.selectedViewController!
            } else {
                let count = currentViewController.children.count
                if  count > 0 {
                    currentViewController = currentViewController.children.last!
                }
                return currentViewController
            }
        }
        return currentViewController
    }
    class func getCurrentVC(with currentView: UIView) -> UIViewController? {
        var next: UIView = currentView
        while next.superview != nil {
            let resp = next.next!
            if resp.isKind(of: UIViewController.self) {
                return resp as? UIViewController
            }
            next = next.superview!
        }
        return nil
    }
}


public extension UIViewController {
    var isNavigationRootViewController: Bool {
        self.navigationController?.viewControllers.first == self
    }
}
