//
//  SSProgressHUD.swift
//  SSHUD
//
//  Created by yangsq on 2019/10/25.
//  Copyright © 2019 Aiagain. All rights reserved.
//

import UIKit


fileprivate let kActivityIndicatorViewSize = CGSize(width: 28, height: 28)
fileprivate let kActivityIndicatorViewAndTextSpace: CGFloat = 10
fileprivate let kTextLabelMaxWidth = UIScreen.main.bounds.size.width * 0.6
fileprivate let kCustomViewCornerRadius: CGFloat = 10
///遮罩视图类型
public enum  SSProgressHUDMaskType{
    ///默认没有背景
    case none
    ///透明背景
    case clear
    ///黑色背景
    case black
}

///展示类型
public enum SSProgressHUDMode {
    
    ///loading  和文字
    case  loadAndText
    ///只有loding
    case  loadOnly
    ///只有文字
    case  texOnly
     ///进度条
    case  progressValue
     ///图标
    case  image
}

///风格
public enum SSProgressHUDStyle {
    ///白色风格
    case white
    ///黑色风格
    case black
}


fileprivate func maskColor(_ masktype: SSProgressHUDMaskType) -> UIColor? {
    switch masktype {
    case .none:
        return nil
    case .clear:
        return UIColor.clear
    case .black:
        return UIColor.black.withAlphaComponent(0.3)
    }
}

fileprivate func textColor(_ style: SSProgressHUDStyle) -> UIColor {
    switch style {
    case .white:
        return UIColor.black
    case .black:
        return UIColor.white
    }
}

fileprivate func customBackgroundColor(_ style: SSProgressHUDStyle) -> UIColor {
    switch style {
    case .white:
        return UIColor.white
    case .black:
        return UIColor.black.withAlphaComponent(0.8)
    }
}




public protocol SSProgressCustom {
    var text: String? { get set }
    var textColor: UIColor? { get set}
    var textFont: UIFont? { get  set}
    var customSize: CGSize { get set}
    var image: UIImage? { get  set}
}


fileprivate extension UIView {
   func removeAllSubView()  {
        for v in self.subviews {
            v.removeFromSuperview()
        }
    }
}

// MARK: Load And TEXT

enum CustomLoadTextMode {
    case loadAndText
    case loadOnly
    case textOnly
}

class ProgressCustomLoadTextView: UIView & SSProgressCustom {
    var text: String? {
        
        get {
            return _text
        }
        set {
            _text = newValue
            self.updateViews()
        }
        
    }
    
   
    var textColor: UIColor? {
        get {
            return _textColor
        }
        set {
            _textColor = newValue
            self.updateViews()
        }
    }
    var textFont: UIFont? {
        get {
            return _textFont
        }
        set {
            _textFont = newValue
            self.updateViews()
        }
    }
    var customSize: CGSize {
        get {
            return _customSize
        }
        set {
            _customSize = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return _image
        }
        set {
            _image = newValue
        }
        
    }
    
    private var _text: String? = nil
    private var _textColor: UIColor? = UIColor.white
    private var _textFont: UIFont? = UIFont.systemFont(ofSize: 15,weight: .medium)
    private var _customSize: CGSize = .zero
    private var _image: UIImage? = nil
    
    var textLabel: UILabel? = nil
    var activityIndicatorView: UIActivityIndicatorView? = nil
    var mode: CustomLoadTextMode
    
    init(mode:CustomLoadTextMode) {
        self.mode = mode
        super.init(frame:.zero)
        self.updateViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func updateViews() {
        self.removeAllSubView()
        if self.mode == .loadAndText || self.mode == .textOnly {
            textLabel = UILabel(frame: .zero)
            textLabel!.numberOfLines = 0;
            textLabel!.text = _text
            textLabel!.textColor = _textColor
            textLabel!.font = _textFont
            textLabel!.adjustsFontSizeToFitWidth = false
            textLabel!.isOpaque = false
            self.addSubview(textLabel!)
        }
        
        if self.mode == .loadAndText || self.mode == .loadOnly {
            if #available(iOS 13.0, *) {
                activityIndicatorView =  UIActivityIndicatorView(style: .large)
                activityIndicatorView?.color = UIColor.white
            } else {
                activityIndicatorView =  UIActivityIndicatorView(style: .white)
            }
            activityIndicatorView?.color = textColor
            activityIndicatorView!.startAnimating()
            self.addSubview(activityIndicatorView!)
            self.setNeedsLayout()
        }
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var selfWidth: CGFloat = 0
        var selfHeight: CGFloat = 0
        var activityIndicatorViewY: CGFloat = 0;
        if let activityIndicatorView = activityIndicatorView {
            activityIndicatorView.frame = CGRect(x: (self.frame.size.width - kActivityIndicatorViewSize.width) / 2, y: 0, width: kActivityIndicatorViewSize.width, height: kActivityIndicatorViewSize.height)
            selfHeight = kActivityIndicatorViewSize.height
            selfWidth = kActivityIndicatorViewSize.width
            activityIndicatorViewY += kActivityIndicatorViewAndTextSpace + selfHeight
        }
        
        
        if let textLabel = textLabel, let _ = _text {
            let textSize = textLabel.sizeThatFits(CGSize(width: kTextLabelMaxWidth, height: CGFloat(MAXFLOAT)))
            textLabel.frame = CGRect(x: (self.frame.size.width - textSize.width) / 2, y: activityIndicatorViewY, width: textSize.width, height: textSize.height)
            selfHeight  =  textSize.height + activityIndicatorViewY
            selfWidth = max(kActivityIndicatorViewSize.width, textSize.width)
        }
                
        _customSize = CGSize(width: selfWidth, height: selfHeight)
        self.superview!.setNeedsLayout()
    }
  
}


// MARK: image
class SSProgressCustomImageAndTextView: UIView & SSProgressCustom {
    var text: String? {
        get {
            return _text
        }
        set {
            _text = newValue
            self.updateViews()
        }
    }
    
    var textColor: UIColor? {
        get {
            return _textColor
        }
        set {
            _textColor = newValue
            self.updateViews()
        }
    }
    
    var textFont: UIFont? {
        get {
            return _textFont
        }
        set {
            _textFont = newValue
            self.updateViews()
        }
    }
    
    var customSize: CGSize {
        get {
            _customSize
        }
        set {
            _customSize = .zero
        }
    }
    
    var image: UIImage? {
        get {
            return _image
        }
        set {
            _image = newValue
            self.imageView.image = _image
            self.setNeedsLayout()
        }
    }
    
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var _image: UIImage? = nil
    var imageView: UIImageView = {
        let imageview = UIImageView(frame: .zero)
        return imageview
    }()
    var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = kTextLabelMaxWidth
        return label
    }()
    private var _text: String? = nil
    private var _customSize: CGSize = .zero
    private var _textFont: UIFont? = UIFont.systemFont(ofSize: 15, weight: .medium)
    private var _textColor: UIColor? = UIColor.white
    
    override init(frame: CGRect) {
           
        super.init(frame: frame)
        self.updateViews()
    }
    
    private func updateViews() {
        self.removeAllSubView()
        if let text = _text {
            self.addSubview(self.textLabel)
            self.textLabel.text = text
            self.textLabel.font = _textFont
            self.textLabel.textColor = _textColor
        }
        self.addSubview(self.imageView)
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        var selfWidth: CGFloat = 0
        var selfHeight: CGFloat = 0
        var activityIndicatorViewY: CGFloat = 0
        var imageWidth: CGFloat = 0
        if let image = _image {
            self.imageView.frame = CGRect(x: (self.frame.width - image.size.width) / 2.0, y: 0, width: image.size.width, height: image.size.height)
            selfWidth = image.size.width
            activityIndicatorViewY += kActivityIndicatorViewAndTextSpace + image.size.height
            imageWidth = image.size.width
        }
        
        
        if let _ = _text {
            let textSize = textLabel.sizeThatFits(CGSize(width: kTextLabelMaxWidth, height: CGFloat(MAXFLOAT)))
            textLabel.frame = CGRect(x: (self.frame.size.width - textSize.width) / 2, y: activityIndicatorViewY, width: textSize.width, height: textSize.height)
            selfHeight += activityIndicatorViewY + textSize.height
            selfWidth = max(imageWidth, textSize.width)
        }
                
        _customSize = CGSize(width: selfWidth, height: selfHeight)
        self.superview!.setNeedsLayout()
  
    }
    
}





// MARK: SSProgressHUD

public class SSProgressHUD: UIView {
    
   lazy var maskBackgroundView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = maskColor(self.maskType)
        maskView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return maskView
    }()
    
    ///背景视图
    var maskType = SSProgressHUDMaskType.none
    var customView: UIView & SSProgressCustom
    var customEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    private var effectBulrView: UIVisualEffectView
    private var style: SSProgressHUDStyle
    
    var isShowEffectBulrView: Bool = false
    
   public convenience init(mode:SSProgressHUDMode, style: SSProgressHUDStyle = .black) {
        var customView: UIView & SSProgressCustom
        switch mode {
            case .loadAndText:
                       customView = ProgressCustomLoadTextView.init(mode: .loadAndText)
            case .loadOnly:
                       customView = ProgressCustomLoadTextView.init(mode: .loadOnly)
            case .texOnly:
                       customView = ProgressCustomLoadTextView.init(mode: .textOnly)
            case .progressValue:
                       customView = ProgressCustomLoadTextView.init(mode: .loadOnly)
            case .image:
                customView = SSProgressCustomImageAndTextView.init(frame: .zero)
        }
        self.init(customView:customView, style:style)
    }
    
  
  public init(customView: UIView & SSProgressCustom, style: SSProgressHUDStyle) {
        self.customView = customView
        self.style = style
        ///
        let effect = UIBlurEffect.init(style: .light)
        self.effectBulrView =  UIVisualEffectView.init(effect: effect)
        self.effectBulrView.layer.masksToBounds = true
        self.effectBulrView.backgroundColor = customBackgroundColor(self.style)
        super.init(frame: .zero)
        self.layer.cornerRadius = kCustomViewCornerRadius
        self.layer.masksToBounds = true
        self.customView.textColor = textColor(self.style)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.customView.frame = CGRect(x: self.customEdgeInsets.left, y: self.customEdgeInsets.top, width: self.customView.customSize.width, height: self.customView.customSize.height)
        
        let selfWidth = self.customView.customSize.width + self.customEdgeInsets.left + self.customEdgeInsets.right
        let selfHeight = self.customView.customSize.height + self.customEdgeInsets.top + self.customEdgeInsets.bottom
        let selfX = ((self.superview?.frame.width)! - selfWidth ) / 2.0
        let selfY = ((self.superview?.frame.height)! - selfHeight ) / 2.0
        self.frame = CGRect(x: selfX, y: selfY, width: selfWidth, height: selfHeight)
        self.effectBulrView.frame = CGRect(x: 0, y: 0, width: selfWidth, height: selfHeight)
//        self.maskBackgroundView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    ///显示
   public func showHUD(onView: UIView?, animation: Bool = true)  {
        if let view = onView  {
            if self.maskType != .none {
                self.maskBackgroundView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height:  view.frame.size.height)
                view.addSubview(self.maskBackgroundView)
            }
            view.addSubview(self)
            if isShowEffectBulrView {
                self.addSubview(self.effectBulrView)
            }else {
                self.backgroundColor = customBackgroundColor(self.style)
            }
            self.addSubview(self.customView)
            if animation {
                self.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    self.alpha = 1.0
                }
            }
        }
    }
    
    ///隐藏，移除
   public func hideHUD(animation:Bool = true,completion: (() -> Void)? = nil) {
        if animation {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0.0
                self.maskBackgroundView.alpha = 0
            }) { (finish) in
                self.removeFromSuperview()
                self.maskBackgroundView.removeFromSuperview()
                if let c = completion {
                    c()
                }
            }
        }else {
            self.alpha = 0.0
            self.removeFromSuperview()
            self.maskBackgroundView.alpha = 0
            self.maskBackgroundView.removeFromSuperview()
            if let c = completion {
                c()
            }
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


fileprivate var kProgressHUDDictKey: UInt8 = 0


extension UIView {
        
    var progressHUDArray: [(Int,SSProgressHUD)] {
        get {
            var c = objc_getAssociatedObject(self, &kProgressHUDDictKey)
            if c == nil {
              objc_setAssociatedObject(self, &kProgressHUDDictKey, [(Int, SSProgressHUD)](), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
               c = objc_getAssociatedObject(self, &kProgressHUDDictKey)
            }
            return c as! [(Int, SSProgressHUD)]
        }
        
        set {
            
            objc_setAssociatedObject(self, &kProgressHUDDictKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
    
    
    ///文本，自动移除
    @discardableResult
    public func showTextHUD(maskType: SSProgressHUDMaskType = .none, _ text: String? = nil, _ autoHide: Bool = true, tag: Int = -1, hideFinished: (() -> Void )? = nil) -> SSProgressHUD? {
        return self.showHUD(mode: .texOnly, maskType: maskType, text: text, image: nil, autoHide: autoHide, hideFinished: hideFinished)
    }
    ///loading + 文本，主动隐藏
    @discardableResult
    public func showLoadingTextHUD(maskType: SSProgressHUDMaskType = .none, _ text: String? = nil, _ autoHide: Bool = false,  tag: Int = -1, hideFinished: (() -> Void )? = nil) -> SSProgressHUD? {
        return self.showHUD(mode: .loadAndText, maskType: maskType, text: text, image: nil, autoHide: autoHide, hideFinished: hideFinished)
    }
    
    ///loading + 文本，主动隐藏
    @discardableResult
    public func showImageTextHUD(maskType: SSProgressHUDMaskType = .none, _ image: UIImage, _ text: String, _ autoHide: Bool = true,  tag: Int = -1, hideFinished: (() -> Void )? = nil)  -> SSProgressHUD? {
        return self.showHUD(mode: .image, maskType: maskType, text: text, image: image, autoHide: autoHide, hideFinished: hideFinished)
    }
    
    ///隐藏
    public func hideHUD(tag: Int = -1, hideFinished: (() -> Void )? = nil)  {
//        if tag == -1 {
//            for (_, view) in self.progressHUDArray {
//
//                view.hideHUD(completion: hideFinished)
//            }
//
//        }else {
//            for (t, view) in self.progressHUDArray {
//                if t == tag {
//                    view.hideHUD(completion: hideFinished)
//                }
//
//            }
//        }
        
        for (t, view) in self.progressHUDArray {
            if t == tag {
                view.hideHUD(completion: hideFinished)
            }
            
        }
        
    }
    
    
    private  func showHUD(mode: SSProgressHUDMode, maskType: SSProgressHUDMaskType = .none, text: String?, image: UIImage?, autoHide: Bool,  tag: Int = -1, hideFinished: (() -> Void )? = nil) -> SSProgressHUD?  {
        if mode == .texOnly  {
            if text == nil {
                return nil
            }else {
                if text!.count == 0 {
                    return nil
                }
            }
        }
        
        let hud = SSProgressHUD(mode: mode)
        if mode == .texOnly || mode == .image {
            hud.customEdgeInsets = UIEdgeInsets(top: 23.wScale, left: 20.wScale, bottom: 23.wScale, right: 20.wScale)
        }else {
            hud.customEdgeInsets = UIEdgeInsets(top: 30.wScale, left: 30.wScale, bottom: 30.wScale, right: 30.wScale)
        }
        hud.customView.text = text
        hud.customView.image = image
        hud.maskType = maskType
        if let text = text,text.count > 0 {
            
            let line = text.stringLineCount(font: UIFont.systemFont(ofSize: 15, weight: .medium), width: kTextLabelMaxWidth)
            if line == 1 {
                hud.customView.textFont = UIFont.boldSystemFont(ofSize: 15)
            }else {
                hud.customView.textFont = UIFont.systemFont(ofSize: 15, weight: .medium)
            }
        }
        var tag = tag
        if tag == -1 && (mode != .loadAndText && mode != .loadOnly) {
            tag = -2
        }
        hud.showHUD(onView: self)
        
        if autoHide {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hideHUD(tag: -2, hideFinished: hideFinished)
            }
        }
        self.progressHUDArray.append((tag,hud))
        return hud
    }
    
    
    
}


extension String {
    
    func stringLineCount(font: UIFont, width: CGFloat) -> Int {
        if self.count == 0 {
            return 0
        }
        var fontName = font.fontName
        if fontName == ".SFUI-Medium" || fontName == ".SFUI-Regular" {
            fontName = "TimesNewRomanPSMT"
        }
        let font = CTFontCreateWithName(fontName as NSString, font.pointSize, nil)
        let attStr = NSMutableAttributedString(string: self)
        attStr.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: attStr.length))
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0,y: 0, width: width, height: CGFloat(MAXFLOAT)))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame) as NSArray
        return lines.count
    }

}
