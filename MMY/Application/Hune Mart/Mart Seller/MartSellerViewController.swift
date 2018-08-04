//
//  MartSellerViewController.swift
//  MMY
//
//  Created by Apple on 7/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON

class MartSellerViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addLeftBarButton()
        title = "Seller".localized()
        let section = Section()
        let rowBanner = LabelRow().cellSetup { (cell, row) in
            row.title = "MartSellerViewController1".localized()
            cell.imageView?.image = UIImage(named: "icon_post")
        }
        rowBanner.onCellSelection { (_, _) in
            let vc = PostNewsViewController(checkEdit: false, dataEdit: ManageStoreModel(json: JSON.null)!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowBanner)
        
        let rowPlace = LabelRow().cellSetup { (cell, row) in
            row.title = "MartSellerViewController2".localized()
            cell.imageView?.image = UIImage(named: "icon_manage_store")
        }
        rowPlace.onCellSelection { (_, _) in
            let vc = ManageStoreViewController .loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowPlace)
        
        let rowManage = LabelRow().cellSetup { (cell, row) in
            row.title = "MartSellerViewController3".localized()
            cell.imageView?.image = UIImage(named: "icon_manage_order")
        }
        rowManage.onCellSelection { (_, _) in
            //let vc = ManageOrderViewController .loadFromNib()
            self.navigationController?.pushViewController(ManageOrderViewController(), animated: true)
        }
        section.append(rowManage)
        
        
        form +++ section
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
