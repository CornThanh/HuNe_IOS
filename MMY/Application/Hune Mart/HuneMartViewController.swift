//
//  HuneMartViewController.swift
//  MMY
//
//  Created by Apple on 7/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON

class HuneMartViewController: FormViewController {
    
    var backGroundColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "HuneMart".localized()
        
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "00AB4E")
        self.getConfig()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupUI() {
        let section = Section()
        let rowBanner = LabelRow().cellSetup { (cell, row) in
            row.title = "Buyer".localized()
            cell.imageView?.image = UIImage(named: "ic_buyer")
        }
        rowBanner.onCellSelection { (_, _) in
//            let vc = MartBuyerViewController.loadFromNib()
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowBanner)
        
        let rowBannerBuyer = LabelRow().cellSetup { (cell, row) in
            row.title = "MartBuyerViewController1".localized()
            cell.imageView?.image = UIImage(named: "ic_product_buyer")
            cell.layoutMargins.left = 32
        }
        rowBannerBuyer.onCellSelection { (_, _) in
            let vc = ProductMartViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowBannerBuyer)
        
        let rowPlaceBuyer = LabelRow().cellSetup { (cell, row) in
            row.title = "MartBuyerViewController2".localized()
            cell.imageView?.image = UIImage(named: "ic_check_buyer")
            cell.layoutMargins.left = 32
        }
        rowPlaceBuyer.onCellSelection { (_, _) in
            let vc = CheckOrderViewController .loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowPlaceBuyer)
        
        let rowPlace = LabelRow().cellSetup { (cell, row) in
            row.title = "Seller".localized()
            cell.imageView?.image = UIImage(named: "ic_seller")
        }
        rowPlace.onCellSelection { (_, _) in
            //            let vc = MartSellerViewController .loadFromNib()
            //            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowPlace)
        
        
        let rowBannerSeller = LabelRow().cellSetup { (cell, row) in
            row.title = "MartSellerViewController1".localized()
            cell.imageView?.image = UIImage(named: "icon_post")
            cell.layoutMargins.left = 32
        }
        rowBannerSeller.onCellSelection { (_, _) in
            let vc = PostNewsViewController(checkEdit: false, dataEdit: ManageStoreModel(json: JSON.null)!)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowBannerSeller)
        
        let rowPlaceSeller = LabelRow().cellSetup { (cell, row) in
            row.title = "MartSellerViewController2".localized()
            cell.imageView?.image = UIImage(named: "icon_manage_store")
            cell.layoutMargins.left = 32
        }
        rowPlaceSeller.onCellSelection { (_, _) in
            let vc = ManageStoreViewController .loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowPlaceSeller)
        
        let rowManage = LabelRow().cellSetup { (cell, row) in
            row.title = "MartSellerViewController3".localized()
            cell.imageView?.image = UIImage(named: "icon_manage_order")
            cell.layoutMargins.left = 32
        }
        rowManage.onCellSelection { (_, _) in
            //let vc = ManageOrderViewController .loadFromNib()
            self.navigationController?.pushViewController(ManageOrderViewController(), animated: true)
        }
        section.append(rowManage)
        
        
        
        form +++ section

    }
    
    func getConfig() {
        let group = DispatchGroup()
        group.enter()
        ServiceManager.martService.configType { (result) in
            switch result {
            case .success(let data, _):
                print("okkkkk",data)
                ShareData.arrType = data
                group.leave()
            case .failure(let error):
                print("errrorrrr", error)
                group.leave()
            }
        }
        group.enter()
        ServiceManager.martService.configUnit { (result) in
            switch result {
            case .success(let data, _):
                print("okkkkk",data)
                ShareData.arrUnit = data
                group.leave()
            case .failure(let error):
                print("errrorrrr", error)
                group.leave()
            }
        }
        group.enter()
        ServiceManager.martService.configProductType{ (result) in
            switch result {
            case .success(let data, _):
                print("okkkkk",data)
                ShareData.arrProductType = data
                group.leave()
            case .failure(let error):
                print("errrorrrr", error)
                group.leave()
            }
        }
        
        group.notify(queue: .global(qos: .background)) {
            DispatchQueue.main.async {
                self.setupUI()
            }
        }
        
    }
}
