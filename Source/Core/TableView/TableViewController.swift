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

open class CustomNavView: View {
    public private(set) var hideButton: UIButton!
    public private(set) var showButton: UIButton!
    public private(set) var label: UILabel!
    public var showColor: UIColor = .white
    public var showStatusBarStyle: UIStatusBarStyle = .default
    public var hideStatusBarStyle: UIStatusBarStyle = .lightContent
    public override func make() {
        backgroundColor = showColor
        let label = UILabel.makeLabel(text: nil, textColor: Colors.headline, font: Fonts.medium(18))
        self.label = label
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(0)
        }
        
        let button = CustomButton()
        button.contentType = .leftImageRigthText(space: 0, autoSize: false)
        button.imageOriginAutoX = 0
        self.hideButton = button
        addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalTo(16.wScale)
            make.centerY.equalTo(label.snp.centerY)
            make.size.equalTo(CGSize(width: 40, height: 44))
        }
        
        let button1 = CustomButton()
        button1.contentType = .leftImageRigthText(space: 0, autoSize: false)
        button1.imageOriginAutoX = 0
        self.showButton = button1
        addSubview(button1)
        button1.snp.makeConstraints { make in
            make.left.equalTo(16.wScale)
            make.centerY.equalTo(label.snp.centerY)
            make.size.equalTo(CGSize(width: 40, height: 44))
        }
        button1.alpha = 0
    }
}

public extension Reactive where Base: UITableView {
    public var reloadData: ControlEvent<Void> {
    let source = self.methodInvoked(#selector(UIKit.UITableView.reloadData as ((UITableView) -> () -> Void))).mapToVoid()
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
    open var isAutoShowNavWhenHideNavVisualEffectView = true
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
                
                tableView.rx.contentOffset.subscribe(onNext: {
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
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isShowCustomNavView {
            self.view.bringSubviewToFront(customNavView)
        }
    }
    open override var emptyOnView: UIView? {
        if customEmptyOnView != nil {
          return customEmptyOnView!
        }
        return self.tableView
    }
    
    private var refreshErrorDataTrigger = BehaviorRelay<Void>(value: ())

    
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
            if self.isHideNavVisualEffectView && self.isAutoShowNavWhenHideNavVisualEffectView {
                if isHide {
                    self.setClearNav()
                } else {
                    self.setDefaultNav()
                }
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
                    self.emptyOnView?.hideEmptyView()
//                    print(self.tableView.numberOfSections)
                    if self.tableView.numberOfSections == 0 {
                        self.emptyOnView?.showNetworkErrorEmptyView {
                            self.notNetworkRetryTrigger.onNext(())
                        }
                        self.emptyOnView?.notNetworkEmptyView?.centerOffset = self.emptyCenterOffset ?? App.emptyCenterOffset

//                        if self.tableView.tableHeaderView != nil {
//                            self.emptyOnView?.notNetworkEmptyView?.centerOffset = CGPoint(x: 0, y: -App.navAndStatusBarHeight + App.emptyCenterOffset.y + (self.tableView.tableHeaderView?.ss_h ?? 0))
//
//                        }
                    } else {
                        var row = [Int](0..<self.tableView.numberOfSections).reduce(0, {
                            result, index in
                            return result + self.tableView.numberOfRows(inSection: index)
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
                    self.textToastOnView?.showTextHUD(localized(name: "network_error_common_msg"), tag: kOnlyShowOneHudTag)?.layer.zPosition = 10
                }
            }
           
        }).disposed(by: disposeBag)
        
        viewModel.showFooterRefresh.observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] isShow in
             guard let self = self else { return }
            self.tableView.showFooterRefresh(isShow: isShow, customLoadingView: self.footerCustomLoadingView)
         }).disposed(by: disposeBag)
        
        tableView.rx.reloadData.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            var row = [Int](0..<self.tableView.numberOfSections).reduce(0, {
                result, index in
                return result + self.tableView.numberOfRows(inSection: index)
            })
            if row > 0 {
                self.emptyOnView?.hideNetworkErrorEmptyView()
                self.emptyOnView?.hideEmptyView()
            }
        }).disposed(by: disposeBag)
        self.tableView.rx.didEndDisplayingCell.subscribe(onNext: {
            [weak self]
            event in
            guard let self = self else { return }
            self.emptyOnView?.hideNetworkErrorEmptyView()
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(self.tableView.rx.reloadData.catchAndReturn(()), Observable.merge(viewModel.emptyNoDataError.asObservable().map({($0, true)}), viewModel.noData.map({($0, false)}))).observe(on: MainScheduler.instance).subscribe(onNext: {
            [weak self] data
            in
            let (noData, isError) = data.1

            guard let self = self else {return}
            if let error = noData?.error as? MoyaError, error.errorCode == 6, noData != nil  {
                return
            }
            self.emptyOnView?.hideNetworkErrorEmptyView()
            var row = [Int](0..<self.tableView.numberOfSections).reduce(0, {
                result, index in
                return result + self.tableView.numberOfRows(inSection: index)
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

                
                self.tableView.customFooterView?.isHidden = true
                self.tableView.footerEndRefresh()
            } else {
                self.tableView.hideEmptyView()
            }
//            self.tableView.isHidden = (noData != nil)
        }).disposed(by: disposeBag)
        
        notNetworkRetryTrigger.subscribe(onNext: {
            [weak self]
            in
            guard let self = self else {return}
            self.emptyOnView?.hideEmptyView()
            self.tableView.isHidden = false
            self.beginHeaderRefresh()
        }).disposed(by: disposeBag)
        
        if App.isAutoShowFooterNoMoreData {
            tableView.rx.observe(CGSize.self, "contentSize").subscribe(with: self, onNext: {
                (self, contentSize) in
                if let contentSize = contentSize  {
                    if contentSize.height < self.tableView.bounds.height, self.tableView.customFooterView?.isHideNoMoreData == false   {
                        self.tableView.customFooterView?.isHideNoMoreData = true
                    }
                }
            }).disposed(by: disposeBag)
        }
        
        
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            [weak self] in guard let self = self else { return }
            self.tableView.headerBeginRefresh()
        }
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
                tableVC.tableView.showFooterRefresh(isShow: true, customLoadingView: tableVC.footerCustomLoadingView)
                tableVC.tableView.mj_footer?.endRefreshingWithNoMoreData()
                tableVC.tableView.customFooterView?.isHideNoMoreData = false
                if tableVC.tableView.contentSize.height < tableVC.tableView.bounds.height, tableVC.tableView.customFooterView?.isHideNoMoreData == false  {
                    tableVC.tableView.customFooterView?.isHideNoMoreData = true
                }
                
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
