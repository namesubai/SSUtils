//
//  UITableView+Add.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/17.
//

import Foundation

public extension UITableView {
    func layoutAndScrollToBottom(animation: Bool) {
        self.layoutIfNeeded()
        DispatchQueue.main.async {
            [weak self]
            in
            guard let self = self else { return }
            let offsetY = self.contentSize.height - self.frame.height + self.contentInset.bottom
            if offsetY > 0 {
                self.setContentOffset(CGPoint(x: 0, y: offsetY), animated: animation)
            }
        }
    }
}
