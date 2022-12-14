//
//  SSSafeArray.swift
//  SSUtils
//
//  Created by Shuqy on 2022/11/30.
//

public class SSSafeArray<Element> {
    private let queue = DispatchQueue(label: "com.swiftfortunewheel.synchronizedarray", attributes: .concurrent)
    private var array = [Element]()

    public init() {}
}

extension SSSafeArray {

    public var synchronizedArray: [Element] {
        var array: [Element] = []
        queue.sync {
            array = self.array
        }
        return array
    }

    public var count: Int {
        var count = 0
        queue.sync {
            count = self.array.count
        }
        return count
    }

    public func append(_ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }

    public func clear() {
        queue.async(flags: .barrier) {
            self.array.removeAll()
        }
    }

    public subscript(index: Int) -> Element {
        var element: Element!
        queue.sync {
            element = self.array[index]
        }
        return element
    }
}

extension SSSafeArray where Element: Comparable {

    public func index(_ element: Element) -> Int? {
        var index: Int?
        queue.sync {
            index = self.array.firstIndex(where: {$0 == element})
        }
        return index
    }

    public func contains(_ element: Element) -> Bool {
        var contains = false
        queue.sync {
            contains = self.array.contains(element)
        }
        return contains
    }
}
