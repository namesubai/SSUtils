//
//  EventTrigger.swift
//  
//
//  Created by yangsq on 2020/11/4.
//

import Foundation

public protocol EventTrigger {
    associatedtype Event
    typealias TriggerEvent = (Event) -> Void
    var triggerEvent: TriggerEvent? { get set }
    func trigger(event: TriggerEvent?)
}

private var triggerEventKey: UInt8 = 0
public extension EventTrigger {
    private var _triggerEvent:TriggerEvent? {
        get {return objc_getAssociatedObject(self, &triggerEventKey) as? Self.TriggerEvent}
        set {objc_setAssociatedObject(self, &triggerEventKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)}
    }
    
    var triggerEvent: TriggerEvent? {
        get{_triggerEvent}
        set{
            if newValue != nil {
                _triggerEvent = newValue!
            }
        }
    }
    
    func trigger(event: TriggerEvent?) {
        if event != nil {
            objc_setAssociatedObject(self, &triggerEventKey, event!, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
