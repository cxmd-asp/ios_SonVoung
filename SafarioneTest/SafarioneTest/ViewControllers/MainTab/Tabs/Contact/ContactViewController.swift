//
//  ContactViewController.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/23/23.
//

import UIKit

class ContactViewController: BaseViewController {
    @IBOutlet weak var baseTableView: UITableView! {
        didSet {
            baseTableView.dataSource = self
            baseTableView.delegate = self
        }
    }

    var allFriends: [UserModel] = [
        UserModel(
            username: "909196671061",
            password: ""
        ),
        UserModel(
            username: "909824830353",
            password: ""
        ),
        UserModel(
            username: "909810565026",
            password: ""
        ),
        UserModel(
            username: "909726822209",
            password: ""
        ),
        UserModel(
            username: "909673129072",
            password: ""
        ),
        UserModel(
            username: "909352982193",
            password: ""
        ),
        UserModel(
            username: "909394105461",
            password: ""
        ),
        UserModel(
            username: "909785876597",
            password: ""
        ),
        UserModel(
            username: "909769646054",
            password: ""
        ),
        UserModel(
            username: "909230524267",
            password: ""
        ),
        UserModel(
            username: "909725319593",
            password: ""
        ),
        UserModel(
            username: "909293654285",
            password: ""
        ),
        UserModel(
            username: "909609412760",
            password: ""
        ),
        UserModel(
            username: "909314268942",
            password: ""
        ),
        UserModel(
            username: "909369272283",
            password: ""
        ),
        UserModel(
            username: "909369862943",
            password: ""
        ),
        UserModel(
            username: "909171221894",
            password: ""
        ),
        UserModel(
            username: "908517758688",
            password: ""
        ),
        UserModel(
            username: "909128920474",
            password: ""
        ),
        UserModel(
            username: "908915696685",
            password: ""
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contact"
        baseTableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        if let currentUser = AppSessionData.shared.currentUser {
            allFriends = allFriends
                .filter({ $0.username != currentUser.username })
        }
    }
}

// MARK: UITableViewDataSource
extension ContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as? ContactCell {
            cell.setData(allFriends[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
}

// MARK: UITableViewDelegate
extension ContactViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let chatViewController = ChatViewController()
        chatViewController.sender = AppSessionData.shared.currentUser
        chatViewController.receiver = allFriends[indexPath.row]
        smartPush(chatViewController)
    }
}
