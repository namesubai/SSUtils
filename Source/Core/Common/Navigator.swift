
import UIKit

public protocol Navigatale {
    var navigator: Navigator? { get set }
}

public protocol NavigatorScene {
    func viewController() -> UIViewController?
}

public protocol NavigatorMoudle {
    static func load()
}


public extension Navigator {
    enum Transition {
        case root(in: UIWindow, animated: Bool)
        case navigation
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

public class Navigator: NSObject {
    public static var `default` = Navigator()
    private var registers = [NavigatorRegister]()
    public override init() {
        super.init()
        
    }
    @discardableResult
    public func show(scene: NavigatorScene,
                     sender: UIViewController?,
                     transition: Transition = .navigation, reduceLast: Int = 0) -> UIViewController? {
        if let target = scene.viewController()  {
            show(target: target, sender: sender, transition: transition, reduceLast: reduceLast)
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
    
    private func show(target: UIViewController,
                      sender: UIViewController?,
                      transition: Transition,
                      reduceLast: Int = 0) {
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
                })
            }

           
            
        case .navigation:
            DispatchQueue.main.async {
                if reduceLast == 0 {
                    sender?.navigationController?.pushViewController(target, animated: true)
                } else {
                    if var viewControllers = sender?.navigationController?.viewControllers {
                        for _ in 0..<reduceLast {
                            viewControllers.removeLast()
                        }
                        viewControllers.append(target)
                        sender?.navigationController?.setViewControllers(viewControllers, animated: true)
                    }
                }
            }
            
        case .modal:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                sender?.present(target, animated: true, completion: nil)
            }
            
        case .modalCross:
            target.modalTransitionStyle = .crossDissolve
            target.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                sender?.present(target, animated: true, completion: nil)
            }
        case .fullScreenModal:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .fullScreen
                sender?.present(target, animated: true, completion: nil)
            }
        case .overFullScreenModal:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .overFullScreen
                sender?.present(target, animated: true, completion: nil)
            }
            
        case .customTransitionModal(let transition):
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .fullScreen
                target.transitioningDelegate = transition
                sender?.present(target, animated: true, completion: nil)
            }
            
        case .customModal:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .custom
                sender?.present(target, animated: true, completion: nil)
            }
        case .pageSheet:
            DispatchQueue.main.async {
                target.modalPresentationCapturesStatusBarAppearance = true
                target.modalPresentationStyle = .pageSheet
                sender?.present(target, animated: true, completion: nil)
            }
        }
    }
    
    
    public func register(_ name: String, params:[String:Any?]? = nil, load:@escaping (String, [String:Any?]?) -> NavigatorScene?) {
        if !registers.contains(where: {$0.name == name}) {
            let register = NavigatorRegister(name: name, params: params, load: load)
            registers.append(register)
        }
    }
    
    @discardableResult
    public func show(_ name: String,
                     sender: UIViewController? = nil,
                     params:[String:Any?]? = nil,
                     transition: Transition = .navigation, reduceLast: Int = 0) -> UIViewController? {
        if let register = registers.first(where: {$0.name == name}) {
            if let scene = register.load(name, params) {
                return show(scene: scene, sender: sender, transition: transition, reduceLast: reduceLast)
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


