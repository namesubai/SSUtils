//
//  UITableView+Add.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/17.
//

import Foundation

public extension UIScrollView {
    public func layoutAndScrollToBottom(animation: Bool) {
        self.layoutIfNeeded()
        DispatchQueue.main.async {
            [weak self]
            in
            guard let self = self else { return }
            let offsetY = self.contentSize.height - self.bounds.height + self.space.bottom
            if offsetY > 0 {
                self.setContentOffset(CGPoint(x: 0, y: offsetY), animated: animation)
            }
        }
    }
    
    var isBottom: Bool {
        let boottomOffset = self.contentSize.height - self.bounds.height + self.space.bottom
        if abs(boottomOffset - self.contentOffset.y) < 3 {
            return true
        }
        return false
    }
    
    var isTop: Bool {
        if self.contentOffset.y == -self.space.top {
            return true
        }
        return false
    }
    
    public var space: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.adjustedContentInset
        } else {
            return self.contentInset
        }
    }
}
