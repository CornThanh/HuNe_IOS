//
//  ManageOrderTableViewCell.swift
//  MMY
//
//  Created by Apple on 7/21/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class ManageOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var lbOrder: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
