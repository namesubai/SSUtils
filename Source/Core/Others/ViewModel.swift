//
//  ViewModel.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxCocoa
import RxSwift

public protocol ViewModelType: NSObject {
    associatedtype Input
    associatedtype Output
    associatedtype Provider
    func transform(input: Input) -> Output
    init(provider: Provider)
}

private var providerKey: Int8 = 0
public extension ViewModelType {
    var provider: Provider {
        get {
            return objc_getAssociatedObject(self, &providerKey) as! Self.Provider
        }
        set {
            return objc_setAssociatedObject(self, &providerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public init(provider: Provider) {
        self.init()
        self.provider = provider
    }
}

public struct NoData {
    public var title: String?
    public var titleFont: UIFont?
    public var titleColor: UIColor?

    public var image: UIImage?
    public var imageName: String?
    public var buttonTitle: String?
    public var buttonTitleFont: UIFont?
    public var buttonTitleColor: UIColor?
    public var customButtonView: UIView?
    public init(title: String? = nil,
                titleFont: UIFont? = nil,
                titleColor: UIColor? = nil,
                image: UIImage? = nil,
                imageName: String? = nil,
                buttonTitle: String? = nil,
                buttonTitleFont: UIFont? = nil,
                buttonTitleColor: UIColor? = nil,
                customButtonView: UIView? = nil) {
        
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.image = image
        self.imageName = imageName
        self.buttonTitle = buttonTitle
        self.customButtonView = customButtonView
        self.buttonTitleFont = buttonTitleFont
        self.buttonTitleColor = buttonTitleColor
    }
   
}

open class ViewModel: NSObject {
    
    public var page: Int = 1
    public var size: Int = 20
    public var msgToast = SuccessMsgTracker()
    public var loading = ActivityIndicator()
    public var customLoading = ActivityIndicator()
    public var clearLoading = ActivityIndicator()
    public var headerLoading = ActivityIndicator()
    public var footerLoading = ActivityIndicator()
    public var noMore = BehaviorRelay<Bool>(value: false)
    public var showFooterRefresh = BehaviorRelay<Bool>(value: false)
    public var error = ErrorTracker()

    public var noData = PublishRelay<NoData?>()
    public var noNetwork = PublishRelay<Bool>()
    public var showHud = PublishSubject<String?>()
    public var showCustomLoading = PublishRelay<Bool>()
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
}
