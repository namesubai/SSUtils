//
//  CustomPageControl.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/27.
//

import UIKit
import RxSwift
import SnapKit


private class CustomPageIndicator: Button {
    
}

open class CustomPageControl: View, EventTrigger {
    
    public enum Event {
        case selectPageNum(num: Int)
    }
    
    private lazy var containerStackView: HorizontalStackView = {
        let stackView = HorizontalStackView()
        stackView.spacing = pageIndicatorSpace
        stackView.distribution = .fill
        return stackView
    }()
    
    public var pageIndicatorSpace: CGFloat = 4.5.wScale
    public var pageIndicatorSize: CGSize = CGSize(width: 4.5.wScale, height: 4.5.wScale)
    public var pageIndicatorNormalColor: UIColor = UIColor.hex(0x575A66)
    public var pageIndicatorSelectedColor: UIColor = UIColor.hex(0xFFFFFF)
    public var currentPageIndicatorSize: CGSize = CGSize(width: 4.5.wScale, height: 4.5.wScale)
    public var hidesForSinglePage: Bool = true
    private var pageWidthConstraints = [Constraint]()
    private var pageHeightConstraints = [Constraint]()
    public var currentPageNum: Int = 0 {
        
        didSet {
            if currentPageNum >= numOfPages {
                return
            }
         
            for indicator in indicators {
                let num = indicators.firstIndex(of: indicator)
                let heightConstraint = pageHeightConstraints[num!]
                let widthConstraint = pageWidthConstraints[num!]
                if num == currentPageNum {
                    indicator.isSelected = true
                    widthConstraint.update(offset: currentPageIndicatorSize.width)
                    heightConstraint.update(offset: currentPageIndicatorSize.height)

                } else {
                    indicator.isSelected = false
                    widthConstraint.update(offset: pageIndicatorSize.width)
                    heightConstraint.update(offset: pageIndicatorSize.height)
                }
            }
        }
    }
    private var indicators: [CustomPageIndicator] = []
    
    public var numOfPages: Int = 0 {
        didSet {
            
            if numOfPages <= 1 && hidesForSinglePage {
                isHidden = true
            } else {
                isHidden = false
            }
            containerStackView.removAllarrangedSubviews()
            indicators.removeAll()
            pageWidthConstraints.removeAll()
            pageHeightConstraints.removeAll()
            for index in 0..<numOfPages {
                let indicator = CustomPageIndicator()
                indicator.setBackgroundImage(UIImage(color: pageIndicatorNormalColor, size: CGSize(width: pageIndicatorSize.width * UIScreen.main.scale, height: pageIndicatorSize.height * UIScreen.main.scale)), for: .normal)
                indicator.setBackgroundImage(UIImage(color: pageIndicatorSelectedColor, size: CGSize(width: pageIndicatorSize.width * UIScreen.main.scale, height: pageIndicatorSize.height * UIScreen.main.scale)), for: .selected)
                indicator.layer.cornerRadius = pageIndicatorSize.height / 2
                indicator.layer.masksToBounds = true
                containerStackView.addArrangedSubview(indicator)
                indicators.append(indicator)
                indicator.snp.makeConstraints { (make) in
                    let widthConstraints = make.width.equalTo(pageIndicatorSize.width).priority(.high).constraint
                    let heightConstraints = make.height.equalTo(pageIndicatorSize.height).priority(.high).constraint
                    self.pageWidthConstraints.append(widthConstraints)
                    self.pageHeightConstraints.append(heightConstraints)
                }
//                let touchButton = UIButton()
//                addSubview(touchButton)
//                touchButton.snp.makeConstraints { make in
//                    make.width.equalTo(indicator.snp.width)
//                    make.centerY.equalTo(indicator.snp.centerY)
//                    make.height.equalTo(20)
//                }
                indicator.rx.tap().subscribe(onNext: {
                    [weak self] in guard let self = self else { return }
                    self.triggerEvent?(.selectPageNum(num: index))
                }).disposed(by: indicator.rx.disposeBag)
            }
            layoutIfNeeded()
            currentPageNum = 0
        }
    }
    
    open override func make() {
        super.make()
        addSubview(containerStackView)
        containerStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(0).priority(.high)
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let view = self.indicators.first(where: {$0.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)).contains(CGPoint(x: point.x, y: point.y))}) {
            return view
        }
        return super.hitTest(point, with: event)
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
