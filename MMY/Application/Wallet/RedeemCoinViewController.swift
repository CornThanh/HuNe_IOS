//
//  RedeemCoinViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/7/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class RedeemCoinViewController: BaseViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTextfield: UILabel!
    @IBOutlet weak var tfInputPromotionCode: UITextField!
    @IBOutlet weak var btRedeem: UIButton!
    
    var backGroundColor: UIColor?
    var postType: PostType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        
        title = "RedeemCoin".localized()
        lbTitle.text = "RedeemViewController".localized()
        lbTextfield.text = "RedeemViewController1".localized()
        tfInputPromotionCode.placeholder = "RedeemViewController2".localized()
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        tfInputPromotionCode.layer.cornerRadius = tfInputPromotionCode.frame.size.height/2
        tfInputPromotionCode.layer.borderWidth = 1.0
        tfInputPromotionCode.layer.borderColor = backGroundColor?.cgColor
        tfInputPromotionCode.layer.masksToBounds = true
    
        btRedeem.layer.cornerRadius = btRedeem.frame.size.height/2
        btRedeem.setTitle("RedeemViewController3".localized().uppercased(), for: .normal)
        btRedeem.backgroundColor = backGroundColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    @IBAction func btRedeemPoint(_ sender: Any) {
        if tfInputPromotionCode.text == "" {
            self.showDialog(title: "Lỗi", message: "Vui lòng nhập đầy đủ thông tin", handler:nil)
        } else {
            if let code = tfInputPromotionCode.text {
                ServiceManager.walletService.changeCoin(code , completion: { (result) in
                    switch result {
                    case .success( _):
                        self.showDialog(title: "RedeemCoin" , message: "Đã đổi coupon thành công", handler: nil)
                    case .failure( _):
                        self.showDialog(title: "Lỗi" , message: "Mã không tồn tại", handler: nil)
                    }
                })
            }
        }
    }
    
}
