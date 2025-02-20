//
//  UIColor+.swift
//  
//
//  Created by yangsq on 2020/10/21.
//

import UIKit

public extension UIColor {
    static func hex(_ hex: Int, alpha: CGFloat = 1) -> UIColor? {
        var trans = alpha
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }

        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        return self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    
    static func hex(_ hex: Int, alpha: CGFloat = 1) -> UIColor {
        return self.hex(hex, alpha: alpha) ?? .clear
    }
    
    static func rhex(_ hex: Int, alpha: CGFloat = 1) -> UIColor {
        return self.hex(hex, alpha: alpha) ?? .clear
    }
    
    static func hex(_ hexString: String, alpha: CGFloat = 1) -> UIColor {
        return self.hex(hexString, alpha: alpha) ?? .clear
    }
    
    static func hex(_ hexString: String, alpha: CGFloat = 1) -> UIColor? {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string =  hexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }

        if string.count == 3 { // convert hex to 6 digit format if in short format
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }

        guard let hexValue = Int(string, radix: 16) else { return nil }
        
        var trans = alpha
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = (hexValue >> 16) & 0xff
        let green = (hexValue >> 8) & 0xff
        let blue = hexValue & 0xff
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }

        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        return self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    
    var hexString: String {
        let components: [Int] = {
            let comps = cgColor.components!
            let components = comps.count == 4 ? comps : [comps[0], comps[0], comps[0], comps[1]]
            return components.map { Int($0 * 255.0) }
        }()
        return String(format: "#%02X%02X%02X", components[0], components[1], components[2])
    }
    
    var alpha: CGFloat {
        return cgColor.alpha
    }
}

public extension UIColor {
    static var random: UIColor {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
}

public extension CGColor {
    var hexString: String {
        let components: [Int] = {
            let comps = self.components!
            let components = comps.count == 4 ? comps : [comps[0], comps[0], comps[0], comps[1]]
            return components.map { Int($0 * 255.0) }
        }()
        return String(format: "#%02X%02X%02X", components[0], components[1], components[2])
    }
    
    var cgAlpha: CGFloat {
        return self.alpha
    }
}

public extension UIColor {
    static func blend(_ color1: UIColor, intensity1: CGFloat = 0.5, with color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        // http://stackoverflow.com/questions/27342715/blend-uicolors-in-swift
        
        let total = intensity1 + intensity2
        let level1 = intensity1/total
        let level2 = intensity2/total
        
        guard level1 > 0 else { return color2 }
        guard level2 > 0 else { return color1 }
        
        let components1: [CGFloat] = {
            let comps = color1.cgColor.components!
            return comps.count == 4 ? comps : [comps[0], comps[0], comps[0], comps[1]]
        }()
        
        let components2: [CGFloat] = {
            let comps = color2.cgColor.components!
            return comps.count == 4 ? comps : [comps[0], comps[0], comps[0], comps[1]]
        }()
        
        let red1 = components1[0]
        let red2 = components2[0]
        
        let green1 = components1[1]
        let green2 = components2[1]
        
        let blue1 = components1[2]
        let blue2 = components2[2]
        
        let alpha1 = color1.cgColor.alpha
        let alpha2 = color2.cgColor.alpha
        
        let red = level1*red1 + level2*red2
        let green = level1*green1 + level2*green2
        let blue = level1*blue1 + level2*blue2
        let alpha = level1*alpha1 + level2*alpha2
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
