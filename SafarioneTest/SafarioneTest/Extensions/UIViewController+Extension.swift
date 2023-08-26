//
//  UIViewController+Extension.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/23/23.
//

import KVLoading
import UIKit

// MARK: Move to ...
extension UIViewController {
    func goTo(_ viewController: UIViewController?) {
        guard let window = UIApplication.getKeyWindow(),
              UIApplication.shared.applicationState == .active else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.goTo(viewController)
            }
            return
        }

        DispatchQueue.main.async {
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = CATransitionType.fade
            window.layer.add(transition, forKey: kCATransition)
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }

    func smartPresent(_ viewController: UIViewController, animated: Bool = true) {
        viewController.modalPresentationStyle = .fullScreen

        var smartPresentedViewController: UIViewController?
        if let tabBarController = tabBarController {
            if let navigationController = tabBarController.navigationController {
                if let targetViewController = navigationController.presentedViewController {
                    smartPresentedViewController = targetViewController
                }
            } else {
                if let targetViewController = tabBarController.presentedViewController {
                    smartPresentedViewController = targetViewController
                }
            }
        } else {
            if let navigationController = navigationController {
                if let targetViewController = navigationController.presentedViewController {
                    smartPresentedViewController = targetViewController
                }
            } else {
                if let targetViewController = presentedViewController {
                    smartPresentedViewController = targetViewController
                }
            }
        }
        DispatchQueue.main.async {
            if let smartPresentedViewController = smartPresentedViewController {
                smartPresentedViewController.present(viewController, animated: animated)
            } else {
                self.present(viewController, animated: animated)
            }
        }
    }

    func smartPush(_ viewController: UIViewController, animated: Bool = true) {
        var smartPushNavigationController: UINavigationController?
        if let tabBarController = tabBarController {
            if let navigationController = tabBarController.navigationController {
                smartPushNavigationController = navigationController
            }
        } else {
            if let navigationController = navigationController {
                smartPushNavigationController = navigationController
            }
        }
        DispatchQueue.main.async {
            if let smartPushNavigationController = smartPushNavigationController {
                if let baseViewController = viewController as? BaseViewController {
                    baseViewController.previousViewController = smartPushNavigationController.viewControllers.last
                }
                smartPushNavigationController.pushViewController(viewController, animated: animated)
            }
        }
    }
}

// MARK: KVLoading
extension UIViewController {
    @objc func showLoadingInView(_ view: UIView, customView: UIView? = nil, timeout: Int = 66, animated: Bool = true) {
        DispatchQueue.main.async {
            if timeout > 0 {
                UIView.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideLoading(animated:)), object: nil)
                self.perform(#selector(self.hideLoading(animated:)), with: nil, afterDelay: TimeInterval(timeout))
            }
            KVLoading.shared.showInView(view: view, customView: customView, animated: animated)
        }
    }

    @objc func showLoading(_ customView: UIView? = nil, timeout: Int = 66, animated: Bool = true) {
        guard let window = UIApplication.getKeyWindow() else { return }
        DispatchQueue.main.async {
            self.showLoadingInView(window, customView: customView, timeout: timeout, animated: animated)
        }
    }

    @objc func hideLoading(animated: Bool = true) {
        DispatchQueue.main.async {
            UIView.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideLoading(animated:)), object: nil)
            KVLoading.shared.hide(animated: animated)
        }
    }
}
