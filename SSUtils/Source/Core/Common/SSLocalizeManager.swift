//
//  SSLocalizeManager.swift
//  SSUtils
//
//  Created by yangsq on 2021/12/6.
//

import Foundation
import RxCocoa
import RxSwift

public var currentLangType: LangType {
    SSLocalizeManager.shared.currentLangType
}

//public var currentSystemLangType: LangType {
////    if var currentSystemLang = (UserDefaults.standard.object(forKey: "AppleLanguages") as? Array<String>)?.first, let type = LangType(rawValue: currentSystemLang.replacingOccurrences(of: "-", with: "_")) {
////        return type
////    } else {
//        return .en
////    }
//
////    if let lang = LocalizeManager.shared.defaulLangType {
////        return lang
////    }
//}

public var currentLang: String {
    SSLocalizeManager.shared.currentLangType.rawValue
}
public var currentLangs: [String] {
    [currentLang]
}

private let hostingBundle = Bundle(for: LocaliszedClass.self)
fileprivate let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current

public enum LangType: String {
    case en = "en"
    case ptBR = "pt_BR"
    case id = "id"
    case ru = "ru"
    case cn = "zh-Hans"
}

public struct LocalizeConfig {
    public static var defaulLangType: LangType?
}


public class SSLocalizeManager: NSObject {
    public static let shared = SSLocalizeManager()
    public private(set) var currentLangType: LangType!
    public var langDisChange: BehaviorRelay<LangType>!
    public override init() {
        super.init()
        if let localLang = UserDefaults.standard.object(forKey: "ChoseLang") as? String, let type = LangType(rawValue: localLang) {
            self.currentLangType = type
        } else {
            if let defaulLangType = LocalizeConfig.defaulLangType {
                self.currentLangType = defaulLangType
            } else {
//                if let currentSystemLang = (UserDefaults.standard.object(forKey: "AppleLanguages") as? Array<String>)?.first, let type = LangType(rawValue: currentSystemLang.replacingOccurrences(of: "-", with: "_")) {
//                    self.currentLangType = type
//                } else {
//                    self.currentLangType = .en
//                }
                self.currentLangType = .en
            }
            
        }
        langDisChange = BehaviorRelay(value: self.currentLangType)
    }
    
    public func switchLang(type: LangType) {
        self.currentLangType = type
        UserDefaults.standard.set(type.rawValue, forKey: "ChoseLang")
        UserDefaults.standard.synchronize()
        langDisChange.accept(type)
    }
    
}



class LocaliszedClass {
    
}

public func localized(name: String, preferredLanguages: [String]? = nil) -> String {
    var preferredLanguages = preferredLanguages ?? currentLangs
//    guard let preferredLanguages = preferredLanguages else {
//        return NSLocalizedString(name, bundle: hostingBundle, comment: "")
//    }
//
    guard let (_, bundle) = localeBundle(tableName: "Localizable", preferredLanguages: preferredLanguages) else {
        return name
    }
    
    return NSLocalizedString(name, bundle: bundle, comment: "")
}


func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
        .map { Locale(identifier: $0) }
        .prefix(1)
        .flatMap { locale -> [String] in
            if hostingBundle.localizations.contains(locale.identifier) {
                if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
                    return [locale.identifier, language]
                } else {
                    return [locale.identifier]
                }
            } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
                return [language]
            } else {
                return []
            }
        }
    
    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
}
