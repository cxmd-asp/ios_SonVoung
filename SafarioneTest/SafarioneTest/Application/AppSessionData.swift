//
//  AppSessionData.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/24/23.
//

import UIKit

class AppSessionData: NSObject {
    static let shared = AppSessionData()

    var currentUser: UserModel?
}
