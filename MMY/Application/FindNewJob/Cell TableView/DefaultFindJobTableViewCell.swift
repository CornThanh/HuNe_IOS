//
//  DefaultFindJobTableViewCell.swift
//  MMY
//
//  Created by Apple on 4/20/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class DefaultFindJobTableViewCell: UITableViewCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var btEdit: UIButton!
    @IBOutlet weak var btCheck: UIButton!
    @IBOutlet weak var lbOn: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
