//
//  CustomSegment.swift
//  SSUtils
//
//  Created by yangsq on 2022/6/23.
//

import UIKit
import SnapKit

open class CustomSegment: View, EventTrigger {
    public enum Event {
        case selected(index: Int)
    }
    public lazy var containerV: HorizontalStackView = {
        let view = HorizontalStackView()
        view.distribution = .fillEqually
        return view
    }()
    public var selectedTextColor: UIColor = Colors.headline
    public var normalTextColor: UIColor = UIColor.hex(0x737780)
    public var selectedBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex(0xffffff)
        view.layer.cornerRadius = 32.wScale / 2
        view.layer.masksToBounds = true
        return view
    }()
    public var titles: [String]
    private var buttons = [UIButton]()
    public private(set) var currentIndex: Int = 0
    public init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        refreshButtonStatus(index: self.currentIndex, animated: false)
    }
    
    public override func make() {
        super.make()
        layer.cornerRadius = 5.wScale
        backgroundColor = UIColor.hex(0xF3F4F5)
        addSubview(selectedBgView)
        addSubview(containerV)
        
        containerV.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        titles.forEach { title in
            let index = titles.firstIndex(of: title)!
            let button = UIButton.makeButton(type: .custom,
                                             title: title,
                                             titleColor: normalTextColor,
                                             font: Fonts.auto(14))
            button.setTitleColor(selectedTextColor, for: .selected)
            button.setTitleColor(normalTextColor, for: [.selected, .highlighted])
            containerV.addArrangedSubview(button)
            buttons.append(button)
            button.snp.makeConstraints { make in
                make.top.bottom.equalTo(0)
            }
            button.rx.tap().subscribe(onNext: {
                [weak self] in guard let self = self else { return }
                self.refreshButtonStatus(index: index)
            }).disposed(by: button.rx.disposeBag)
        }
    }
    
    public func refreshButtonStatus(index: Int, animated: Bool = true) {
        if self.buttons.count > index {
            self.currentIndex = index
            let button = self.buttons[index]
            self.triggerEvent?(.selected(index: index))
            UIView.animate(withDuration: animated ? 0.2 : 0, delay: 0, options: .curveEaseInOut) {
                let equalWidth = (App.width - 20.wScale * 2) / CGFloat(self.titles.count) - 4 * 2.wScale
                self.selectedBgView.ss_w = equalWidth
                self.selectedBgView.ss_h = 32.wScale
                self.selectedBgView.ss_centerX = button.ss_centerX
                self.selectedBgView.ss_centerY = self.ss_h / 2
                button.isSelected = true
                self.buttons.filter({$0 != button}).forEach({$0.isSelected = false})
            }
          
        }
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
