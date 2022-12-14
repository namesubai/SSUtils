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
public let kOnlyShowOneHudTag = 999888
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
    
    case custom(customView: UIView & SSProgressCustom)
    
    var isLoadAndText: Bool {
        switch self {
        case .loadAndText:
            return true
        default:
            return false
        }
    }
    
    var isLoadOnly: Bool {
        switch self {
        case .loadOnly:
            return true
        default:
            return false
        }
    }
    
    var isTexOnly: Bool {
        switch self {
        case .texOnly:
            return true
        default:
            return false
        }
    }
    
    var isImage: Bool {
        switch self {
        case .image:
            return true
        default:
            return false
        }
    }
    
    var isProgressValue: Bool {
        switch self {
        case .progressValue:
            return true
        default:
            return false
        }
    }
    
    var isCustom: Bool {
        switch self {
        case .custom:
            return true
        default:
            return false
        }
    }
    
}

///风格
public enum SSProgressHUDStyle {
    ///白色风格
    case white
    ///黑色风格
    case black
    
    /// 透明
    case clear
    /// 自定义
    case custom(color: UIColor)
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
    case .clear:
        return UIColor.black
    case .custom(let color):
        return UIColor.white
    }
}

fileprivate func customBackgroundColor(_ style: SSProgressHUDStyle) -> UIColor {
    switch style {
    case .white:
        return UIColor.white
    case .black:
        return UIColor.black.withAlphaComponent(0.8)
    case .clear:
        return UIColor.clear
    case .custom(let color):
        return color
    }
    
}




public protocol SSProgressCustom {
    var text: String? { get set }
    var textColor: UIColor? { get set}
    var textFont: UIFont? { get  set}
    var customSize: CGSize { get set}
    var image: UIImage? { get  set}
    var progress: CGFloat? { get set }
}

public extension SSProgressCustom {
    var progress: CGFloat? {
        get {
            return nil
        }
        
        set {
            
        }
    }
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
    var loadingView: UIView? = nil
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
            if let loadingView = SSProgressHUDConfig.defaultCustomLoading?() {
                self.loadingView =  loadingView
            } else {
                if #available(iOS 13.0, *) {
                    let activityIndicatorView = UIActivityIndicatorView(style: .large)
                    activityIndicatorView.color = SSProgressHUDConfig.activityIndicatorColor ?? textColor
                    activityIndicatorView.startAnimating()
                    loadingView =  activityIndicatorView
                } else {
                    let activityIndicatorView =  UIActivityIndicatorView(style: .white)
                    activityIndicatorView.color = SSProgressHUDConfig.activityIndicatorColor ?? textColor
                    activityIndicatorView.startAnimating()
                    loadingView =  activityIndicatorView
                }
               
            }
            if let loadingView = loadingView {
                self.addSubview(loadingView)
                self.setNeedsLayout()
            }
        }
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var selfWidth: CGFloat = 0
        var selfHeight: CGFloat = 0
        var activityIndicatorViewY: CGFloat = 0;
        if let loadingView = loadingView {
            if loadingView.ss_size != .zero {
                loadingView.frame = CGRect(x: (self.frame.size.width - loadingView.ss_w) / 2, y: 0, width: loadingView.ss_w, height: loadingView.ss_h)
            } else {
                loadingView.frame = CGRect(x: (self.frame.size.width - kActivityIndicatorViewSize.width) / 2, y: 0, width: kActivityIndicatorViewSize.width, height: kActivityIndicatorViewSize.height)
            }
            
            selfHeight = loadingView.ss_h
            selfWidth = loadingView.ss_w
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
public struct SSProgressHUDConfig {
    /// loading的默认样式 如果不为nil,默认显示这个loading， 否则显示默认菊花样式
    public static var defaultCustomLoading: (() -> UIView?)? = nil
    /// 背景风格
    public static var defaultHUDStyle: SSProgressHUDStyle?
    /// 文字模式背景颜色
    public static var defaultTextHUDStyle: SSProgressHUDStyle? = .black
    /// loading模式背景颜色
    public static var defaultLoadingHUDStyle: SSProgressHUDStyle? = .black
    public static var defaultLoadingAndTextHUDStyle: SSProgressHUDStyle? = .black

    /// 背景圆角大小
    public static var defaultHUDRadious: CGFloat = 10
    /// 文字提示字体大小
    public static var defaulHUDTextFont: UIFont = UIFont.systemFont(ofSize: 15,weight: .medium)
    /// 文字提示字体颜色
    public static var defaulHUDTextColor: UIColor?
    /// 指示器颜色
    public static var activityIndicatorColor: UIColor?

    /// 内边距
    public static var defaultCustomInsetsEdge: UIEdgeInsets?
    public static var defaultTextOnlyCustomInsetsEdge: UIEdgeInsets?
    public static var defaultLoadingCustomInsetsEdge: UIEdgeInsets?
    public static var defaultLoadingAndTextCustomInsetsEdge: UIEdgeInsets?

}

public class SSProgressHUD: UIView {
    
   lazy var maskBackgroundView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = maskColor(self.maskType)
        maskView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        return maskView
    }()
    
    ///背景视图
    public var maskType = SSProgressHUDMaskType.none
    public var customView: UIView & SSProgressCustom
    public var customEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    private var effectBulrView: UIVisualEffectView
    public var style: SSProgressHUDStyle
    public var mode: SSProgressHUDMode?
    public var isShowEffectBulrView: Bool = false
    
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
                customView = CircleLoadingCustomView(type: .progress)
            case .image:
                customView = SSProgressCustomImageAndTextView.init(frame: .zero)
            case .custom(let cst):
                customView = cst
        }
        self.init(customView:customView, style:style)
       self.mode = mode

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
        self.layer.cornerRadius = SSProgressHUDConfig.defaultHUDRadious
        self.layer.masksToBounds = true
        if let textColor = SSProgressHUDConfig.defaulHUDTextColor {
            self.customView.textColor = textColor
        } else {
            self.customView.textColor = textColor(self.style)
        }
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
            } else {
                switch mode {
                    case .loadOnly:
                        
                        if let defaultStyle = SSProgressHUDConfig.defaultLoadingHUDStyle {
                            self.backgroundColor = customBackgroundColor(defaultStyle)
                        } else {
                            self.backgroundColor = customBackgroundColor(self.style)
                        }
                    case .loadAndText:
                        if let defaultStyle = SSProgressHUDConfig.defaultLoadingAndTextHUDStyle {
                            self.backgroundColor = customBackgroundColor(defaultStyle)
                        } else {
                            self.backgroundColor = customBackgroundColor(self.style)
                        }
                        
                    case .texOnly:
                        if let defaultStyle = SSProgressHUDConfig.defaultHUDStyle {
                            self.backgroundColor = customBackgroundColor(defaultStyle)
                        } else {
                            self.backgroundColor = customBackgroundColor(self.style)
                        }
                    default:
                        self.backgroundColor = customBackgroundColor(self.style)
                }
                
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
        } else {
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
        return self.showHUD(mode: .texOnly, maskType: maskType, text: text, image: nil, autoHide: autoHide, tag: tag, hideFinished: hideFinished)
    }
    ///loading + 文本，主动隐藏
    @discardableResult
    public func showLoadingTextHUD(maskType: SSProgressHUDMaskType = .none, _ text: String? = nil, _ autoHide: Bool = false,  tag: Int = -1, hideFinished: (() -> Void )? = nil) -> SSProgressHUD? {
        if text?.isLength == true {
            return self.showHUD(mode: .loadAndText, maskType: maskType, text: text, image: nil, autoHide: autoHide, tag: tag, hideFinished: hideFinished)
        } else {
            return self.showHUD(mode: .loadOnly, maskType: maskType, text: text, image: nil, autoHide: autoHide, tag: tag, hideFinished: hideFinished)
        }
        
    }
    
    @discardableResult
    public func showLoadingHUD(maskType: SSProgressHUDMaskType = .none, _ text: String? = nil, _ autoHide: Bool = false,  tag: Int = -1, hideFinished: (() -> Void )? = nil) -> SSProgressHUD? {
        return self.showHUD(mode: .loadOnly, maskType: maskType, text: text, image: nil, autoHide: autoHide, tag: tag, hideFinished: hideFinished)
    }
    
    ///loading + 文本，主动隐藏
    @discardableResult
    public func showImageTextHUD(maskType: SSProgressHUDMaskType = .none, _ image: UIImage, _ text: String, _ autoHide: Bool = true,  tag: Int = -1, hideFinished: (() -> Void )? = nil)  -> SSProgressHUD? {
        return self.showHUD(mode: .image, maskType: maskType, text: text, image: image, autoHide: autoHide, tag: tag, hideFinished: hideFinished)
    }
    
    @discardableResult
    public func showProgress(maskType: SSProgressHUDMaskType = .none, tag: Int = -1, hideFinished: (() -> Void )? = nil)  -> SSProgressHUD? {
        return self.showHUD(mode: .progressValue, maskType: maskType, tag: tag, hideFinished: hideFinished)
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
       
        for index in 0..<self.progressHUDArray.count {
            let (t, view) = self.progressHUDArray[index]
            if t == tag {
                view.hideHUD(completion: {
                    hideFinished?()
                    self.progressHUDArray.removeAll(where: {$0.1 == view})
                })
            }
        }
        
        
    }
    
    @discardableResult
    public func showHUD(mode: SSProgressHUDMode, maskType: SSProgressHUDMaskType = .none, style: SSProgressHUDStyle = .black, text: String? = nil, image: UIImage? = nil, autoHide: Bool = false,  tag: Int = -1, hideFinished: (() -> Void )? = nil) -> SSProgressHUD?  {
       
        if tag == kOnlyShowOneHudTag, self.progressHUDArray.contains(where: {$0.0 == kOnlyShowOneHudTag}) {
            return nil
        }
        if mode.isTexOnly  {
            if text == nil {
                return nil
            }else {
                if text!.count == 0 {
                    return nil
                }
            }
        }
        
        let hud = SSProgressHUD(mode: mode)
        if let hudStyle = SSProgressHUDConfig.defaultHUDStyle {
            hud.style = hudStyle
        } else {
            hud.style = style
        }
        
        
        if let customEdgeInsets = SSProgressHUDConfig.defaultCustomInsetsEdge {
            hud.customEdgeInsets = customEdgeInsets

        } else {
            
            if mode.isTexOnly {
                hud.customEdgeInsets = SSProgressHUDConfig.defaultTextOnlyCustomInsetsEdge ?? UIEdgeInsets(top: 23.wScale, left: 20.wScale, bottom: 23.wScale, right: 20.wScale)
            } else if mode.isImage {
                UIEdgeInsets(top: 23.wScale, left: 20.wScale, bottom: 23.wScale, right: 20.wScale)
            } else if mode.isLoadOnly {
                hud.customEdgeInsets = SSProgressHUDConfig.defaultLoadingCustomInsetsEdge ??  UIEdgeInsets(top: 30.wScale, left: 30.wScale, bottom: 30.wScale, right: 30.wScale)
            } else if mode.isLoadAndText {
                hud.customEdgeInsets = SSProgressHUDConfig.defaultLoadingAndTextCustomInsetsEdge ??  UIEdgeInsets(top: 30.wScale, left: 30.wScale, bottom: 30.wScale, right: 30.wScale)
            } else {
                hud.customEdgeInsets = UIEdgeInsets(top: 30.wScale, left: 30.wScale, bottom: 30.wScale, right: 30.wScale)
            }
          
        }
        
        hud.customView.text = text
        hud.customView.image = image
        hud.maskType = maskType
        if let text = text,text.count > 0 {
            
            let line = text.stringLineCount(font: UIFont.systemFont(ofSize: 15, weight: .medium), width: kTextLabelMaxWidth)
            hud.customView.textFont = SSProgressHUDConfig.defaulHUDTextFont
        }
//        var tag = tag
//        if tag == -1 && (!mode.isLoadAndText && !mode.isLoadOnly) {
//            tag = -2
//        }
        
        hud.showHUD(onView: self)
        self.progressHUDArray.append((tag,hud))

        if autoHide {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hideHUD(tag: tag, hideFinished: hideFinished)
            }
        }
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
