//
//  SSCustomSegment.swift
//  SSUtils
//
//  Created by yangsq on 2022/6/23.
//

import UIKit
import SnapKit

open class SSCustomSegment: SSView, SSEventTrigger {
    public enum Event {
        case selected(index: Int)
    }
    public lazy var containerV: SSHorizontalStackView = {
        let view = SSHorizontalStackView()
        view.distribution = .fillEqually
        return view
    }()
    public var selectedTextColor: UIColor? {
        didSet {
            buttons.forEach { button in
                button.setTitleColor(selectedTextColor, for: .selected)
            }
        }
    }
    public var normalTextColor: UIColor? {
        didSet {
            buttons.forEach { button in
                button.setTitleColor(normalTextColor, for: [.selected, .highlighted])
                button.setTitleColor(normalTextColor, for: [.normal])
            }
        }
    }
    public var selectedBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex(0xffffff)
        view.layer.masksToBounds = true
        return view
    }()
    public var titles: [String]
    private var buttons = [UIButton]()
    public private(set) var currentIndex: Int = 0
    private var bgHeight: CGFloat
    private var bgCornerRadious: CGFloat?
    private var font: UIFont
    private var bgColor: UIColor
    public init(titles: [String], bgHeight: CGFloat, bgColor: UIColor = UIColor.hex(0xffffff), bgCornerRadious: CGFloat? = nil, selectedTextColor: UIColor? = SSColors.headline, normalTextColor: UIColor = UIColor.hex(0x737780), font: UIFont = SSFonts.auto(14)) {
        self.titles = titles
        self.bgHeight = bgHeight
        self.bgCornerRadious = bgCornerRadious
        self.selectedTextColor = selectedTextColor
        self.normalTextColor = normalTextColor
        self.font = font
        self.bgColor = bgColor
        super.init(frame: .zero)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        refreshButtonStatus(index: self.currentIndex, animated: false, isTrigger:  false)
    }
    
    
    public override func make() {
        super.make()
        layer.cornerRadius = 5.wScale
        backgroundColor = UIColor.hex(0xF5F6F7)
        addSubview(selectedBgView)
        addSubview(containerV)
        selectedBgView.backgroundColor = bgColor
        
        containerV.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        titles.forEach { title in
            let index = titles.firstIndex(of: title)!
            let button = UIButton.makeButton(type: .custom,
                                             title: title,
                                             titleColor: normalTextColor,
                                             font: self.font)
            button.setTitleColor(selectedTextColor, for: .selected)
            button.setTitleColor(normalTextColor, for: [.selected, .highlighted])
            containerV.addArrangedSubview(button)
            buttons.append(button)
            button.snp.makeConstraints { make in
                make.top.bottom.equalTo(0)
            }
            button.rx.tap().subscribe(onNext: {
                [weak self] in guard let self = self else { return }
                self.selectIndex(index: index)
            }).disposed(by: button.rx.disposeBag)
        }
    }
    
    public func selectIndex(index: Int, animated: Bool = true) {
        self.currentIndex = index
        refreshButtonStatus(index: index, animated: animated)
    }
    
    private func refreshButtonStatus(index: Int, animated: Bool = true, isTrigger: Bool = true) {
        if self.buttons.count > index {
            let button = self.buttons[index]
            if isTrigger {
                self.triggerEvent?(.selected(index: index))
            }
            
            func changeFrame() {
                let space = (self.ss_h - self.bgHeight) / 2
                let equalWidth = self.ss_w / CGFloat(self.titles.count) - 2 * space
                self.selectedBgView.ss_w = equalWidth
                self.selectedBgView.ss_h = self.bgHeight
                self.selectedBgView.ss_x = space + (equalWidth + space * 2) * CGFloat(index)
                self.selectedBgView.ss_y = space
                self.selectedBgView.layer.cornerRadius = self.bgCornerRadious ?? (self.bgHeight / 2)
                button.isSelected = true
                self.buttons.filter({$0 != button}).forEach({$0.isSelected = false})
            }
            
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
                    changeFrame()
                }
            } else {
                changeFrame()
            }
           
          
        }
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
