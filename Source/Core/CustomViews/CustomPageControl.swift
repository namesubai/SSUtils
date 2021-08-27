//
//  CustomPageControl.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/27.
//

import UIKit
import RxSwift


private class CustomPageIndicator: Button {
    
}

open class CustomPageControl: View {
    
    private lazy var containerStackView: HorizontalStackView = {
        let stackView = HorizontalStackView()
        stackView.spacing = pageIndicatorSpace
        return stackView
    }()
    
    public var pageIndicatorSpace: CGFloat = 4.5.wScale
    public var pageIndicatorSize: CGSize = CGSize(width: 4.5.wScale, height: 4.5.wScale)
    public var pageIndicatorNormalColor: UIColor = UIColor.hex(0x575A66)
    public var pageIndicatorSelectedColor: UIColor = UIColor.hex(0xFFFFFF)
    public var currentPageNum: Int = 0 {
        didSet {
            for indicator in indicators {
                let num = indicators.firstIndex(of: indicator)
                if num == currentPageNum {
                    indicator.isSelected = true
                } else {
                    if indicator.isSelected {
                        indicator.isSelected = false
                    }
                }
            }
        }
    }
    private var indicators: [CustomPageIndicator] = []
    
    public var numOfPages: Int = 0 {
        didSet {
            if numOfPages > 1 {
                containerStackView.arrangedSubviews.forEach { view in
                    containerStackView.removeArrangedSubview(view)
                }
                indicators.removeAll()
                for _ in 0..<numOfPages {
                    let indicator = CustomPageIndicator()
            
                    indicator.setBackgroundImage(UIImage(color: pageIndicatorNormalColor, size: CGSize(width: pageIndicatorSize.width * UIScreen.main.scale, height: pageIndicatorSize.height * UIScreen.main.scale)), for: .normal)
                    indicator.setBackgroundImage(UIImage(color: pageIndicatorSelectedColor, size: CGSize(width: pageIndicatorSize.width * UIScreen.main.scale, height: pageIndicatorSize.height * UIScreen.main.scale)), for: .selected)
                    indicator.layer.cornerRadius = pageIndicatorSize.height / 2
                    indicator.layer.masksToBounds = true
                    containerStackView.addArrangedSubview(indicator)
                    indicators.append(indicator)
                    indicator.snp.makeConstraints { (make) in
                        make.size.equalTo(pageIndicatorSize)
                    }
                }
            }
        }
    }
    
    open override func make() {
        super.make()
        addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


public extension Reactive where Base: CustomPageControl {
    var numOfPages: Binder<Int> {
        return Binder(self.base, binding: { (view, numOfPages) in
            view.numOfPages = numOfPages
        })
    }
    
    var currentPageNum: Binder<Int> {
        return Binder(self.base, binding: { (view, currentPageNum) in
            view.currentPageNum = currentPageNum
        })
    }
}