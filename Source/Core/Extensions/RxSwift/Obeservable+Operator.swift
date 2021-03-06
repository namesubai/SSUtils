//
//  Obeservable+Operator.swift
//  
//
//  Created by yangsq on 2020/11/10.
//

import Foundation
import RxSwift
import RxCocoa
import RxGesture

public extension Reactive where Base: UIView {
    func tap() -> Observable<Void> {
        return tapGesture().when(.recognized).mapToVoid()
    }
}
public extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (selfE) -> Bool in
            return value != selfE
        }
    }
}


public extension ObservableType where Element == Bool {
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
}

public extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

public extension ObservableType {

    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
//            assertionFailure("Error \(error)")
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
