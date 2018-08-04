//
//  PromotionTableViewCell.swift
//  MMY
//
//  Created by Apple on 6/13/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class PromotionTableViewCell: UITableViewCell {
    @IBOutlet weak var imagePromotion: UIImageView!
    @IBOutlet weak var lbTitlePromotion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
