//
//  NextPlaceAdsViewController.swift
//  MMY
//
//  Created by Apple on 5/20/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import CoreLocation

class NextPlaceAdsViewController: UIViewController {
    @IBOutlet weak var lb1: UILabel!
    @IBOutlet weak var lb2: UILabel!
    @IBOutlet weak var lb3: UILabel!
    @IBOutlet weak var lb4: UILabel!
    @IBOutlet weak var lb5: UILabel!
    @IBOutlet weak var lb6: UILabel!
    @IBOutlet weak var lb7: UILabel!
    @IBOutlet weak var lb8: UILabel!
    @IBOutlet weak var lb9: UILabel!
    @IBOutlet weak var bt1: UIButton!
    @IBOutlet weak var bt2: UIButton!
    @IBOutlet weak var bt3: UIButton!
    @IBOutlet weak var btNext: UIButton!
    
    var backGroundColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func setup() {
        lb1.text = "NextPlaceAdsViewController1".localized()
        lb2.text = "NextPlaceAdsViewController2".localized()
        lb3.text = "NextPlaceAdsViewController4".localized()
        lb4.text = "NextPlaceAdsViewController5".localized()
        lb5.text = "NextPlaceAdsViewController6".localized()
        lb6.text = "NextPlaceAdsViewController7".localized()
        lb7.text = "NextPlaceAdsViewController8".localized()
        lb8.text =  "  " + "NextPlaceAdsViewController3".localized()
        lb9.text =  "  " + "NextPlaceAdsViewController9".localized()
        btNext.setTitle("PlaceAdsViewController4".localized().uppercased(), for: .normal)
        
        DispatchQueue.main.async {
            self.lb8.layer.cornerRadius = self.lb8.frame.size.height/2
            self.lb9.layer.cornerRadius = self.lb9.frame.size.height/2
            self.btNext.layer.cornerRadius = self.btNext.frame.size.height/2
        }
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        self.lb8.layer.borderWidth = 1.0
        self.lb9.layer.borderWidth = 1.0
        self.lb8.layer.borderColor = backGroundColor?.cgColor
        self.lb9.layer.borderColor = backGroundColor?.cgColor
        self.lb4.textColor = backGroundColor
        self.lb5.textColor = backGroundColor
        self.lb6.textColor = backGroundColor
        self.btNext.backgroundColor = backGroundColor
        
        let tap1 = UITapGestureRecognizer(target:self,action:#selector(pickerDate1))
        lb8.isUserInteractionEnabled = true
        lb8.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target:self,action:#selector(pickerDate2))
        lb9.isUserInteractionEnabled = true
        lb9.addGestureRecognizer(tap2)
    }
    
    func pickerDate1() {
        let mapPickerViewController = MapPickerViewController()
        mapPickerViewController.location = Authenticator.shareInstance.getLocation()
        mapPickerViewController.onDismissCallback = {(location) in
            AdsLocation.location = location!
        }
        navigationController?.pushViewController(mapPickerViewController, animated: true)
    }
    
    func pickerDate2() {
        
        let vc = PickerDateViewController.loadFromNib()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btChooseSex(_ sender: UIButton) {
        if sender.tag == 0 {
            bt1.setImage(UIImage(named: "icon_check"), for: .normal)
            bt2.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            bt3.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            AdsLocation.gender = [1]
        } else if sender.tag == 1 {
            bt1.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            bt2.setImage(UIImage(named: "icon_check"), for: .normal)
            bt3.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            AdsLocation.gender = [2]
        } else {
            bt1.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            bt3.setImage(UIImage(named: "icon_check"), for: .normal)
            bt2.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            AdsLocation.gender = [1,2]
        }
    }
    
    @IBAction func btTapNext(_ sender: Any) {
        if AdsLocation.location.coordinate.latitude == 0 || AdsLocation.gender.count == 0 || AdsLocation.dates.count == 0 {
            self.showDialog(title: "Error", message: "Vui lòng nhập đầy đủ thông tin", handler:nil)
        } else {
            ServiceManager.adsService.buyAsPlace(location: AdsLocation.location, name: AdsLocation.name, description: AdsLocation.description, branchs: AdsLocation.branch, logo: AdsLocation.logo, targetGenders: AdsLocation.gender, dates: AdsLocation.dates) { (result) in
                switch result {
                case .success(let data ):
                    if let id = data.id {
                        let vc = PaymentAdsViewController(id: String(describing: id), totalMoney: AdsLocation.dates.count)
                        self.navigationController?.pushViewController(vc, animated: true)
                        AdsLocation.clearData()
                    }
                case .failure( _):
                    self.showDialog(title: "Error", message: "Có lỗi xảy ra khi đăng banner, vui lòng thử lại", handler:nil)
                }

            }
        }
    
    }
    
}
