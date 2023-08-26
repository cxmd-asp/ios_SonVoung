//
//  ContactCell.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/24/23.
//

import UIKit

class ContactCell: BaseTableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: Override actions
extension ContactCell {
    override func setData(_ data: Any?) {
        guard let user = data as? UserModel else { return }
        if let username = user.username {
            usernameLabel.text = username
        }
    }
}
