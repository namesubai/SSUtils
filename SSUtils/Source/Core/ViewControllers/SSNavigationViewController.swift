//
//  SSNavigationViewController.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

private var isHideVisualEffectViewKey: Int8 = 0
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
    func setBackGroundView(color: UIColor?) {
        findBackGroudView(onView: self, name: "_UIBarBackground")?.backgroundColor = color
    }
    public var isHideVisualEffectView: Bool {
        set {
            objc_setAssociatedObject(self, &isHideVisualEffectViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        
        get {
            (objc_getAssociatedObject(self, &isHideVisualEffectViewKey) as? Bool) ?? false
        }
    }
    
    func findBackGroudView(onView: UIView, name: String) -> UIView? {
        for view in onView.subviews {
            if  NSStringFromClass(view.classForCoder) == name {
                return view
            } else if let view = self.findBackGroudView(onView: view, name: name) {
                return view
            }
        }
        return nil
    }
    
    func hideVisualEffectView (isHide: Bool, navBarColor: UIColor?) {
        if let bgView = findBackGroudView(onView: self, name: "_UIBarBackground") {
            bgView.subviews.forEach { view in
                view.isHidden = isHide
                isHideVisualEffectView = isHide
                if view.isKind(of: UIVisualEffectView.self) {
                    view.subviews.forEach { subView in
                        subView.isHidden = isHide
                    }
                }
//                UIView.animate(withDuration: UINavigationController.hideShowBarDuration) {
//
//                }
                
            }
        }
//        if let visualEffectView = findBackGroudView(onView: self, name: "UIVisualEffectView") {
////            visualEffectView.isHidden = isHide
//            if isHide {
//                if let bgView = findBackGroudView(onView: self, name: "_UIBarBackground") {
//                    barTintColor = nil
//                    bgView.isHidden = true
//                    bgView.backgroundColor = .clear
//                }
//            } else {
//                if let bgView = findBackGroudView(onView: self, name: "_UIBarBackground") {
//                    
//                    barTintColor = navBarColor
//                    bgView.isHidden = false
//                    bgView.backgroundColor = navBarColor
//                }
//            }
//        }
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
    
    func addCorner(radious: CGFloat) {
        if let bgView = findBackGroudView(onView: self, name: "_UIBarBackground") {
            bgView.addCorner(roundingCorners: [.topLeft, .topRight], cornerSize: CGSize(width: radious, height: radious))
        }
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

fileprivate enum TransilateType {
    case push(vc: UIViewController, animated: Bool)
    case pop(vc: UIViewController?, animated: Bool)
    case set(vcs: [UIViewController] , animated: Bool)
    
    var vc: UIViewController? {
        switch self {
        case .push(let vc, _):
            return  vc
        case .pop(let vc, _):
            return  vc
        case .set(let vcs, _):
            return  vcs.last
        }
    }
}

fileprivate class TransilateData: NSObject {
    var transilateType: TransilateType
    init(transilateType: TransilateType) {
        self.transilateType = transilateType
        super.init()
    }
}


open class SSNavigationViewController: UINavigationController{
    
    /// 用来处理多次push或者pop奔溃问题， bug: Can't Add Self as Subview
//    var shouldIgnorePushingViewControllers: Bool = false
    fileprivate var transilateDatas = [TransilateData]()
    
    fileprivate func beginTransilate(trasilateData: TransilateData) {
        transilateDatas.append(trasilateData)
        if transilateDatas.count == 1 {
            transilate(data: trasilateData)
        }
    }
    
    fileprivate func transilate(data: TransilateData) {
        switch data.transilateType {
        case .push(let vc, let animated):
            super.pushViewController(vc, animated: animated)
        case .set(let vcs, let animated):
            super.setViewControllers(vcs, animated: animated)
        case .pop(_, let animated):
            super.popViewController(animated: animated)
        }
        transilateDatas.removeAll(where: {$0 == data})
    }
    
    fileprivate func endTransilate(vc: UIViewController?) {
        guard let vc = vc else { return }
        if let index = transilateDatas.firstIndex(where: {$0.transilateType.vc == vc}), index + 1 < transilateDatas.count {
            let data = transilateDatas[index + 1]
            transilate(data: data)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        navigationBar.isTranslucent = false
//        navigationBar.barStyle = App.tabBarStyle
//        navigationBar.barTintColor = Colors.backgroud
//        self.navigationBar.backIndicatorImage = UIImage(named: R.image.left_arrow.name)?.withRenderingMode(.alwaysOriginal)
//        self.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: R.image.left_arrow.name)?.withRenderingMode(.alwaysOriginal)
        
        interactivePopGestureRecognizer?.delegate = self
        
        navigationBar.rx.methodInvoked(#selector(setter: UINavigationBar.titleTextAttributes)).subscribe(onNext: { [weak self] attr in
            self?.navigationBarAppearanceTitleConfig()
        }).disposed(by: rx.disposeBag)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : SSColors.headline , NSAttributedString.Key.font : SSApp.navBarTitleFont]

        
//        var count:UInt32 = 0
//        if let list = class_copyMethodList(UINavigationController.self,  &count) {
//            for i in 0..<count {
//                let name = method_getName(list[Int(i)])
//                let sel_name = sel_getName(name)
//                print("===\(NSStringFromSelector(name))")
//                self.topViewController?.transitionCoordinator
//            }
//        }
        navigationBarAppearanceConfig()
        self.delegate = self
//        rx.didShow.asObservable().subscribe(onNext: {
//            [weak self] _ in guard let self = self else { return }
//            self.shouldIgnorePushingViewControllers = false
//        }).disposed(by: rx.disposeBag)
//
//        rx.willShow.asObservable().subscribe(onNext: {
//            [weak self] _ in guard let self = self else { return }
//            if let tc = self.topViewController?.transitionCoordinator {
//                tc.notifyWhenInteractionEnds { [weak self] _ in guard let self = self else { return }
//                    self.shouldIgnorePushingViewControllers = false
//                }
//            }
//        }).disposed(by: rx.disposeBag)
        
//        var disposeBag = DisposeBag()
//        self.navigationBar.rx.methodInvoked(#selector(UINavigationBar.layoutSubviews)).subscribe(onNext: {
//            [weak self] _ in guard let self = self else { return }
//            for subView in self.navigationBar.subviews {
//                if NSStringFromClass(subView.classForCoder).contains("_UINavigationBarContentView") {
//                    disposeBag = DisposeBag()
//                    subView.rx.methodInvoked(#selector(UINavigationBar.layoutSubviews)).subscribe(onNext: {
//                        [weak self] _ in guard let self = self else { return }
//                        for subV in subView.subviews {
//                            if NSStringFromClass(subV.classForCoder).contains("_UIButtonBarStackView") {
//                                if subV.ss_x == 20 {
//                                    subV.ss_x = 16
//                                }
//                                if subView.ss_w - subV.ss_maxX == 20 {
//                                    subV.ss_x = subView.ss_w - 16 - subV.ss_w
//                                }
//                            }
//                        }
//                    }).disposed(by: disposeBag)
//                    
//                }
//            }
//        }).disposed(by: rx.disposeBag)
        
        
        // Do any additional setup after loading the view.
    }
    
    private func navigationBarAppearanceConfig() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        //            appearance.backgroundColor = Colors.navBarBackgroud
        appearance.backgroundColor = SSColors.navBarBackgroud.withAlphaComponent(0.8)
        appearance.backgroundEffect = UIBlurEffect(style: .light)
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }
    
    
    private func navigationBarAppearanceTitleConfig() {
        let appearance = navigationBar.standardAppearance
        appearance.titleTextAttributes = navigationBar.titleTextAttributes ?? [NSAttributedString.Key : Any]()
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        defer {
//            shouldIgnorePushingViewControllers = true
//        }
//        guard !shouldIgnorePushingViewControllers else { return }
        if viewControllers.count == 1 && viewController != viewControllers.first {
            viewController.hidesBottomBarWhenPushed = viewController.hideTabbarWhenPushUseSystem
        }
        self.isPush = true
        self.isPop = false
        beginTransilate(trasilateData: TransilateData(transilateType: .push(vc: viewController, animated: animated)))
//        super.pushViewController(viewController, animated: animated)
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
//        defer {
//            shouldIgnorePushingViewControllers = true
//        }
//        guard !shouldIgnorePushingViewControllers else { return }
        if viewControllers.count > 1 {
            viewControllers[1].hidesBottomBarWhenPushed = viewControllers[1].hideTabbarWhenPushUseSystem
        }
        self.isPush = true
        self.isPop = false
        beginTransilate(trasilateData: TransilateData(transilateType: .set(vcs: viewControllers, animated: animated)))
//        super.setViewControllers(viewControllers, animated: animated)
    }
    
    
    open override func popViewController(animated: Bool) -> UIViewController? {
//        defer {
//            shouldIgnorePushingViewControllers = true
//        }
//        guard !shouldIgnorePushingViewControllers else { return nil }
        self.isPop = true
        self.isPush = false
        self.view.endEditing(true)
        let vc = topViewController
        beginTransilate(trasilateData: TransilateData(transilateType: .pop(vc: vc, animated: animated)))
//        let vc = super.popViewController(animated: animated)
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
}

private var isPushKey: Int8 = 0
private var isPopKey: Int8 = 0

extension UINavigationController {
    public var isPush: Bool {
        set {
            objc_setAssociatedObject(self, &isPushKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        
        get {
            (objc_getAssociatedObject(self, &isPushKey) as? Bool) ?? false
        }
    }
    
    public var isPop: Bool {
        set {
            objc_setAssociatedObject(self, &isPopKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        
        get {
            (objc_getAssociatedObject(self, &isPopKey) as? Bool) ?? false
        }
    }
}

extension SSNavigationViewController: UINavigationControllerDelegate, UINavigationBarDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        shouldIgnorePushingViewControllers = false
        
    }

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let tc = navigationController.topViewController?.transitionCoordinator {
//            tc.notifyWhenInteractionEnds { [weak self] _ in guard let self = self else { return }
////                self.shouldIgnorePushingViewControllers = false
//                self.endTransilate(vc: navigationController.topViewController)
//            }
            tc.animate(alongsideTransition: nil) { [weak self] _ in guard let self = self else { return }
                self.endTransilate(vc: navigationController.topViewController)
            }
        }
    }
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
        return true
    }

    public func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {
        isPush = false
    }

    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        return true
    }

    public func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        isPop = false
    }

}

extension SSNavigationViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer, visibleViewController == viewControllers.first {
            return false
        }
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
private var hideTabbarWhenPushUseSystemKey: Int8 = 0
public extension UIViewController {
    var hideTabbarWhenPushUseSystem: Bool {
        set {
            objc_setAssociatedObject(self, &hideTabbarWhenPushUseSystemKey, newValue ? 1 : 0, .OBJC_ASSOCIATION_ASSIGN)
        }
        
        get {
            if let value = objc_getAssociatedObject(self, &hideTabbarWhenPushUseSystemKey) as? Int {
                return  value == 1 ? true : false
            } else {
                return SSApp.isHideTabBarWhenPush
            }
        }
    }
}

public extension UIViewController {
    var custonNavigaionViewController: SSNavigationViewController? {
        return self.navigationController as? SSNavigationViewController
    }
}


