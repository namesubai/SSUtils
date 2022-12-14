//
//  SSTask.swift
//  SSUtils
//
//  Created by Shuqy on 2022/11/24.
//

import Foundation
import RxSwift
import RxCocoa
public class SSTask {
    
    public class ToDo: NSObject {
        private var endComplete: (() -> Void)? = nil
        
        override init() {
            super.init()
        }
        
        func end(endComplete: @escaping () -> Void) {
            self.endComplete = endComplete
        }
        public func complete() {
            self.endComplete?()
            self.endComplete = nil
        }
    }
    
    private var lastToDoTask: BehaviorSubject<ToDo>?
    
    public init() {
        
    }
    public func add(task: @escaping (ToDo) -> Void) {
        let todo = ToDo()
        let toDoTask = BehaviorSubject<ToDo>(value: todo)
        if let lastToDoTask = lastToDoTask {
            lastToDoTask.asObservable().concat(toDoTask).filter({$0 == todo}).subscribe(onNext: {
                todo in
                task(todo)
            }).disposed(by: todo.rx.disposeBag)
        } else {
            toDoTask.subscribe(onNext: { todo in
                task(todo)
            }).disposed(by: todo.rx.disposeBag)
        }
        todo.end {
            toDoTask.onCompleted()
        }
        lastToDoTask = toDoTask
        
    }
    
}
