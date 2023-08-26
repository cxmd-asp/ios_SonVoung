//
//  UserModel.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/24/23.
//

import MessageKit
import RealmSwift

class UserModel: BaseModel, SenderType {
    var senderId: String
    var displayName: String

    var username: String?
    var password: String?

    init(username: String, password: String) {
        self.senderId = username
        self.displayName = username

        self.username = username
        self.password = password
    }
}

class UserObject: Object {
    @Persisted(primaryKey: true) var username = ""

    func save() {
        do {
            let realm = try Realm()
            try realm.write({
                realm.add(self, update: .modified)
            })
        } catch (let error) {
            print("UserObject:save:error: \(error.localizedDescription)")
        }
    }
}
