//
//  SSCustomProgressView.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/27.
//

import UIKit
import SnapKit
import RxSwift
open class SSCustomProgressView: SSView {
    
    private lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    public let progressChangeTrigger = PublishSubject<Double>()
    public let beginDragTrigger = PublishSubject<Void>()
    public let endDragTrigger = PublishSubject<Void>()
    public let endProgressTrigger = PublishSubject<Double>()
    private var progressViewWidthConstriant: Constraint?
    
    var progress: Double = 0 {
        didSet {
            if progress > 1 {
                progress = 1
            }
            progressViewWidthConstriant?.update(offset: self.bounds.width * CGFloat(progress))
        }
    }

    open override func make() {
        super.make()
        backgroundColor = UIColor.white.withAlphaComponent(0.4)
        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            progressViewWidthConstriant = make.width.equalTo(0).constraint
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        addGestureRecognizer(pan)
    }
    
    @objc
    func panAction(pan: UIPanGestureRecognizer)  {
        let point = pan.location(in: self)
        switch pan.state {
        case .began:
            beginDragTrigger.onNext(())
            
        case .changed:
            self.progress = Double(point.x / self.bounds.width)
            self.progressChangeTrigger.onNext(self.progress)
            
        case .ended:
            endDragTrigger.onNext(())
            self.endProgressTrigger.onNext(self.progress)
        case .cancelled:
            endDragTrigger.onNext(())
            self.endProgressTrigger.onNext(self.progress)
        default:
            break
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("---------")
//        touches.forEach { [weak self] (touch) in
//            guard let self = self else { return }
//            let point = touch.location(in: self)
//
//            if self.bounds.contains(point) {
//                
//                self.progress = Double(point.x / self.bounds.width)
//                self.progressTrigger.onNext(self.progress)
//            }
//       }
//        super.touchesMoved(touches, with: event)
//
//    }
//
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        beginDragTrigger.onNext(())
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endDragTrigger.onNext(())
        touches.forEach { [weak self] (touch) in
            guard let self = self else { return }
            let point = touch.location(in: self)
            if self.bounds.contains(point) {
                self.progress = Double(point.x / self.bounds.width)
                self.endProgressTrigger.onNext(self.progress)
            }
       }
        super.touchesEnded(touches, with: event)

    }
    
    
}

