//
//  CouponDetailViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/31/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import SDWebImage

class CouponDetailViewController: BaseViewController {
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var lbMoney: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbDownDay: UILabel!
    @IBOutlet weak var lbCodeCoupon: UILabel!
    @IBOutlet weak var lbLocationApply: UILabel!
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var btBuy: UIButton!
    var coupon: CouponModel!
    var backGroundColor: UIColor?
    var group: String?
    var dataDetailCoupon: DetailCouponModel?
    
    init(_ idCoupon: String) {
        super.init(nibName:"CouponDetailViewController" , bundle: nil)
        self.group = idCoupon
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "DetailCoupon".localized()
        ServiceManager.storeService.getDetail(group) { (result) in
            switch result {
            case .success(let data):
                self.dataDetailCoupon = data
                self.setupView()
                break
            case .failure(let error):
                print(error.errorMessage)
                break
            }
        }
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        btBuy.backgroundColor = backGroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewOne.layer.cornerRadius = self.viewOne.frame.size.height/2
        self.viewTwo.layer.cornerRadius = self.viewTwo.frame.size.height/2
        self.btBuy.layer.cornerRadius = self.btBuy.frame.size.height/2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        imageLogo.sd_setImage(with: URL(string: (dataDetailCoupon?.image)!), placeholderImage: UIImage(named: "placeholder.png"), options: [], completed: nil)
        lbTitle.text = dataDetailCoupon?.name
        lbMoney.text = dataDetailCoupon?.price?.stringWithSepator
        if let fdate = dataDetailCoupon?.from_date , let tdate = dataDetailCoupon?.to_date {
            let dateF = fdate.components(separatedBy: " ")
            let dateT = tdate.components(separatedBy: " ")
            lbDate.text = "\(dateF[0]) đến \(dateT[0])"
        }
        lbDownDay.text = "Còn 200 ngày"
        if let availableCount = dataDetailCoupon?.coupon_available_count {
            lbCodeCoupon.text = "Còn \(availableCount) mã coupon"
        }
        lbLocationApply.text = dataDetailCoupon?.branch
        if let amount = dataDetailCoupon?.couponCount {
            lbAmount.text = String(describing: amount.stringWithSepator) + " Coupon"
        }
        lbDescription.text = dataDetailCoupon?.description
    }
    
    func buyCoupon(_ coupon: CouponModel) {
        ServiceManager.storeService.buyCoupon(coupon.id!) { (result) in
            if let error = result.error {
                self.showErrorDialog(error)
            }
            else {
                self.showDialog(title: "", message: "Successful".localized(), handler: nil)
            }
        }
    }
    
    @IBAction func btActionBuy(_ sender: Any) {
        self.buyCoupon(coupon)
    }
    
}
