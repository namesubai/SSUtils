//
//  TableViewController.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import Moya
import RxSwift
import RxCocoa


public extension Reactive where Base: UITableView {
    
    public var reloadData: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.reloadData)).map { _ in }
        return ControlEvent(events: source)
    }
}

open class TableViewController: ViewController {
    open var isNoMore: Bool = false
    open var isSelectionAutoDimiss = false {
        didSet {
            if isSelectionAutoDimiss {
                tableView.rx.itemSelected.subscribe(onNext: {
                    [weak self]
                    indexPath in
                    guard let self = self else { return }
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }).disposed(by: rx.disposeBag)
            }
        }
    }
    
    public private(set) lazy var headerRefreshTrigger: Observable<Void> = {
        return tableView.headerRefreshTrigger
    }()
    
    public private(set) lazy var footerRefreshTrigger: Observable<Void> = {
        return tableView.footerRefreshTrigger
    }()
    
    public var tableViewStyle: UITableView.Style = .plain

    public var tableView: TableView!

    
    open var isHideKeboardWhenTouch: Bool = false {
        didSet {
            self.hideKeyboardGestrue.isEnabled = isHideKeboardWhenTouch
        }
    }
    private lazy var hideKeyboardGestrue: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(hideKeyboardTouchAction(tap:)))
        return tap
    }()
    
    open var headerCustomLoadingView: UIView? {
        
        return App.headerCustomLodingView != nil ? App.headerCustomLodingView!() : nil
    }
    
    open var footerCustomLoadingView: UIView? {
        return App.footerCustomLodingView != nil ? App.footerCustomLodingView!() : nil
    }
    
    open override var bottomToolView: UIView? {
        didSet {
            if let bottomToolView = bottomToolView {
                tableView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h - bottomToolView.ss_h)
            } else {
                tableView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h)
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func make() {
        super.make()
        tableView = TableView(frame: .zero, style: tableViewStyle)
        tableView.backgroundColor = Colors.backgroud
        tableView.frame = CGRect(x: 0, y: 0, width: view.ss_w, height: view.ss_h)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        tableView.rx.tap().subscribe(onNext: {
//            [weak self] in
//            self?.view.endEditing(true)
//        }).disposed(by: rx.disposeBag)
//        tableView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        tableView.rx.contentOffset.map({$0.y <= 0}).skip(1).distinctUntilChanged().subscribe(onNext: {
            [weak self]
            isHide in
            guard let self = self else { return }
            if self.isHideNavVisualEffectView  {
                self.navigationController?.navigationBar.hideVisualEffectView(isHide: isHide, navBarColor: self.navigationBarColor)
            }
        }).disposed(by: disposeBag)
        
        Observable.merge(tableView.rx.willBeginDragging.asObservable(), tableView.rx.willBeginDecelerating.asObservable()).subscribe(onNext: {
            [weak self]
            in
            guard let self = self else { return }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
        view.addSubview(tableView)

    }
    
    open override func bind() {
        super.bind()
        guard let viewModel = self.viewModel else { return }
        viewModel.noMore.observe(on: MainScheduler.instance).bind(to: rx.isFooterNoMoreData).disposed(by: disposeBag)
        notNetworkRetryTrigger.bind(to: tableView.headerRefreshTrigger).disposed(by: disposeBag)
        viewModel.error.asObservable().observe(on: MainScheduler.instance).subscribe(onNext: {
           [weak self] (error) in
            guard let self = self else {return}
            if let error = error as? Moya.MoyaError {
                
//                self.toastOnView?.showTextHUD(error.errorDescription)
                if error.errorCode == 6 && self.isAutoShowNoNetWrokEmptyView {
                    self.tableView.hideEmptyView()
//                    print(self.tableView.numberOfSections)
                    if self.tableView.numberOfSections == 0 {
                        self.tableView.showNetworkErrorEmptyView {
                            self.notNetworkRetryTrigger.onNext(())
                        }
                        if self.tableView.tableHeaderView != nil {
                            self.tableView.notNetworkEmptyView?.centerOffset = CGPoint(x: 0, y: -App.navAndStatusBarHeight + (self.tableView.tableHeaderView?.ss_h ?? 0))

                        }
                    } else {
                        var row = [Int](0..<self.tableView.numberOfSections).reduce(0, {
                            result, index in
                            return result + self.tableView.numberOfRows(inSection: index)
                        })
                        if row == 0 {
                            self.tableView.showNetworkErrorEmptyView {
                                self.notNetworkRetryTrigger.onNext(())
                            }
                            if self.tableView.tableHeaderView != nil {
                                self.tableView.notNetworkEmptyView?.centerOffset = CGPoint(x: 0, y: -App.navAndStatusBarHeight - (self.tableView.tableHeaderView?.ss_h ?? 0))

                            }
                        }
                    }

                }
                
                if error.errorCode == 6 {
                    self.toastOnView?.showTextHUD(localized(name: "noInternetAccess"))
                } else {
                    self.toastOnView?.showTextHUD(localized(name: "network_error_common_msg"))
                }
            }
           
        }).disposed(by: disposeBag)
        
        viewModel.showFooterRefresh.observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] isShow in
             guard let self = self else { return }
            self.tableView.showFooterRefresh(isShow: isShow, customLoadingView: self.footerCustomLoadingView)
         }).disposed(by: disposeBag)
        tableView.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.tableView.numberOfSections > 0 {
                self.tableView.hideNetworkErrorEmptyView()
            }
        }).disposed(by: disposeBag)
//        tableView.rx.reloadData.subscribe(onNext: { [weak self]  in
//            guard let self = self else { return }
//            if self.tableView.numberOfSections > 0 {
//                self.tableView.hideNetworkErrorEmptyView()
//            }
//        }).disposed(by: disposeBag)
//        tableView.rx.didEndDisplayingCell.subscribe(onNext: {
//            [weak self]
//            event in
//            guard let self = self else { return }
//            if self.tableView.numberOfSections > 0 {
//                self.tableView.hideNetworkErrorEmptyView()
//            }
//        }).disposed(by: disposeBag)
        
        viewModel.noData.observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self]
            noData
            in
            guard let self = self else {return}
            self.tableView.hideNetworkErrorEmptyView()
            
            if let noData = noData  {
                let emptyView  = self.tableView.showEmptyView(image: noData.image,
                                                              title: noData.title,
                                                              titleFont: noData.titleFont,
                                                              titleColor: noData.titleColor,
                                                              buttonTitle:
                                                                noData.buttonTitle,
                                                              buttonTitleFont: noData.buttonTitleFont,
                                                              buttonTitleColor: noData.buttonTitleColor, buttonCustomView: noData.customButtonView) {
                    self.emptyTrigger.onNext(())
                }
                self.tableView.customFooterView?.isHidden = true
                self.tableView.footerEndRefresh()
            }else {
                self.tableView.hideEmptyView()
            }
//            self.tableView.isHidden = (noData != nil)
        }).disposed(by: disposeBag)
        
        notNetworkRetryTrigger.subscribe(onNext: {
            [weak self]
            in
            guard let self = self else {return}
            self.tableView.hideEmptyView()
            self.tableView.isHidden = false
            self.beginHeaderRefresh()
        }).disposed(by: disposeBag)
        
    }
    
    @objc
    private func hideKeyboardTouchAction(tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    public func setTableViewStyle(style: UITableView.Style)  {
        if style == tableViewStyle {
            return
        }
        tableViewStyle = style
    }
    
    public func showHeaderRefreshView() {
        guard let viewModel = self.viewModel else { return }
        viewModel.headerLoading.asObservable().bind(to: rx.isHeaderRefresh).disposed(by: rx.disposeBag)
        tableView.showHeaderRefresh(isShow: true, customLoadingView: headerCustomLoadingView)
    }
    
    public func showFooterRefreshView() {
        guard let viewModel = self.viewModel else { return }
        viewModel.footerLoading.asObservable().bind(to: rx.isFooterRefresh).disposed(by: disposeBag)
        tableView.showFooterRefresh(isShow: true, customLoadingView: footerCustomLoadingView)
    }
    
    public func beginHeaderRefresh() {
        self.navigationController?.view.setNeedsDisplay()
        self.navigationController?.view.layoutIfNeeded()
        tableView.headerBeginRefresh()
    }
    
}

public extension Reactive where Base: TableViewController {
    
     var isHeaderRefresh: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            tableVC.isNoMore = false
            if value {
//                tableVC.tableView.headerBeginRefresh()
            } else {
                tableVC.tableView.headerEndRefresh()
            }
        }
    }
    
    var isFooterRefresh: Binder<Bool> {
       return Binder(self.base) { tableVC, value in
        if !tableVC.isNoMore {
            if value {
//                tableVC.tableView.footerBeginRefresh()
            } else {
                tableVC.tableView.footerEndRefresh()
            }
        }
           
       }
   }
    
    var isFooterNoMoreData: Binder<Bool> {
        return Binder(self.base) { tableVC, value in
            tableVC.tableView.customFooterView?.isHidden = false
            tableVC.tableView.customFooterView?.stateLabel?.isHidden = false
            if value {
                tableVC.isNoMore = true
//                tableVC.tableView.showFooterRefresh(isShow: true, customLoadingView: tableVC.footerCustomLoadingView)
                tableVC.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }else {
                tableVC.isNoMore = false
                tableVC.tableView.mj_footer?.resetNoMoreData()
            }
        }
    }
    
}

extension TableViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
//        if let touchView = touch.view, let cellClass = NSClassFromString("UITableViewCellContentView"), touchView.isKind(of: cellClass){
//            return false
//        }
        return true
    }
}
