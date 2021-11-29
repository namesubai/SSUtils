//
//  TabBarViewController.swift
//  
//
//  Created by yangsq on 2020/10/20.
//

import UIKit
import RxSwift
import RxCocoa


public struct TabBarItem {
    public var title:String?
    public var normalImage: UIImage?
    public var selectedImage: UIImage?
    public var normalTitleColor: UIColor?
    public var selectedTitleColor: UIColor?
    public var viewController: UIViewController
    public init(title: String? = nil,
         normalImage: UIImage?,
         selectedImage: UIImage?,
         normalTitleColor: UIColor? = nil,
         selectedTitleColor: UIColor? = nil,
         viewController: UIViewController) {
        self.title = title
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.normalTitleColor = normalTitleColor
        self.selectedTitleColor = selectedTitleColor
        self.viewController = viewController
    }
}

open class TabBarViewController: UITabBarController,Navigatale {

    public private(set) var viewModel: ViewModel?
    public var navigator: Navigator?
    public init(viewModel: ViewModel? = nil, navigator: Navigator? = nil) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    public var customTabBar: Tabbar {
        return self.tabBar as! Tabbar
    }
    
    required public init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        self.tabBar.backgroundImage = UIImage(color: .white)
//        self.tabBar.shadowImage = UIImage(named: R.image.tabbar_shadow.name)
        // Do any additional setup after loading the view.
        
        self.setValue(Tabbar(), forKey: "tabBar")
        self.tabBar.barTintColor = Colors.tabBarBackgroud
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = Colors.tabBarBackgroud
//            appearance.backgroundEffect = UIBlurEffect(style: .light)
//            appearance.backgroundColor = Colors.tabBarBackgroud.withAlphaComponent(0.9)
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
        
        make()
        bind()
    }
    
    open func make() {
        
    }
    
    open func bind() {
        
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

public extension UITabBarController {
    func hideTabbar(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .layoutSubviews) {
                self.tabBar.ss_y = App.height
            } completion: { finish in
                
            }

        } else {
            self.tabBar.ss_y = App.height
        }
       
    }
    
    func showTabbar(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.tabBar.ss_y = App.height - self.tabBar.ss_h
            }
        } else {
            self.tabBar.ss_y = App.height - self.tabBar.ss_h
        }
    }
}


public extension Reactive where Base: UITabBarController {

    var viewControllers: Binder<[UIViewController]> {
        return Binder(self.base) { view, attr in
            view.viewControllers = attr
        }
    }
    
}
