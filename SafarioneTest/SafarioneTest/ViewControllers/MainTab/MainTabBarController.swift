//
//  MainTabBarController.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/23/23.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        title = "SafarioneTest"
        let cachedTab0ViewController = R.storyboard.messages.messagesViewController()
        let cachedTab1ViewController = R.storyboard.contact.contactViewController()
        if let tab0ViewController = cachedTab0ViewController,
           let tab1ViewController = cachedTab1ViewController {
            viewControllers = [
                tab0ViewController,
                tab1ViewController,
            ]

            tab0ViewController.tabBarItem.image = UIImage(systemName: "ellipsis.message.fill")
            tab0ViewController.tabBarItem.title = "Messages"
            tab1ViewController.tabBarItem.image = UIImage(systemName: "person.crop.circle.fill")
            tab1ViewController.tabBarItem.title = "Contact"

            tabBar.backgroundColor = UIColor.white
            tabBar.unselectedItemTintColor = UIColor.black
            tabBar.tintColor = UIColor.systemTeal

            tabBar.clipsToBounds = true
            tabBar.layer.borderColor = UIColor.separator.cgColor
            tabBar.layer.borderWidth = 0.5

            let allMessages = RealmManager.shared.getAllMessagesGroupedByUser()
            if !allMessages.isEmpty {
                selectedIndex = 0
                title = "Messages"
            } else {
                selectedIndex = 1
                title = "Contact"
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        XMPPManager.shared.fetchRoster()
    }
}

// MARK: UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is MessagesViewController {
            title = "Messages"
        } else if viewController is ContactViewController {
            title = "Contact"
        }
    }
}
