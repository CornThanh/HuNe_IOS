//
//  MartBuyerViewController.swift
//  MMY
//
//  Created by Apple on 7/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import Eureka

class MartBuyerViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "Buyer".localized()
        let section = Section()
        let rowBanner = LabelRow().cellSetup { (cell, row) in
            row.title = "MartBuyerViewController1".localized()
            cell.imageView?.image = UIImage(named: "ic_product_buyer")
        }
        rowBanner.onCellSelection { (_, _) in
            let vc = ProductMartViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowBanner)
        
        let rowPlace = LabelRow().cellSetup { (cell, row) in
            row.title = "MartBuyerViewController2".localized()
            cell.imageView?.image = UIImage(named: "ic_check_buyer")
        }
        rowPlace.onCellSelection { (_, _) in
            let vc = CheckOrderViewController .loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowPlace)
        
        
        form +++ section
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
