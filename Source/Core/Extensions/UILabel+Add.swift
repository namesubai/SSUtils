//
//  UILabel+.swift
//  
//
//  Created by yangsq on 2020/10/22.
//

import Foundation

public extension UILabel {
    
    
    @discardableResult static func makeLabel(text: String? = "",
                                             textColor: UIColor? = .black,
                                             font: UIFont? = UIFont.systemFont(ofSize: 15),
                                             cornerRadius: CGFloat = 0,
                                             masksToBounds: Bool = false,
                                             numberOfLines: Int = 1,
                                             alignment: NSTextAlignment = .left) -> Self {
        let label = Self()
        label.text = text
        if let textColor = textColor {
            label.textColor = textColor
        }
        if let font = font {
            label.font = font
        }
        if cornerRadius > 0 {
            label.layer.cornerRadius = cornerRadius
        }
        
        if masksToBounds {
            label.layer.masksToBounds = masksToBounds
        }
        label.numberOfLines = numberOfLines
        label.textAlignment = alignment
        return label
    }
}

public extension UILabel {
    func setLineHeight(_ lineHeight: CGFloat) {
        guard let text = text else {
            return
        }
        let attrString = NSMutableAttributedString(string: text)
        if let attributedText = attributedText {
            let attrString = NSMutableAttributedString(attributedString: attributedText)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.count))
        attributedText = attrString
    }
    
    func setLineSpacing(_ lineSpacing: CGFloat) {
        guard let text = text else {
            return
        }
        var attrString = NSMutableAttributedString(string: text)
        if let attributedText = attributedText {
            let attrString = NSMutableAttributedString(attributedString: attributedText)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.count))
        attributedText = attrString
    }
}
