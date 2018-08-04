//
//  DefaultFindJobCollectionViewCell.swift
//  MMY
//
//  Created by Apple on 4/20/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import Kingfisher

class DefaultFindJobCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageJob: UIImageView!
    
    @IBOutlet weak var lbNameJob: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCategoryCell(category: CategoryModel) {
        lbNameJob.text = category.name
        let url = URL(string: (category.icon?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed))!)
        self.imageJob.kf.setImage(with: url, placeholder: UIImage(named: "default_category_white"))
    }

}
