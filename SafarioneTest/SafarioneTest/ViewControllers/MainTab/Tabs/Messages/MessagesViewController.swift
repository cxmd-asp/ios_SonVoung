//
//  MessagesViewController.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/23/23.
//

import UIKit

class MessagesViewController: BaseViewController {
    @IBOutlet weak var baseTableView: UITableView! {
        didSet {
            baseTableView.dataSource = self
            baseTableView.delegate = self
        }
    }

    private var allMessages: [MessageModel] = RealmManager.shared.getAllMessagesGroupedByUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        baseTableView.register(UINib(nibName: "IndividualMessageCell", bundle: nil), forCellReuseIdentifier: "IndividualMessageCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allMessages = RealmManager.shared.getAllMessagesGroupedByUser()
        baseTableView.reloadData()
    }
}

// MARK: Observers
extension MessagesViewController {
    override func addObservers() {
        super.addObservers()
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(updateMessages),
                name: NSNotification.Name.updateChat,
                object: nil
            )
    }
}

// MARK: Observers
extension MessagesViewController {
    @objc func updateMessages() {
        allMessages = RealmManager.shared.getAllMessagesGroupedByUser()
        baseTableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "IndividualMessageCell") as? IndividualMessageCell {
            cell.setData(allMessages[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
}

// MARK: UITableViewDelegate
extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let chatViewController = ChatViewController()
        chatViewController.sender = AppSessionData.shared.currentUser
        if let savedUser = AppSessionData.shared.currentUser {
            if savedUser.username != allMessages[indexPath.row].sender.senderId {
                chatViewController.receiver = allMessages[indexPath.row].sender as? UserModel
            } else {
                chatViewController.receiver = allMessages[indexPath.row].receiver as? UserModel
            }
            smartPush(chatViewController)
        }
    }
}
