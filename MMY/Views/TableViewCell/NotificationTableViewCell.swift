//
//  NotificationTableViewCell.swift
//  MMY
//
//  Created by Minh tuan on 7/29/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var contentLB: UILabel!
    @IBOutlet weak var dateLB: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateWithNotification(notification: NotificationModel) {
        self.titleLB.text = notification.title
        self.contentLB.text = notification.content
        self.dateLB.text = notification.created_at
    }
    
}
