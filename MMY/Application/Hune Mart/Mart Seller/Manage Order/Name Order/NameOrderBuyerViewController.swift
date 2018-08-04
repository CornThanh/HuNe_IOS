//
//  NameOrderViewController.swift
//  MMY
//
//  Created by Apple on 7/23/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class NameOrderBuyerViewController: UIViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTotal: UILabel!
    @IBOutlet weak var lbNumberPhoneBuyer: UILabel!
    @IBOutlet weak var lbAddressBuyer: UILabel!
    @IBOutlet weak var btCheckStatus: UIButton!
    
    var data: ManageOrderModel?
    var nameTitle: String?
    
    init(data: ManageOrderModel, nameTitle: String) {
        super.init(nibName: "NameOrderBuyerViewController" , bundle: nil)
        self.data = data
        self.nameTitle = nameTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "DetailOrder".localized()
        self.setupUI()
        self.setData()
        if data?.status == 1 {
            btCheckStatus.isHidden = false
        } else {
            btCheckStatus.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData() {
        lbTitle.text = nameTitle
    
        var total = 0
        if let quantity = data?.quantity, let price = data?.price {
            total = quantity * price
        }
        lbTotal.text = String(total)
        lbNumberPhoneBuyer.text = data?.phone
    }
 
    func setupUI() {
        lbAddressBuyer.isHidden = true
        btCheckStatus.layer.cornerRadius = self.btCheckStatus.frame.size.height/2
        btCheckStatus.backgroundColor = UIColor(hexString: "00AB4E")
        btCheckStatus.setTitle("Accept".localized(), for: .normal)
    
    }
    
    @IBAction func actionStatus(_ sender: Any) {
        ServiceManager.martService.updateStatusOrderSeller(orderId: (data?.order_id)!) { (result) in
            switch result {
            case .success( _):
                self.showDialog(title: "HuNe Mart", message: "UpdateStatusOrderSuccess".localized(), handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
            case .failure(let error):
                print("error", error.errorCode)
                self.showDialog(title: "HuNe Mart", message: "UpdateStatusOrderError".localized(), handler: nil)
            }
        }
    }
    
}
