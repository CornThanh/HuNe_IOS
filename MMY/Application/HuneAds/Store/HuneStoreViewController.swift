//
//  HuneStoreViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/31/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class HuneStoreViewController: BaseViewController {

    @IBOutlet weak var tbvContent: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "RewardHune".localized()
        tbvContent.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension HuneStoreViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc = CouponListViewController.loadFromNib()
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = MyCouponViewController.loadFromNib()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CoinViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HuneStoreViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")

        if indexPath.row == 0 {
            cell.textLabel?.text = "BuyCoupon".localized()
            cell.imageView?.image = UIImage(named: "ic_coupon")
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "MyCoupon".localized()
            cell.imageView?.image = UIImage(named: "ic_my_coupon")
        } else {
            cell.textLabel?.text = "HuneCoin".localized()
            cell.imageView?.image = UIImage(named: "icHuneCoinGrey")
        }
        return cell
    }
}
