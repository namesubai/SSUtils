//
//  CollectionViewController.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxCocoa
import RxSwift
import MJRefresh
import Moya

open class CollectionViewController: ViewController {
    
    
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
        
        return App.headerCustomLodingView != nil ? App.headerCustomLodingView!() : nil
    }
    
    open var footerCustomLoadingView: UIView? {
        return App.footerCustomLodingView != nil ? App.footerCustomLodingView!() : nil
    }
    
    public var collectionView: CollectionView!
    
    open override var emptyOnView: UIView? {
        if customEmptyOnView != nil {
            return customEmptyOnView!
        }
        return self.collectionView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func make() {
        super.make()
        let layout = UICollectionViewFlowLayout()
        collectionView = CollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = Colors.backgroud
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
        
        
        notNetworkRetryTrigger.bind(to: collectionView.headerRefreshTrigger).disposed(by: disposeBag)
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
                            self.notNetworkRetryTrigger.onNext(())
                        }
                        self.emptyOnView?.notNetworkEmptyView?.centerOffset = self.emptyCenterOffset ?? App.emptyCenterOffset
                    } else {
                        var row = [Int](0..<self.collectionView.numberOfSections).reduce(0, {
                            result, index in
                            return result + self.collectionView.numberOfItems(inSection: index)
                        })
                        if row == 0 {
                            self.emptyOnView?.showNetworkErrorEmptyView {
                                self.notNetworkRetryTrigger.onNext(())
                            }
                            self.emptyOnView?.notNetworkEmptyView?.centerOffset = self.emptyCenterOffset ?? App.emptyCenterOffset
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
        
        collectionView.rx.reloadData.subscribe(onNext: { [weak self] _ in
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
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(self.collectionView.rx.reloadData.catchAndReturn(()), Observable.merge(viewModel.emptyNoDataError.asObservable().map({($0, true)}), viewModel.noData.map({($0, false)}))).observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self]
            data
            in
            let (noData, isError) = data.1
            guard let self = self else {return}
            if let error = noData?.error as? MoyaError, error.errorCode == 6, noData != nil  {
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
                emptyView?.centerOffset = self.emptyCenterOffset ?? App.emptyCenterOffset
                self.collectionView.customFooterView?.isHidden = true
                self.collectionView.footerEndRefresh()
            } else {
                self.emptyOnView?.hideEmptyView()
            }
            //            self.collectionView.isHidden = (noData != nil)
        }).disposed(by: disposeBag)
        
        notNetworkRetryTrigger.subscribe(onNext: {
            [weak self]
            in
            guard let self = self else {return}
            self.emptyOnView?.hideEmptyView()
            self.collectionView.isHidden = false
            self.beginHeaderRefresh()
        }).disposed(by: disposeBag)
        
        if App.isAutoShowFooterNoMoreData {
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
    public var reloadData: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(UIKit.UICollectionView.reloadData as ((UICollectionView) -> () -> Void))).mapToVoid()
        return ControlEvent(events: source)
    }
}

public extension Reactive where Base: CollectionViewController {
    
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
