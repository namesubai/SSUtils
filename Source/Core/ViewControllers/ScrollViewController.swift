//
//  ScrollViewController.swift
//  SSUtils
//
//  Created by yangsq on 2021/9/8.
//

import UIKit
import RxSwift
import RxCocoa

open class ScrollViewController: ViewController {
    
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    public lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    open override var bottomToolView: UIView? {
        didSet {
            if let bottomToolView = bottomToolView {
                scrollView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h - bottomToolView.ss_h)
            } else {
                scrollView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h)
            }
        }
    }
    
    open var isNoMore: Bool = false
    public private(set) lazy var headerRefreshTrigger: Observable<Void> = {
        return scrollView.headerRefreshTrigger
    }()
    
    public private(set) lazy var footerRefreshTrigger: Observable<Void> = {
        return scrollView.footerRefreshTrigger
    }()
    
    open var headerCustomLoadingView: UIView? {
        
        return App.headerCustomLodingView != nil ? App.headerCustomLodingView!() : nil
    }
    
    open var footerCustomLoadingView: UIView? {
        return App.footerCustomLodingView != nil ? App.footerCustomLodingView!() : nil
    }
    
    public func showHeaderRefreshView() {
        guard let viewModel = self.viewModel else { return }
        viewModel.headerLoading.asObservable().bind(to: rx.isHeaderRefresh).disposed(by: rx.disposeBag)
        scrollView.showHeaderRefresh(isShow: true, customLoadingView: headerCustomLoadingView)
    }
    
    public func showFooterRefreshView() {
        guard let viewModel = self.viewModel else { return }
        viewModel.footerLoading.asObservable().bind(to: rx.isFooterRefresh).disposed(by: disposeBag)
        scrollView.showFooterRefresh(isShow: true, customLoadingView: footerCustomLoadingView)
    }
    
    public func beginHeaderRefresh() {
        self.navigationController?.view.setNeedsDisplay()
        self.navigationController?.view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            [weak self] in guard let self = self else { return }
            self.scrollView.headerBeginRefresh()
        }
    }
    
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let bottomToolView = bottomToolView {
            scrollView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h - bottomToolView.ss_h)
        } else {
            scrollView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    open override func make() {
        super.make()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(0)
            make.width.equalTo(App.width)
//            make.height.greaterThanOrEqualTo(view.ss_h + 1).priority(.high)
        }
    }
    
    open override func bind() {
        guard let viewModel = viewModel else { return }
        super.bind()
        viewModel.showFooterRefresh.observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] isShow in
             guard let self = self else { return }
            self.scrollView.showFooterRefresh(isShow: isShow, customLoadingView: self.footerCustomLoadingView)
         }).disposed(by: disposeBag)
        viewModel.noMore.observe(on: MainScheduler.instance).bind(to: rx.isFooterNoMoreData).disposed(by: disposeBag)
       
    }


}


public extension Reactive where Base: ScrollViewController {
    
     var isHeaderRefresh: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            tableVC.isNoMore = false
            if value {
//                tableVC.tableView.headerBeginRefresh()
            } else {
                tableVC.scrollView.headerEndRefresh()
            }
        }
    }
    
    var isFooterRefresh: Binder<Bool> {
       return Binder(self.base) { tableVC, value in
        if !tableVC.isNoMore {
            if value {
//                tableVC.tableView.footerBeginRefresh()
            } else {
                tableVC.scrollView.footerEndRefresh()
            }
        }
           
       }
   }
    
    var isFooterNoMoreData: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            tableVC.scrollView.customFooterView?.isHidden = false
            tableVC.scrollView.customFooterView?.stateLabel?.isHidden = false
            if value {
                tableVC.isNoMore = true
//                tableVC.tableView.showFooterRefresh(isShow: true, customLoadingView: tableVC.footerCustomLoadingView)
                tableVC.scrollView.mj_footer?.endRefreshingWithNoMoreData()
            }else {
                tableVC.isNoMore = false
                tableVC.scrollView.mj_footer?.resetNoMoreData()
            }
        }
    }
    
}
