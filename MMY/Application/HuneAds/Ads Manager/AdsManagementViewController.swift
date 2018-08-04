//
//  AdsManagementViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/22/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class AdsManagementViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var dataAdsManage = [AdsManageModel]()
    var arrType = ["QUẢNG CÁO THÔNG BÁO", "QUẢNG CÁO KHU VỰC", "QUẢNG CÁO BANNER"]
    var arrStatus = ["Chưa thanh toán", "Đã thanh toán", "Đã huỷ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "AdsManagement".localized()
        
        tableView.register(UINib(nibName:"AdsManagerTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        DispatchQueue.global().async {
            ServiceManager.adsService.getAds { (result) in
                if let dataRes = result {
                    self.dataAdsManage = dataRes
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

extension AdsManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAdsManage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AdsManagerTableViewCell
        cell.lbType.text = arrType[dataAdsManage[indexPath.row].type! - 1]
        if let money =  dataAdsManage[indexPath.row].amount {
            cell.lbMoney.text =  "Thanh toán: " + money.stringWithSepator + " " + "VND".localized()
        }
        
        if let indexStatus = dataAdsManage[indexPath.row].status {
            cell.lbStatus.text = arrStatus[indexStatus - 1]
            cell.imageStatus.sizeToFit()
            if indexStatus == 1 {
                cell.imageStatus.image = UIImage(named: "icon_delete_red")
                cell.lbStatus.textColor = UIColor.red
            } else if indexStatus == 2 {
                cell.imageStatus.image = UIImage(named: "icFinished")
                cell.lbStatus.textColor = UIColor(red: 30/255, green: 198/255, blue: 89/255, alpha: 1.0)
            } else {
                cell.imageStatus.image = UIImage(named: "icWaiting")
                cell.lbStatus.textColor = UIColor(red: 30/255, green: 198/255, blue: 89/255, alpha: 1.0)
            }
        }
        cell.lbDescription.text = dataAdsManage[indexPath.row].name
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}


