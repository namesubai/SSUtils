//
//  CollectionView.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit

open class CollectionView: UICollectionView {
    
    override init(frame: CGRect,
                  collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = Colors.backgroud
        keyboardDismissMode = .onDrag
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
public extension UICollectionViewCell {
    static var cellName: String {
        return String(describing: self)
    }
}
