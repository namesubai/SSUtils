//
//  ViewController.swift
//  
//
//  Created by yangsq on 2020/10/16.
//

import UIKit
import Moya
import RxSwift
import RxCocoa



open class ViewController: UIViewController,Navigatale {
    open var disposeBag = DisposeBag()
    open var viewModel: ViewModel?
    open var navigator: Navigator?
    open var error = PublishSubject<Error>()
    public let loading = PublishSubject<Bool>()
    public let interactionDisableLoading = PublishSubject<Bool>()
    public let customLoading = PublishSubject<(Bool, String?, Bool)>()
    public let messageToast = PublishSubject<String?>()
    public let emptyTrigger = PublishSubject<Void>()
    public let emptyErrorTrigger = PublishSubject<Void>()
    public let notNetworkRetryTrigger = PublishSubject<Void>()

    open var statusBarStyle: UIStatusBarStyle = .default { didSet { self.setNeedsStatusBarAppearanceUpdate() } }
    open var statusBarHidden: Bool = false { didSet { self.setNeedsStatusBarAppearanceUpdate() } }

    open var navigationBarColor: UIColor? = Colors.navBarBackgroud
    public let goBackCompletion = PublishSubject<Void>()
    open var isHideNavigationBar = false
    /// 是否检查当前vc是否是隐藏导航栏，会影响导航栏的设置
    open var isNeedCheckCurrentVCHideNavigationBar = false
    /// 是否在 ViewDisappear 方法设置导航栏
    open var isViewDisappearSetNavigatorBar = true
    /// 把导航栏背景透明
    open var isHideNavVisualEffectView = false
    open var isToastOnWidow: Bool = false
    /// 自定义toast的父视图
    open var customToastOnView: UIView? = nil
    /// 自定义空界面的父视图
    open var customEmptyOnView: UIView? = nil
    /// 自定义文字toast的父视图
    open var customTextToastOnView: UIView? = nil
    public var isAutoShowNoNetWrokEmptyView = false
    public var defaultFirstTableView: UITableView?
    /// 是否自动展示和隐藏返回按钮
    public var isAutoShowAndHideNavBackButton = true
    public var isDimiss = false
    /// 用来控制空界面显示；默认是： 当接口有数据返回，空界面noData为nil, 并且不是服务器错误的空界面，才设置为true
    ///这个属性只有在直接继承ViewController的VC才有效，不是间接继承：例如tableviewController,collectionViewController
    public var isHasContent = false
    /// 是否动画隐藏和展示tabbar，不使用系统的方式
    public var isAutoShowAndHideTabbarNotUseSystem: Bool? = nil {
        didSet {
            if isAutoShowAndHideTabbarNotUseSystem == true {
                hideTabbarWhenPushUseSystem = false
            } else {
                hideTabbarWhenPushUseSystem = true
            }
        }
    }
    
    public var isShowNavBarBottomLine: Bool = true
    
    public var otherleftBarButtonItems = [UIBarButtonItem]() {
        didSet {
            refreshBackButton()
        }
    }
    public var backImage: UIImage? {
        didSet {
            refreshBackButton()
        }
    }
    public var isTranslucent = App.navIsTranslucent
    
    public var emptyCenterOffset: CGPoint?
    
    public var navTitleFont: UIFont?
    public var navTitleColor: UIColor?

    open var bottomToolView: UIView? = nil {
        didSet {
            if let view = oldValue {
                view.removeFromSuperview()
            }
            if let bottomToolView = bottomToolView {
                
                view.addSubview(bottomToolView)
                bottomToolView.ss_y = view.ss_h - bottomToolView.ss_h
            }
        }
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
    
    open var textToastOnView: UIView? {
        if customTextToastOnView != nil {
            return customTextToastOnView!
        }
        return toastOnView
    }
    
    open var emptyOnView: UIView? {
        if customEmptyOnView != nil {
            return customEmptyOnView!
        }
        return self.view
    }
    
    public weak var currentCustomToastView: SSProgressHUD?
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
    open override var prefersStatusBarHidden: Bool {
        statusBarHidden
    }
    public var backButon: CustomButton? {
        self.backButton
    }
    
    public var notNetworkAndEmptyTrigger: Observable<Void> {
        Observable.merge(emptyTrigger, notNetworkRetryTrigger, emptyErrorTrigger)
    }
    
    public var voidAndNotNetworkAndEmptyTrigger:Observable<Void> {
        Observable.merge(Observable.just(()) ,emptyTrigger, notNetworkRetryTrigger, emptyErrorTrigger)
    }
    
    public var voidAndNotNetworkAndOnlyErrorEmptyTrigger:Observable<Void> {
        Observable.merge(Observable.just(()), notNetworkRetryTrigger, emptyErrorTrigger)
    }
    
    public var popFinish: (() -> Void)? = nil

    public init(viewModel: ViewModel? = nil, navigator: Navigator? = nil) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    private var backButton: CustomButton = {
        let backButton = CustomButton(type: .system)
        return backButton
    }()
    
    required public init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        view.backgroundColor = Colors.backgroud
        
        let backImage: UIImage? = App.navBackImage ?? ssImage("back")
        if (!isNavigationRootViewController && backImage != nil && isAutoShowAndHideNavBackButton) || !isAutoShowAndHideNavBackButton {
            self.backImage = backImage
        }
        backButton.rx.tap.asDriver().drive(onNext:{[weak self]() in
            self?.backAction()
        }).disposed(by: backButton.rx.disposeBag)
        make()
        bind()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isAutoShowAndHideTabbarNotUseSystem == true {
            self.tabBarController?.hideTabbar(animated: true)
        }
        
        if !isHideNavVisualEffectView && !isHideNavigationBar {
            setDefaultNav()
        }
       
        
        if isHideNavVisualEffectView && !isNeedCheckCurrentVCHideNavigationBar{
//            self.navigationController?.navigationBar.hideVisualEffectView(isHide: true, navBarColor: navigationBarColor)
           setClearNav()
        }
       

        if (isHideNavigationBar && !isNeedCheckCurrentVCHideNavigationBar) || (isNeedCheckCurrentVCHideNavigationBar && UIViewController.getCurrentViewController() == self) {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        } 
      
        if #available(iOS 11.0, *) {
//            navigationItem.largeTitleDisplayMode = .never
        }

    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if !isHideNavVisualEffectView && !isHideNavigationBar, isTranslucent {
//            if #available(iOS 15.0, *) {
//                if var appearance = navigationController?.navigationBar.standardAppearance {
//                    appearance.backgroundEffect = UIBlurEffect(style: .light)
//                    appearance.backgroundColor = navigationBarColor?.withAlphaComponent(0.8)
//                    appearance.backgroundImage = nil
//                    navigationController?.navigationBar.standardAppearance = appearance
//                    navigationController?.navigationBar.scrollEdgeAppearance = appearance
//                }
//
//            } else {
//                navigationController?.navigationBar.isTranslucent = true
//            }
//        }
       
        
//        if self.navigationController?.navigationBar.isHideVisualEffectView == true {
//            if !isNeedCheckCurrentVCHideNavigationBar {
//                self.navigationController?.navigationBar.hideVisualEffectView(isHide: false, navBarColor: navigationBarColor)
//            }
//
//            if isHideNavVisualEffectView && !isNeedCheckCurrentVCHideNavigationBar {
//                self.navigationController?.navigationBar.hideVisualEffectView(isHide: true, navBarColor: navigationBarColor)
//            }
//
//            if (isHideNavigationBar && !isNeedCheckCurrentVCHideNavigationBar) || (isNeedCheckCurrentVCHideNavigationBar && UIViewController.getCurrentViewController() == self)  {
//                navigationController?.setNavigationBarHidden(true, animated: animated)
//            }
//        }
        
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        if !isHideNavVisualEffectView && !isHideNavigationBar, isTranslucent {
//            if #available(iOS 15.0, *) {
//                if var appearance = navigationController?.navigationBar.standardAppearance {
//                    appearance.configureWithTransparentBackground()
//                    appearance.backgroundColor = navigationBarColor
//                    appearance.backgroundImage = UIImage(color: navigationBarColor ?? .white, size: CGSize(width: App.width, height: self.navigationBarAndStatusBarHeight))
//                    navigationController?.navigationBar.standardAppearance = appearance
//                    navigationController?.navigationBar.scrollEdgeAppearance = appearance
//                }
//
//            } else {
//                navigationController?.navigationBar.isTranslucent = false
//            }
//        }
        /// push下个界面，判断是否需要显示tabbar
        if isAutoShowAndHideTabbarNotUseSystem == true {
            if self.navigationController?.viewControllers.count == 1 {
                self.tabBarController?.showTabbar(animated: true)
            } else {
                if self.navigationController?.viewControllers.last?.hideTabbarWhenPushUseSystem != true {
                    self.tabBarController?.showTabbar(animated: true)
                } else {
                    self.tabBarController?.hideTabbar(animated: false)
                }
            }
        }
        let previousVC = self.navigationController?.viewControllers.last as? ViewController
        if isHideNavigationBar && !isNeedCheckCurrentVCHideNavigationBar && isViewDisappearSetNavigatorBar && self.presentedViewController == nil && previousVC?.isHideNavigationBar != true {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
//        if isHideNavVisualEffectView && !isNeedCheckCurrentVCHideNavigationBar && isViewDisappearSetNavigatorBar && self.presentedViewController == nil && previousVC?.isHideNavigationBar != true  && self.navigationController?.isPush == true {
//            self.navigationController?.navigationBar.hideVisualEffectView(isHide: false, navBarColor: navigationBarColor)
//        }
        

    }
            
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.navigationController?.view.endEditing(true)
        self.view.endEditing(true)
    }
    
    public func setDefaultNav() {
        if var appearance = navigationController?.navigationBar.standardAppearance.copy() {
            if let navTitleFont = navTitleFont {
                appearance.titleTextAttributes = [.font : navTitleFont]
            }
            
            if let navTitleColor = navTitleColor {
                appearance.titleTextAttributes = [.backgroundColor : navTitleColor]
            }
            
            if isTranslucent == true {
                appearance.backgroundEffect = UIBlurEffect(style: .light)
                appearance.backgroundColor = navigationBarColor?.withAlphaComponent(0.8)
                
            } else {
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = navigationBarColor
            }
            if isShowNavBarBottomLine {
                appearance.shadowColor = .clear
                appearance.shadowImage = nil
            }
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }
    }
    
    public func setClearNav() {
        if var appearance = navigationController?.navigationBar.standardAppearance.copy() {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear
            if isShowNavBarBottomLine {
                appearance.shadowColor = .clear
                appearance.shadowImage = nil
            }
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        }
    }
    
    open func backAction() {
       closeVC()
    }
    
    open func closeVC() {
        if self.presentingViewController != nil && self.navigationController?.viewControllers.count == 1 {
            isDimiss = true
            if let navigator = self.navigator {
                navigator.dimiss(sender: self, completion: popFinish)
            } else {
                self.dismiss(animated: true, completion: popFinish)
            }
        } else {
            if let navigator = self.navigator {
                navigator.pop(sender: self, completion: popFinish)
            } else {
                self.navigationController?.popViewController(animated: true, popFinish)
            }
        }
    }
    
    func refreshBackButton() {
        if let image = backImage?.withRenderingMode(.alwaysOriginal) {
            backButton.setImage(image, for: .normal)
            /// 用App.navBarHeight，self.navBarHeight有时候为0
            backButton.contentSize = CGSize(width: 40, height: App.navBarHeight)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.imageOriginAutoX = 0
            backButton.contentType = .leftImageRigthText(space: 0, autoSize: false)
            let leftMargin = (backButton.contentSize.width - image.size.width) / 2
//            backButton.overrideAlignmentRectInsets = UIEdgeInsets(top: 0, left: leftMargin + 4.wScale, bottom: 0, right: 0)
//
//            if image != nil {
//                backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -leftMargin, bottom: 0, right: 0)
//            }
            let backButtonItem = UIBarButtonItem(customView: backButton)
            /// 只能左边加个space，默认的左边距离，系统是不同分辨率默认不一样，加space是8开始，然后8 + 8 = 16
            let negativeSeperator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            negativeSeperator.width = 8
            if otherleftBarButtonItems.count > 0 {
                self.navigationItem.leftBarButtonItems = [negativeSeperator, backButtonItem] + otherleftBarButtonItems
            } else {
                self.navigationItem.leftBarButtonItems = [negativeSeperator, backButtonItem]
            }
          
        } else {
            self.navigationItem.backBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.leftBarButtonItems = []
            self.navigationItem.hidesBackButton = true
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
            self.textToastOnView?.showTextHUD(msg, tag: kOnlyShowOneHudTag)
             
         }).disposed(by: disposeBag)
        
        viewModel.showHud.observe(on: MainScheduler.instance).asObservable().subscribe(onNext: {
            [weak self] (msg) in
             guard let self = self else {return}
            self.textToastOnView?.showTextHUD(msg, tag: kOnlyShowOneHudTag)

         }).disposed(by: disposeBag)
        viewModel.haveContents.subscribe(onNext: {
            [weak self] hasContents in guard let self = self else { return }
            self.isHasContent = hasContents
        }).disposed(by: disposeBag)
        viewModel.error.asObservable().observe(on: MainScheduler.instance).bind(to: error).disposed(by: disposeBag)
        
        viewModel.error.asObservable().observe(on: MainScheduler.instance).subscribe(onNext: {
           [weak self] (error) in
            guard let self = self else {return}
            if let error = error as? ServiceError {
                self.textToastOnView?.showTextHUD(error.errorMsg, tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
//                if error.code == .tokenInvalid || error.code == .loginExpired || error.code == .needLogin  {
////                    self.navigator?.show(interface: .login(viewModel: HKLoginInVM(provider: viewModel.provider)), sender: self)
//                }
            } else if let error = error as? Moya.MoyaError {
//                self.toastOnView?.showTextHUD(error.errorDescription)
               
                if error.errorCode == 6 &&
                    self.defaultFirstTableView == nil &&
                    self.tableView() == nil &&
                    self.isAutoShowNoNetWrokEmptyView &&
                    !self.isHasContent {
                    self.emptyOnView?.hideEmptyView()
                    let emptyView = self.emptyOnView?.showNetworkErrorEmptyView(){
                        [weak self] in guard let self = self else {return}
                        self.notNetworkRetryTrigger.onNext(())
                    }
                    emptyView?.centerOffset = self.emptyCenterOffset ?? App.emptyCenterOffset
                }
                
                if error.errorCode == 6 {
                    self.textToastOnView?.showTextHUD(localized(name: "noInternetAccess"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                } else {
                    self.textToastOnView?.showTextHUD(localized(name: "network_error_common_msg"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                }
            }
            else {
                if error.localizedDescription.isLength {
                    self.textToastOnView?.showTextHUD(error.localizedDescription, tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                } else {
                    let error = error as? NSError
                    let message = error?.userInfo[NSLocalizedDescriptionKey] as? String
                    self.textToastOnView?.showTextHUD(message, tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                }
               
            }
           
        }).disposed(by: disposeBag)
        
        Observable.merge(viewModel.emptyNoDataError.asObservable().map({($0, true)}), viewModel.noData.map({($0, false)})).observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self]
            (noData, isError)
            in
            guard let self = self else {return}
            if self.tableView() == nil && self.defaultFirstTableView == nil && !self.isHasContent {
                
                if let error = noData?.error as? MoyaError, error.errorCode == 6, noData != nil  {
                    return
                }
                
                self.emptyOnView?.hideNetworkErrorEmptyView()
                if let noData = noData {
                    if !isError {
                        viewModel.haveContents.accept(false)
                    }
                    self.emptyOnView?.hideEmptyView()
                    let emptyView = self.emptyOnView?.showEmptyView(image: noData.image,
                                                    title: noData.title,
                                                    titleFont: noData.titleFont,
                                                    titleColor: noData.titleColor,
                                                    buttonTitle: noData.buttonTitle,
                                                    buttonTitleFont: noData.buttonTitleFont,
                                                    buttonTitleColor: noData.buttonTitleColor,
                                                    buttonCustomView: noData.customButtonView) {
                        [weak self] in
                        guard let self = self else {return}
                        if isError {
                            self.emptyErrorTrigger.onNext(())
                        } else {
                            self.emptyTrigger.onNext(())
                        }
                    }
                    emptyView?.centerOffset = self.emptyCenterOffset ?? App.emptyCenterOffset
                } else {
                    self.emptyOnView?.hideEmptyView()
                    if !isError {
                        viewModel.haveContents.accept(true)
                    }
                }
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.changeCustomLoadingText.subscribe(with: self, onNext: {
            (self, text) in
            self.currentCustomToastView?.customView.text = text
        }).disposed(by: disposeBag)
        
    }
    
    
    func tableView() -> UIScrollView? {
        if let tableView = self.view.subviews.first(where: {$0 is UITableView}) as? UITableView {
            return tableView
        }
        if let collectView = self.view.subviews.first(where: {$0 is UICollectionView}) as? UICollectionView {
            return collectView
        }
        return nil
    }
        
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
    
    //MARK: 自定义导航栏
    public func showCustomNavigationBar(makeConstraints: ((_ bar: UIView) -> Void)? = nil) -> UIView {
        isHideNavigationBar = true
        let navBar = UIView()
        navBar.backgroundColor = navigationBarColor
        view.addSubview(navBar)
        if let makeConstraints = makeConstraints {
            makeConstraints(navBar)
        } else {
            navBar.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(statusBarHeight)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(navigationBarHeight)
            }
        }
        return navBar
    }
}

public extension Reactive where Base: ViewController {

    var cannotClickLoading: Binder<Bool> {
        return Binder(self.base) { viewController, attr in
            if attr {
                (viewController.customToastOnView ?? App.mainWindow)?.showLoadingTextHUD(maskType: .clear, tag: 13222)
            } else {
                (viewController.customToastOnView ?? App.mainWindow)?.hideHUD(tag: 13222)
            }
        }
    }
    
    var loading: Binder<Bool> {
        return Binder(self.base) { viewController, attr in
            if attr {
                viewController.toastOnView?.showLoadingTextHUD()
            } else {
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
                    viewController.currentCustomToastView = (viewController.customToastOnView ?? App.mainWindow)?.showLoadingTextHUD(maskType: .clear, message,  tag: 13223)
                } else {
                    viewController.currentCustomToastView = viewController.toastOnView?.showLoadingTextHUD(message, tag: 13223)
                }
                
            } else{
                
                if isCanNotTouch {
                    (viewController.customToastOnView ?? App.mainWindow)?.hideHUD(tag: 13223)
                } else {
                    viewController.toastOnView?.hideHUD(tag: 13223)
                }
            }
        }
    }
}

