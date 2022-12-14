//
//  UIScrollView+Rx.swift
//  SSUtils
//
//  Created by yangsq on 2022/9/16.
//

import Foundation
import RxSwift
import RxCocoa

public extension Reactive where Base: UIScrollView {
    var pageHorIndex: Observable<Int> {
        base.rx.contentOffset.map({
            contentOffset -> Int in
            guard base.bounds.width > 0 else { return 0 }
            var page = Int(contentOffset.x / base.bounds.width)
            page = max(0, page)
            return page
        })
    }
    
    var pageVerIndex: Observable<Int> {
        base.rx.contentOffset.map({
            contentOffset -> Int in
            guard base.bounds.height > 0 else { return 0 }
            var page = Int(contentOffset.y / base.bounds.height)
            page = max(0, page)
            return page
        })
    }
    
    var scrollTolHide: Observable<Void> {
        base.rx.didScroll.mapToVoid().filter({
            [weak base] _ -> Bool in guard let base = base else { return false }
            return base.contentOffset.y > -base.contentInset.top
        })
    }
    
    var endScrollTolShow: Observable<Void> {
        Observable.merge(base.rx.didEndDecelerating.mapToVoid(),  base.rx.didEndDragging.filter({$0 == false}).mapToVoid())
    }
}


