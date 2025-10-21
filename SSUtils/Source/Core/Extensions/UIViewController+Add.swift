//
//  UIViewController+.swift
//  
//
//  Created by yangsq on 2020/10/22.
//

import Foundation
import NSObject_Rx
import UIKit

public extension UIViewController {
    enum ButtonItemType {
        case title(title: String, color: UIColor? = SSColors.subTitle, font: UIFont = UIFont.systemFont(ofSize: 18))
        case image(_ image: UIImage?)
        case custom(customView: UIView)
        case space(width: CGFloat)
    }
    
    var navigationBarHeight: CGFloat {
        if let navigationBar = self.navigationController?.navigationBar {
            return navigationBar.frame.height
        }
        return 0
    }
    
    var statusBarHeight: CGFloat {
        return SSApp.statusBarHeight
    }
    
    var navigationBarAndStatusBarHeight: CGFloat {
        navigationBarHeight + SSApp.statusBarHeight
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
        case .image(let image):
            let barButtonItem = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
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
        case .space(let width):
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            barButtonItem.width = width
            self.navigationItem.setLeftBarButtonItems([barButtonItem], animated: animated)
            return barButtonItem
        }
    }
    
    @discardableResult func setLeftBarButtonItems(itemTypes: [ButtonItemType],animated: Bool = false, onTigger: ((Int) -> Void)? = nil) -> [UIBarButtonItem] {
        var barButtonItems = [UIBarButtonItem]()
        for i in 0..<itemTypes.count {
            let itemType = itemTypes[i]
            var barButtonItem: UIBarButtonItem!
            var isSpace: Bool = false
            switch itemType {
            case .title(let title, let color, let font):
                barButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
                barButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor : color as Any], for: .normal)
                barButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor : color as Any], for: .highlighted)
                 
            case .image(let image):
                barButtonItem = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
                
            case .custom(let customView):
                barButtonItem = UIBarButtonItem(customView: customView)
                
            case .space(let width):
                barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                barButtonItem.width = width
                isSpace = true
            }
            barButtonItems.append(barButtonItem)
            if !isSpace {
                barButtonItem.rx.tap.asObservable().subscribe(onNext:{
                    if onTigger != nil {
                        onTigger!(i)
                    }
                }).disposed(by: rx.disposeBag)
                
                if let button = barButtonItem.customView as? UIButton {
                    button.rx.tap.asObservable().subscribe(onNext:{
                        if onTigger != nil {
                            onTigger!(i)
                        }
                    }).disposed(by: rx.disposeBag)
                } else if let view = barButtonItem.customView as? UIView {
                    view.rx.tap().subscribe(onNext:{
                        if onTigger != nil {
                            onTigger!(i)
                        }
                    }).disposed(by: rx.disposeBag)
                }
            }
           
        }
        self.navigationItem.setLeftBarButtonItems(barButtonItems, animated: animated)

        return barButtonItems
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
        case .image(let image):
            let barButtonItem = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
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
        case .space(let width):
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            barButtonItem.width = width
            self.navigationItem.setLeftBarButtonItems([barButtonItem], animated: animated)
            return barButtonItem
        }
    }
    
    @discardableResult func setRightBarButtonItems(itemTypes: [ButtonItemType],animated: Bool = false, onTigger: ((Int) -> Void)? = nil) -> [UIBarButtonItem] {
        var barButtonItems = [UIBarButtonItem]()
        for i in 0..<itemTypes.count {
            let itemType = itemTypes[i]
            var barButtonItem: UIBarButtonItem!
            var isSpace: Bool = false
            switch itemType {
            case .title(let title, let color, let font):
                barButtonItem = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
                barButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor : color as Any], for: .normal)
                barButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor : color as Any], for: .highlighted)
                 
            case .image(let image):
                barButtonItem = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
                
            case .custom(let customView):
                barButtonItem = UIBarButtonItem(customView: customView)
                
            case .space(let width):
                barButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                barButtonItem.width = width
                isSpace = true
            }
            barButtonItems.append(barButtonItem)
            if !isSpace {
                barButtonItem.rx.tap.asObservable().subscribe(onNext:{
                    if onTigger != nil {
                        onTigger!(i)
                    }
                }).disposed(by: rx.disposeBag)
                if let button = barButtonItem.customView as? UIButton {
                    button.rx.tap.asObservable().subscribe(onNext:{
                        if onTigger != nil {
                            onTigger!(i)
                        }
                    }).disposed(by: rx.disposeBag)
                } else if let view = barButtonItem.customView as? UIView {
                    view.rx.tap().asObservable().subscribe(onNext:{
                        if onTigger != nil {
                            onTigger!(i)
                        }
                    }).disposed(by: rx.disposeBag)
                }
            }
           
        }
        self.navigationItem.setRightBarButtonItems(barButtonItems, animated: animated)

        return barButtonItems
    }
}


public extension UIViewController {
    class func getRootViewController(fromWindow: UIWindow? = nil) -> UIViewController? {
        let window: UIWindow? = fromWindow ?? SSApp.mainWindow
        return window?.rootViewController
    }
    class func getCurrentViewController(fromWindow: UIWindow? = nil) -> UIViewController? {
        guard var currentViewController = UIViewController.getRootViewController(fromWindow: fromWindow) else {
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
    
    var previousViewController: UIViewController?  {
        if let currentIndex = navigationController?.viewControllers.firstIndex(where: {$0 == self}) {
            if currentIndex > 0 {
                let lastIndex = currentIndex - 1
                return navigationController?.viewControllers[lastIndex]
            }
        }
        
        return nil
    }
}

