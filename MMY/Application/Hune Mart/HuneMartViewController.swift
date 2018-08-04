//
//  HuneMartViewController.swift
//  MMY
//
//  Created by Apple on 7/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import Eureka

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
            let vc = MartBuyerViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowBanner)
        
        let rowPlace = LabelRow().cellSetup { (cell, row) in
            row.title = "Seller".localized()
            cell.imageView?.image = UIImage(named: "ic_seller")
        }
        rowPlace.onCellSelection { (_, _) in
            let vc = MartSellerViewController .loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowPlace)
        
        
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
