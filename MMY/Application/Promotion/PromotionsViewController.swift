//
//  PromotionsViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/8/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class PromotionsViewController: TableViewController<CouponModel> {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadData() {
        self.showLoading()
        ServiceManager.adsService.getPromoCoupons { (value) in
            self.didFinishLoad(with: value)
            self.hideLoading()
        }
    }

}
