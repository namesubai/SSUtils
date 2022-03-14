//
//  CollectionViewCell.swift
//  
//
//  Created by yangsq on 2020/10/21.
//

import UIKit
import RxSwift


open class CollectionViewCell: UICollectionViewCell {
    
    public var disposeBag = DisposeBag()
    open var isCellSelected: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        make()
    }
    
    open func make() {
        
    }
    
    open func bind(_ cellViewModel: CellViewModel) {
        disposeBag = DisposeBag()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
}
public extension Reactive where Base: CollectionViewCell {

    var isCellSelected: Binder<Bool> {
        return Binder(self.base) { view, attr in
            view.isCellSelected = attr
        }
    }
}
