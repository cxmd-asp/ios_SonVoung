//
//  ChatViewController.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/24/23.
//

import InputBarAccessoryView
import MessageKit
import UIKit

class ChatViewController: MessageKit.MessagesViewController {

    var sender: UserModel?
    var receiver: UserModel?

    lazy var allMessages: [MessageModel] = RealmManager.shared.getAllMessagesWithUser(user: receiver)

    private var isScrollToLastItemAtFirstLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = receiver?.username
        addObservers()
        configureMessageCollectionView()
        configureMessageInputBar()
        messagesCollectionView.alpha = 0.0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isScrollToLastItemAtFirstLoad {
            isScrollToLastItemAtFirstLoad = true
            messagesCollectionView.alpha = 1.0
            messagesCollectionView.scrollToLastItem(animated: false)
        }
    }

    deinit {
        removeObservers()
    }
}

// MARK: Actions
extension ChatViewController {
    func addObservers() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(updateMessages),
                name: NSNotification.Name.updateChat,
                object: nil
            )
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = UIColor.red
        messageInputBar.sendButton.setTitleColor(UIColor.red, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor.red.withAlphaComponent(0.3), for: .highlighted)
    }

    @objc func updateMessages() {
        allMessages = RealmManager.shared.getAllMessagesWithUser(user: receiver)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}

// MARK: MessagesDataSource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        if let _sender = sender {
            return _sender
        }
        fatalError()
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return allMessages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return allMessages.count
    }
}

// MARK: MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
}

// MARK: MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
}

// MARK: MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
}

// MARK: InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if let _receiver = receiver {
            inputBar.inputTextView.text = ""
            XMPPManager.shared.sendMessage(text, to: _receiver)
        }
    }
}
