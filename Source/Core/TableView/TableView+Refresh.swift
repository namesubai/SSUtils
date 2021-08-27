//
//  TableView+Refresh.swift
//  patter
//
//  Created by yangsq on 2021/1/11.
//

import Foundation
import MJRefresh
import RxCocoa
import RxSwift

public class CustomFooterRefreshView: MJRefreshAutoNormalFooter {
    
    public override func prepare() {
        super.prepare()
        stateLabel?.font = UIFont.systemFont(ofSize: 14)
        stateLabel?.textColor = UIColor.hex(0x9C9DA1)
        stateLabel?.isHidden = true
        isRefreshingTitleHidden = true
        triggerAutomaticallyRefreshPercent = 0
        setTitle("no more date", for: .noMoreData)
        setTitle("", for: .idle)
        setTitle("", for: .pulling)
        setTitle("", for: .refreshing)
        setTitle("", for: .willRefresh)
    }
}

private var headerRefreshTriggerKey: Int8 = 0
private var footerRefreshTriggerKey: Int8 = 0
private var customHeaderViewKey: Int8 = 0

public extension UITableView {
    public var customFooterView: CustomFooterRefreshView? {
        return mj_footer as? CustomFooterRefreshView
    }
    
    public var customHeaderView: UIRefreshControl? {
        if let refreshControl = objc_getAssociatedObject(self, &customHeaderViewKey) as? UIRefreshControl {
            return refreshControl
        } else {
            let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            refreshControl.rx.controlEvent(.valueChanged).bind(to: headerRefreshTrigger).disposed(by: rx.disposeBag)
            objc_setAssociatedObject(self, &customHeaderViewKey, refreshControl, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return refreshControl
        }
    }
    public var headerRefreshTrigger: ReplaySubject<Void> {
        if let refresh = objc_getAssociatedObject(self, &headerRefreshTriggerKey) as? ReplaySubject<Void> {
            return refresh
        } else {
            let refresh = ReplaySubject<Void>.create(bufferSize: 1)
            objc_setAssociatedObject(self, &headerRefreshTriggerKey, refresh, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return refresh
        }
    }
    
    public var footerRefreshTrigger: PublishSubject<Void> {
        if let refresh = objc_getAssociatedObject(self, &footerRefreshTriggerKey) as? PublishSubject<Void> {
            return refresh
        } else {
            let refresh = PublishSubject<Void>()
            objc_setAssociatedObject(self, &footerRefreshTriggerKey, refresh, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return refresh
        }
    }
    
    public func showHeaderRefresh(isShow: Bool) {
        if isShow {
            if self.refreshControl == nil {
                self.refreshControl = customHeaderView
            }
        } else {
            self.refreshControl = nil
        }
    }
    
    public func showFooterRefresh(isShow: Bool) {
        if isShow {
            mj_footer = CustomFooterRefreshView(refreshingBlock: {
                [weak self] in
                guard let self = self else { return }
                self.footerRefreshTrigger.onNext(())
            })
        } else {
            mj_footer = nil
        }
    }
    
    public func headerBeginRefresh() {
        if self.refreshControl != nil {
            self.refreshControl!.beginRefreshing()
            headerRefreshTrigger.onNext(())
        }
    }
    
    public func footerBeginRefresh() {
        if mj_footer != nil {
            mj_footer!.beginRefreshing()
        }
    }
    
    public func headerEndRefresh() {
        if self.refreshControl != nil {
            self.refreshControl!.endRefreshing()
        }
    }
    
    public func footerEndRefresh() {
        if mj_footer != nil {
            mj_footer!.endRefreshing()
        }
    }
}

