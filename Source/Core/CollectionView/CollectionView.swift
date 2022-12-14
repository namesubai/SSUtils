//
//  CollectionView.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit

open class CollectionView: UICollectionView {
    
    public lazy var bgView: UIView = {
        let whiteView = UIView()
        whiteView.backgroundColor = UIColor.hex(0xffffff)
        whiteView.layer.cornerRadius = 20.wScale
        whiteView.layer.masksToBounds = true
        whiteView.layer.zPosition = -29
        whiteView.isUserInteractionEnabled = false
        return whiteView
    }()
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if subview != bgView, subviews.first != subview {
            sendSubviewToBack(bgView)
        }
    }
    
    public lazy var isHideBgView: Bool = true {
        didSet {
            bgView.isHidden = isHideBgView
        }
    }
    
    public var bgViewContentEdgeInset: UIEdgeInsets?
    
    override init(frame: CGRect,
                  collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = Colors.backgroud
        keyboardDismissMode = .onDrag
        bgView.isHidden = true
        addSubview(bgView)

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
    open override func reloadData() {
        super.reloadData()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !isHideBgView, let bgViewContentEdgeInset = bgViewContentEdgeInset {
            bgView.frame = CGRect(x: bgViewContentEdgeInset.left, y: bgViewContentEdgeInset.top, width: contentSize.width - bgViewContentEdgeInset.left - bgViewContentEdgeInset.right, height: contentSize.height - bgViewContentEdgeInset.top - bgViewContentEdgeInset.bottom)
        }
        
    }

}
public extension UICollectionViewCell {
    static var cellName: String {
        return NSStringFromClass(self.classForCoder())
    }
}
