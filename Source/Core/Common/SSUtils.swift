//
//  SSUtils.swift
//  SSUtils
//
//  Created by Shuqy on 2022/11/11.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

public let keyWindowVM = ViewModel()
public class SSUtilsMoudle: NavigatorMoudle {
    public static func load() {
        if let keyWindow = App.mainWindow {
            keyWindowVM.loading.asObservable().subscribe(on: MainScheduler.instance).subscribe(onNext:{
                isLoad in
                if isLoad {
                    keyWindow.showLoadingHUD()
                } else {
                    keyWindow.hideHUD()
                }
            }).disposed(by: keyWindow.rx.disposeBag)
            
            keyWindowVM.clearLoading.asObservable().subscribe(on: MainScheduler.instance).subscribe(onNext:{
                isLoad in
                if isLoad {
                    keyWindow.showLoadingHUD(maskType: .clear)
                } else {
                    keyWindow.hideHUD()
                }
            }).disposed(by: keyWindow.rx.disposeBag)
            
        }
        #if DEBUG
        setupDLog()
        #endif
    }
    
   
    
}
