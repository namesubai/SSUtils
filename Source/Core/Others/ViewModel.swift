//
//  ViewModel.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxCocoa
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

struct NoData {
    var title: String?
    var imageName: String?
    var buttonTitle: String?
}

open class ViewModel: NSObject {
    
    var provider: NetworkAPI
    var page: Int = 1
    var size: Int = 20
    let msgToast = SuccessMsgTracker()
    let loading = ActivityIndicator()
    let customLoading = ActivityIndicator()
    let clearLoading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()
    let noMore = PublishRelay<Bool>()
    let error = ErrorTracker()
    let noData = PublishRelay<NoData?>()
    let noNetwork = PublishRelay<Bool>()
    let showHud = PublishSubject<String>()
    let showCustomLoading = PublishRelay<Bool>()
    init(provider: NetworkAPI) {
        self.provider = provider
    }
    deinit {
        logDebug(">>>>>\(type(of: self)): 已释放<<<<<< ")
    }
}
