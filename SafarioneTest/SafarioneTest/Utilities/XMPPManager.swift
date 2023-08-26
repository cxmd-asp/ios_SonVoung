//
//  XMPPManager.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/23/23.
//

import XMPPFramework

class XMPPManager: NSObject {
    static var shared = XMPPManager()

    private var xmppStream = XMPPStream()
    private var xmppReconnect = XMPPReconnect()
    private var xmppRosterCoreDataStorage = XMPPRosterCoreDataStorage()
    private lazy var xmppRoster = XMPPRoster(rosterStorage: xmppRosterCoreDataStorage)
    private var xmppMessageArchiveManagement = XMPPMessageArchiveManagement()
    private var cachedPassword = ""

    private(set) var allFriends = [String]()
    private(set) var onlineFriends = [String]()

    private var connectClosure: ((Bool) -> Void)?

    func connect(user: UserModel, completion: ((Bool) -> Void)?) {
        if xmppStream.isConnected {
            return
        }
        if xmppStream.isConnecting {
            return
        }
        guard let username = user.username,
              let password = user.password else {
            return
        }
        cachedPassword = password
        xmppStream.addDelegate(self, delegateQueue: .main)
        xmppStream.hostName = Constant.host
        xmppStream.myJID = XMPPJID(string: username + "@" + Constant.host)
        xmppStream.hostPort = Constant.port

        xmppRoster.activate(xmppStream)
        xmppRoster.addDelegate(self, delegateQueue: .main)

        xmppMessageArchiveManagement.activate(xmppStream)
        xmppMessageArchiveManagement.addDelegate(self, delegateQueue: .main)

        connectClosure = completion
        xmppReconnect.activate(xmppStream)
        xmppReconnect.manualStart()
    }

    func disconnect() {
        // Go offline
        let xmppPresence = XMPPPresence(type: "unavailable")
        xmppStream.send(xmppPresence)
        xmppStream.disconnectAfterSending()
    }

    func fetchRoster() {
        xmppRoster.fetch()
    }

    func sendMessage(_ text: String, to user: UserModel) {
        if let username = user.username {
            let receiver = XMPPJID(string: username + "@" + Constant.host)
            let message = XMPPMessage(type: "chat", to: receiver)
            message.addAttribute(withName: "messageId", stringValue: XMPPStream.generateUUID)
            message.addAttribute(withName: "createdAt", stringValue: Date().toUTC().toString(.iso8601))
            if let string = xmppStream.myJID?.user, !string.isEmpty {
                message.addAttribute(withName: "sender", stringValue: string)
            }
            if let string = user.username, !string.isEmpty {
                message.addAttribute(withName: "receiver", stringValue: string)
            }
            message.addBody(text)
            xmppStream.send(message)
        }
    }
}

// MARK: XMPPStreamDelegate
extension XMPPManager: XMPPStreamDelegate {
    func xmppStreamWillConnect(_ sender: XMPPStream) {
        print("xmppStreamWillConnect")
    }

    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("xmppStreamConnectDidTimeout")
    }

    func xmppStream(_ sender: XMPPStream, socketDidConnect socket: GCDAsyncSocket) {
        print("sender:socketDidConnect:socket")
    }

    func xmppStreamDidConnect(_ sender: XMPPStream) {
        print("xmppStreamDidConnect")
        if let user = sender.myJID?.bare as? String {
            print("xmppStreamDidConnect:Connected as user: \(user)")
            do {
                try sender.authenticate(withPassword: cachedPassword)
                connectClosure?(true)
            } catch let error {
                print("xmppStreamDidConnect:error: \(error.localizedDescription)")
                connectClosure?(false)
            }
        }
    }

    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("xmppStreamDidAuthenticate")
        // Go online
        let xmppPresence = XMPPPresence()
        xmppStream.send(xmppPresence)
    }

    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("sender:didNotAuthenticate:error: \(error)")
    }

    func xmppStreamDidChangeMyJID(_ xmppStream: XMPPStream) {
        print("xmppStreamDidChangeMyJID")
        if let myJID = xmppStream.myJID?.bare as? String {
            print("xmppStreamDidChangeMyJID:Stream: new JID: \(myJID)")
        }
    }

    func xmppStream(_ sender: XMPPStream, willReceive iq: XMPPIQ) -> XMPPIQ? {
        print("sender:willReceive:iq: \(iq)")
        return iq
    }

    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        print("sender:didReceive:iq: \(iq)")
        return true
    }

    func xmppStream(_ sender: XMPPStream, willReceive message: XMPPMessage) -> XMPPMessage? {
        print("sender:willReceive:message: \(message)")
        return message
    }

    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("sender:didReceive:message: \(message)")
        if message.type == "chat" {
            if let messageId = message.attribute(forName: "messageId")?.stringValue, !messageId.isEmpty,
               let sender = message.attribute(forName: "sender")?.stringValue, !sender.isEmpty,
               let receiver = message.attribute(forName: "receiver")?.stringValue, !receiver.isEmpty,
               let createdAt = message.attribute(forName: "createdAt")?.stringValue?.toDate(.iso8601),
               let content = message.body, !content.isEmpty {
                let senderObject = UserObject()
                senderObject.username = sender
                let receiverObject = UserObject()
                receiverObject.username = receiver

                let messageObject = MessageObject()
                messageObject.messageId = messageId
                messageObject.sender = senderObject
                messageObject.receiver = receiverObject
                if let savedUser = AppSessionData.shared.currentUser,
                   let savedUsername = savedUser.username {
                    let senderUsername = senderObject.username
                    let receiverUsername = receiverObject.username
                    if savedUsername == senderUsername {
                        messageObject.groupId = senderUsername + "+" + receiverUsername
                    } else {
                        messageObject.groupId = receiverUsername + "+" + senderUsername
                    }
                }
                messageObject.createdAt = createdAt
                messageObject.content = content
                messageObject.save()

                NotificationCenter.default.post(name: Notification.Name.updateChat, object: nil)
            }
        }
    }

    func xmppStream(_ sender: XMPPStream, willReceive presence: XMPPPresence) -> XMPPPresence? {
        print("sender:willReceive:presence: \(presence)")
        return presence
    }

    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        print("sender:didReceive:presence: \(presence)")
    }

    func xmppStream(_ sender: XMPPStream, willSend message: XMPPMessage) -> XMPPMessage? {
        print("sender:willSend:message: \(message)")
        return message
    }

    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("sender:didSend:message: \(message)")
        if message.type == "chat" {
            if let messageId = message.attribute(forName: "messageId")?.stringValue, !messageId.isEmpty,
               let sender = message.attribute(forName: "sender")?.stringValue, !sender.isEmpty,
               let receiver = message.attribute(forName: "receiver")?.stringValue, !receiver.isEmpty,
               let createdAt = message.attribute(forName: "createdAt")?.stringValue?.toDate(.iso8601),
               let content = message.body, !content.isEmpty {
                let senderObject = UserObject()
                senderObject.username = sender
                let receiverObject = UserObject()
                receiverObject.username = receiver

                let messageObject = MessageObject()
                messageObject.messageId = messageId
                messageObject.sender = senderObject
                messageObject.receiver = receiverObject
                if let savedUser = AppSessionData.shared.currentUser,
                   let savedUsername = savedUser.username {
                    let senderUsername = senderObject.username
                    let receiverUsername = receiverObject.username
                    if savedUsername == senderUsername {
                        messageObject.groupId = senderUsername + "+" + receiverUsername
                    } else {
                        messageObject.groupId = receiverUsername + "+" + senderUsername
                    }
                }
                messageObject.createdAt = createdAt
                messageObject.content = content
                messageObject.save()

                NotificationCenter.default.post(name: Notification.Name.updateChat, object: nil)
            }
        }
    }

    func xmppStream(_ sender: XMPPStream, didFailToSend message: XMPPMessage, error: Error) {
        print("sender:didFailToSend:message: \(message), error: \(error.localizedDescription)")
    }
}

// MARK: XMPPRosterDelegate
extension XMPPManager: XMPPRosterDelegate {
    func xmppRoster(_ sender: XMPPRoster, didReceiveRosterItem item: DDXMLElement) {
        print("sender:didReceiveRosterItem:item: \(item)")
    }
}

// MARK: XMPPMessageArchiveManagementDelegate
extension XMPPManager: XMPPMessageArchiveManagementDelegate {
    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didFinishReceivingMessagesWith resultSet: XMPPResultSet) {
        print("xmppMessageArchiveManagement:didFinishReceivingMessagesWith:resultSet: \(resultSet)")
    }

    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didReceiveMAMMessage message: XMPPMessage) {
        print("xmppMessageArchiveManagement:didReceiveMAMMessage:message: \(message)")
    }

    func xmppMessageArchiveManagement(_ xmppMessageArchiveManagement: XMPPMessageArchiveManagement, didFailToReceiveMessages error: XMPPIQ?) {
        print("xmppMessageArchiveManagement:didFailToReceiveMessages:error")
    }
}
