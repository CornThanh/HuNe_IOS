//
//  ProductMartCollectionViewCell.swift
//  MMY
//
//  Created by Apple on 7/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class ProductMartCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lbNameSeller: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbNameProduct: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
