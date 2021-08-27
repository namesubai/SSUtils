//
//  Tabbar.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit

open class Tabbar: UITabBar {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        addLine(line: .top)
    }
    
    public required init?(coder: NSCoder) {
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
