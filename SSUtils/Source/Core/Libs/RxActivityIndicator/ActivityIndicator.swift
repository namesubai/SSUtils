//
//  ActivityIndicator.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 10/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

private struct ActivityToken<E>: ObservableConvertibleType, Disposable {
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

/**
 Enables monitoring of sequence computation.
 If there is at least one sequence computation in progress, `true` will be sent.
 When all activities complete `false` will be sent.
 */
public class ActivityIndicator: SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay(value: 0)
    private let _loading: SharedSequence<SharingStrategy, Bool>
    public init() {
        _loading = _relay.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source, isHideOnNextCallback: Bool) -> Observable<Source.Element> {
        return Observable.using({ () -> ActivityToken<Source.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }, observableFactory: { value in
            return value.asObservable()
        }).do(onNext: {
            _ in
            if isHideOnNextCallback {
                self.hide()
            }
        })
    }

    private func increment() {
        _lock.lock()
        _relay.accept(_relay.value + 1)
        _lock.unlock()
    }

    private func decrement() {
        _lock.lock()
        _relay.accept(max(0, _relay.value - 1))
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
    
    public func hide() {
        decrement()
    }
}

extension ObservableConvertibleType {
    /// isHideOnNext：监听onNext直接隐藏。如：在使用接口带缓存的时候，loading 在缓存和网络数据回调的时候隐藏,而不是默认dispose才隐藏
    public func trackActivity(_ activityIndicator: ActivityIndicator, isHideOnNextCallback: Bool = false, needShowLoading: Bool = true) -> Observable<Element> {
        if needShowLoading {
            return activityIndicator.trackActivityOfObservable(self, isHideOnNextCallback: isHideOnNextCallback)
        } else {
            return self.asObservable()
        }
    }
}

public struct ActivityCacheData<Element> {
    var element: Element
    var isCache: Bool
}





public class CustomActivityIndicator: SharedSequenceConvertibleType {
    public typealias Element = (Bool, String?, Bool)
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay<(Int, String?, Bool)>(value: (0, nil, false))
    private let _loading: SharedSequence<SharingStrategy, (Bool, String?, Bool)>
    public init() {
        _loading = _relay.asDriver()
            .map { ($0.0 > 0, $0.1, $0.2) }
            .distinctUntilChanged({$0.0})
    }
    
    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source,  message: String? = nil, isCanNotTouchToast: Bool = false) -> Observable<Source.Element> {
        return Observable.using({ () -> ActivityToken<Source.Element> in
            self.increment(message: message, isCanNotTouchToast: isCanNotTouchToast)
            return ActivityToken(source: source.asObservable(), disposeAction: {
                self.decrement(message: message, isCanNotTouchToast: isCanNotTouchToast)
            })
        }, observableFactory: { value in
            return value.asObservable()
        })
    }
    
    private func increment(message: String? = nil, isCanNotTouchToast: Bool = false) {
        _lock.lock()
        _relay.accept((_relay.value.0 + 1, message, isCanNotTouchToast))
        _lock.unlock()
    }
    
    private func decrement(message: String? = nil, isCanNotTouchToast: Bool = false) {
        _lock.lock()
        _relay.accept((_relay.value.0 - 1, message, isCanNotTouchToast))
        _lock.unlock()
    }
    
    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
}

extension ObservableConvertibleType {
    public func trackCustomActivity(_ activityIndicator: CustomActivityIndicator, message: String? = nil, isCanNotTouchToast: Bool = false) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self, message: message, isCanNotTouchToast: isCanNotTouchToast)
    }
}
