//
//  NSObject+Add.swift
//  FreeEarsBook
//
//  Created by yangsq on 2021/3/10.
//

import Foundation
//import StoreKit
private let defaulAppStoreID = 1559345315
public extension NSObject {
    static var className: String {
        return NSStringFromClass(self)
    }
    
    func jumpToAppStore(_ url: String?) {
        var appUrl: String = "itms-apps://itunes.apple.com/app/id\(defaulAppStoreID)"
        if url != nil {
            appUrl = url!
        }
        
        let  appURL = URL(string: appUrl)
        
        // 注意: 跳转之前, 可以使用 canOpenURL: 判断是否可以跳转
        if !UIApplication.shared.canOpenURL(appURL!) {
            // 不能跳转就不要往下执行了
            return
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL!, options: [:]) { (success) in
                if (success) {
                    print("10以后可以跳转url")
                }else{
                    print("10以后不能完成跳转")
                }
            }
         } else {
            // Fallback on earlier versions
            let success = UIApplication.shared.openURL(appURL!)
            if (success) {
                print("10以下可以跳转")
            }else{
                print("10以下不能完成跳转")
            }
         }
    }
    
//    func jumpToAppStoreInApp() {
//        let storeProductVC = StoreKit.SKStoreProductViewController()
//          storeProductVC.delegate = self
//          let dict = [SKStoreProductParameterITunesItemIdentifier: "1142110895"]
//          storeProductVC.loadProduct(withParameters: dict) { (result, error) in
//             guard error == nil else {
//                  return
//             }
//           }
//           present(storeProductVC, animated: true, completion: nil)
//    }
}

