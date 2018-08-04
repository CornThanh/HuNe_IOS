//
//  CouponCollectionViewCell.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/31/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class CouponCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var btnBuy: UIButton?

    var handleBuyAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        btnBuy?.setTitle("Buy".localized(), for: .normal)
    }

    @IBAction func handleBtnBuyTouched(_ sender: Any) {
        handleBuyAction?()
    }

}
