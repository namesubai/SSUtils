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
    func group(by size: Int) -> [[Element]] {
        var newArr = [[Element]]()
        var lastIndex: Int = 0
        while lastIndex < count {
            let to = lastIndex + size
            if to < count {
                let sizeArry =  Array(self[lastIndex..<to])
                newArr.append(sizeArry)
            } else if lastIndex < count {
                let sizeArry =  Array(self[lastIndex..<count])
                newArr.append(sizeArry)
            }
            lastIndex = to
        }
        return newArr
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


extension Float {
   public func notRounding(_ digits: Int = 2) -> Float {
        if digits == 0 {
            return floor(self)
        } else {
            let num = pow(Float(10.0),Float(digits))
            return floor(self * num) / num
        }
    }
}

extension Double {
    public func notRounding(_ digits: Int = 2) -> Double {
        if digits == 0 {
            return floor(self)
        } else {
            let num = pow(Double(10.0),Double(digits))
            return floor(self * num) / num
        }
    }
}

extension CGFloat {
    public func notRounding(_ digits: Int = 2) -> CGFloat {
        if digits == 0 {
            return floor(self)
        } else {
            let num = pow(CGFloat(10.0),CGFloat(digits))
            return floor(self * num) / num
        }
    }
}


extension CGAffineTransform {
    public var scale: CGFloat {
        let _trans = self
        let scale = sqrt(_trans.a * _trans.a + _trans.c * _trans.c)
        return scale
    }
    
    public var angle: CGFloat {
        let _trans = self
        var rotate = CGFloat(atanf(Float(_trans.b / _trans.a))) //acosf(_trans.a);
        if _trans.a < 0 && _trans.b > 0 {
            rotate += M_PI
        }else if(_trans.a < 0 && _trans.b < 0){
            rotate -= M_PI
        }
        return rotate
    }
}
