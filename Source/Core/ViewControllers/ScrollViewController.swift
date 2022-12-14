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
    
    public var isAutoShowNavWhenHideNavVisualEffectView = false
    
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
    
    public private(set) lazy var customNavView: CustomNavView = {
        let view = CustomNavView()
        Observable.merge(view.hideButton.rx.tap.mapToVoid(),  view.showButton.rx.tap.mapToVoid()).subscribe(with: self, onNext: {
            (self, _) in
            self.backAction()
        }).disposed(by: disposeBag)
        return view
    }()
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
                
                scrollView.rx.contentOffset.subscribe(onNext: {
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
    
    //FIXME: 这里不能重新布局，每次滑动到边缘都会抽搐
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let bottomToolView = bottomToolView {
            scrollView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h - bottomToolView.ss_h)
        } else {
            scrollView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h)
        }
        if isShowCustomNavView {
            self.view.bringSubviewToFront(customNavView)
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
        
        scrollView.rx.contentOffset.map({$0.y <= 0}).skip(1).distinctUntilChanged().subscribe(onNext: {
            [weak self]
            isHide in
            guard let self = self else { return }
            if self.isHideNavVisualEffectView && self.isAutoShowNavWhenHideNavVisualEffectView {
                if isHide {
                    self.setClearNav()
                } else {
                    self.setDefaultNav()
                }
            }
        }).disposed(by: disposeBag)
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
