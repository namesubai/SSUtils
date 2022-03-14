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
    ///是否自动展示和隐藏返回按钮
    public var isAutoShowAndHideNavBackButton = true
    public var isDimiss = false

    public var isTranslucent = App.navIsTranslucent
    
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
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    public var backButon: UIButton? {
        self.backButton
    }

    public init(viewModel: ViewModel? = nil, navigator: Navigator? = nil) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    private var backButton: Button = {
        let backButton = Button(type: .system)
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
        
        let backImage: UIImage? =  App.navBackImage ?? image("back")
        
        if (!isNavigationRootViewController && backImage != nil && isAutoShowAndHideNavBackButton) || !isAutoShowAndHideNavBackButton {
            let image = backImage?.withRenderingMode(.alwaysOriginal)
            backButton.setImage(image, for: .normal)
            backButton.contentSize = CGSize(width: 40, height: self.navigationBarHeight)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            let leftMargin = (40 - image!.size.width) / 2
            backButton.overrideAlignmentRectInsets = UIEdgeInsets(top: 0, left: leftMargin + 4, bottom: 0, right: 0)

            if image != nil {
                backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -leftMargin, bottom: 0, right: 0)
            }
            let negativeSeperator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            negativeSeperator.width = 8
            let backButtonItem = UIBarButtonItem(customView: backButton)
            self.navigationItem.leftBarButtonItems = [negativeSeperator, backButtonItem]
            backButton.rx.tap.asDriver().drive(onNext:{[weak self]() in
                self?.backAction()
            }).disposed(by: disposeBag)
        }

        make()
        bind()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isHideNavVisualEffectView && !isHideNavigationBar {
            if #available(iOS 15.0, *) {

                if var appearance = navigationController?.navigationBar.standardAppearance {
                    if isTranslucent == true {
                        appearance.backgroundEffect = UIBlurEffect(style: .light)
                        appearance.backgroundColor = navigationBarColor?.withAlphaComponent(0.8)
                        
                    } else {
                        appearance.configureWithTransparentBackground()
                        appearance.backgroundColor = navigationBarColor
                    }
                    navigationController?.navigationBar.standardAppearance = appearance
                    navigationController?.navigationBar.scrollEdgeAppearance = appearance
                }
               
            } else {
                navigationController?.navigationBar.barTintColor = navigationBarColor
            }
        }
       
        
        if isHideNavVisualEffectView {
            self.navigationController?.navigationBar.hideVisualEffectView(isHide: true, navBarColor: navigationBarColor)
        }
       

        if isHideNavigationBar  {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
      
        if #available(iOS 11.0, *) {
//            navigationItem.largeTitleDisplayMode = .never
        }

    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.navigationController?.navigationBar.isHideVisualEffectView == true {
            self.navigationController?.navigationBar.hideVisualEffectView(isHide: false, navBarColor: navigationBarColor)
            
            if isHideNavVisualEffectView {
                self.navigationController?.navigationBar.hideVisualEffectView(isHide: true, navBarColor: navigationBarColor)
            }
           

            if isHideNavigationBar  {
                navigationController?.setNavigationBarHidden(true, animated: animated)
            }
        }
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let previousVC = self.navigationController?.viewControllers.last as? ViewController
        if isHideNavigationBar && self.presentedViewController == nil && previousVC?.isHideNavigationBar != true {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        self.navigationController?.navigationBar
        if isHideNavVisualEffectView && self.presentedViewController == nil && previousVC?.isHideNavigationBar != true  && self.navigationController?.isPush == true {
            self.navigationController?.navigationBar.hideVisualEffectView(isHide: false, navBarColor: navigationBarColor)
        }
    }
    

    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.navigationController?.view.endEditing(true)
        self.view.endEditing(true)
    }
    
   open func backAction() {
        if self.presentingViewController != nil && self.navigationController?.viewControllers.count == 1 {
            isDimiss = true
            self.navigator?.dimiss(sender: self)
        } else {
            self.navigator?.pop(sender: self)
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
                    emptyView?.centerOffset = App.emptyCenterOffset
                }
                
                if error.errorCode == 6 {
                    self.toastOnView?.showTextHUD(localized(name: "noInternetAccess"))
                } else {
                    self.toastOnView?.showTextHUD(localized(name: "network_error_common_msg"))
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
                    let emptyView = self.toastOnView?.showEmptyView(image: noData.image,
                                                    title: noData.title,
                                                    titleFont: noData.titleFont,
                                                    titleColor: noData.titleColor,
                                                    buttonTitle: noData.buttonTitle,
                                                    buttonTitleFont: noData.buttonTitleFont,
                                                    buttonTitleColor: noData.buttonTitleColor,
                                                    buttonCustomView: noData.customButtonView) {
                        [weak self] in
                        guard let self = self else {return}
                        self.emptyTrigger.onNext(())
                    }
                    emptyView?.centerOffset = App.emptyCenterOffset
                }else {
                    self.toastOnView?.hideEmptyView()
                }
            }
            
        }).disposed(by: disposeBag)
        
        
        
    }
    
    
    func tableView() -> UIScrollView? {
        return self.view.subviews.first(where: {$0 is UITableView}) as? UITableView
    }
    
  
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
}

public extension Reactive where Base: ViewController {

    var cannotClickLoading: Binder<Bool> {
        return Binder(self.base) { viewController, attr in
            if attr {
                UIApplication.shared.keyWindow?.showLoadingTextHUD(maskType: .clear)
            }else{
                UIApplication.shared.keyWindow?.hideHUD()
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
    var customLoading: Binder<Bool> {
        return Binder(self.base) { viewController, attr in
            if attr {
//                viewController.toastOnView?.showCustomLoadingView()
            }else{
//                viewController.toastOnView?.hideCustomLoadingView()
            }
        }
    }
}

