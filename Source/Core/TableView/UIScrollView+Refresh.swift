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

//private var headerLoingViewKey: Int8 = 0
//private var footerLoingViewKey: Int8 = 0
//
//public extension UITableView {
//    var headerLoingView: UIView?  {
//        set {
//            objc_setAssociatedObject(self, &headerLoingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//
//        get {
//            objc_getAssociatedObject(self, &headerLoingViewKey) as? UIView
//        }
//    }
//
//    var footerLoingView: UIView?  {
//        set {
//            objc_setAssociatedObject(self, &footerLoingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//
//        get {
//            objc_getAssociatedObject(self, &footerLoingViewKey) as? UIView
//        }
//    }
//}


public class CustomFooterRefreshView: MJRefreshAutoNormalFooter {
    
    public override func prepare() {
        super.prepare()
        stateLabel?.font = UIFont.systemFont(ofSize: 14)
        stateLabel?.textColor = UIColor.hex(0x9C9DA1)
        stateLabel?.isHidden = true
        isRefreshingTitleHidden = true
        triggerAutomaticallyRefreshPercent = 0.1
        setTitle(localized(name: "noMoreData"), for: .noMoreData)
        setTitle("", for: .idle)
        setTitle("", for: .pulling)
        setTitle("", for: .refreshing)
        setTitle("", for: .willRefresh)
       
    }
    var customLoadingView: UIView? {
        didSet {
            if customLoadingView != nil   {
                loadingView?.alpha = 0
                oldValue?.removeFromSuperview()
                addSubview(customLoadingView!)
                mj_h = 40
                if state == .idle || state == .noMoreData {
                    customLoadingView?.isHidden = true
                }
            } else {
                loadingView?.alpha = 1
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        customLoadingView?.ss_center = CGPoint(x: ss_w / 2, y: ss_h / 2)
        if customLoadingView != nil {
            if self.state != .noMoreData {
                stateLabel?.isHidden = true
            }
            loadingView?.alpha = 0
        }
    }
    
    public override var state: MJRefreshState {
        didSet {
            customLoadingView?.isHidden = false
            stateLabel?.isHidden = true

            switch state {
            case .idle:
                customLoadingView?.isHidden = true
            case . noMoreData:
                stateLabel?.isHidden = false
                customLoadingView?.isHidden = true
            default:
                break
            }
            if customLoadingView != nil {
                loadingView?.alpha = 0
            }

        }
    }
    
}

public class CustomHeaderRefreshView: MJRefreshNormalHeader {
    
    public override func prepare() {
        super.prepare()
        stateLabel?.font = UIFont.systemFont(ofSize: 14)
        stateLabel?.textColor = UIColor.hex(0x9C9DA1)
        stateLabel?.isHidden = true
        setTitle("", for: .noMoreData)
        setTitle("", for: .idle)
        setTitle("", for: .pulling)
        setTitle("", for: .refreshing)
        setTitle("", for: .willRefresh)
        if customLoadingView != nil {
            arrowView?.alpha = 0
            loadingView?.alpha = 0
        }
    
    }
    
    var customLoadingView: UIView? {
        didSet {
            if customLoadingView != nil {
                arrowView?.alpha = 0
                oldValue?.removeFromSuperview()
                addSubview(customLoadingView!)
                mj_h = 40
                loadingView?.alpha = 0
            } else {
                arrowView?.alpha = 1
                loadingView?.alpha = 1
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        customLoadingView?.ss_center = CGPoint(x: ss_w / 2, y: ss_h / 2)
        if customLoadingView != nil {
            arrowView?.alpha = 0
            loadingView?.alpha = 0
        }
    }
    
    public override var state: MJRefreshState {
        didSet {
            customLoadingView?.isHidden = false

            switch state {
            case .pulling:
                let feedback = UIImpactFeedbackGenerator(style: .light)
                feedback.prepare()
                feedback.impactOccurred()
            case .idle:
                customLoadingView?.isHidden = true
            default:
                break
            }
            if customLoadingView != nil {
                arrowView?.alpha = 0
                loadingView?.alpha = 0
            }
          
        }
    }
    
    public override func scrollViewContentOffsetDidChange(_ change: [AnyHashable : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        if customLoadingView != nil {
            arrowView?.isHidden = true
            loadingView?.alpha = 0
        }
       
    }
}

private var headerRefreshTriggerKey: Int8 = 0
private var footerRefreshTriggerKey: Int8 = 0
private var customHeaderViewKey: Int8 = 0
private var customFooterViewKey: Int8 = 0

public extension UIScrollView {
   
    public var customHeaderView: CustomHeaderRefreshView? {
        if let refreshView = objc_getAssociatedObject(self, &customHeaderViewKey) as? CustomHeaderRefreshView {
            return refreshView
        } else {
            let refreshView = CustomHeaderRefreshView {
                [weak self] in guard let self = self else { return }
                self.headerRefreshTrigger.onNext(())
            }
            objc_setAssociatedObject(self, &customHeaderViewKey, refreshView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return refreshView
        }
    }
    
    public var customFooterView: CustomFooterRefreshView? {
        if let refreshView = objc_getAssociatedObject(self, &customFooterViewKey) as? CustomFooterRefreshView {
            return refreshView
        } else {
            let refreshView = CustomFooterRefreshView {
                [weak self] in guard let self = self else { return }
                self.footerRefreshTrigger.onNext(())
            }
            objc_setAssociatedObject(self, &customFooterViewKey, refreshView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return refreshView
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
    
    public func showHeaderRefresh(isShow: Bool, customLoadingView: UIView? = nil) {
        if isShow && (mj_header != customHeaderView || mj_header != nil) {
            customHeaderView?.customLoadingView = customLoadingView
            self.mj_header = customHeaderView
          
        } else {
            self.mj_header = nil
        }
    }
    
    public func showFooterRefresh(isShow: Bool, customLoadingView: UIView? = nil) {
        
        if isShow && (mj_footer != customFooterView || mj_footer != nil) {
            customFooterView?.customLoadingView = customLoadingView
            self.mj_footer = customFooterView
          
        } else {
            self.mj_footer = nil
        }
        
    }
    
    public func headerBeginRefresh() {
        if self.mj_header != nil {
            self.mj_header?.beginRefreshing()
        }
    }
    
    public func footerBeginRefresh() {
        if mj_footer != nil {
            mj_footer!.beginRefreshing()
        }
    }
    
    public func headerEndRefresh() {
        if self.mj_header != nil {
            self.mj_header?.endRefreshing()
        }
    }
    
    public func footerEndRefresh() {
        if mj_footer != nil {
            mj_footer!.endRefreshing()
        }
    }
}

