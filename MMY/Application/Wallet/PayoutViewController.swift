//
//  PayoutViewController.swift
//  MMY
//
//  Created by Apple on 4/30/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class PayoutViewController: BaseViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTextfield: UILabel!
    
    @IBOutlet weak var btConfirm: UIButton!
    @IBOutlet weak var btMoney3: UIButton!
    @IBOutlet weak var btMoney2: UIButton!
    @IBOutlet weak var btMoney1: UIButton!
    @IBOutlet weak var btMoney: UIButton!
    @IBOutlet weak var tfInputMoney: UITextField!
    
    var postType: PostType?
    var backGroundColor: UIColor?
    var valueMoney = 0
    
    init(_ value: Int) {
        super.init(nibName: "PayoutViewController", bundle: nil)
        valueMoney = value
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "Payout".localized()
        
        if valueMoney != 0 {
            lbTitle.text = lbTitle.text! + ": " + valueMoney.stringWithSepator + " " + "VND".localized()
        }
        
        lbTitle.text = "PayoutViewController".localized()
        lbTextfield.text = "PayoutViewController1".localized()
        
        btMoney.layer.cornerRadius = btMoney.frame.size.height/2
        btMoney1.layer.cornerRadius = btMoney.frame.size.height/2
        btMoney2.layer.cornerRadius = btMoney.frame.size.height/2
        btMoney3.layer.cornerRadius = btMoney.frame.size.height/2
        tfInputMoney.layer.cornerRadius = tfInputMoney.frame.size.height/2
        btConfirm.layer.cornerRadius = btConfirm.frame.size.height/2
        btMoney.layer.borderWidth = 1.0
        btMoney1.layer.borderWidth = 1.0
        btMoney2.layer.borderWidth = 1.0
        btMoney3.layer.borderWidth = 1.0
        tfInputMoney.layer.borderWidth = 1.0
        tfInputMoney.placeholder = "PayoutViewController2".localized()
        
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        btMoney.layer.borderColor = backGroundColor?.cgColor
        btMoney1.layer.borderColor = backGroundColor?.cgColor
        btMoney2.layer.borderColor = backGroundColor?.cgColor
        btMoney3.layer.borderColor = backGroundColor?.cgColor
        tfInputMoney.layer.borderColor = backGroundColor?.cgColor
        tfInputMoney.layer.masksToBounds = true
        
        btConfirm.setTitle("Confirm".localized().uppercased(), for: .normal)
        btConfirm.titleLabel?.font = UIFont(name: "Lato-Regular", size: 22)
        btConfirm.backgroundColor = backGroundColor
        
        tfInputMoney.addTarget(self, action: #selector(changeMoney), for: .editingChanged)
    }
    
    func changeMoney() {
        tfInputMoney.stringAfterAddSeparateFromLeft()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btPrice(_ sender: UIButton) {
        if sender.tag == 0 {
            tfInputMoney.text = "100.000"
        } else if sender.tag == 1 {
            tfInputMoney.text = "200.000"
        } else if sender.tag == 2 {
            tfInputMoney.text = "500.000"
        } else {
            tfInputMoney.text = "1.000.000"
        }
    }
    @IBAction func btTapConfirm(_ sender: Any) {
    }
    
}
