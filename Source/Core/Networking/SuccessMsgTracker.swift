//
//  SuccessMsgTracker.swift
//  
//
//  Created by yangsq on 2020/11/20.
//

import Foundation
import RxSwift
import RxCocoa

private struct SuccessMsgToken<E>: ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Cancelable

    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    func dispose() {
        _dispose.dispose()
    }

    func asObservable() -> Observable<E> {
        return _source
    }
}


public class SuccessMsgTracker: NSObject,SharedSequenceConvertibleType {
    public typealias Element = String?
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay<String?>(value: nil)
    private let _loading: SharedSequence<SharingStrategy, String?>

    var customMsg: String?
    
    
    public init(_ customMsg: String? = nil) {
        self.customMsg = customMsg
        _loading = _relay.asDriver()
            .filter { $0 != nil }
    }

    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType> (_ source: Source)  -> Observable<Source.Element> where Source.Element: MapResult {
        return Observable.using({ () -> SuccessMsgToken<Source.Element> in

            var dispose: Disposable?
            dispose = source.asObservable().share().subscribe(onNext: {
                (result) in
                self.increment(result.result)
                dispose?.dispose()
            }, onError: {
                _ in
                dispose?.dispose()
            })
            return SuccessMsgToken(source: source.asObservable(), disposeAction: self.decrement)
        }, observableFactory: { value in
            return value.asObservable()
        })
    }

    private func increment(_ result: RootResult?) {
        _lock.lock()
        if result?.isSuccess == true {
            if let customMsg = self.customMsg {
                _relay.accept(customMsg)

            }else {
                _relay.accept(result?.msg)
            }
        }
        _lock.unlock()
    }

    private func decrement() {
        _relay.accept(nil)
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
}

public extension ObservableConvertibleType where Element: MapResult {
    public func trackSuccessMsg(_ activityIndicator: SuccessMsgTracker, _ msg: String? = nil) -> Observable<Element> {
        activityIndicator.customMsg = msg
        return activityIndicator.trackActivityOfObservable(self)
    }
}
