//
//  RealmManager.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/24/23.
//

import RealmSwift

class RealmManager: NSObject {
    static let shared = RealmManager()
}

// MARK: Public methods
extension RealmManager {
    func configureFor(_ user: UserModel) {
        var config = Realm.Configuration(
            schemaVersion: 0,
            deleteRealmIfMigrationNeeded: true
        )
        if let fileURL = config.fileURL,
           let username = user.username, !username.isEmpty {
            config.fileURL = fileURL
                .deletingLastPathComponent()
                .appendingPathComponent(username)
                .appendingPathExtension(".realm")
        }
        Realm.Configuration.defaultConfiguration = config
    }
}

// MARK: MessageObject
extension RealmManager {
    func getAllMessagesGroupedByUser() -> [MessageModel] {
        do {
            let realm = try Realm()
            let objects = realm
                .objects(MessageObject.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
                .distinct(by: ["groupId"])
                .toArray(ofType: MessageObject.self)
            return objects.map({ $0.toMessageModel() })
        } catch (let error) {
            print("RealmManager:getAllMessagesGroupedByUser:error: \(error.localizedDescription)")
        }
        return []
    }

    func getAllMessagesWithUser(user: UserModel?) -> [MessageModel] {
        guard let savedUser = AppSessionData.shared.currentUser,
              let savedUsername = savedUser.username,
              let targetUser = user,
              let targetUsername = targetUser.username else { return [] }
        do {
            let realm = try Realm()
            let objects = realm
                .objects(MessageObject.self)
                .sorted(byKeyPath: "createdAt", ascending: true)
                .filter("(sender.username == %@ AND receiver.username == %@) OR (sender.username == %@ AND receiver.username == %@)", savedUsername, targetUsername, targetUsername, savedUsername)
                .toArray(ofType: MessageObject.self)
            return objects.map({ $0.toMessageModel() })
        } catch (let error) {
            print("RealmManager:getAllMessagesWithUser:error: \(error.localizedDescription)")
        }
        return []
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for result in self {
            if let element = result as? T {
                array.append(element)
            }
        }
        return array
    }
}
