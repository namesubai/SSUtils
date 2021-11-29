//
//  CustomTextView.swift
//  
//
//  Created by yangsq on 2020/11/3.
//

import UIKit

open class CustomTextView: View, EventTrigger {
    
    public enum Event {
        case returnAction
    }
    
    public var padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            containerView.snp.remakeConstraints { make in
                make.edges.equalTo(padding).priority(.low)
            }
            layoutIfNeeded()
        }
    }
    public override var backgroundColor: UIColor? {
        didSet{
            if textView != nil {
                textView.backgroundColor = self.backgroundColor
            }
        }
    }
    
    public lazy var containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .trailing
        view.spacing = 0
        return view
    }()
    
    public lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = .zero
        textView.delegate = self
        textView.font = Fonts.medium( 15)
        textView.textColor = Colors.subTitle
        return textView
    }()
    public lazy var lengthLab: UILabel = {
        let lengthLab = UILabel.makeLabel(textColor:UIColor.hex(0xBCBEC3),
                                        font: Fonts.medium(14),
                                        alignment: .right)
        return lengthLab
    }()
    public lazy var placeholderLab: UILabel = {
        let label = UILabel.makeLabel(textColor: Colors.detailText,
                                      font: Fonts.medium(15),
                                      numberOfLines: 0)
        self.addSubview(label)
        return label
    
    }()
    public var maxLength: Int = 0 {
        didSet {
            lengthLab.text = "0/\(maxLength)"
        }
    }
    
    public var isFirstWordCannotEmpty = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        containerView.addArrangedSubview(textView)
        containerView.addArrangedSubview(lengthLab)
        maxLength = 400
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(padding).priority(.low)
        }
        
        textView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
        }
        
        textView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        
       let contentChange =  textView.rx.value.map { (value) -> Bool in
            guard let text = value else { return false }
            return text.count != 0
        }
        contentChange.bind(to: placeholderLab.rx.isHidden).disposed(by: rx.disposeBag)
        
        textView.rx.value.map {
            [weak self]
            (value) -> String in
            guard let self = self else { return "" }
            let text = value ?? "0"
            return "\(text.count)/\(self.maxLength)"
        }.bind(to: lengthLab.rx.text).disposed(by: rx.disposeBag)
        textView.rx.value.subscribe(onNext: {
            [weak self]
            text in
            guard let self = self else { return }
            if self.isFirstWordCannotEmpty, var text = text, text.count > 0 {
                for c in text {
                    if c == " " {
                        text.removeFirst()
                    } else {
                        break
                    }
                }
                self.textView.text = text
            }
            self.setNeedsLayout()
        }).disposed(by: rx.disposeBag)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLab.frame = CGRect(x: padding.left + 5, y: padding.top, width: self.bounds.width - padding.left - padding.right - 5, height: 0)
        placeholderLab.sizeToFit()
//        lengthLab.sizeToFit()
//        lengthLab.frame = CGRect(x: self.bounds.width - 10 - lengthLab.ss_w, y: self.bounds.height - 6.5 - lengthLab.ss_h, width: lengthLab.ss_w, height: lengthLab.ss_h)
//        textView.frame = CGRect(x: padding.left - 5,
//                                y: padding.top - 5,
//                                width: self.bounds.width - (padding.left - 5 + padding.right),
//                                height: self.bounds.height - 20 - 6.5 - (padding.top - 5 + padding.bottom))
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

extension CustomTextView: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var string = textView.text! as NSString
        string = string.replacingCharacters(in: range, with: text) as NSString
        if text == "\n", textView.returnKeyType != .default  {
            if let trigger = self.triggerEvent {
                trigger(.returnAction)
            }
            return false
        }

        if string.length > maxLength {
            textView.text = string.substring(to: maxLength)
            return false
        }
      
      
        return true
    }
   
}
