//
//  Reachability.swift
//  
//
//  Created by yangsq on 2020/11/10.
//

import Foundation
import RxSwift
import Alamofire

public func connectedToInternet() -> Observable<Bool> {
    return Reachability.shared.reach
}

public class Reachability: NSObject {
    
    public static let shared = Reachability()
    public let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    public var reach: Observable<Bool> {
        return reachSubject.asObserver()
    }
    public private(set) var reachAble: Bool = false
    public private(set) var stateStrng: String = "Unknow"
    public private(set) var isWiFi: Bool = false
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
