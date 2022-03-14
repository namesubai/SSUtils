//
//  View.swift
//  
//
//  Created by yangsq on 2020/10/21.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

open class View: UIView {
    public var viewModel: ViewModel?

    public var disposeBag = DisposeBag()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        make()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func make() {
    }
   
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
    
    open func bindViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel
        viewModel.loading.asObservable().bind(to: rx.loading).disposed(by: disposeBag)
        viewModel.clearLoading.asObservable().bind(to: rx.clearLoading).disposed(by: disposeBag)
        viewModel.customLoading.asObservable().bind(to: rx.customLoading).disposed(by: disposeBag)
        viewModel.msgToast.asObservable().subscribe(onNext: {
            [weak self] (msg) in
             guard let self = self else {return}
            self.showTextHUD(msg)
             
         }).disposed(by: disposeBag)
        
        viewModel.error.asObservable().subscribe(onNext: {
            [weak self] (error) in
             guard let self = self else {return}
             if let error = error as? ServiceError {
                 self.showTextHUD(error.errorMsg)
                
             } else if let error = error as? Moya.MoyaError {
                 self.showTextHUD(error.errorDescription)
             }
             else {
                 let error = error as NSError
                 let message = error.userInfo[NSLocalizedDescriptionKey] as? String
                 self.showTextHUD(message)
             }
        }).disposed(by: disposeBag)
        
        viewModel.showCustomLoading.asObservable().subscribe(onNext: {
            [weak self] (isShow) in
             guard let self = self else {return}
            
         }).disposed(by: disposeBag)
    }
    
    open func bind(_ cellViewModel: CellViewModel) {
        
    }
  
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

public extension Reactive where Base: View {

    var clearLoading: Binder<Bool> {
        return Binder(self.base) { view, attr in
            if attr {
                UIApplication.shared.keyWindow?.showLoadingTextHUD(maskType: .clear)
            }else{
                UIApplication.shared.keyWindow?.hideHUD()
            }
        }
    }
    
    var loading: Binder<Bool> {
        return Binder(self.base) { view, attr in
            if attr {
                view.showLoadingTextHUD()
            }else{
                view.hideHUD()
            }
        }
    }
    var customLoading: Binder<Bool> {
        return Binder(self.base) { view, attr in
            if attr {
//                view.showCustomLoadingView()
            }else{
//                view.hideCustomLoadingView()
            }
        }
    }
}


open class  TopRoundedCornerView: View {
    private var roundedLayer: CAShapeLayer!
    private var roundedPath: UIBezierPath!
    public var topConerRadious: CGFloat = 25.wScale
    
    private lazy var topIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex(0xF0F0F0)
        view.layer.cornerRadius = 4.5.wScale / 2
        return view
    }()
    
    public var isHideTopLine: Bool = true {
        didSet {
            topIndicatorView.isHidden = isHideTopLine
        }
    }

    open override func make() {
        super.make()
        backgroundColor = UIColor.hex(0xFFFFFF)
        roundedLayer = CAShapeLayer()
        roundedLayer.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(roundedLayer)
        
        addSubview(topIndicatorView)
        topIndicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(13.wScale)
            make.size.equalTo(CGSize(width: 40, height: 4.5).wScale)
        }
        isHideTopLine = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        roundedPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: topConerRadious, height: topConerRadious))
        roundedLayer.path = roundedPath.cgPath
        layer.mask = roundedLayer
    }
}


open class AllRoundedCornerView: View {
    public var conerRadious: CGFloat = 20.wScale {
        didSet {
            layer.cornerRadius = conerRadious
            layoutIfNeeded()
        }
    }

    open override func make() {
        super.make()
        layer.cornerRadius = conerRadious
        layer.masksToBounds = true
    }
}



