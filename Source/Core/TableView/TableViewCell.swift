//
//  TableViewCell.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxSwift
import RxCocoa

open class TableViewCell: UITableViewCell {
    public var disposeBag = DisposeBag()
    
    public lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = Colors.line
        return lineView
    }()
    
    private lazy var customSelectedBackgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    open var isHideLineView: Bool = true {
        didSet {
            lineView.isHidden = isHideLineView
        }
    }
    
    open var lineHeight: CGFloat = 0.5
    
    open var isCellSelected: Bool = false
    
    
    open var selectedBackgroundColor: UIColor? = nil {
        didSet {
            if selectedBackgroundColor == nil {
                self.selectedBackgroundView = nil
            } else {
                customSelectedBackgroundView.backgroundColor = selectedBackgroundColor
                self.selectedBackgroundView = customSelectedBackgroundView
            }
        }
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        make()
    }
    
    open func make() {
        backgroundColor = Colors.contentBackgroud
        lineView = UIView()
        lineView.backgroundColor = Colors.line
        contentView.addSubview(lineView)
        isHideLineView = true
        
    }
    
    open func bind(_ cellViewModel: CellViewModel) {
        disposeBag = DisposeBag()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        lineView.frame = CGRect(x: separatorInset.left, y: self.frame.height - separatorInset.bottom - lineHeight, width: self.frame.width - separatorInset.left - separatorInset.right, height: lineHeight)
        customSelectedBackgroundView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.customSelectedBackgroundView.alpha = selected ? 1 : 0
        // Configure the view for the selected state
    }
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
    
}


public extension Reactive where Base: TableViewCell {

    var isCellSelected: Binder<Bool> {
        return Binder(self.base) { view, attr in
            view.isCellSelected = attr
        }
    }
}

public extension UITableViewCell {
    static var cellName: String {
        return String(describing: self)
    }
    var tableView: UITableView? {
        return findTableView(view: self)
    }
    
    private func findTableView(view: UIView?) -> UITableView? {
        if view?.superview?.isKind(of: UITableView.self) == true {
            return view?.superview as? UITableView
        } else {
            return findTableView(view: view?.superview)
        }
    }
}
