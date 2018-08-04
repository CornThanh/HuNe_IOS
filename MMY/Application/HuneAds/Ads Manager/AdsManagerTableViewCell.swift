//
//  AdsManagerTableViewCell.swift
//  MMY
//
//  Created by Apple on 6/12/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class AdsManagerTableViewCell: UITableViewCell {
    @IBOutlet weak var imageStatus: UIImageView!
    
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbType: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbMoney: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
