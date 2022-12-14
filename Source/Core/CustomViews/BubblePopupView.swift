//
//  BubblePopupView.swift
//  HeyWorld
//
//  Created by yangsq on 2022/9/17.
//

import SSUtils

extension BubblePopupView {
    public class Action {
        public var image: UIImage?
        public var title: String?
        public var titleColor: UIColor?
        public var titleFont: UIFont?
        public var space: CGFloat
        public var imageSize: CGSize
        public var height: CGFloat
        public var onTrigger: (() -> Void)?
        init(image: UIImage? = nil,
             title: String? = nil,
             titleColor: UIColor? = UIColor.hex(0xffffff),
             titleFont: UIFont? = Fonts.auto(14.wScale),
             space: CGFloat = 5,
             imageSize: CGSize = .zero,
             height: CGFloat = 35.wScale,onTrigger: (() -> Void)? = nil) {
            self.image = image
            self.title = title
            self.titleColor = titleColor
            self.titleFont = titleFont
            self.space = space
            self.imageSize = imageSize
            self.height = height
            self.onTrigger = onTrigger
        }
    }
    
    public func add(_ action: Action) {
        let button = CustomButton()
        button.setImage(action.image, for: .normal)
        button.setTitle(action.title, for: .normal)
        button.titleLabel?.font = action.titleFont
        button.setTitleColor(action.titleColor, for: .normal)
        button.customImageSize = action.imageSize
        button.contentType = .leftImageRigthText(space: action.space, autoSize: false)
        containView.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(action.height)
        }
        button.rx.tap.subscribe(onNext: {
            action.onTrigger?()
        }).disposed(by: button.rx.disposeBag)
    }
    
    public func add(_ actionTitles: [String], onTrigger: @escaping (Int) -> Void) {
        for index in 0..<actionTitles.count {
            let title = actionTitles[index]
            let action = Action(title: title, onTrigger: {
                [weak self] in guard let self = self else { return }
                onTrigger(index)
                self.hide()
            })
            add(action)
        }
    }
    
    public func customView(_ customView: UIView) {
        containView.addArrangedSubview(customView)
        customView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(0)
        }
    }
}

public extension BubblePopupView {
    /// 三角形在视图的位置
    enum TriangleDirection {
        case bottom
        case top
    }
}

open class BubblePopupView: UIView {
    /// 边框大小
    public var lineWidth: CGFloat = 1
    
    /// 边框颜色
    public var lineColor: UIColor? = UIColor.hex(0xffffff) {
        didSet {
            shapeLayer.strokeColor = lineColor?.cgColor
        }
    }
    
    /// 边框透明度
    public var lineOpacity: Float = 0.25 {
        didSet {
            shapeLayer.opacity = lineOpacity
        }
    }
    
    /// 三角高度
    public var triangleHeight: CGFloat = 6.wScale {
        didSet {
            refreshContainerLayout()
        }
    }
    
    /// 三角宽度
    public var triangleWidth: CGFloat = 10.wScale
    
    /// 圆角
    public var radious: CGFloat = 10.wScale
    
    /// 三角形的在矩形的边的中心点X轴, 默认是矩形边的中心点
    public var triangleCenterX: CGFloat?
    /// 三角形在视图的位置
    public var triangleDirection: TriangleDirection = .bottom
    
    /// 内容内边距
    public var contentSpace: UIEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0).wScale {
        didSet {
            refreshContainerLayout()
        }
    }
    
    
    private lazy var containView: VerticalStackView = {
        let view = VerticalStackView()
        view.spacing = 0
        view.distribution = .fill
        return view
    }()
    
    private lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = lineColor?.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.opacity = lineOpacity
        return layer
    }()
    
    private lazy var bgShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.red.cgColor
        return layer
    }()
    
    private var maskBGView: UIView?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = creatPath().cgPath
        bgShapeLayer.path = creatPath().cgPath
        self.layer.mask = bgShapeLayer
    }
    
    private func refreshContainerLayout() {
        if triangleDirection == .top {
            containView.snp.remakeConstraints { make in
                make.directionalEdges.equalTo(UIEdgeInsets(top: contentSpace.top + triangleHeight, left: contentSpace.left, bottom: contentSpace.bottom, right: contentSpace.right))
            }
        } else {
            containView.snp.remakeConstraints { make in
                make.directionalEdges.equalTo(UIEdgeInsets(top: contentSpace.top, left: contentSpace.left, bottom: triangleHeight + contentSpace.bottom, right: contentSpace.right))
            }
        }
    }
    
    private func creatPath() -> UIBezierPath {
        
        
        if triangleDirection == .top {
            let triangleRect = bounds.inset(by: UIEdgeInsets(top: triangleHeight, left: 0, bottom: 0, right: 0))
            let inRect = triangleRect.inset(by: UIEdgeInsets(top: radious, left: radious, bottom: radious, right: radious))
            
            let leftTop = inRect.origin
            let rightTop = CGPoint(x: inRect.maxX, y: inRect.minY)
            let leftBottom = CGPoint(x: inRect.minX, y: inRect.maxY)
            let rightBottom = CGPoint(x: inRect.maxX, y: inRect.maxY)
            let triangleBottom = CGPoint(x: triangleCenterX ?? (ss_w / 2), y: 0)
            let path = UIBezierPath()
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            path.move(to: triangleBottom)
            path.addLine(to: CGPoint(x: triangleBottom.x + triangleWidth / 2, y: triangleBottom.y + triangleHeight))
            
            /// 右上
            path.addLine(to: CGPoint(x: inRect.maxX, y: triangleRect.minY))
            path.addArc(withCenter: rightTop, radius: radious, startAngle: -Double.pi / 2, endAngle: 0, clockwise: true)
            
            /// 右下
            path.addLine(to: CGPoint(x: triangleRect.maxX, y: triangleRect.maxY - radious))
            path.addArc(withCenter: rightBottom, radius: radious, startAngle: 0, endAngle: Double.pi / 2, clockwise: true)
            
            /// 左下
            path.addLine(to: CGPoint(x: inRect.minX, y: triangleRect.maxY))
            path.addArc(withCenter: leftBottom, radius: radious, startAngle: Double.pi / 2, endAngle: Double.pi, clockwise: true)
            
            /// 左上
            path.addLine(to: CGPoint(x: triangleRect.minX, y: inRect.minY))
            path.addArc(withCenter: leftTop, radius: radious, startAngle: Double.pi, endAngle: -Double.pi / 2, clockwise: true)
            
            
            path.addLine(to: CGPoint(x: triangleBottom.x - triangleWidth / 2, y: triangleBottom.y + triangleHeight))
            
            path.close()
            return path
            
        } else {
            let triangleRect = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: triangleHeight, right: 0))
            let inRect = triangleRect.inset(by: UIEdgeInsets(top: radious, left: radious, bottom: radious, right: radious))
            
            let leftTop = inRect.origin
            let rightTop = CGPoint(x: inRect.maxX, y: inRect.minY)
            let leftBottom = CGPoint(x: inRect.minX, y: inRect.maxY)
            let rightBottom = CGPoint(x: inRect.maxX, y: inRect.maxY)
            let triangleBottom = CGPoint(x: triangleCenterX ?? (ss_w / 2), y: ss_h)
            let path = UIBezierPath()
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            path.move(to: triangleBottom)
            path.addLine(to: CGPoint(x: triangleBottom.x + triangleWidth / 2, y: triangleBottom.y - triangleHeight))
            /// 右下
            path.addLine(to: CGPoint(x: triangleRect.maxX - radious, y: triangleRect.maxY))
            path.addArc(withCenter: rightBottom, radius: radious, startAngle: Double.pi / 2, endAngle: 0, clockwise: false)
            /// 右上
            path.addLine(to: CGPoint(x: triangleRect.maxX, y: inRect.minY + radious))
            path.addArc(withCenter: rightTop, radius: radious, startAngle: 0, endAngle: -Double.pi / 2, clockwise: false)
            /// 左上
            path.addLine(to: CGPoint(x: inRect.minX, y: triangleRect.minY))
            path.addArc(withCenter: leftTop, radius: radious, startAngle: Double.pi * 3 / 2, endAngle: Double.pi, clockwise: false)
            /// 左下
            path.addLine(to: CGPoint(x: triangleRect.minX, y: inRect.maxY))
            path.addArc(withCenter: leftBottom, radius: radious, startAngle: Double.pi, endAngle: Double.pi / 2, clockwise: false)
            
            path.addLine(to: CGPoint(x: triangleBottom.x - triangleWidth / 2, y: triangleBottom.y - triangleHeight))
            
            path.close()
            return path
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let effect = UIBlurEffect(style: .dark)
        let bgView = UIVisualEffectView(effect: effect)
        bgView.backgroundColor = UIColor.hex(0x111111)?.withAlphaComponent(0.5)
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(0)
        }
        
        layer.addSublayer(shapeLayer)
        addSubview(containView)
        refreshContainerLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(sourceView: UIView, sourceRect: CGRect? = nil, distance: CGFloat = 10.wScale, width: CGFloat = 100.wScale) {
        guard let window = App.keyWindow else { return }
        guard let sourceFrameOnWindow = sourceView.superview?.convert(sourceRect ?? sourceView.frame, to: window) else { return }
        let maskView = UIButton()
        window.addSubview(maskView)
        self.maskBGView = maskView
        maskView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(0)
        }
        
        window.addSubview(self)
        let ratio = width / 2 - (triangleCenterX ?? 0)
        if triangleDirection == .top {
            self.snp.makeConstraints { make in
                make.top.equalTo(window.snp.top).offset(sourceFrameOnWindow.maxY + distance)
                make.centerX.equalTo(window.snp.leading).offset(sourceFrameOnWindow.minX + sourceFrameOnWindow.width / 2 + ratio)
                make.width.equalTo(width)
            }
        } else {
            self.snp.makeConstraints { make in
                make.bottom.equalTo(window.snp.top).offset(sourceFrameOnWindow.minY - distance)
                make.centerX.equalTo(window.snp.leading).offset(sourceFrameOnWindow.minX + sourceFrameOnWindow.width / 2 + ratio)
                make.width.equalTo(width)
            }
        }
        
        maskView.rx.tap.subscribe(onNext: {
            [weak self] in
            self?.hide()
        }).disposed(by: maskView.rx.disposeBag)
        self.maskBGView?.isHidden = true
        self.isHidden = true
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.maskBGView?.isHidden = false
            self.isHidden = false
        }, completion: { _ in
            
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, delay: 0, animations: {
            self.maskBGView?.isHidden = true
            self.isHidden = true
        }, completion: { _ in
            self.maskBGView?.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
}

