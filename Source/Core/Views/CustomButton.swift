//
//  SSCustomButton.swift
//  
//
//  Created by yangsq on 2020/10/31.
//

import UIKit

open class CustomButton: Button {
   public enum ContentType {
        case leftImageRigthText(space: CGFloat = 6, autoSize: Bool)
        case topImageBottomText(space: CGFloat = 6, autoSize: Bool = false)
        case leftTitleRigthImage(space: CGFloat = 6, autoSize: Bool)
        case topTextBottomImage(space: CGFloat = 6, autoSize: Bool = false)
       var space: CGFloat {
           switch self {
           case .leftImageRigthText(let space, _): return space
           case .topImageBottomText(let space, _): return space
           case .leftTitleRigthImage(let space, _): return space
           case .topTextBottomImage(let space, _): return space

           }
       }
    }
    
    public enum Aligentment {
        case top, left, bottom, right, center
    }
    
    public var imageOrigin: CGPoint? {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    public var titleLabelOrigin: CGPoint? {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    /// tileLabel 会自动跟随
    public var imageOriginAutoX: CGFloat? = nil

    
    public var titleAligentment: Aligentment = .center {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    
    public var customImageSize: CGSize = .zero
    public var maxWidth: CGFloat? = nil
    public var minHeight: CGFloat? = nil
    public var isDefaultEnabledChang: Bool = true

    open override var isEnabled: Bool {
        didSet {
            if isDefaultEnabledChang {
                self.alpha = isEnabled ? 1 : 0.5
            }
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
            layoutIfNeeded()
        }
    }
   

    public var contentType: ContentType? {
        didSet {
            guard let _ = contentType else { return }
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        
        guard let contentType = contentType else { return }
        switch contentType {
        case .leftImageRigthText(let space, let autoSize):
            
            if autoSize {
                var imageSize = CGSize.zero
                if let image = image(for: state) {
                    imageSize = image.size
                    if !customImageSize.equalTo(.zero) {
                        imageSize = customImageSize
                    }
                }
                var titleSize = CGSize.zero
                if let titleLabel = titleLabel  {
                    if maxWidth == nil {
                        titleLabel.sizeToFit()
                        titleSize = titleLabel.ss_size
                    } else {
                        titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth!, height: CGFloat(MAXFLOAT)))
                    }
                    
                }
                
                var height = max(imageSize.height, titleSize.height) + contentEdgeInsets.top + contentEdgeInsets.bottom
                if let minHeight = minHeight,  height < minHeight {
                    height = max(minHeight, height)
                }
                let width = imageSize.width + space + titleSize.width + contentEdgeInsets.left + contentEdgeInsets.right
                self.contentSize = CGSize(width: width, height: height)
                invalidateIntrinsicContentSize()
                if let imageView = imageView {
                    imageView.frame = CGRect(x: contentEdgeInsets.left, y: (height - imageSize.height)/2, width: imageSize.width, height: imageSize.height)
                }
                
                if let titleLabel = titleLabel {
                    titleLabel.frame = CGRect(x: contentEdgeInsets.left + imageSize.width + space, y: (height - titleSize.height)/2, width: titleSize.width, height: titleSize.height)
                }
                
                
                
            } else {
                var imageSize = CGSize.zero
                if let image = image(for: state) {
                    imageSize = image.size
                    if !customImageSize.equalTo(.zero) {
                        imageSize = customImageSize
                    }
                }
                var titleSize = CGSize.zero
                if let titleLabel = titleLabel  {
                    if maxWidth == nil {
                        titleLabel.sizeToFit()
                        titleSize = titleLabel.ss_size
                    } else {
                        titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth!, height: CGFloat(MAXFLOAT)))
                    }
                }

                let totalWidth = imageSize.width + space + titleSize.width
                var titleLabelX: CGFloat = 0
                if let imageView = imageView {
                    imageView.frame = CGRect(x: (ss_w - totalWidth)/2, y: (ss_h - imageSize.height)/2, width: imageSize.width, height: imageSize.height)
                    titleLabelX = imageView.frame.maxX + space
                }

                if let titleLabel = titleLabel {
                    titleLabel.frame = CGRect(x: titleLabelX, y: (ss_h - titleSize.height)/2, width: titleSize.width, height: titleSize.height)
                }
                

            }
            
        case .leftTitleRigthImage(let space, let autoSize):
            
            if autoSize {
                var imageSize = CGSize.zero
                if let image = image(for: state) {
                    imageSize = image.size
                    if !customImageSize.equalTo(.zero) {
                        imageSize = customImageSize
                    }
                }
                var titleSize = CGSize.zero
                if let titleLabel = titleLabel  {
                    if maxWidth == nil {
                        titleLabel.sizeToFit()
                        titleSize = titleLabel.ss_size
                    } else {
                        titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth!, height: CGFloat(MAXFLOAT)))
                    }
                }
                
                var height = max(imageSize.height, titleSize.height) + contentEdgeInsets.top + contentEdgeInsets.bottom
                if let minHeight = minHeight,  height < minHeight {
                    height = max(minHeight, height)
                }
                let width = imageSize.width + space + titleSize.width + contentEdgeInsets.left + contentEdgeInsets.right
                self.contentSize = CGSize(width: width, height: height)
                invalidateIntrinsicContentSize()
              
                if let titleLabel = titleLabel {
                    titleLabel.frame = CGRect(x: contentEdgeInsets.left, y: (height - titleSize.height)/2, width: titleSize.width, height: titleSize.height)
                }
                
                if let imageView = imageView {
                    imageView.frame = CGRect(x: contentEdgeInsets.left + titleSize.width + space, y: (height - imageSize.height)/2, width: imageSize.width, height: imageSize.height)
                }
                
                
                
            } else {
                var imageSize = CGSize.zero
                if let image = image(for: state) {
                    imageSize = image.size
                    if !customImageSize.equalTo(.zero) {
                        imageSize = customImageSize
                    }
                }
                var titleSize = CGSize.zero
                if let titleLabel = titleLabel  {
                    if maxWidth == nil {
                        titleLabel.sizeToFit()
                        titleSize = titleLabel.ss_size
                    } else {
                        titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth!, height: CGFloat(MAXFLOAT)))
                    }
                }

                let totalWidth = imageSize.width + space + titleSize.width
                var titleLabelX: CGFloat = 0
                
                if let titleLabel = titleLabel {
                    titleLabel.frame = CGRect(x: (ss_w - totalWidth)/2, y: (ss_h - titleSize.height)/2, width: titleSize.width, height: titleSize.height)
                    titleLabelX = titleLabel.frame.maxX + space

                }
                
                if let imageView = imageView {
                    imageView.frame = CGRect(x: titleLabelX, y: (ss_h - imageSize.height)/2, width: imageSize.width, height: imageSize.height)
                }

                

            }
            
        case .topImageBottomText(let space, let autoSize):
            
            if autoSize {
                var imageSize = CGSize.zero
                var totalHeight: CGFloat = 0
                if let image = image(for: state) {
                    imageSize = image.size
                    if !customImageSize.equalTo(.zero) {
                        imageSize = customImageSize
                    }
                    totalHeight += imageSize.height
                }
                var titleSize = CGSize.zero
                if let titleLabel = titleLabel  {
                    if maxWidth == nil {
                        titleLabel.sizeToFit()
                        titleSize = titleLabel.ss_size
                    } else {
                        titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth!, height: CGFloat(MAXFLOAT)))
                    }
                    totalHeight += space
                    totalHeight += titleSize.height
                }
                
                var height = totalHeight + contentEdgeInsets.top + contentEdgeInsets.bottom
                if let minHeight = minHeight,  height < minHeight {
                    height = max(minHeight, height)
                }
                let width = max(titleSize.width, imageSize.width) + contentEdgeInsets.left + contentEdgeInsets.right
                self.contentSize = CGSize(width: width, height: height)
                invalidateIntrinsicContentSize()
                
                var maxY = (height - titleSize.height)/2
                if let imageView = imageView {
                    imageView.frame = CGRect(x: (width - imageSize.width)/2 , y: (height - totalHeight)/2, width: imageSize.width, height: imageSize.height)
                    maxY = imageView.frame.maxY + space
                }
                
                
                if let titleLabel = titleLabel {
                    titleLabel.frame = CGRect(x: (width - titleSize.width)/2, y: maxY, width: titleSize.width, height: titleSize.height)
                }
                
            } else {
                var imageSize = CGSize.zero
                var totalHeight: CGFloat = 0
                if let image = image(for: state) {
                    imageSize = image.size
                    if !customImageSize.equalTo(.zero) {
                        imageSize = customImageSize
                    }
                    totalHeight += imageSize.height
                }
                var titleSize = CGSize.zero
                if let titleLabel = titleLabel  {
                    if maxWidth == nil {
                        titleLabel.sizeToFit()
                        titleSize = titleLabel.ss_size
                    } else {
                        titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth!, height: CGFloat(MAXFLOAT)))
                    }
                    totalHeight += space
                    totalHeight += titleSize.height
                }
                
                var maxY = (ss_h - titleSize.height)/2
                if let imageView = imageView {
                    imageView.frame = CGRect(x: (ss_w - imageSize.width)/2 , y: (ss_h - totalHeight)/2, width: imageSize.width, height: imageSize.height)
                    maxY = imageView.frame.maxY + space
                }
                
                if let titleLabel = titleLabel {
                    titleLabel.frame = CGRect(x: (ss_w - titleSize.width)/2, y: maxY, width: titleSize.width, height: titleSize.height)
                }
            }
            
            
        case .topTextBottomImage(let space, let autoSize):
            
            if autoSize {
                var imageSize = CGSize.zero
                var totalHeight: CGFloat = 0
                if let image = image(for: state) {
                    imageSize = image.size
                    if !customImageSize.equalTo(.zero) {
                        imageSize = customImageSize
                    }
                    totalHeight += imageSize.height
                }
                var titleSize = CGSize.zero
                if let titleLabel = titleLabel  {
                    if maxWidth == nil {
                        titleLabel.sizeToFit()
                        titleSize = titleLabel.ss_size
                    } else {
                        titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth!, height: CGFloat(MAXFLOAT)))
                    }
                    totalHeight += space
                    totalHeight += titleSize.height
                }
                
                var height = totalHeight + contentEdgeInsets.top + contentEdgeInsets.bottom
                if let minHeight = minHeight,  height < minHeight {
                    height = max(minHeight, height)
                }
                let width = max(titleSize.width, imageSize.width) + contentEdgeInsets.left + contentEdgeInsets.right
                self.contentSize = CGSize(width: width, height: height)
                invalidateIntrinsicContentSize()
                
                var maxY = (height - imageSize.height)/2
                if let titleLabel = titleLabel {
                    titleLabel.frame = CGRect(x: (width - titleSize.width)/2, y: (height - totalHeight)/2, width: titleSize.width, height: titleSize.height)
                    maxY = titleLabel.frame.maxY + space
                }
                
                if let imageView = imageView {
                    imageView.frame = CGRect(x: (width - imageSize.width)/2 , y: maxY, width: imageSize.width, height: imageSize.height)
                    
                }
                
                
                
                
            } else {
                var imageSize = CGSize.zero
                var totalHeight: CGFloat = 0
                if let image = image(for: state) {
                    imageSize = image.size
                    if !customImageSize.equalTo(.zero) {
                        imageSize = customImageSize
                    }
                    totalHeight += imageSize.height
                }
                var titleSize = CGSize.zero
                if let titleLabel = titleLabel  {
                    if maxWidth == nil {
                        titleLabel.sizeToFit()
                        titleSize = titleLabel.ss_size
                    } else {
                        titleSize = titleLabel.sizeThatFits(CGSize(width: maxWidth!, height: CGFloat(MAXFLOAT)))
                    }
                    totalHeight += space
                    totalHeight += titleSize.height
                }
                
                var maxY = (ss_h - imageSize.height)/2
                
                if let titleLabel = titleLabel {
                    titleLabel.frame = CGRect(x: (ss_w - titleSize.width)/2, y: (ss_h - totalHeight)/2, width: titleSize.width, height: titleSize.height)
                    maxY = titleLabel.frame.maxY + space
                }
                
                if let imageView = imageView {
                    imageView.frame = CGRect(x: (ss_w - imageSize.width)/2 , y: maxY, width: imageSize.width, height: imageSize.height)
                }
             
            }
        }
        
      
        
        if let imageOrigin = imageOrigin , var imageV = imageView {
            imageV.ss_origin = CGPoint(x: imageOrigin.x + contentEdgeInsets.left, y: imageOrigin.y + contentEdgeInsets.top)
            if titleAligentment == .center {
                titleLabel?.ss_center = CGPoint(x: ss_w / 2, y: ss_h / 2)
            }
        }
    
        if let titleLabelOrigin = titleLabelOrigin, var titleLabel = titleLabel {
            titleLabel.ss_origin = CGPoint(x: titleLabelOrigin.x + contentEdgeInsets.left, y: titleLabelOrigin.y + contentEdgeInsets.top)
        }
        
        if let imageOriginAutoX = imageOriginAutoX, var imageV = imageView {
            imageV.ss_x = imageOriginAutoX
            titleLabel?.ss_x = imageV.ss_maxX + contentType.space
        }
    }
    
    open override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    open override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        setNeedsLayout()
        setNeedsDisplay()
    }
    
   
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


open class GradientCustomButton: CustomButton {
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    public var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    public var selectedGradientColors: [CGColor]?
    public var normalGradientColors: [CGColor]? {
        didSet {
            if !isSelected {
                gradientLayer.colors = normalGradientColors
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.hex(0x2D8BFF).cgColor, UIColor.hex(0x2080FF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
    
    open override var isSelected: Bool {
        didSet {
            if let selectedGradientColors = selectedGradientColors {
                if isSelected {
                    gradientLayer.colors = selectedGradientColors

                } else {
                    gradientLayer.colors = normalGradientColors

                }
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
