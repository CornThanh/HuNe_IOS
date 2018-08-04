//
//  NotiAdsTableViewCell.swift
//  MMY
//
//  Created by Apple on 5/3/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class NotiAdsTableViewCell: UITableViewCell {
    @IBOutlet weak var lbNameStore: UILabel!
    @IBOutlet weak var tfLocation: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
