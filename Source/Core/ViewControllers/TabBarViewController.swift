//
//  TabBarViewController.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxSwift
import RxCocoa
import Moya


public struct TabBarItem {
    public var title:String?
    public var normalImage: UIImage?
    public var selectedImage: UIImage?
    public var normalTitleColor: UIColor?
    public var selectedTitleColor: UIColor?
    public var viewController: UIViewController
    public init(title: String? = nil,
         normalImage: UIImage?,
         selectedImage: UIImage?,
         normalTitleColor: UIColor? = nil,
         selectedTitleColor: UIColor? = nil,
         viewController: UIViewController) {
        self.title = title
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.normalTitleColor = normalTitleColor
        self.selectedTitleColor = selectedTitleColor
        self.viewController = viewController
    }
}

open class TabBarViewController: UITabBarController,Navigatale {
    open var disposeBag = DisposeBag()
    public private(set) var viewModel: ViewModel?
    public var navigator: Navigator?
    open var error = PublishSubject<Error>()
    public let loading = PublishSubject<Bool>()
    public let interactionDisableLoading = PublishSubject<Bool>()
    public let customLoading = PublishSubject<Bool>()
    public let messageToast = PublishSubject<String?>()
    public let emptyTrigger = PublishSubject<Void>()
    public let notNetworkRetryTrigger = PublishSubject<Void>()

    open var navigationBarColor: UIColor? = Colors.navBarBackgroud
    public let goBackCompletion = PublishSubject<Void>()
    open var isHideNavigationBar = false
    open var isHideNavVisualEffectView = false
    open var isToastOnWidow: Bool = false
    open var customToastOnView: UIView? = nil
    public var isAutoShowNoNetWrokEmptyView = false
    public var defaultFirstTableView: UITableView?
    public var emptyCenterOffset: CGPoint?
    public init(viewModel: ViewModel? = nil, navigator: Navigator? = nil) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    public var customTabBar: Tabbar {
        return self.tabBar as! Tabbar
    }
    
    open var toastOnView: UIView? {
        if customToastOnView != nil {
            return customToastOnView!
        }
        if isToastOnWidow {
            return self.view.window
        }
        return self.view
    }
    
    required public init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        self.tabBar.backgroundImage = UIImage(color: .white)
//        self.tabBar.shadowImage = UIImage(named: R.image.tabbar_shadow.name)
        // Do any additional setup after loading the view.
        delegate = self
        self.setValue(Tabbar(), forKey: "tabBar")
        updateTabBarAppearance(bgColor: Colors.tabBarBackgroud)
        
        make()
        bind()
    }
    
    open func updateTabBarAppearance(bgColor: UIColor?) {
    
        let appearance = UITabBarAppearance()
        if App.tabIsTranslucent {
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .light)
            appearance.backgroundColor = bgColor?.withAlphaComponent(0.9)
        } else {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = bgColor
        }
        self.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = appearance
        } 
    }
    
    open func make() {
        
    }
    
    open func bind() {
        guard let viewModel = self.viewModel else { return }
        viewModel.loading.asObservable().subscribe(on: MainScheduler.instance).bind(to:loading).disposed(by: disposeBag)
        viewModel.loading.asObservable().subscribe(on: MainScheduler.instance).bind(to: rx.loading).disposed(by: disposeBag)
        loading.subscribe(onNext: { isLoading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
        }).disposed(by: disposeBag)
        viewModel.clearLoading.asObservable().observe(on: MainScheduler.instance).bind(to: interactionDisableLoading).disposed(by: disposeBag)
        viewModel.clearLoading.asObservable().observe(on: MainScheduler.instance).bind(to: rx.cannotClickLoading).disposed(by: disposeBag)
        interactionDisableLoading.observe(on: MainScheduler.instance).subscribe(onNext: { isLoading in
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
        }).disposed(by: disposeBag)
        
        viewModel.customLoading.asObservable().observe(on: MainScheduler.instance).bind(to: rx.customLoading).disposed(by: disposeBag)
        
        viewModel.msgToast.asObservable().observe(on: MainScheduler.instance).bind(to: messageToast).disposed(by: disposeBag)
        viewModel.msgToast.asObservable().observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] (msg) in
             guard let self = self else {return}
            self.toastOnView?.showTextHUD(msg)
             
         }).disposed(by: disposeBag)
        
        viewModel.showHud.observe(on: MainScheduler.instance).asObservable().subscribe(onNext: {
            [weak self] (msg) in
             guard let self = self else {return}
            self.toastOnView?.showTextHUD(msg)

         }).disposed(by: disposeBag)

        viewModel.error.asObservable().observe(on: MainScheduler.instance).bind(to: error).disposed(by: disposeBag)
        viewModel.error.asObservable().observe(on: MainScheduler.instance).subscribe(onNext: {
           [weak self] (error) in
            guard let self = self else {return}
            if let error = error as? ServiceError {
                self.toastOnView?.showTextHUD(error.errorMsg)
//                if error.code == .tokenInvalid || error.code == .loginExpired || error.code == .needLogin  {
////                    self.navigator?.show(interface: .login(viewModel: HKLoginInVM(provider: viewModel.provider)), sender: self)
//                }
            } else if let error = error as? Moya.MoyaError {
//                self.toastOnView?.showTextHUD(error.errorDescription)
               
                if error.errorCode == 6 &&
                    self.defaultFirstTableView == nil &&
                    self.tableView() == nil &&
                    self.isAutoShowNoNetWrokEmptyView  {
                    self.toastOnView?.hideEmptyView()
                    let emptyView = self.toastOnView?.showNetworkErrorEmptyView(){
                        self.notNetworkRetryTrigger.onNext(())
                    }
                    emptyView?.centerOffset = self.emptyCenterOffset ?? App.emptyCenterOffset
                }
                
                if error.errorCode == 6 {
                    self.toastOnView?.showTextHUD(localized(name: "noInternetAccess"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                } else {
                    self.toastOnView?.showTextHUD(localized(name: "network_error_common_msg"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                }
            }
            else {
                let error = error as NSError
                let message = error.userInfo[NSLocalizedDescriptionKey] as? String
                self.toastOnView?.showTextHUD(message)
            }
           
        }).disposed(by: disposeBag)
        
        viewModel.noData.observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self]
            noData
            in
            guard let self = self else {return}
            if self.tableView() == nil && self.defaultFirstTableView == nil {
                self.toastOnView?.hideNetworkErrorEmptyView()
                if let noData = noData  {
                    self.toastOnView?.hideEmptyView()
                    let emptyView = self.toastOnView?.showEmptyView(image: noData.image,
                                                    title: noData.title,
                                                    titleFont: noData.titleFont,
                                                    titleColor: noData.titleColor,
                                                    buttonTitle: noData.buttonTitle,
                                                    buttonTitleFont: noData.buttonTitleFont,
                                                    buttonTitleColor: noData.buttonTitleColor,
                                                    buttonCustomView: noData.customButtonView) {
                        self.emptyTrigger.onNext(())
                    }
                    emptyView?.centerOffset = self.emptyCenterOffset ?? App.emptyCenterOffset
                }else {
                    self.toastOnView?.hideEmptyView()
                }
            }
            
        }).disposed(by: disposeBag)
        
        
    }
    
    func tableView() -> UITableView? {
        return self.view.subviews.first(where: {$0 is UITableView}) as? UITableView
    }

    open override var childForStatusBarHidden: UIViewController? {
        return self.selectedViewController
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.selectedViewController
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

extension TabBarViewController: UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        customTabBar.lineView.isHidden = true
    }
}

private var isHideTabbarUseAnimationKey: Int8 = 0
public extension UITabBarController {
    
    var isHideTabbarUseAnimation: Bool {
        set {
            objc_setAssociatedObject(self, &isHideTabbarUseAnimationKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        
        get {
            (objc_getAssociatedObject(self, &isHideTabbarUseAnimationKey) as? Bool) ?? false
        }
    }
    
    func hideTabbar(animated: Bool = true) {
        isHideTabbarUseAnimation = true
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .layoutSubviews) {
                self.tabBar.ss_y = App.height
            } completion: { finish in
                
            }

        } else {
            self.tabBar.ss_y = App.height
        }
    }
    
    func showTabbar(animated: Bool = true) {
        isHideTabbarUseAnimation = false
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.tabBar.ss_y = App.height - self.tabBar.ss_h
            }
        } else {
            self.tabBar.ss_y = App.height - self.tabBar.ss_h
        }
        
    }
}


public extension Reactive where Base: UITabBarController {

    var viewControllers: Binder<[UIViewController]> {
        return Binder(self.base) { view, attr in
            view.viewControllers = attr
        }
    }
    
}
public extension Reactive where Base: TabBarViewController {

    var cannotClickLoading: Binder<Bool> {
        return Binder(self.base) { viewController, attr in
            if attr {
                (viewController.customToastOnView ?? UIApplication.shared.keyWindow)?.showLoadingTextHUD(maskType: .clear)
            }else{
                (viewController.customToastOnView ?? UIApplication.shared.keyWindow)?.hideHUD()
            }
        }
    }
    
    var loading: Binder<Bool> {
        return Binder(self.base) { viewController, attr in
            if attr {
                viewController.toastOnView?.showLoadingTextHUD()
            }else{
                viewController.toastOnView?.hideHUD()
            }
        }
    }
    var customLoading: Binder<(Bool, String?, Bool)> {
        return Binder(self.base) { viewController, attr in
            let isShow = attr.0
            let message = attr.1
            let isCanNotTouch = attr.2
            if isShow {
                if isCanNotTouch {
                    (viewController.customToastOnView ?? UIApplication.shared.keyWindow)?.showLoadingTextHUD(maskType: .clear, message)
                } else {
                    viewController.toastOnView?.showLoadingTextHUD(message)
                }
                
            } else{
                
                if isCanNotTouch {
                    (viewController.customToastOnView ?? UIApplication.shared.keyWindow)?.hideHUD()
                } else {
                    viewController.toastOnView?.hideHUD()
                }
            }
        }
    }
}
