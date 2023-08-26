//
//  BaseViewController.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/24/23.
//

import UIKit

class BaseViewController: UIViewController {

    var previousViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
    }

    deinit {
        removeObservers()
    }
}

// MARK: Observers
extension BaseViewController {
    @objc func addObservers() {
        // TO DO
    }

    @objc func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Public actions
extension BaseViewController {
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        // TO DO
    }
}
