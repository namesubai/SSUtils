//
//  Common.swift
//  Alamofire
//
//  Created by yangsq on 2021/8/26.
//

import Foundation
#if DEBUG
import CocoaLumberjack
#endif

import UIKit
import AudioToolbox

/// 动态插入字体
var registerRecord = [String:Bool]()

public func registerFont(url: URL?) {
    
    if url != nil {
        var fontName = url?.lastPathComponent.replacingOccurrences(of: ".ttf", with: "")
        fontName = fontName?.replacingOccurrences(of: ".otf", with: "")
        if let fontName = fontName {
            if registerRecord[fontName] ?? false == false {
                let isSuccess = CTFontManagerRegisterFontsForURL(url as! CFURL, .process, nil)
                registerRecord[fontName] = isSuccess
            }
        }
    }
}

public enum SSCommonError: Error {
    case `default`
    case msg(msg: String?)
}

public struct SSColors {
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

public struct SSApp {
    public static let shared = SSApp()
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
    
    @available(*, deprecated, message: "use 'AppName' instead")
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
        let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]
        return simModelCode != nil
    }
    
    public static var isDarkMode: Bool {
        if #available(iOS 12.0, *) {
           return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
    
    public static func feedbackGenerateImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light)  {
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        feedback.impactOccurred()
    }
    
    public static func playSound(url: URL, completion: ((Bool) -> Void)? = nil) {
        var sourcId: SystemSoundID = 0
        let errorCode = AudioServicesCreateSystemSoundID(url as CFURL, &sourcId)
        if errorCode == 0 {
            AudioServicesPlaySystemSoundWithCompletion(sourcId) {
                completion?(true)
            }
        } else {
            completion?(false)
        }
        
    }
    
    public static var keyWindow: UIWindow? {
        if #available(iOS 13.0.0, *) {
            return UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    public static var mainWindow: UIWindow? {
        if let delegate = UIApplication.shared.delegate, delegate.responds(to: #selector(getter: UIApplicationDelegate.window)) {
            return delegate.window ?? nil
        }
        let windows = UIApplication.shared.windows
        if windows.count == 1 {
            return windows.first
        } else {
            return windows.first(where: {$0.windowLevel == .normal})
        }
    }
    
    public static let size = UIScreen.main.bounds.size
    public static let width =  size.width
    public static let height =  size.height
    
    public static let systemVersion = UIDevice.current.systemVersion
    public static var statusBarHeight: CGFloat {
        if UIApplication.shared.isStatusBarHidden == true {
          return safeAreaInsets.top
        } else {
            return keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? UIApplication.shared.statusBarFrame.height
        }
        
    }
    public static let navBarHeight: CGFloat = 44
    public static let navAndStatusBarHeight = statusBarHeight + navBarHeight
    public static let widthScale = (width / 375.0)
    public static let heigtScale = (height / 812.0)
    public static let fontScale = min(SSApp.width, SSApp.height) / 375.0
    public static var safeAreaTop: CGFloat { safeAreaInsets.top }
    public static var safeAreaBottom: CGFloat { safeAreaInsets.bottom }
    public static var pixel: CGFloat { 1.0 / UIScreen.main.scale }
    public static var minPixel: CGFloat { max(1.0 / UIScreen.main.scale, 0.5) }

    public static var navBackImage: UIImage? = nil
    public static var isHideTabBarWhenPush: Bool = true
    public static var navIsTranslucent: Bool = true
    public static var tabIsTranslucent: Bool = true
    public static var navBarTitleFont: UIFont = SSFonts.semiBold(15)
    public static var headerCustomLodingView: (() -> UIView?)? = nil
    public static var footerCustomLodingView: (() -> UIView?)? = nil
    public static var isShowFooterNoMoreData: Bool = true
    public static var isAutoShowFooterNoMoreData: Bool = true
    public static var emptyNotNetworkImage: UIImage? = nil
    public static var emptyErrorImage: UIImage? = nil
    public static var emptyNotNetworkText: String? = nil
    public static var emptyNotNetworkTextFont: UIFont? = nil
    public static var emptyNotNetworkTextColor: UIColor? = nil
    public static var emptyTitleFont: UIFont? = nil
    public static var emptyTitleColor: UIColor? = nil
    public static var emptyButtonTitleFont: UIFont? = nil
    public static var emptyButtonTitleColor: UIColor? = nil
    public static var defaulAppStoreID: String = ""
    public static var emptyNotNetworkButtonCustomView: (() -> UIView?)? = nil
    public static var emptyCenterOffset: CGPoint = .zero
    public static var emptyTitleTopMargin: CGFloat? = nil
    public static var emptyButtonTopMargin: CGFloat? = nil
    public static var emptyBgColor: UIColor? = nil

    var serviceErrorHandle:(() -> Void)?
    
    public mutating func serviceErrorHandle(block:@escaping () -> Void) {
        self.serviceErrorHandle = block
    }
    
    /// 是否支持锁屏组件？
    public static var isSupportLockScreenWidget: Bool {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }
    
    /// 是否支持展示灵动岛入口？
    public static var isNeeShowDynamicIsLand: Bool {
        if isiPhoneXScreen {
            return true
        } else {
            return false
        }
    }
    
    public static var appStoreLink: String {
        "itms-apps://itunes.apple.com/app/id\(defaulAppStoreID)"
    }
    
    public static var appStoreURL: URL {
        .init(string: appStoreLink)!
    }
}


public struct SSFonts {
    public static var defaultFontFamilyName = ""
    private static func defaultFont(_ size: CGFloat, weight: UIFont.Weight) -> UIFont {
        var weightString: String?
        if weight == .regular {
            weightString = "Regular"
        }
        
        if weight == .bold {
            weightString = "Bold"
        }
        
        if weight == .heavy {
            weightString = "Heavy"
        }
        if weight == .medium {
            weightString = "Medium"
        }
        if weight == .light {
            weightString = "Light"
        }
        if weight == .thin {
            weightString = "Thin"
        }
        if weight == .semibold {
            weightString = "Semibold"
        }
        
        if weight == .ultraLight {
            weightString = "UltraLight"
        }
        if weight == .black {
            weightString = "Black"
        }
        if defaultFontFamilyName.isEmpty {
            return UIFont.systemFont(ofSize: size, weight: weight)
        } else {
            let name = defaultFontFamilyName + "-\(weightString ?? "")"
            return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
    public static func auto(_ size: CGFloat) -> UIFont {
        return defaultFont(autoSize(size: size), weight: .regular)
    }
    
    public static func autoBold(_ size: CGFloat) -> UIFont {
        return defaultFont(autoSize(size: size), weight: .bold)
    }
    
    public static func autoMedium(_ size: CGFloat) -> UIFont {
        return defaultFont(autoSize(size: size), weight: .medium)
    }
    
    public static func autoSemibold(_ size: CGFloat) -> UIFont {
        return defaultFont(autoSize(size: size), weight: .semibold)
    }
    
    public static func autoHeavy(_ size: CGFloat) -> UIFont {
        return defaultFont(autoSize(size: size), weight: .heavy)
    }
    
    public static func system(_ size: CGFloat) -> UIFont {
        return defaultFont(size, weight: .regular)
    }
    
    public static func bold(_ size: CGFloat) -> UIFont {
        return defaultFont(size, weight: .bold)
    }
    
    public static func medium(_ size: CGFloat) -> UIFont {
        return defaultFont(size, weight: .medium)
    }
    
    public static func semiBold(_ size: CGFloat) -> UIFont {
        return defaultFont(size, weight: .semibold)
    }
    
    public static func heavy(_ size: CGFloat) -> UIFont {
        return defaultFont(size, weight: .heavy)
    }
    
    public static func black(_ size: CGFloat) -> UIFont {
        return defaultFont(size, weight: .black)
    }
    
    public static func autoSize(size: CGFloat) -> CGFloat {
        size * SSApp.fontScale
    }
}

extension UIFont {
    func smallFont() -> UIFont {
        if SSApp.height <= 667 {
            return self.withSize(self.pointSize *  SSApp.heigtScale + 1)
        }
        return self
    }
}


public struct SSPaths {
    public static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    public static let Library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
    public static let Tmp = NSTemporaryDirectory()
    public static let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
}


public struct Notifications {
    
}


public extension CGFloat {
    var wScale: CGFloat {
        return self * SSApp.widthScale
    }
    var hScale: CGFloat {
        return self * SSApp.heigtScale
    }

    var fontScale: CGFloat {
        self * SSApp.fontScale
    }
}

public extension Int {
    var wScale: CGFloat {
        return CGFloat(self) * SSApp.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * SSApp.heigtScale
    }
    var fontScale: CGFloat {
        CGFloat(self) * SSApp.fontScale
    }
}


public extension Double {
    var wScale: CGFloat {
        return CGFloat(self) * SSApp.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * SSApp.heigtScale
    }
    var fontScale: CGFloat {
        CGFloat(self) * SSApp.fontScale
    }
}


public extension Float {
    var wScale: CGFloat {
        return CGFloat(self) * SSApp.widthScale
    }
    var hScale: CGFloat {
        return CGFloat(self) * SSApp.heigtScale
    }
    var fontScale: CGFloat {
        CGFloat(self) * SSApp.fontScale
    }
}

public extension UIEdgeInsets {
    var wScale: UIEdgeInsets {
        return scale(SSApp.widthScale)
    }
    var hScale: UIEdgeInsets {
        return  scale(SSApp.heigtScale)
    }
}

public extension CGSize {
    var wScale: CGSize {
        return scale(SSApp.widthScale)
    }
    var hScale: CGSize {
        return  scale(SSApp.heigtScale)
    }
}

#if DEBUG
//MARK: 日志
func setupDLog() {
    addLog(log: .normalLog)
    addLog(log: .networkLog)
}

func addLog(log: CustomLog) {
    let logger = CustomLogger()
    logger.logFormatter = CustomLogFormatter(name: log.style.name)
    log.add(logger)
    let fileLogger: DDFileLogger = DDFileLogger() // File Logger
    fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)  // 24 hours
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7
    log.add(fileLogger)
}

extension CustomLog {
    static let normalLog = CustomLog()
    static let networkLog = CustomLog(style: .network)
}

class CustomLog: DDLog {
    enum Style {
        case normal
        case network
        var name: String {
            switch self {
                case .normal: return ""
                case .network: return "Network"
            }
        }
    }
    var style: Style
    init(style: Style = .normal) {
        self.style = style
        super.init()
    }
}

let networkLog = DDLog()

class CustomLogger: NSObject, DDLogger {
    func log(message logMessage: DDLogMessage) {
       let msg = logFormatter?.format(message: logMessage) ?? logMessage.message
       print(msg)
    }
    
    var logFormatter: DDLogFormatter?
    
}

class CustomLogFormatter: NSObject, DDLogFormatter {
    private lazy var dateFormatter = DateFormatter()
    var name: String?
    init(name: String? = nil) {
        self.name = name
        super.init()
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
    }
    
    func format(message logMessage: DDLogMessage) -> String? {
        var level = ""
        switch logMessage.flag {
            case .error:
                level = "Error"
            case .warning:
                level = "Warning"
            case .info:
                level = "Info"
            case .debug:
                level = "Debug"
            case .verbose:
                level = "Verbose"
            default:
                break
        }
        let time = dateFormatter.string(from: logMessage.timestamp)
        let msg = logMessage.message
        let name = self.name?.isLength == true ? "[\(self.name!)]" : ""
        return "[\(time)][SSUtil]\(name)[\(level)] \(msg)"
    }
    
}

#endif

public func logDebug(_ message: String) {
    #if DEBUG
    DDLogDebug(message, ddlog: CustomLog.normalLog)
    #endif
}

public func logNetWorkDebug(_ message: String) {
#if DEBUG
    DDLogDebug(message, ddlog: CustomLog.networkLog)
#endif
}

class Class {
    
}
public func ssImage(_ name: String) -> UIImage? {
    let image = UIImage(named: name, in: Bundle(for: Class.self), compatibleWith: nil)
    return image
}




