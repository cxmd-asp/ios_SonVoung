//
//  MessageModel.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/24/23.
//

import MessageKit
import RealmSwift

class MessageModel: BaseModel, MessageType {
    var sender: MessageKit.SenderType
    var receiver: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
    var groupId: String = ""

    init(
        sender: MessageKit.SenderType,
        receiver: MessageKit.SenderType,
        messageId: String,
        sentDate: Date,
        kind: MessageKit.MessageKind
    ) {
        self.sender = sender
        self.receiver = receiver
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
        if let savedUser = AppSessionData.shared.currentUser,
           let savedUsername = savedUser.username,
           let _sender = sender as? UserModel, let senderUsername = _sender.username,
           let _receiver = receiver as? UserModel, let receiverUsername = _receiver.username {
            if savedUsername == senderUsername {
                groupId = senderUsername + "+" + receiverUsername
            } else {
                groupId = receiverUsername + "+" + senderUsername
            }
        }
    }
}

class MessageObject: Object {
    @Persisted(primaryKey: true) var messageId = ""
    @Persisted var groupId: String = ""
    @Persisted var sender: UserObject?
    @Persisted var receiver: UserObject?
    @Persisted var createdAt = Date()
    @Persisted var content: String = ""

    func toMessageModel() -> MessageModel {
        let message = MessageModel(
            sender: UserModel(
                username: sender?.username ?? "undefined",
                password: ""
            ),
            receiver: UserModel(
                username: receiver?.username ?? "undefined",
                password: ""
            ),
            messageId: messageId,
            sentDate: createdAt,
            kind: .text(content)
        )
        message.groupId = groupId
        return message
    }

    func save() {
        do {
            let realm = try Realm()
            try realm.write({
                realm.add(self, update: .modified)
            })
        } catch (let error) {
            print("MessageObject:save:error: \(error.localizedDescription)")
        }
    }
}
