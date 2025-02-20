//
//  DownloadImageView.swift
//  SSUtils
//
//  Created by yangsq on 2021/11/13.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

public class DownloadImageView: UIImageView {
    lazy var loadingHud: SSProgressHUD = {
        let hud = SSProgressHUD(mode: .progressValue, style: .clear)
        hud.maskBackgroundView.isHidden = true
        hud.isHidden = true
        return hud
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadingHud.showHUD(onView: self, animation: false)

    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        loadingHud.ss_center = CGPoint(x: ss_w / 2, y: ss_h / 2)
    }
    
    required init?(coder: NSCoder) {
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

public extension Reactive where Base: DownloadImageView {
    var progress: Binder<CGFloat> {
        return Binder(self.base, binding: { (imageView, progress) in
            imageView.loadingHud.isHidden = progress >= 1
            imageView.loadingHud.customView.progress = progress
        })
    }
    
}
