//
//  CoinViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/7/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import Eureka

class CoinViewController: FormViewController {
    
    @IBOutlet weak var lbMoney: UILabel!
    var userModel: UserModel? {
        didSet {
            form.allSections.first?.reload()
        }
    }
    
    var titleCell = ""
    var valueCoin = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        getUser()
        title = "HuneCoin".localized()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createTable() {
        let section = Section()
        let huneCoin = LabelRow().cellSetup { (cell, row) in
//            cell.imageView?.image = UIImage(named: "icHuneCoinGrey")
//            cell.imageView?.contentMode = .scaleAspectFit
//            cell.accessoryType = .none
//            cell.selectionStyle = .none
//
//            row.title = self.titleCell
            let viewCell = self.addView()
            cell.addSubview(viewCell)
            viewCell.snp.makeConstraints({ (make) in
                make.leading.equalTo(cell.snp.leading)
                make.top.equalTo(cell.snp.top)
                make.bottom.equalTo(cell.snp.bottom)
                make.trailing.equalTo(cell.snp.trailing)
            })
        }
        section.append(huneCoin)
        
        let redeemPoint = LabelRow().cellSetup { (cell, row) in
            row.title = "RedeemCoin".localized()
            cell.imageView?.image = UIImage(named: "icTopUp")
            cell.layoutMargins.left = 32
        }
        redeemPoint.onCellSelection { (_, _) in
            let vc = RedeemCoinViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(redeemPoint)
        
        let coinHistoryRow = LabelRow().cellSetup { (cell, row) in
            row.title = "History".localized()
            cell.imageView?.image = UIImage(named: "icHistory")
            cell.layoutMargins.left = 32
        }
        coinHistoryRow.onCellSelection { (_, _) in
            let vc = CoinTransactionHistoryViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(coinHistoryRow)
        form +++ section
    }
    
    func addView() -> UIView {
        let viewCell = UIView()
        
        let imageHuneCoin = UIImageView()
        imageHuneCoin.image = UIImage(named:"icHuneCoinGrey")
        imageHuneCoin.sizeToFit()
        viewCell.addSubview(imageHuneCoin)
        imageHuneCoin.snp.makeConstraints { (make) in
            make.leading.equalTo(viewCell.snp.leading).offset(10.0)
            make.centerY.equalTo(viewCell.snp.centerY)
            make.width.equalTo(viewCell.snp.width).multipliedBy(0.05)
            make.height.equalTo(viewCell.snp.width).multipliedBy(0.05)
        }
        
        let lbMyCoupon = UILabel()
        lbMyCoupon.text = "MyCoin".localized().uppercased() + ": "
        viewCell.addSubview(lbMyCoupon)
        lbMyCoupon.snp.makeConstraints { (make) in
            make.left.equalTo(imageHuneCoin.snp.right).offset(8.0)
            make.centerY.equalTo(imageHuneCoin.snp.centerY)
        }
        
        let lbMyCoin = UILabel()
        lbMyCoin.text = String(valueCoin.stringWithSepator)
        lbMyCoin.textColor = UIColor.red
        viewCell.addSubview(lbMyCoin)
        lbMyCoin.snp.makeConstraints { (make) in
            make.left.equalTo(lbMyCoupon.snp.right).offset(8.0)
            make.centerY.equalTo(lbMyCoupon.snp.centerY)
        }
        
        let imageCoin = UIImageView()
        imageCoin.image = UIImage(named: "icCoin")
        imageCoin.sizeToFit()
        viewCell.addSubview(imageCoin)
        imageCoin.snp.makeConstraints { (make) in
            make.left.equalTo(lbMyCoin.snp.right).offset(8.0)
            make.centerY.equalTo(lbMyCoin.snp.centerY)
            make.width.equalTo(imageHuneCoin.frame.size.width)
            make.height.equalTo(imageHuneCoin.frame.size.height)
        }
        
        return viewCell
    }
    
    func getUser() {
        ServiceManager.userService.get(userId: "") { [unowned self] (result) in
            switch result {
            case .success(let user):
                self.userModel = user
                if let value = self.userModel?.remainCoin {
                    self.valueCoin = value
                    self.titleCell = "MyCoin".localized().uppercased()
                    self.titleCell = self.titleCell + ": " + String(value.stringWithSepator)
                }
               self.createTable()
            case .failure(_):
                break
            }
        }
    }
    
}
