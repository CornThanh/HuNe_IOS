//
//  PaymentAdsViewController.swift
//  MMY
//
//  Created by Apple on 5/20/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class PaymentAdsViewController: BaseViewController {
    @IBOutlet weak var lb1: UILabel!
    @IBOutlet weak var lb2: UILabel!
    @IBOutlet weak var lb3: UILabel!
    @IBOutlet weak var lb4: UILabel!
    @IBOutlet weak var tfCodePromotion: UITextField!
    
    @IBOutlet weak var lb5: UILabel!
    @IBOutlet weak var lb6: UILabel!
    @IBOutlet weak var lb7: UILabel!
    @IBOutlet weak var lb8: UILabel!
    @IBOutlet weak var btPayment: UIButton!
    
    var backGroundColor: UIColor?
    var id = ""
    var totalMoney = 0
    
    init(id: String, totalMoney: Int) {
        super.init(nibName: "PaymentAdsViewController" , bundle: nil)
        self.id = id
        self.totalMoney = totalMoney
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setup() {
        let intMoney = (totalMoney * 10000).stringWithSepator
        lb1.text = "PaymentAdsViewController1".localized()
        lb3.text = "PaymentAdsViewController2".localized()
        lb4.text = "PaymentAdsViewController3".localized()
        tfCodePromotion.placeholder = "PaymentAdsViewController4".localized()
        lb5.text = "PaymentAdsViewController5".localized()
        lb7.text = "PaymentAdsViewController6".localized()
        btPayment.setTitle("PaymentAdsViewController7".localized(), for: .normal)
        lb2.text = "\(intMoney)" + " " + "VND".localized()
        lb8.text = "\(intMoney)" + " " + "VND".localized()
        lb6.text = "0" + " " + "VND".localized()
        
        DispatchQueue.main.async {
            self.tfCodePromotion.layer.cornerRadius = self.tfCodePromotion.frame.size.height/2
            self.btPayment.layer.cornerRadius = self.btPayment.frame.size.height/2
        }
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        self.tfCodePromotion.layer.borderWidth = 1.0
        self.tfCodePromotion.layer.borderColor = backGroundColor?.cgColor
        self.btPayment.backgroundColor = backGroundColor
        self.tfCodePromotion.layer.masksToBounds = true
        
        let button = UIButton(frame: CGRect(x: tfCodePromotion.frame.size.width - 50, y: 0, width: 90.0, height: tfCodePromotion.frame.size.height))
        button.setTitle("PaymentAdsViewController8".localized(), for: .normal)
        button.setTitleColor(backGroundColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.addTarget(self, action: #selector(btApply), for: .touchUpInside)
        tfCodePromotion.rightViewMode = .always
        tfCodePromotion.rightView = button
    
    }
    
    func btApply() {
        
    }
    
    @IBAction func btTapPayment(_ sender: Any) {
        ServiceManager.adsService.payment(id: id, coupon: "") { (result) in
            switch result {
            case .success:
                 self.showDialog(title: "", message: "Thanh toán thành công", handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                 })
            case .failure( _):
                self.showDialog(title: "Lỗi", message: "Không đủ cash để thanh toán", handler:nil)

            }
        }
    }
    
}
