//
//  LoginViewController.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/24/23.
//

import IBAnimatable
import UIKit

class LoginViewController: BaseViewController {
    @IBOutlet weak var usernameTextField: AnimatableTextField!
    @IBOutlet weak var passwordTextField: AnimatableTextField!
    @IBOutlet weak var loginButton: AnimatableButton! {
        didSet {
            loginButton.isEnabled = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        usernameTextField?.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField?.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
}

// MARK: Override actions
extension LoginViewController {
    override func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case usernameTextField:
            validateData()
        case passwordTextField:
            validateData()
        default:
            break
        }
    }
}

// MARK: IBActions
extension LoginViewController {
    @IBAction func clickToLogin(_ button: UIButton) {
        hideKeyboard()
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else { return }
        let user = UserModel(username: username, password: password)
        showLoading()
        XMPPManager.shared.connect(
            user: user,
            completion: { [weak self] (isSuccess) in
                guard let weakSelf = self else { return }
                DispatchQueue.main.async {
                    weakSelf.hideLoading()
                    if isSuccess {
                        AppSessionData.shared.currentUser = user
                        RealmManager.shared.configureFor(user)
                        let mainTabBarController = MainTabBarController()
                        weakSelf.goTo(UINavigationController(rootViewController: mainTabBarController))
                    }
                }
            }
        )
    }
}

// MARK: Actions
extension LoginViewController {
    func validateData() {
        var isNext = true
        if let username = usernameTextField.text, username.isEmpty {
            isNext = false
        }
        if let password = passwordTextField.text, password.isEmpty {
            isNext = false
        }
        loginButton.isEnabled = isNext
    }
}
