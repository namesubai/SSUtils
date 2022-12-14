//
//  Foundation+.swift
//  
//
//  Created by yangsq on 2020/11/12.
//

import Foundation
public extension Int {

    func sizeFromKB() -> String {
        return (self*1024).sizeFromByte()
    }

    func sizeFromByte() -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }

    func kFormattedStr() -> String {
        let sign = ((self < 0) ? "-" : "" )
        if self < 1000 {
            return "\(sign)\(self)"
        }
        let num = fabs(Double(self))
        let exp: Int = Int(log10(num) / 3.0 ) //log10(1000))
        let units: [String] = ["K", "M", "G", "T", "P", "E"]
        let roundedNum: Double = round(10 * num / pow(1000.0, Double(exp))) / 10
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
    
    func string() -> String? {
        if self == nil {
            return nil
        } else {
            return "\(self)"
        }
    }
}


public extension Array {
    func randomSubArray(size: Int) -> [Element] {
        var total = 0
        var temp = Array(self)

        if count >= size {
            var array = [Element]()
            while total < size{
                let index = Int.random(in: 0..<temp.count)
                array.append(temp[index])
                temp.remove(at: index)
                total += 1
            }
            return array
        } else {
            return temp
        }
        
       
    }
}

public extension Optional where Wrapped == Int {
    var toStr: String? {
        if self == nil {
            return nil
        } else {
            return "\(self!)"
        }
    }
}
