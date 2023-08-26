//
//  UIApplication+Extension.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/23/23.
//

import UIKit

// MARK: Constant values
extension UIApplication {
    static var getTopSafeAreaInsets: CGFloat {
        if let window = UIApplication.shared.windows.first {
            return window.safeAreaInsets.top
        }
        return 0
    }
    
    static var getBottomSafeAreaInsets: CGFloat {
        if let window = UIApplication.shared.windows.first {
            return window.safeAreaInsets.bottom
        }
        return 0
    }
}

// MARK: Get KeyWindow
extension UIApplication {
    class func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
    }
}

// MARK: Get TopViewController
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.getKeyWindow()?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
