//
//  NameOrderViewController.swift
//  MMY
//
//  Created by Apple on 7/18/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class NameOrderViewController: UIViewController {


    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbTotalMoney: UILabel!
    @IBOutlet weak var lbNumberPhoneSeller: UILabel!
    @IBOutlet weak var lbAddressSeller: UILabel!
    @IBOutlet weak var btEvaluate: UIButton!
    
    var orderData: OrderModel?
    var nameOrder: String?
    
    init(orderData: OrderModel, nameOrder: String) {
        super.init(nibName: "NameOrderViewController", bundle: nil)
        self.orderData = orderData
        self.nameOrder = nameOrder
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error load nib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = self.nameOrder
        lbStatus.text = "NameOrderViewController2".localized()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton()
        setupUI()
    }
    
    func setupUI() {
        if orderData?.comments_status == 1 {
            btEvaluate.isHidden = true
            lbStatus.text = "NameOrderViewController5".localized()
        } else {
            if orderData?.status == 1 {
                btEvaluate.isHidden = true
                lbStatus.text = "NameOrderViewController2".localized()
            } else {
                btEvaluate.isHidden = false
                lbStatus.text = "NameOrderViewController4".localized()
            }
        }
        
        var total = 0
        if let quantity = orderData?.quantity, let price = orderData?.price {
            total = quantity * price
        }
        lbTotalMoney.text = String(total)
        lbAddressSeller.text = orderData?.address
        lbNumberPhoneSeller.text = orderData?.phone_number
    }
    
    func setupButton() {
        btEvaluate.backgroundColor = UIColor(hexString: "00AB4E")
        btEvaluate.layer.cornerRadius = btEvaluate.frame.size.height/2
        btEvaluate.setTitle("NameOrderViewController1".localized(), for: .normal)
    }
    
    @IBAction func actionEvaluate(_ sender: Any) {
        let vc = CommentSellerViewController(orderData: orderData!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
