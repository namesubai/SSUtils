//
//  Reachability.swift
//  
//
//  Created by yangsq on 2020/11/10.
//

import Foundation
import RxSwift
import Alamofire
import CoreTelephony

public func connectedToInternet() -> Observable<Bool> {
    return SSReachability.shared.reach
}

public func cellularNotRestricted() -> Observable<Bool> {
    return SSReachability.shared.cellularState.map({$0 == .notRestricted})
}

public class SSReachability: NSObject {
    
    public static let shared = SSReachability()
    public let reachSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private let cellularStateDidChange = ReplaySubject<CTCellularDataRestrictedState>.create(bufferSize: 1)
    public var reach: Observable<Bool> {
        return reachSubject.asObservable().observe(on: MainScheduler.instance)
    }
    
    public var cellularState: Observable<CTCellularDataRestrictedState> {
        return cellularStateDidChange.asObservable().observe(on: MainScheduler.instance)
    }
    
    public private(set) var reachAble: Bool = false
    public private(set) var stateStrng: String = "Unknow"
    public private(set) var isWiFi: Bool = false
    public private(set) lazy var cellularStateData = CTCellularData()
    
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
        cellularStateDidChange.onNext(cellularStateData.restrictedState)
        cellularStateData.cellularDataRestrictionDidUpdateNotifier = {
            [weak self] state in guard let self = self else { return }
            self.cellularStateDidChange.onNext(state)
        }
    }
}
