//
//  UIScrollView+Add.swift
//  SSUtils
//
//  Created by yangsq on 2023/5/11.
//

import UIKit

public extension UIScrollView {
    func scrollItemToCenter(itemView: UIView, animated: Bool = true) {
        guard let frame = itemView.superview?.convert(itemView.frame, to: self) else { return }
        if frame.midX < bounds.width / 2 {
            scrollToLeft(animation: animated)
        } else if frame.midX > contentSize.width - bounds.width / 2 {
            scrollToRight(animation: animated)
        } else {
            var toPoint = frame.origin
            toPoint.x -= bounds.width / 2 - itemView.bounds.width / 2
            toPoint.x += contentInset.left
            setContentOffset(CGPoint(x: toPoint.x, y: 0), animated: animated)
        }
    }
}
