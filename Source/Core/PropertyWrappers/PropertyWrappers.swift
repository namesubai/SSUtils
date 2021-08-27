//
//  PropertyWrappers.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/4/6.
//

import Foundation

@propertyWrapper
public struct Default<T> {
    
    private var defaultValue: T
    var value: T?
    public init(_ defaultValue: T) {
        self.defaultValue = defaultValue
    }
    public var wrappedValue: T? {
        get { return value ?? defaultValue }
        set { value = newValue }
    }

}
