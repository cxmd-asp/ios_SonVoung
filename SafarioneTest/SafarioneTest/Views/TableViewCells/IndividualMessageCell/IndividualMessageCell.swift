//
//  IndividualMessageCell.swift
//  SafarioneTest
//
//  Created by Vuong Son on 8/23/23.
//

import UIKit

class IndividualMessageCell: BaseTableViewCell {
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: Override actions
extension IndividualMessageCell {
    override func setData(_ data: Any?) {
        guard let message = data as? MessageModel else { return }
        if let savedUser = AppSessionData.shared.currentUser {
            if savedUser.username != message.sender.senderId {
                primaryLabel.text = message.sender.displayName
            } else {
                primaryLabel.text = message.receiver.displayName
            }
        }
        switch message.kind {
        case .text(let value):
            secondaryLabel.text = message.sentDate.toLocal().toString(.custom1) + " - " + value
        default:
            break
        }
    }
}
