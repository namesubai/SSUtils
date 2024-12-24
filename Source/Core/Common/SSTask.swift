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
    
    public class Action: NSObject {
        var todo: ToDo
        var task: (ToDo) -> Void
        init(todo: ToDo, task: @escaping (ToDo) -> Void) {
            self.todo = todo
            self.task = task
        }
        func start() {
            task(todo)
        }
        
    }
    
    private var actions = [Action]()
    
    public init() {
        
    }
    public func add(task: @escaping (ToDo) -> Void) {
        let todo = ToDo()
        let action = Action(todo: todo, task: task)
        actions.append(action)
        if actions.count == 1 {
            action.start()
        }
        todo.end {
            [weak self] in guard let self = self else { return }
            self.actions.removeAll(where: {$0 == action})
            self.actions.first?.start()
        }
       
    }
   
}
