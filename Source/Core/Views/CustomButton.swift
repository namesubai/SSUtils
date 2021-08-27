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
    }
    var imageCenter: CGPoint?
    var imageOriginX: CGFloat?
    var titleLabelCneter: CGPoint?
    var titleLabelOriginX: CGFloat?
    var contentSize: CGSize = .zero
    var customImageSize: CGSize = .zero
    
    open override var isEnabled: Bool {
        didSet {
            self.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            setNeedsDisplay()
            layoutIfNeeded()
        }
    }
   

    var contentType: ContentType? {
        didSet {
            guard let _ = contentType else { return }
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    var autoCornerRadious: Bool = false
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let imageCenter = imageCenter, let imageView = imageView{
            imageView.center = imageCenter
        }
        
        if let imageOriginX = imageOriginX, let imageView = imageView{
            imageView.ss_x = imageOriginX
        }
        
        if let titleLabelCenter = titleLabelCneter, let titleLabel = titleLabel{
            titleLabel.center = titleLabelCenter
        }
        if let titleLabelOriginX = titleLabelOriginX, let titleLabel = titleLabel{
            titleLabel.ss_x = titleLabelOriginX
        }
        
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
                    titleLabel.sizeToFit()
                    titleSize = titleLabel.ss_size
                }
                
                let height = max(imageSize.height, titleSize.height) + contentEdgeInsets.top + contentEdgeInsets.bottom
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
                    titleLabel.sizeToFit()
                    titleSize = titleLabel.ss_size
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
                    titleLabel.sizeToFit()
                    titleSize = titleLabel.ss_size
                }
                
                let height = max(imageSize.height, titleSize.height) + contentEdgeInsets.top + contentEdgeInsets.bottom
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
                    titleLabel.sizeToFit()
                    titleSize = titleLabel.ss_size
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
                    titleLabel.sizeToFit()
                    titleSize = titleLabel.ss_size
                    totalHeight += space
                    totalHeight += titleSize.height
                }
                
                let height = totalHeight + contentEdgeInsets.top + contentEdgeInsets.bottom
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
                    titleLabel.sizeToFit()
                    titleSize = titleLabel.ss_size
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
                    titleLabel.sizeToFit()
                    titleSize = titleLabel.ss_size
                    totalHeight += space
                    totalHeight += titleSize.height
                }
                
                let height = totalHeight + contentEdgeInsets.top + contentEdgeInsets.bottom
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
                    titleLabel.sizeToFit()
                    titleSize = titleLabel.ss_size
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
        
        if autoCornerRadious {
            layer.cornerRadius = ss_h / 2
            layer.masksToBounds = true
        }
    
    }
    
    open override var intrinsicContentSize: CGSize {
        if self.contentSize != .zero {
            return self.contentSize
        }
        return super.intrinsicContentSize
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
    var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.hex(0x2D8BFF).cgColor, UIColor.hex(0x2080FF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
