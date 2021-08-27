
  import UIKit
  
  public protocol Navigatale {
    var navigator: Navigator? { get set }
  }
  
  public protocol NavigatorScene {
    func viewController() -> UIViewController?
  }
  
  public extension Navigator {
    enum Transition {
        case root(in: UIWindow)
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
  
  public class Navigator {
    static var `default` = Navigator()
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
            sender?.navigationController?.popToRootViewController(animated: animated)
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
        case .root(let window):
            window.rootViewController?.removeFromParent()
            window.rootViewController = nil
            window.rootViewController = target
            
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
    
    
  }
  
  
