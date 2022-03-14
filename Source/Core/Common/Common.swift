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
    public static let shared = App()
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
        return UIApplication.shared.statusBarFrame.height != 20
    }()
    
    public static var isiPhoneXR: Bool = {
        if let size = UIScreen.main.currentMode?.size {
            if CGSize(width: 828, height: 1792) == size || CGSize(width: 750, height: 1624) == size  {
                return true
            }
        }
        return false
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
    public static let widthScale = (width / 375.0)
    public static let heigtScale = (height / 812.0)
    public static let fontScale = min(App.width, App.height) / 375.0

    public static var navBackImage: UIImage? = nil
    public static var isHideTabBarWhenPush: Bool = true
    public static var navIsTranslucent: Bool = true
    public static var tabIsTranslucent: Bool = true
    public static var navBarTitleFont: UIFont = Fonts.semiBold(18)
    public static var headerCustomLodingView: (() -> UIView?)? = nil
    public static var footerCustomLodingView: (() -> UIView?)? = nil
    public static var emptyNotNetworkImage: UIImage? = nil
    public static var emptyErrorImage: UIImage? = nil
    public static var emptyNotNetworkText: String? = nil
    public static var emptyNotNetworkTextFont: UIFont? = nil
    public static var emptyNotNetworkTextColor: UIColor? = nil
    public static var emptyTitleFont: UIFont? = nil
    public static var emptyTitleColor: UIColor? = nil
    public static var emptyButtonTitleFont: UIFont? = nil
    public static var emptyButtonTitleColor: UIColor? = nil
    public static var defaulAppStoreID: String = "1606154284"
    public static var emptyNotNetworkButtonCustomView: UIView? = nil
    public static var emptyCenterOffset: CGPoint = .zero

    var serviceErrorHandle:(() -> Void)?
    public mutating func serviceErrorHandle(block:@escaping () -> Void) {
        self.serviceErrorHandle = block
    }
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
        ceil(size * App.fontScale)
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
    public static let Library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
    public static let Tmp = NSTemporaryDirectory()
}


public struct Notifications {
    
}


public extension CGFloat {
    var wScale: CGFloat {
        return self * App.widthScale
    }
    var hScale: CGFloat {
        return self * App.heigtScale
    }

    var fontScale: CGFloat {
        ceil(self * App.fontScale)
    }
}

public extension Int {
    var wScale: CGFloat {
        return CGFloat(self) * App.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * App.heigtScale
    }
    var fontScale: CGFloat {
        ceil(CGFloat(self) * App.fontScale)
    }
}


public extension Double {
    var wScale: CGFloat {
        return CGFloat(self) * App.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * App.heigtScale
    }
    var fontScale: CGFloat {
        ceil(CGFloat(self) * App.fontScale)
    }
}


public extension Float {
    var wScale: CGFloat {
        return CGFloat(self) * App.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * App.heigtScale
    }
    var fontScale: CGFloat {
        ceil(CGFloat(self) * App.fontScale)
    }
}

public extension UIEdgeInsets {
    var wScale: UIEdgeInsets {
        return scale(App.widthScale)
    }
    var hScale: UIEdgeInsets {
        return  scale(App.heigtScale)
    }
}

public extension CGSize {
    var wScale: CGSize {
        return scale(App.widthScale)
    }
    var hScale: CGSize {
        return  scale(App.heigtScale)
    }
}


public func logDebug(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}

class Class {
    
}

public func image(_ name: String) -> UIImage? {
    let image = UIImage(named: name, in: Bundle(for: Class.self), compatibleWith: nil)
    return image
}




