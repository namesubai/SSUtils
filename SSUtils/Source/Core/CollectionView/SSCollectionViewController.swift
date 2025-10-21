//
//  SSCollectionViewController.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxCocoa
import RxSwift
import MJRefresh
import Moya

open class SSCollectionViewController: SSViewController {
    
    
    public private(set) lazy var headerRefreshTrigger: Observable<Void> = {
        return collectionView.headerRefreshTrigger
    }()
    
    public private(set) lazy var footerRefreshTrigger: Observable<Void> = {
        return collectionView.footerRefreshTrigger
    }()
    
//    public lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(headerRefreshAction), for: .valueChanged)
//        return refreshControl
//    }()
//    
//    public lazy var footerRefreshView: MJRefreshAutoNormalFooter = {
//        let footerView = MJRefreshAutoNormalFooter(refreshingBlock:{
//            [weak self] in
//            self?.footerRefreshTrigger.onNext(())
//        })
////        footerView.stateLabel?.isHidden = true
//        footerView.isRefreshingTitleHidden = true
//        footerView.triggerAutomaticallyRefreshPercent = 0
//        return footerView
//    }()
    open var isNoMore: Bool = false
    open var headerCustomLoadingView: UIView? {
        
        return SSApp.headerCustomLodingView != nil ? SSApp.headerCustomLodingView!() : nil
    }
    
    open var footerCustomLoadingView: UIView? {
        return SSApp.footerCustomLodingView != nil ? SSApp.footerCustomLodingView!() : nil
    }
    
    public var collectionView: SSCollectionView!
    
    open override var emptyOnView: UIView? {
        if customEmptyOnView != nil {
            return customEmptyOnView!
        }
        return self.collectionView
    }
    
    public private(set) lazy var customNavView: SSCustomNavView = {
        let view = SSCustomNavView()
        Observable.merge(view.hideButton.rx.tap.mapToVoid(),  view.showButton.rx.tap.mapToVoid()).subscribe(with: self, onNext: {
            (self, _) in
            self.backAction()
        }).disposed(by: disposeBag)
        return view
    }()
    
    public var autoShowAndHideNavWhenScroll: Bool = false
    
    public var isShowCustomNavView: Bool = false {
        didSet {
            if !isShowCustomNavView {
                if self.customNavView.superview != nil {
                    self.customNavView.removeFromSuperview()
                }
            } else {
                self.view.addSubview(self.customNavView)
                self.customNavView.snp.makeConstraints { make in
                    make.left.top.right.equalTo(0)
                    make.height.equalTo(self.navigationBarAndStatusBarHeight)
                }
                self.customNavView.backgroundColor = self.customNavView.showColor.withAlphaComponent(0)
                if autoShowAndHideNavWhenScroll {
                    
                    collectionView.rx.contentOffset.subscribe(onNext: {
                        [weak self] contentOffset in guard let self = self else { return }
                        if contentOffset.y >= self.navigationBarAndStatusBarHeight {
                            self.customNavView.backgroundColor = self.customNavView.showColor
                            self.customNavView.label.alpha = 1
                            self.statusBarStyle = self.customNavView.showStatusBarStyle
                            self.customNavView.hideButton.alpha = 0
                            self.customNavView.showButton.alpha = 1
                        } else {
                            var alpha = contentOffset.y / self.navigationBarAndStatusBarHeight
                            self.customNavView.backgroundColor = self.customNavView.showColor.withAlphaComponent(alpha)
                            alpha = max(0, alpha)
                            self.customNavView.label.alpha = alpha
                            self.customNavView.hideButton.alpha = 1 - alpha
                            self.customNavView.showButton.alpha = alpha
                            self.statusBarStyle = alpha == 0 ? self.customNavView.hideStatusBarStyle : self.customNavView.showStatusBarStyle
                        }
                        
                    }).disposed(by: self.customNavView.rx.disposeBag)
                }
                
            }
            
        }
    }
    
    public override init(viewModel: SSViewModel? = nil, navigator: SSNavigator? = nil) {
        super.init(viewModel: viewModel, navigator: navigator)
        let layout = UICollectionViewFlowLayout()
        collectionView = SSCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = SSColors.backgroud
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isShowCustomNavView {
            self.view.bringSubviewToFront(customNavView)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func make() {
        super.make()
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    open override func bind() {
        super.bind()
        guard let viewModel = self.viewModel else { return }
        viewModel.noMore.observe(on: MainScheduler.instance).bind(to: rx.isFooterNoMoreData).disposed(by: disposeBag)
        viewModel.showFooterRefresh.observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] isShow in
            guard let self = self else { return }
            self.collectionView.showFooterRefresh(isShow: isShow, customLoadingView: self.footerCustomLoadingView)
        }).disposed(by: disposeBag)
        
//        viewModel.noData.observe(on: MainScheduler.instance).subscribe(onNext: {
//            [weak self]
//            noData
//            in
//            guard let self = self else {return}
//            self.collectionView.isHidden = noData != nil
//        }).disposed(by: disposeBag)
//
//        notNetworkRetryTrigger.subscribe(onNext: {
//            [weak self]
//            in
//            guard let self = self else {return}
//            self.view.hideEmptyView()
//            self.collectionView.isHidden = false
//            self.beginHeaderRefresh()
//        }).disposed(by: disposeBag)
        
        
//        notNetworkRetryTrigger.bind(to: collectionView.headerRefreshTrigger).disposed(by: disposeBag)
        viewModel.error.asObservable().observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] (error) in
            guard let self = self else {return}
            if let error = error as? Moya.MoyaError {
                
                //                self.toastOnView?.showTextHUD(error.errorDescription)
                if error.errorCode == 6 && self.isAutoShowNoNetWrokEmptyView {
                    self.emptyOnView?.hideEmptyView()
                    //                    print(self.collectionView.numberOfSections)
                    if self.collectionView.numberOfSections == 0 {
                        self.emptyOnView?.showNetworkErrorEmptyView {
                            [weak self] in guard let self = self else {return}
                            self.notNetworkRetryTrigger.onNext(())
                        }
                        self.emptyOnView?.notNetworkEmptyView?.centerOffset = self.emptyCenterOffset ?? SSApp.emptyCenterOffset
                    } else {
                        var row = [Int](0..<self.collectionView.numberOfSections).reduce(0, {
                            result, index in
                            return result + self.collectionView.numberOfItems(inSection: index)
                        })
                        if row == 0 {
                            self.emptyOnView?.showNetworkErrorEmptyView {
                                [weak self] in guard let self = self else {return}
                                self.notNetworkRetryTrigger.onNext(())
                            }
                            self.emptyOnView?.notNetworkEmptyView?.centerOffset = self.emptyCenterOffset ?? SSApp.emptyCenterOffset
                        }
                    }
                    
                }
                
                if error.errorCode == 6 {
                    self.textToastOnView?.showTextHUD(localized(name: "noInternetAccess"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                } else {
                    self.textToastOnView?.showTextHUD(localized(name: "network_error_common_msg"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 100
                }
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.showFooterRefresh.observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] isShow in
            guard let self = self else { return }
            self.collectionView.showFooterRefresh(isShow: isShow, customLoadingView: self.footerCustomLoadingView)
        }).disposed(by: disposeBag)
        
        collectionView.reloadDataTrigger.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            var row = [Int](0..<self.collectionView.numberOfSections).reduce(0, {
                result, index in
                return result + self.collectionView.numberOfItems(inSection: index)
            })
            if row > 0 {
                self.emptyOnView?.hideNetworkErrorEmptyView()
                self.emptyOnView?.hideEmptyView()
            }
        }).disposed(by: disposeBag)
        self.collectionView.rx.didEndDisplayingCell.subscribe(onNext: {
            [weak self]
            event in
            guard let self = self else { return }
            self.emptyOnView?.hideNetworkErrorEmptyView()
            self.emptyOnView?.hideEmptyView()
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(self.collectionView.reloadDataTrigger.catchAndReturn(()), Observable.merge(viewModel.emptyNoDataError.asObservable().map({($0, true)}), viewModel.noData.map({($0, false)}))).observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self]
            data
            in
            let (noData, isError) = data.1
            guard let self = self else {return}
            if let error = noData?.error as? MoyaError, error.errorCode == 6, noData != nil  {
                self.emptyOnView?.hideEmptyView()
                return
            }
            self.emptyOnView?.hideNetworkErrorEmptyView()
            var row = [Int](0..<self.collectionView.numberOfSections).reduce(0, {
                result, index in
                return result + self.collectionView.numberOfItems(inSection: index)
            })
            if let noData = noData, row == 0  {
                self.emptyOnView?.hideEmptyView()
                let emptyView  = self.emptyOnView?.showEmptyView(image: noData.image,
                                                              title: noData.title,
                                                              titleFont: noData.titleFont,
                                                              titleColor: noData.titleColor,
                                                              buttonTitle: noData.buttonTitle,
                                                              buttonTitleFont: noData.buttonTitleFont,
                                                              buttonTitleColor: noData.buttonTitleColor,
                                                              buttonCustomView: noData.customButtonView) {
                    [weak self] in guard let self = self else {return}
                    if isError {
                        self.emptyErrorTrigger.onNext(())
                    } else {
                        self.emptyTrigger.onNext(())
                    }
                }
                emptyView?.centerOffset = self.emptyCenterOffset ?? SSApp.emptyCenterOffset
                self.collectionView.customFooterView?.isHidden = true
                self.collectionView.footerEndRefresh()
            } else {
                self.emptyOnView?.hideEmptyView()
            }
            //            self.collectionView.isHidden = (noData != nil)
        }).disposed(by: disposeBag)
        
//        notNetworkRetryTrigger.subscribe(onNext: {
//            [weak self]
//            in
//            guard let self = self else {return}
//            self.emptyOnView?.hideEmptyView()
//            self.collectionView.isHidden = false
//        }).disposed(by: disposeBag)
        
        if SSApp.isAutoShowFooterNoMoreData {
            collectionView.rx.observe(CGSize.self, "contentSize").subscribe(with: self, onNext: {
                (self, contentSize) in
                if let contentSize = contentSize  {
                    if contentSize.height < self.collectionView.bounds.height, self.collectionView.customFooterView?.isHideNoMoreData == false   {
                        self.collectionView.customFooterView?.isHideNoMoreData = true
                    }
                }
            }).disposed(by: disposeBag)
        }
    }
    
    
    
    public func showHeaderRefreshView() {
        guard let viewModel = self.viewModel else { return }
        viewModel.headerLoading.asObservable().bind(to: rx.isHeaderRefresh).disposed(by: rx.disposeBag)
        collectionView.showHeaderRefresh(isShow: true, customLoadingView: headerCustomLoadingView)
    }
    
    public func showFooterRefreshView() {
        guard let viewModel = self.viewModel else { return }
        viewModel.footerLoading.asObservable().bind(to: rx.isFooterRefresh).disposed(by: disposeBag)
        collectionView.showFooterRefresh(isShow: true, customLoadingView: footerCustomLoadingView)
    }
    
    public func beginHeaderRefresh() {
        self.navigationController?.view.setNeedsDisplay()
        self.navigationController?.view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            [weak self] in guard let self = self else { return }
            self.collectionView.headerBeginRefresh()
        }
    }
    
}


public extension Reactive where Base: UICollectionView {
    /// 方法监听必须在kvo监听前面，不然会抛出异常
    public var reloadData: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(UIKit.UICollectionView.reloadData as ((UICollectionView) -> () -> Void))).mapToVoid()
        return ControlEvent(events: source)
    }
}

public extension Reactive where Base: SSCollectionViewController {
    
    var isHeaderRefresh: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            tableVC.isNoMore = false
            if value {
                //                tableVC.tableView.headerBeginRefresh()
            } else {
                tableVC.collectionView.headerEndRefresh()
            }
        }
    }
    
    var isFooterRefresh: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            if !tableVC.isNoMore {
                if value {
                    //                tableVC.tableView.footerBeginRefresh()
                } else {
                    tableVC.collectionView.footerEndRefresh()
                }
            }
            
        }
    }
    
    var isFooterNoMoreData: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            tableVC.collectionView.customFooterView?.isHidden = false
            tableVC.collectionView.customFooterView?.stateLabel?.isHidden = false
            if value {
                tableVC.isNoMore = true
                tableVC.collectionView.showFooterRefresh(isShow: true, customLoadingView: tableVC.footerCustomLoadingView)
                tableVC.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                tableVC.collectionView.customFooterView?.isHideNoMoreData = false
                if tableVC.collectionView.contentSize.height < tableVC.collectionView.bounds.height, tableVC.collectionView.customFooterView?.isHideNoMoreData == false  {
                    tableVC.collectionView.customFooterView?.isHideNoMoreData = true
                }
            }else {
                tableVC.isNoMore = false
                tableVC.collectionView.mj_footer?.resetNoMoreData()
            }
        }
    }
    
     
    
}
