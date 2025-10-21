
import UIKit

public protocol Navigatale {
    var navigator: SSNavigator? { get set }
}

public protocol NavigatorScene {
    func viewController() -> UIViewController?
}

public protocol NavigatorMoudle {
    static func load()
}


public extension SSNavigator {
    enum Transition {
        case root(in: UIWindow, animated: Bool)
        case navigation(animate: Bool)
        case modal
        case fullScreenModal
        case overFullScreenModal
        case modalCross
        case customModal
        case pageSheet
        case customTransitionModal(transition: UIViewControllerTransitioningDelegate)
    }
}

struct  NavigatorRegister {
    var name: String
    var params:[String:Any?]? = nil
    var load: (String, [String:Any?]?) -> NavigatorScene?
}

public class SSNavigator: NSObject {
    public static var `default` = SSNavigator()
    private var registers = [NavigatorRegister]()
    public override init() {
        super.init()
        
    }
    private var jumpTask = SSTask()
    @discardableResult
    public func show(scene: NavigatorScene,
                     sender: UIViewController?,
                     transition: Transition = .navigation(animate: true), reduceLast: Int = 0, automReduceSameNameVC: Bool = false, isAutoInSequence: Bool = false, completion: (() -> Void)? = nil) -> UIViewController? {
        if let target = scene.viewController()  {
            if !isAutoInSequence {
                show(target: target, sender: sender, transition: transition, reduceLast: reduceLast, automReduceSameNameVC: automReduceSameNameVC, completion: completion)
            } else {
                self.jumpTask.add { [weak self] todo in
                    self?.show(target: target, sender: sender, transition: transition, reduceLast: reduceLast, automReduceSameNameVC: automReduceSameNameVC, completion: {
                        todo.complete()
                        completion?()
                    })
                }
            }
            return target
        }
        return nil
    }
    
    
    
    public func pop(sender: UIViewController?, toRoot: Bool = false, animated: Bool = true, completion: (() -> Void)? = nil)  {
        if toRoot {
            sender?.navigationController?.popRootViewController(animated: animated, completion)
        }else {
            sender?.navigationController?.popViewController(animated: animated, completion)
        }
        
    }
    
    public func dimiss(sender: UIViewController?,animated: Bool = true,completion: (() -> Void)? = nil) {
        sender?.dismiss(animated: animated, completion: completion)
    }
    
    public func show(target: UIViewController,
                      sender: UIViewController?,
                      transition: Transition = .navigation(animate: true),
                      reduceLast: Int = 0,
                      automReduceSameNameVC: Bool = false,
                      completion: (() -> Void)? = nil) {
        switch transition {
        case .root(let window, let animated):
            if !animated  {
                window.rootViewController?.removeFromParent()
                window.rootViewController = nil
                window.rootViewController = target
                
            } else {
                UIView.transition(with: window, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                    let oldState = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(false)
                    window.rootViewController?.removeFromParent()
                    window.rootViewController = nil
                    window.rootViewController = target
                    UIView.setAnimationsEnabled(oldState)
                }, completion: { _ in
                    completion?()
                })
            }

           
            
        case .navigation(let animated):
            DispatchQueue.main.async {
                
                var viewControllers = sender?.navigationController?.viewControllers ?? []
                if automReduceSameNameVC, viewControllers.count > 0 {
                    if var lastVc = viewControllers.last {
                        
                        while NSStringFromClass(target.classForCoder) == NSStringFromClass(lastVc.classForCoder) {
                            viewControllers.removeLast()
                            guard let last = viewControllers.last  else  {
                                break
                            }
                            lastVc = last
                        }
                    }
                    
                }
                
                if reduceLast == 0 {
                    if viewControllers.count > 0 {
                        for _ in 0..<reduceLast {
                            viewControllers.removeLast()
                        }
                        viewControllers.append(target)
                    }
                    sender?.navigationController?.setViewControllers(viewControllers, animated: animated, completion: completion)

                } else {
                    if var viewControllers = sender?.navigationController?.viewControllers {
                        for _ in 0..<reduceLast {
                            viewControllers.removeLast()
                        }
                        viewControllers.append(target)
                        sender?.navigationController?.setViewControllers(viewControllers, animated: animated, completion: completion)
                    }
                }
            }
            
        case .modal:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                sender?.present(target, animated: true, completion: completion)
            }
            
        case .modalCross:
            target.modalTransitionStyle = .crossDissolve
            target.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                sender?.present(target, animated: true, completion: completion)
            }
        case .fullScreenModal:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .fullScreen
                sender?.present(target, animated: true, completion: completion)
            }
        case .overFullScreenModal:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .overFullScreen
                sender?.present(target, animated: true, completion: completion)
            }
            
        case .customTransitionModal(let transition):
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .fullScreen
                target.transitioningDelegate = transition
                sender?.present(target, animated: true, completion: completion)
            }
            
        case .customModal:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .custom
                sender?.present(target, animated: true, completion: completion)
            }
        case .pageSheet:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .pageSheet
                sender?.present(target, animated: true, completion: completion)
            }
        }
    }
    
    
    
    
    
    @discardableResult
    public func show(_ name: String,
                     sender: UIViewController? = nil,
                     params:[String:Any?]? = nil,
                     transition: Transition = .navigation(animate: true), reduceLast: Int = 0, automReduceSameNameVC: Bool = false) -> UIViewController? {
        if let register = registers.first(where: {$0.name == name}) {
            if let scene = register.load(name, params) {
                return show(scene: scene, sender: sender, transition: transition, reduceLast: reduceLast, automReduceSameNameVC: automReduceSameNameVC)
            }
            
        }
        return nil
    }
    
    
    
    public func viewController(name: String) -> UIViewController? {
        if let register = registers.first(where: {$0.name == name}) {
            let scene = register.load(name, register.params)
            return scene?.viewController()
        }
        return nil
    }
    
    public func loadModule(_ name: String) {
        var cl = NSClassFromString(name)
        if cl == nil {
            cl = NSClassFromString(name + "." + name)
        }
        if let type = cl as? NavigatorMoudle.Type {
            type.load()
        }
    }
        
}


extension SSNavigator {
    public func register(_ name: String, params:[String:Any?]? = nil, load:@escaping (String, [String:Any?]?) -> NavigatorScene?) {
        if !registers.contains(where: {$0.name == name}) {
            let register = NavigatorRegister(name: name, params: params, load: load)
            registers.append(register)
        }
    }
    
    public func register(_ names: [String], params:[String:Any?]? = nil, load:@escaping (String, [String:Any?]?) -> NavigatorScene?) {
        for name in names {
            if !registers.contains(where: {$0.name == name}) {
                let register = NavigatorRegister(name: name, params: params, load: load)
                registers.append(register)
            }
        }
        
    }
    
    public func canOpenUrl(url: String) -> Bool {
        checkRegister(url: url) != nil
    }
    public func openUrl(url: String, handleJump:([String: String?]?) -> Void ) {
        handleJump(checkRegister(url: url)?.1)
    }
    
    private func checkRegister(url: String) -> (NavigatorRegister, [String: String?])? {
        let components = URLComponents(string: url)
        let queryItems = components?.queryItems ?? []
        var params = [String: String?]()
        queryItems.forEach { item in
            params[item.name] = item.value
        }
        let name = components?.path
        
        if let register = registers.first(where: {
            r -> Bool in
            let nameComponents = URLComponents(string: r.name)
            return nameComponents?.scheme?.lowercased() == components?.scheme?.lowercased() &&
            nameComponents?.host == components?.host &&
            nameComponents?.path == components?.path
        }) {
            return (register, params)
        }
        return nil
    }
    
    @discardableResult
    public func openUrl(_ url: String,
                        sender: UIViewController? = nil,
                        transition: Transition = .navigation(animate: true), reduceLast: Int = 0, automReduceSameNameVC: Bool = false) -> UIViewController? {
        if let (register, params) = checkRegister(url: url) {
            if let scene = register.load(url, params) {
                return show(scene: scene, sender: sender, transition: transition, reduceLast: reduceLast, automReduceSameNameVC: automReduceSameNameVC)
            }
        }
        return nil
    }
}
