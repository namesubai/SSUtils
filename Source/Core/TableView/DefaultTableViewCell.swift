//
//  DefaultTableViewCell.swift
//  
//
//  Created by yangsq on 2020/10/22.
//

import UIKit
import SnapKit
open class DefaultTableViewCell: TableViewCell {
    public var containerHeightConstraint: Constraint!
    public lazy var containerStackView: HorizontalStackView = {
        let view = HorizontalStackView()
        view.spacing = 10
        return view
    }()
    
    public lazy var leftStackView: HorizontalStackView = {
        let view = HorizontalStackView()
        view.spacing = 14.wScale
        view.distribution = .fill
        return view
    }()
    
    public lazy var rightStackView: HorizontalStackView = {
        let view = HorizontalStackView()
        view.spacing = 8.wScale
        return view
    }()
    
    
//    private var hasIcon: Bool = false
//    private var hasArrowImageV: Bool = false
   
    
    public lazy var defaultTitleLab: UILabel = {
        let label = UILabel.makeLabel(textColor: Colors.headline,
                                      font: Fonts.medium(14))
        return label
    }()
    
    public lazy var defaultRightLabel: UILabel = {
        let label = UILabel.makeLabel(textColor: Colors.detailText,
                                      font: Fonts.medium(14),
                                      alignment: .right)
        return label
    }()
    
    public lazy var defaultImgV: UIImageView = {
        let icon = UIImageView()
        icon.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return icon
    }()
    
    public lazy var defaultArrowImgV: UIImageView = {
        let imageV = UIImageView()
        imageV.image = ssImage("arrow_right")
        imageV.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return imageV
    }()
    
    public lazy var defaultRedPoindView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex(0xFF004C)
        view.isHidden = true
        return view
    }()
    
    open func showArrowView(_ isShow: Bool) {
        defaultArrowImgV.isHidden = !isShow
    }
    
    open func showImageView(_ isShow: Bool) {
        defaultImgV.isHidden = !isShow
    }
    
    open override func make() {
        super.make()
        isHideLineView = false
        contentView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(leftStackView)
        containerStackView.addArrangedSubview(rightStackView)
        leftStackView.addArrangedSubview(defaultImgV)
        leftStackView.addArrangedSubview(defaultTitleLab)
        rightStackView.addArrangedSubview(defaultRightLabel)
        rightStackView.addArrangedSubview(defaultRedPoindView)
        rightStackView.addArrangedSubview(defaultArrowImgV)

        rightStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        containerStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 16.wScale, bottom: 0, right: 16.wScale))
            containerHeightConstraint = make.height.equalTo(55).priority(.high).constraint
        }
        
        defaultRedPoindView.snp.makeConstraints { make in
            make.width.height.equalTo(7.wScale)
        }
        
        defaultArrowImgV.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 6.5.wScale, height: 11.wScale))
        }
        
        showImageView(false)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    open override func bind(_ cellViewModel: CellViewModel) {
        super.bind(cellViewModel)
       
    }
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
