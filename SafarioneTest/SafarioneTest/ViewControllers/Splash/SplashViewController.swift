//
//  SplashViewController.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/23/23.
//

import UIKit

class SplashViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let loginViewController = R.storyboard.login.loginViewController() {
            goTo(UINavigationController(rootViewController: loginViewController))
        }
    }
}
