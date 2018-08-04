//
//  WalletViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/7/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import Eureka

class WalletViewController: FormViewController {

    var userModel: UserModel? {
        didSet {
            form.allSections.first?.reload()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "HunePay".localized().uppercased()

        let section = Section()
        let cashRow = LabelRow().cellSetup { (cell, row) in
            var title = "MyCash".localized().uppercased()
            if let value = self.userModel?.remainCash {
                title = title + ": " + value.stringWithSepator + " " + "VND".localized()
            }
            row.title = title
            cell.imageView?.image = UIImage(named: "icHunePay")
            cell.imageView?.contentMode = .scaleAspectFit
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }
        section.append(cashRow)
//
//        let topUpRow = LabelRow().cellSetup { (cell, row) in
//            row.title = "TopUpCash".localized()
//            cell.imageView?.image = UIImage(named: "icTopUp")
//            cell.layoutMargins.left = 32
//        }
//        topUpRow.onCellSelection { (_, _) in
//            let vc = TopUpViewController.loadFromNib()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        section.append(topUpRow)

//        let payoutRow = LabelRow().cellSetup { (cell, row) in
//            row.title = "Payout".localized()
//            cell.imageView?.image = UIImage(named: "icPayout")
//            cell.layoutMargins.left = 32
//        }
//        payoutRow.onCellSelection { (_, _) in
//            var value = 0
//            if let value1 = self.userModel?.remainCash {
//                value = value1
//            }
//            self.navigationController?.pushViewController(PayoutViewController(value), animated: true)
//        }
//        section.append(payoutRow)

        let cashHistoryRow = LabelRow().cellSetup { (cell, row) in
            row.title = "CashTransactionHistory".localized()
            cell.imageView?.image = UIImage(named: "icHistory")
            cell.layoutMargins.left = 32
        }
        cashHistoryRow.onCellSelection { (_, _) in
            let vc = CashTransactionHistoryViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(cashHistoryRow)
//        let coinRow = LabelRow().cellSetup { (cell, row) in
//            row.title = "HuneCoin".localized().uppercased()
//            cell.imageView?.image = UIImage(named: "icHuneCoinGrey")
//        }
//        coinRow.onCellSelection { (_, _) in
//            let vc = CoinViewController.loadFromNib()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        section.append(coinRow)
        form +++ section
    }

    func getUser() {
        ServiceManager.userService.get(userId: "") { [unowned self] (result) in
            switch result {
            case .success(let user):
                self.userModel = user
            case .failure(_):
                break
                //                log.debug(error.errorMessage)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
