//
//  VerStackView.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/10.
//

import UIKit

open class VerticalStackView: UIStackView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        alignment = .center
        distribution = .equalSpacing
    }
    
    public required init(coder: NSCoder) {
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
