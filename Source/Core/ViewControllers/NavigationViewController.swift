//
//  NavigationViewController.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit

public extension UINavigationBar {
    func hideBottomHairline() {
        self.hairlineImageView?.isHidden = true
    }

    func showBottomHairline() {
        self.hairlineImageView?.isHidden = false
    }
    
    func hideNavBackGroundView(isHide: Bool) {
        findBackGroudView(onView: self, name: "_UIBarBackground")?.isHidden = isHide
    }
    
    func setAlphaOfBackGroundView(alpha: CGFloat) {
        findBackGroudView(onView: self, name: "_UIBarBackground")?.alpha = alpha

    }
    
    func findBackGroudView(onView: UIView, name: String) -> UIView? {
        for view in onView.subviews {
            if  NSStringFromClass(view.classForCoder) == name {
                return view
            } else {
                return self.findBackGroudView(onView: view, name: name)
            }
        }
        return nil
    }
    
    func hideVisualEffectView (isHide: Bool, navBarColor: UIColor?) {
        if let visualEffectView = findBackGroudView(onView: self, name: "UIVisualEffectView") {
            visualEffectView.isHidden = isHide
            if isHide {
                if let bgView = findBackGroudView(onView: self, name: "_UIBarBackground") {
                    barTintColor = navBarColor
                    bgView.backgroundColor = navBarColor
                }
            } else {
                if let bgView = findBackGroudView(onView: self, name: "_UIBarBackground") {
                    barTintColor = nil
                    bgView.backgroundColor = .clear
                }
            }
        }
    }
    
    
}

public extension UIToolbar {
    func hideBottomHairline() {
        self.hairlineImageView?.isHidden = true
    }

    func showBottomHairline() {
        self.hairlineImageView?.isHidden = false
    }
    
}

public extension UITabBar {
    func hideVisualEffectView (isHide: Bool) {
        if let visualEffectView = findBackGroudView(onView: self, name: "UIVisualEffectView") {
            visualEffectView.alpha = isHide ? 0 : 1
            if isHide {
                if let bgView = findBackGroudView(onView: self, name: "_UIBarBackground") {
                    bgView.backgroundColor = barTintColor
                }
            } else {
                if let bgView = findBackGroudView(onView: self, name: "_UIBarBackground") {
                    bgView.backgroundColor = .clear
                }
            }
        }
    }
    func findBackGroudView(onView: UIView, name: String) -> UIView? {
        for view in onView.subviews {
            if  NSStringFromClass(view.classForCoder) == name {
                return view
            } else {
                return self.findBackGroudView(onView: view, name: name)
            }
        }
        return nil
    }
}

public extension UIView {
    fileprivate var hairlineImageView: UIImageView? {
        return hairlineImageView(in: self)
    }

    fileprivate func hairlineImageView(in view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView, imageView.bounds.height <= 1.0 {
            return imageView
        }

        for subview in view.subviews {
            if let imageView = self.hairlineImageView(in: subview) { return imageView }
        }

        return nil
    }
    
    
}


open class NavigationViewController: UINavigationController{
    
 
    open override func viewDidLoad() {
        super.viewDidLoad()
//        navigationBar.isTranslucent = false
//        navigationBar.barStyle = App.tabBarStyle
//        navigationBar.barTintColor = Colors.backgroud
//        self.navigationBar.backIndicatorImage = UIImage(named: R.image.left_arrow.name)?.withRenderingMode(.alwaysOriginal)
//        self.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: R.image.left_arrow.name)?.withRenderingMode(.alwaysOriginal)
        interactivePopGestureRecognizer?.delegate = self
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : Colors.headline , NSAttributedString.Key.font : Fonts.semiBold(18)]
//        var count:UInt32 = 0
//        if let list = class_copyMethodList(UINavigationController.self,  &count) {
//            for i in 0..<count {
//                let name = method_getName(list[Int(i)])
//                let sel_name = sel_getName(name)
//                print("===\(NSStringFromSelector(name))")
//                self.topViewController?.transitionCoordinator
//            }
//        }
        
       
        // Do any additional setup after loading the view.
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationBar.hideBottomHairline()
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
//            viewController.isHideTabbarWhenPush = true
//            hideTabbar(animation: true)
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        if self.viewControllers.count > 0 {

        }
        self.view.endEditing(true)
        let vc = super.popViewController(animated: animated)
        return vc
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NavigationViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


public extension UIViewController {
    var isFirstViewController: Bool {
        get {
            if let viewControllers = self.tabBarController?.viewControllers {
                for viewController in viewControllers {
                    if let nav = viewController as? UINavigationController {
                        if nav.viewControllers[0] == self {
                            return true
                        }
                    } else if viewController == self {
                        return true
                    }
                }
            }
            
            return false
        }
    }
}

public extension UIViewController {
    var custonNavigaionViewController: NavigationViewController? {
        return self.navigationController as? NavigationViewController
    }
}