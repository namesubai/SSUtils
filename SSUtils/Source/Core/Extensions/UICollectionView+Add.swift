//
//  UICollectionView+Add.swift
//  SSUtils
//
//  Created by yangsq on 2022/8/17.
//

import Foundation
import UIKit

extension UICollectionView {
    public func safeSelectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        if let indexPath = indexPath {
            if numberOfSections > indexPath.section, numberOfItems(inSection: indexPath.section) > indexPath.row {
                selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
            }
        } else {
            selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        }
    }
}
