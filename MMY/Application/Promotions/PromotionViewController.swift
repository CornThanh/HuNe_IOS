//
//  PromotionViewController.swift
//  MMY
//
//  Created by Apple on 6/13/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import SDWebImage

class PromotionViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var arrCoupon = [CouponModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "Promotion".localized()
        ServiceManager.adsService.getPromotion { (data) in
            if let result = data {
                self.arrCoupon = result
                self.tableView.estimatedRowHeight = 200.0
                self.tableView.rowHeight = UITableViewAutomaticDimension
                self.tableView.reloadData()
            } else {
                
            }
        }
        
        tableView.register(UINib(nibName: "PromotionTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

}

extension PromotionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCoupon.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PromotionTableViewCell
        cell.imagePromotion.sd_setImage(with: URL(string: arrCoupon[indexPath.row].imageUrl!), placeholderImage: UIImage(named: "placeholder.png"), options: [], completed: nil)
        cell.lbTitlePromotion.text = arrCoupon[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.navigationController?.pushViewController(DetailPromotionViewController(arrCoupon[indexPath.row]), animated: true)
    }
}
