//
//  BageView.swift
//  LoolaCommon
//
//  Created by yangsq on 2021/11/8.
//

import Foundation
import SnapKit

open class BageView: View {

    public lazy var bageLab: UILabel = {
        let label = UILabel.makeLabel(textColor: UIColor.white,
                                      font: Fonts.bold(11.fontScale),
                                      alignment: .center)
        return label
    }()
    
    private var widthConstraint: Constraint?
    private var heightConstraint: Constraint?

    open override func make() {
        super.make()
        backgroundColor = UIColor.hex(0xFF445C)
        addSubview(bageLab)
        snp.makeConstraints { make in
            widthConstraint = make.width.equalTo(18.wScale).constraint
            heightConstraint = make.height.equalTo(18.wScale).constraint
        }
//        bageLab.snp.makeConstraints { make in
//            make.edges.equalTo(UIEdgeInsets(top: 2.5, left: 7, bottom: 2.5, right: 7).wScale)
//        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return ss_size
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        bageLab.center = CGPoint(x: ss_w / 2, y: ss_h / 2)
    }
   
    open func refrehFrame() {
        let viewHeight = 18.wScale
        bageLab.sizeToFit()
        let size = bageLab.ss_size
        var viewWidth = size.width + 5.wScale * 2
        if viewWidth < viewHeight {
            viewWidth = viewHeight
        }
        self.ss_w = viewWidth
        self.ss_h = viewHeight
        bageLab.ss_size = size
        bageLab.center = CGPoint(x: ss_w / 2, y: ss_h / 2)
        layer.cornerRadius = ss_h / 2
        invalidateIntrinsicContentSize()
        widthConstraint?.update(offset: viewWidth)
        heightConstraint?.update(offset: viewHeight)
    }
}
