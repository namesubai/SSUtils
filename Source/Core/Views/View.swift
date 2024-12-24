//
//  View.swift
//  
//
//  Created by yangsq on 2020/10/21.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

extension View {
    public struct GradientBorderData {
        public var opacity: Float
        public var colors: [UIColor]
        public var startPoint: CGPoint
        public var endPoint: CGPoint
        public var borderWidth: CGFloat
        public var cornerRadius: CGFloat
        public init(opacity: Float = 1, colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1), borderWidth: CGFloat, cornerRadius: CGFloat) {
            self.opacity = opacity
            self.colors = colors
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
        }
    }
}

open class View: UIView {
    public var viewModel: ViewModel?

    public var disposeBag = DisposeBag()
    public let emptyTrigger = PublishSubject<Void>()
    public let emptyErrorTrigger = PublishSubject<Void>()
    public let notNetworkRetryTrigger = PublishSubject<Void>()
    public var isHasContent: Bool = false
    public var customIntrinsicContentSize: CGSize? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        make()
    }
    var _toastSuperView: UIView?
    public var toastSuperView: UIView? {
        get {
            _toastSuperView ?? self
        }
        set {
            _toastSuperView = newValue
        }
    }
    
    
    public var isAutoShowNotNetworkEmptyView = false
    
    public var gradientBorderData: GradientBorderData? = nil
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientBorderData = gradientBorderData {
            addGradientBorder(opacity: gradientBorderData.opacity,
                              colors: gradientBorderData.colors,
                              startPoint: gradientBorderData.startPoint,
                              endPoint: gradientBorderData.endPoint,
                              borderWidth: gradientBorderData.borderWidth,
                              cornerRadius: gradientBorderData.cornerRadius)
        }
    }
    
    
    open func make() {
    }
   
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
    
    open override var intrinsicContentSize: CGSize {
        if let customIntrinsicContentSize = customIntrinsicContentSize {
            return customIntrinsicContentSize
        }
        return super.intrinsicContentSize
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
    
    open func bindViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel
        viewModel.loading.asObservable().bind(to: rx.loading).disposed(by: disposeBag)
        viewModel.clearLoading.asObservable().bind(to: rx.clearLoading).disposed(by: disposeBag)
        viewModel.customLoading.asObservable().bind(to: rx.customLoading).disposed(by: disposeBag)
        viewModel.msgToast.asObservable().subscribe(onNext: {
            [weak self] (msg) in
             guard let self = self else {return}
            self.toastSuperView?.showTextHUD(msg)
             
         }).disposed(by: disposeBag)
        
        viewModel.haveContents.subscribe(onNext: {
            [weak self] hasContents in guard let self = self else { return }
            self.isHasContent = hasContents
        }).disposed(by: disposeBag)
        
        viewModel.error.asObservable().subscribe(onNext: {
            [weak self] (error) in
             guard let self = self else {return}
             if let error = error as? ServiceError {
                 self.toastSuperView?.showTextHUD(error.errorMsg)
                
             } else if let error = error as? Moya.MoyaError {
                 if self.isAutoShowNotNetworkEmptyView {
                     if error.errorCode == 6, !self.isHasContent {
                         self.toastSuperView?.hideEmptyView()
                         let emptyView = self.toastSuperView?.showNetworkErrorEmptyView() {
                             [weak self] in guard let self = self else { return }
                             self.notNetworkRetryTrigger.onNext(())
                         }
                     }
                 }
                 
                 if error.errorCode == 6 {
                     self.toastSuperView?.showTextHUD(localized(name: "noInternetAccess"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                 } else {
                     self.toastSuperView?.showTextHUD(localized(name: "network_error_common_msg"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                 }
             }
             else {
                 let error = error as NSError
                 let message = error.userInfo[NSLocalizedDescriptionKey] as? String
                 self.toastSuperView?.showTextHUD(message)
             }
        }).disposed(by: disposeBag)
        
        Observable.merge(viewModel.emptyNoDataError.asObservable().map({($0, true)}), viewModel.noData.map({($0, false)})).observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self]
            (noData, isError)
            in
            guard let self = self else {return}
            if self.isAutoShowNotNetworkEmptyView {
                self.toastSuperView?.hideNetworkErrorEmptyView()

            }
            if let noData = noData, !self.isHasContent {
                self.toastSuperView?.hideEmptyView()
                let emptyView = self.toastSuperView?.showEmptyView(image: noData.image,
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
//                emptyView?.centerOffset = App.emptyCenterOffset
            } else {
                self.toastSuperView?.hideEmptyView()
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.showCustomLoading.asObservable().subscribe(onNext: {
            [weak self] (isShow) in
             guard let self = self else {return}
            
         }).disposed(by: disposeBag)
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

public extension Reactive where Base: View {

    var clearLoading: Binder<Bool> {
        return Binder(self.base) { view, attr in
            if attr {
                (view._toastSuperView ?? App.mainWindow)?.showLoadingTextHUD(maskType: .clear)
            }else{
                (view._toastSuperView ?? App.mainWindow)?.hideHUD()
            }
        }
    }
    
    var loading: Binder<Bool> {
        return Binder(self.base) { view, attr in
            if attr {
                view.toastSuperView?.showLoadingTextHUD()
            }else{
                view.toastSuperView?.hideHUD()
            }
        }
    }
    var customLoading: Binder<(Bool, String?, Bool)> {
        return Binder(self.base) { view, attr in
            let isShow = attr.0
            let message = attr.1
            let isCanNotTouch = attr.2
            if isShow {
                if isCanNotTouch {
                    (view._toastSuperView ?? App.mainWindow)?.showLoadingTextHUD(maskType: .clear, message)
                } else {
                    view.toastSuperView?.showLoadingTextHUD(message)
                }
                
            } else{
                
                if isCanNotTouch {
                    (view._toastSuperView ?? App.mainWindow)?.hideHUD()
                } else {
                    view.toastSuperView?.hideHUD()
                }
            }
        }
    }
}


open class TopRoundedCornerView: View {
    private var roundedLayer: CAShapeLayer!
    private var roundedPath: UIBezierPath!
    public var topConerRadious: CGFloat = 15.wScale
    
    public private(set) lazy var topIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex(0xCCCCCC)
        view.layer.cornerRadius = 4.5.wScale / 2
        return view
    }()
    
    public var isHideTopLine: Bool = true {
        didSet {
            topIndicatorView.isHidden = isHideTopLine
        }
    }

    open override func make() {
        super.make()
        backgroundColor = UIColor.hex(0xFFFFFF)
        roundedLayer = CAShapeLayer()
        roundedLayer.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(roundedLayer)
        
        addSubview(topIndicatorView)
        topIndicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(11.wScale)
            make.size.equalTo(CGSize(width: 35, height: 4.5).wScale)
        }
        isHideTopLine = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        roundedPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: topConerRadious, height: topConerRadious))
        roundedLayer.path = roundedPath.cgPath
        layer.mask = roundedLayer
    }
    
  
}


open class AllRoundedCornerView: View {
    public var conerRadious: CGFloat = 20.wScale {
        didSet {
            layer.cornerRadius = conerRadious
            layoutIfNeeded()
        }
    }

    open override func make() {
        super.make()
        layer.cornerRadius = conerRadious
        layer.masksToBounds = true
    }
}



