//
//  TabBarViewController.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxSwift
import RxCocoa

open class TabBarViewController: UITabBarController,Navigatale {

    public private(set) var viewModel: ViewModel?
    public var navigator: Navigator?
    init(viewModel: ViewModel? = nil, navigator: Navigator? = nil) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        self.tabBar.barTintColor = .white
//        self.tabBar.backgroundImage = UIImage(color: .white)
//        self.tabBar.shadowImage = UIImage(named: R.image.tabbar_shadow.name)
        // Do any additional setup after loading the view.
        
        self.setValue(Tabbar(), forKey: "tabBar")
    }
    

    open override var childForStatusBarHidden: UIViewController? {
        return self.selectedViewController
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.selectedViewController
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension Reactive where Base: UITabBarController {

    var viewControllers: Binder<[UIViewController]> {
        return Binder(self.base) { view, attr in
            view.viewControllers = attr
        }
    }
    
}
