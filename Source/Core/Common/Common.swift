//
//  Common.swift
//  Alamofire
//
//  Created by yangsq on 2021/8/26.
//

import Foundation
import CocoaLumberjack
import SSAlertSwift
public struct Colors {
    public static var backgroud: UIColor = UIColor.hex(0xF5F6F7)
    public static var contentBackgroud: UIColor = UIColor.hex(0xFFFFFF)
    public static var main: UIColor = UIColor.hex(0x3C8BFE)
    public static var headline: UIColor = UIColor.hex(0x15161A)
    public static var subTitle: UIColor = UIColor.hex(0x32343A)
    public static var detailText: UIColor = UIColor.hex(0x9497A1)
    public static var moreText: UIColor = UIColor.hex(0x6C7180)
    public static var line: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    public static var tabBarNormalTitle: UIColor = UIColor.hex(0xA8ACB8)
    public static var tabBarSelectedTitle: UIColor = UIColor.hex(0x0066ff)
    public static var tabBarBackgroud: UIColor = UIColor.hex(0xFFFFFF)
    public static var navBarBackgroud: UIColor = UIColor.hex(0xF5F6F7)
    public static var gradientColors = [UIColor.hex(0x2D8BFF).cgColor, UIColor.hex(0x2080FF).cgColor]

}


public struct App {
    public static var bundleIdentifier: String = {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            return bundleIdentifier
        }
        return ""
    }()
    
    public static var version: String = {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            return version as! String
        }
        return ""
    }()
    
    public static var buildCode: String = {
        if let buildCode = Bundle.main.infoDictionary?["CFBundleVersion"] {
            return buildCode as! String
        }
        return ""
    }()
    
    public static var name: String = {
        if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] {
            return name as! String
        }
        return ""
    }()
    
    public static var isiPhoneXScreen: Bool = {
        guard #available(iOS 11.0, *) else {
            return false
        }
        return UIApplication.shared.windows[0].safeAreaInsets != UIEdgeInsets.zero
    }()
    
    public static var safeAreaInsets: UIEdgeInsets = {
        guard #available(iOS 11.0, *) else {
            return .zero
        }
        return UIApplication.shared.windows[0].safeAreaInsets
    }()
    
    
    public static func isSimulator() -> Bool {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }
    
    public static func feedbackGenerateImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light)  {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.prepare()
        feedback.impactOccurred()
    }
    
    public static let width =  UIScreen.main.bounds.width
    public static let height =  UIScreen.main.bounds.height
    public static let systemVersion = UIDevice.current.systemVersion
    public static let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    public static let navBarHeight: CGFloat = 44
    public static let navAndStatusBarHeight = statusBarHeight +  navBarHeight
    public static let widthScale = width / 375.0
    public static let heigtScale = height / 812.0
    public static var navBackImage: UIImage? = nil
}


public struct Fonts {
   
    public static func auto(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: autoSize(size: size))
    }
    
    public static func autoBold(_ size: CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: autoSize(size: size))
    }
    
    public static func autoMedium(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: autoSize(size: size), weight: .medium)
    }
    
    public static func autoSemibold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: autoSize(size: size), weight: .semibold)
    }
    
    public static func autoHeavy(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: autoSize(size: size), weight: .heavy)
    }
    
    public static func system(_ size: CGFloat) -> UIFont {
         return UIFont.systemFont(ofSize: size)
    }
    
    public static func bold(_ size: CGFloat) -> UIFont {
         return UIFont.boldSystemFont(ofSize: size)
    }
    
    public static func medium(_ size: CGFloat) -> UIFont {
         return UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    public static func semiBold(_ size: CGFloat) -> UIFont {
         return UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    public static func heavy(_ size: CGFloat) -> UIFont {
         return UIFont.systemFont(ofSize: size, weight: .heavy)
    }
    
    public static func black(_ size: CGFloat) -> UIFont {
         return UIFont.systemFont(ofSize: size, weight: .black)
    }
    
    public static func autoSize(size: CGFloat) -> CGFloat {
        ceil(size * (min(App.width, App.height) / 375.0))
    }
}

extension UIFont {
    func smallFont() -> UIFont {
        if App.height <= 667 {
            return self.withSize(self.pointSize *  App.heigtScale + 1)
        }
        return self
    }
}


public struct Paths {
    public static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    public static let Tmp = NSTemporaryDirectory()
}


public struct Notifications {
    
}


extension CGFloat {
    var widthScale: CGFloat {
        return self * App.widthScale
    }
    var heightScale: CGFloat {
        return self * App.heigtScale
    }

}

extension Int {
    var wScale: CGFloat {
        return CGFloat(self) * App.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * App.heigtScale
    }
    
}


extension Double {
    var wScale: CGFloat {
        return CGFloat(self) * App.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * App.heigtScale
    }
}


extension Float {
    var wScale: CGFloat {
        return CGFloat(self) * App.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * App.heigtScale
    }
}



public func logDebug(_ message: @autoclosure () -> String) {
    #if DEBUG
    DDLogDebug(message())
    #endif
}
