//
// Created by sergdort on 03/02/2017.
// Copyright (c) 2017 sergdort. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class ErrorTracker: SharedSequenceConvertibleType {
    public typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<Error>()

    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element> {
        return source.asObservable().do(onError: onError)
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }

    public func asObservable() -> Observable<Error> {
        return _subject.asObservable()
    }

    func onError(_ error: Error) {
        _subject.onNext(error)
    }

    deinit {
        _subject.onCompleted()
    }
}

public class ResultTracker: SharedSequenceConvertibleType {
    public typealias SharingStrategy = DriverSharingStrategy
    private let _subject = PublishSubject<(Any?, Error?)>()

    func trackResult<O: ObservableConvertibleType>(from source: O) -> Observable<O.Element>  {
        return source.asObservable().do(onNext: onNext,onError: onError)
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, (Any?,Error?)> {
        return _subject.asObservable().asDriverOnErrorJustComplete()
    }

    public func asObservable() -> Observable<(Any?, Error?)> {
        return _subject.asObservable()
    }

    func onError(_ error: Error) {
        _subject.onNext((nil, error))
    }
    
    func onNext(_ element: Any?) {
        _subject.onNext((element, nil))
    }

    deinit {
        _subject.onCompleted()
    }
}

public extension ObservableConvertibleType {
    func trackResult(_ track: ResultTracker) -> Observable<Element> {
        return track.trackResult(from: self)
    }
    
    func trackError(_ trackError: ErrorTracker) -> Observable<Element> {
        return trackError.trackError(from: self)
    }
}
