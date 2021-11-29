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

open class CollectionViewController: ViewController {
    public let headerRefreshTrigger = ReplaySubject<Void>.create(bufferSize: 1)
    public let footerRefreshTrigger = ReplaySubject<Void>.create(bufferSize: 1)
    
    public lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(headerRefreshAction), for: .valueChanged)
        return refreshControl
    }()
    
    public lazy var footerRefreshView: MJRefreshAutoNormalFooter = {
        let footerView = MJRefreshAutoNormalFooter(refreshingBlock:{
            [weak self] in
            self?.footerRefreshTrigger.onNext(())
        })
//        footerView.stateLabel?.isHidden = true
        footerView.isRefreshingTitleHidden = true
        footerView.triggerAutomaticallyRefreshPercent = 0
        return footerView
    }()
    
    
    public var collectionView: CollectionView!
    
    
    @objc private func headerRefreshAction() {
        self.headerRefreshTrigger.onNext(())
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
        viewModel.noData.observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self]
            noData
            in
            guard let self = self else {return}
            self.collectionView.isHidden = noData != nil
        }).disposed(by: disposeBag)
        
        notNetworkRetryTrigger.subscribe(onNext: {
            [weak self]
            in
            guard let self = self else {return}
            self.view.hideEmptyView()
            self.collectionView.isHidden = false
            self.beginHeaderRefresh()
        }).disposed(by: disposeBag)
    }
    
    public func showHeaderRefreshView() {
        guard let viewModel = self.viewModel else { return }
        viewModel.headerLoading.asObservable().bind(to: rx.isHeaderRefresh).disposed(by: rx.disposeBag)
        collectionView.refreshControl = refreshControl
    }
    
    public func showFooterRefreshView() {
        guard let viewModel = self.viewModel else { return }
        viewModel.footerLoading.asObservable().bind(to: rx.isFooterRefresh).disposed(by: disposeBag)
        collectionView.mj_footer = footerRefreshView
    }
    
    public func beginHeaderRefresh() {
        headerRefreshTrigger.onNext(())
    }
}


public extension Reactive where Base: CollectionViewController {
    
     var isHeaderRefresh: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            if value {
                tableVC.refreshControl.beginRefreshing()
            }else {
                tableVC.refreshControl.endRefreshing()

            }
        }
    }
    
    var isFooterRefresh: Binder<Bool> {
       return Binder(self.base) { tableVC, value in
           if value {
               tableVC.footerRefreshView.beginRefreshing()
           }else {
               tableVC.footerRefreshView.endRefreshing()
           }
       }
   }
    
    var isFooterNoMoreData: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            if value {
                tableVC.footerRefreshView.endRefreshingWithNoMoreData()
            }else {
                tableVC.footerRefreshView.resetNoMoreData()
            }
        }
    }
    
}
