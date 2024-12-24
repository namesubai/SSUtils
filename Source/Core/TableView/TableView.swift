//
//  TableView.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxCocoa
import RxSwift

open class TableView: UITableView {

    init() {
        super.init(frame: .zero, style: .plain)
        setUI()
    }
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame,style: style)
        setUI()
    }
    
    let reloadDataTrigger = PublishSubject<Void>()
    
//    override var separatorInset: UIEdgeInsets {
//        didSet {
//            let newSeparatorInset = UIEdgeInsets(top: separatorInset.top, left: separatorInset.left, bottom: separatorInset.bottom + 10, right: separatorInset.right)
//            super.separatorInset = newSeparatorInset
//        }
//    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    open func setUI() {
        backgroundColor = .white
//        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 50
        estimatedSectionHeaderHeight = 0.0
        estimatedSectionFooterHeight = 0.0
        cellLayoutMarginsFollowReadableWidth = false
        keyboardDismissMode = .onDrag
        separatorColor = Colors.line
        separatorStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 16.wScale, bottom: 0, right: 16.wScale)
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        } 
        tableFooterView = UIView()
//        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.5))
    }
    
    open override func reloadData() {
        super.reloadData()
        reloadDataTrigger.onNext(())
    }
    
    open override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        self.superview?.endEditing(true)
        return true
    }
    
    public var insetGroupedCornerRadius: CGFloat = 10
    public var leftAndRightMargin: CGFloat = 16.wScale
    public var isInsetGroupedAble = false
    open override func layoutSubviews() {
        super.layoutSubviews()
        if isInsetGroupedAble {
            
            let sections = numberOfSections
            for section in 0..<sections {
                let rows = numberOfRows(inSection: section)
                for row in 0..<rows {
                    let indexPath = IndexPath(item: row, section: section)
                    if let cell = cellForRow(at: indexPath) {
                        cell.ss_x = leftAndRightMargin
                        cell.ss_w = frame.width - leftAndRightMargin * 2
                        if let defaultCell = cell as? TableViewCell, defaultCell.isHideLineView == false {
                            defaultCell.lineView.isHidden = false
                        }
                        if rows == 1 {
                            cell.addCorner(roundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], cornerSize: CGSize(width: insetGroupedCornerRadius, height: insetGroupedCornerRadius))
                            if let defaultCell = cell as? TableViewCell, defaultCell.isHideLineView == false {
                                defaultCell.lineView.isHidden = true
                            }
                        } else {
                            if row == 0 {
                                
                                cell.addCorner(roundingCorners: [.topLeft, .topRight], cornerSize: CGSize(width: insetGroupedCornerRadius, height: insetGroupedCornerRadius))
                                
                            } else if row == rows - 1 {
                                cell.addCorner(roundingCorners: [.bottomLeft, .bottomRight], cornerSize: CGSize(width: insetGroupedCornerRadius, height: insetGroupedCornerRadius))
                                if let defaultCell = cell as? TableViewCell, defaultCell.isHideLineView == false {
                                    defaultCell.lineView.isHidden = true
                                }
                            } else {
                                cell.addCorner(roundingCorners: [], cornerSize: CGSize(width: insetGroupedCornerRadius, height: insetGroupedCornerRadius))

                            }
                        }
                    }
                    
                }
            }
        }
        
    }
    
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


