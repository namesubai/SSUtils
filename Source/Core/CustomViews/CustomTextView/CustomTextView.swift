//
//  CustomTextView.swift
//  
//
//  Created by yangsq on 2020/11/3.
//

import UIKit

class CustomTextView: View {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            layoutIfNeeded()
        }
    }
    override var backgroundColor: UIColor? {
        didSet{
            if textView != nil {
                textView.backgroundColor = self.backgroundColor
            }
        }
    }
    var textView: UITextView!
    var lengthLab: UILabel!
    lazy var placeholderLab: UILabel = {
        let label = UILabel.makeLabel(textColor: Colors.detailText,
                                      font: Fonts.medium(15),
                                      numberOfLines: 0)
        self.addSubview(label)
        return label
    
    }()
    var maxLength: Int = 0 {
        didSet {
            lengthLab.text = "0/\(maxLength)"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        textView = UITextView()
        textView.delegate = self
        textView.font = Fonts.medium( 15)
        textView.textColor = Colors.subTitle
        addSubview(textView)
        
        lengthLab = UILabel.makeLabel(textColor:UIColor.hex(0xBCBEC3),
                                        font: Fonts.medium(14),
                                        alignment: .right)
        addSubview(lengthLab)
        maxLength = 400
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
            _ in
            guard let self = self else { return }
            self.setNeedsLayout()
        }).disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLab.frame = CGRect(x: padding.left, y: padding.top, width: self.bounds.width - padding.left - padding.right, height: 0)
        placeholderLab.sizeToFit()
        lengthLab.sizeToFit()
        lengthLab.frame = CGRect(x: self.bounds.width - 10 - lengthLab.ss_w, y: self.bounds.height - 6.5 - lengthLab.ss_h, width: lengthLab.ss_w, height: lengthLab.ss_h)
        textView.frame = CGRect(x: padding.left - 5,
                                y: padding.top - 5,
                                width: self.bounds.width - (padding.left - 5 + padding.right),
                                height: self.bounds.height - 20 - 6.5 - (padding.top - 5 + padding.bottom))
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

extension CustomTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var string = textView.text! as NSString
        string = string.replacingCharacters(in: range, with: text) as NSString
        if string.length > maxLength {
            return false
        }
        return true
    }
   
}
