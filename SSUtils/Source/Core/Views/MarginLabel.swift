//
//  MarginLabel.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/7/5.
//

import UIKit

open class MarginLabel: UILabel {

    open var corners: UIRectCorner = .allCorners {
        didSet {
            refreshLayout()
        }
    }
    open var cornerRadiusSize: CGFloat = 0
    open var isAutoCornerRadius: Bool = false {
        didSet {
            refreshLayout()
        }
    }
    open var lineWidth: CGFloat? {
        didSet {
            refreshLayout()
        }
    }
    open var lineColor: UIColor? {
        didSet {
            refreshLayout()
        }
    }
    open func refreshLayout() {
        setNeedsDisplay()
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.isAutoCornerRadius {
            addCorner(roundingCorners: corners, cornerSize: CGSize(width: self.bounds.height / 2, height: self.bounds.height / 2), borderColor: lineColor?.cgColor, borderWidth: lineWidth)
        } else {
            addCorner(roundingCorners: corners, cornerSize: CGSize(width: cornerRadiusSize, height: cornerRadiusSize), borderColor: lineColor?.cgColor, borderWidth: lineWidth)
        }
    }
    
    open var space: UIEdgeInsets = .zero {
        didSet {
            space = UIEdgeInsets(top: space.top.rounded(), left: space.left.rounded(), bottom: space.bottom.rounded(), right: space.right.rounded())
            setNeedsLayout()
            layoutIfNeeded()
//            invalidateIntrinsicContentSize()
        }
    }
    
//    override var intrinsicContentSize: CGSize {
//        sizeToFit()
//        var size = frame.size
//        size = CGSize(width: size.width + space.left + space.right, height: size.height + space.top + space.bottom)
//        return size
//    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRect(forBounds: bounds.inset(by: space), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= space.left
        rect.origin.y -= space.top
        rect.size.width += (space.left + space.right)
        rect.size.height += (space.top + space.bottom)
        return rect
    }
    

    
    open override func drawText(in rect: CGRect) {
       
        super.drawText(in: rect.inset(by: space))
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


