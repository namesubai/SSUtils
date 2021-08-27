//
//  Reachability.swift
//  
//
//  Created by yangsq on 2020/11/10.
//

import Foundation
import RxSwift
import Alamofire

func connectedToInternet() -> Observable<Bool> {
    return Reachability.shared.reach
}

class Reachability: NSObject {
    
    static let shared = Reachability()
    let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return reachSubject.asObserver()
    }
    private(set) var reachAble: Bool = false
    private(set) var stateStrng: String = "Unknow"
    private(set) var isWiFi: Bool = false
    override init() {
        super.init()
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: {
            [weak self]
            (status) in
            guard let self = self else { return }
                switch status {
                case .notReachable:
                    self.reachSubject.onNext(false)
                    self.reachAble = false
                    self.isWiFi = false
                case .reachable(let type):
                    self.reachSubject.onNext(true)
                    self.reachAble = true
                    switch type {
                    case .ethernetOrWiFi:
                        self.stateStrng = "WIFI"
                        self.isWiFi = true
                    case .cellular:
                        self.stateStrng = "Cellular Data"
                        self.isWiFi = false
                    }
                case .unknown:
                    self.reachSubject.onNext(false)
                    self.reachAble = false
                    self.isWiFi = false
                }
        })
    }
}
