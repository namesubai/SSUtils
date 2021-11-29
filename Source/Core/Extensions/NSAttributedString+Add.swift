//
//  NSAttributedString+Add.swift
//  SSUtils
//
//  Created by yangsq on 2021/9/14.
//

import Foundation

public extension NSAttributedString {
    func add(value: Any, key: NSAttributedString.Key, subString: String) -> NSAttributedString {
        guard let r = string.range(of: subString) else {
            return self
        }
        let range = NSRange(r, in: string)
        let attr = NSMutableAttributedString(attributedString: self)
        attr.addAttribute(key, value: value, range: range)
        return attr
    }
}

public extension String {
    var attributedString: NSAttributedString {
        return NSAttributedString(string: self)
    }
}
