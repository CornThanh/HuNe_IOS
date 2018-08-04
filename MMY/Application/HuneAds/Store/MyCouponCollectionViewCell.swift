//
//  MyCouponCollectionViewCell.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/31/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class MyCouponCollectionViewCell: CouponCollectionViewCell {


    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCode: UILabel!
    @IBOutlet weak var btnCopy: UIButton!
    var handleCopyAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        btnCopy.setTitle("Copy".localized(), for: .normal)
    }

    @IBAction func handleBtnCopyTouched(_ sender: Any) {
        handleCopyAction?()
    }

}
