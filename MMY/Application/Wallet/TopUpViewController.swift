//
//  TopUpViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/7/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class TopUpViewController: BaseViewController {
    
    var postType: PostType?
    var backGroundColor: UIColor?
    
    @IBOutlet weak var lbTextfield: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tfInputMoney: UITextField!
    
    @IBOutlet weak var btPrice: UIButton!
    @IBOutlet weak var btPrice1: UIButton!
    @IBOutlet weak var btPrice2: UIButton!
    @IBOutlet weak var btPrice3: UIButton!
    @IBOutlet weak var btTopupCash: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "TopUpCash".localized()
        
        lbTitle.text = "TopUpViewController".localized()
        lbTextfield.text = "TopUpViewController1".localized()
        btPrice.layer.cornerRadius = btPrice.frame.size.height/2
        btPrice1.layer.cornerRadius = btPrice.frame.size.height/2
        btPrice2.layer.cornerRadius = btPrice.frame.size.height/2
        btPrice3.layer.cornerRadius = btPrice.frame.size.height/2
        tfInputMoney.layer.cornerRadius = tfInputMoney.frame.size.height/2
        btTopupCash.layer.cornerRadius = btTopupCash.frame.size.height/2
        btPrice.layer.borderWidth = 1.0
        btPrice1.layer.borderWidth = 1.0
        btPrice2.layer.borderWidth = 1.0
        btPrice3.layer.borderWidth = 1.0
        tfInputMoney.layer.borderWidth = 1.0
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        btPrice.layer.borderColor = backGroundColor?.cgColor
        btPrice1.layer.borderColor = backGroundColor?.cgColor
        btPrice2.layer.borderColor = backGroundColor?.cgColor
        btPrice3.layer.borderColor = backGroundColor?.cgColor
        tfInputMoney.layer.borderColor = backGroundColor?.cgColor
        tfInputMoney.layer.masksToBounds = true
        tfInputMoney.placeholder = "TopUpViewController2".localized()
        
        btTopupCash.setTitle("TopUpCash".localized().uppercased(), for: .normal)
        btTopupCash.titleLabel?.font = UIFont(name: "Lato-Regular", size: 22)
        btTopupCash.backgroundColor = backGroundColor
        
        tfInputMoney.addTarget(self, action: #selector(changeMoney), for: .editingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeMoney() {
        tfInputMoney.stringAfterAddSeparateFromLeft()
    }
    
    @IBAction func btTapPrice(_ sender: UIButton) {
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
    
    @IBAction func btTopupCash(_ sender: Any) {
        
    }
}

