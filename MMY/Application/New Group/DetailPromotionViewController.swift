//
//  DetailPromotionViewController.swift
//  MMY
//
//  Created by Apple on 6/24/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import SDWebImage

class DetailPromotionViewController: UIViewController {
    
    @IBOutlet weak var lbNamePromotion: UILabel!
    @IBOutlet weak var imagePromotion: UIImageView!
    @IBOutlet weak var lbTitleLoction: UILabel!
    
    @IBOutlet weak var lbDetailLocation: UILabel!
    @IBOutlet weak var lbTitleDescription: UILabel!
    @IBOutlet weak var lbDetailDescription: UILabel!
    var detailCoupon: CouponModel?
    
    init(_ detailPromotion: CouponModel) {
        super.init(nibName: "DetailPromotionViewController", bundle: nil)
        self.detailCoupon = detailPromotion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "DetailOfCoupon".localized()
        
        if let dataDetail = detailCoupon {
            imagePromotion.sd_setImage(with: URL(string: dataDetail.imageUrl!), placeholderImage: UIImage(named: "placeholder.png"), options: [], completed: nil)
            lbNamePromotion.text = dataDetail.name
            lbTitleLoction.text = "PlaceOfApplication".localized() + ":"
            for data in dataDetail.adsBranch {
                lbDetailLocation.text = "- " + data.name! + "\n"
            }
            lbTitleDescription.text = "DescriptionCoupon".localized() + ":"
            lbDetailDescription.text = dataDetail.detail
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
