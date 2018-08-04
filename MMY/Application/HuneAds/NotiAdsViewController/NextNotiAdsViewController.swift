//
//  NextNotiAdsViewController.swift
//  MMY
//
//  Created by Apple on 5/22/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class NextNotiAdsViewController: UIViewController {
    @IBOutlet weak var lb1: UILabel!
    @IBOutlet weak var lb2: UILabel!
    @IBOutlet weak var lb3: UILabel!
    @IBOutlet weak var lb4: UILabel!
    @IBOutlet weak var lb5: UILabel!
    @IBOutlet weak var bt1: UIButton!
    @IBOutlet weak var bt2: UIButton!
    @IBOutlet weak var bt3: UIButton!
    @IBOutlet weak var btSeeker: UIButton!
    @IBOutlet weak var btFindJob: UIButton!
    @IBOutlet weak var btLayoutNext: UIButton!
    @IBOutlet weak var btScruit: UIButton!
    @IBOutlet weak var btFind: UIButton!
    @IBOutlet weak var lbMale: UILabel!
    @IBOutlet weak var lbFemale: UILabel!
    @IBOutlet weak var lbAll: UILabel!
    var checkCruit = true
    var checkFindJob = true
    var checkSex = [Int]()
    
    var backGroundColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lb1.text = "NextPlaceAdsViewController1".localized()
        lb2.text = "NextPlaceAdsViewController2".localized()
        lb3.text = "  " + "NextPlaceAdsViewController3".localized()
        lb4.text = "NextPlaceAdsViewController4".localized()
        lb5.text = "NextNotiAdsViewController3".localized()
        lbMale.text = "NextPlaceAdsViewController5".localized()
        lbFemale.text = "NextPlaceAdsViewController6".localized()
        lbAll.text = "NextPlaceAdsViewController7".localized()
        btScruit.setTitle("NextNotiAdsViewController1".localized(), for: .normal)
        btFindJob.setTitle("NextNotiAdsViewController2".localized(), for: .normal)
        btLayoutNext.setTitle("PlaceAdsViewController4".localized().uppercased(), for: .normal)
        
        DispatchQueue.main.async {
            self.lb3.layer.cornerRadius = self.lb3.frame.size.height/2
            self.btLayoutNext.layer.cornerRadius = self.btLayoutNext.frame.size.height/2
            self.btScruit.layer.cornerRadius = self.btScruit.frame.size.height/2
            self.btFindJob.layer.cornerRadius = self.btFindJob.frame.size.height/2
        }
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        btScruit.layer.borderWidth = 1.0
        btScruit.layer.borderColor = backGroundColor?.cgColor
        btFindJob.layer.borderWidth = 1.0
        btFindJob.layer.borderColor = backGroundColor?.cgColor
        btLayoutNext.backgroundColor = backGroundColor
        lbFemale.textColor = backGroundColor
        lbMale.textColor = backGroundColor
        lbAll.textColor = backGroundColor
        lb3.layer.borderWidth = 1.0
        lb3.layer.borderColor = backGroundColor?.cgColor
        btFindJob.setTitleColor(backGroundColor, for: .normal)
        btScruit.setTitleColor(backGroundColor, for: .normal)
        
        let tap1 = UITapGestureRecognizer(target:self,action:#selector(pickerDate1))
        lb3.isUserInteractionEnabled = true
        lb3.addGestureRecognizer(tap1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkFindAndBook() -> [Int] {
        var arr = [Int]()
        
        if checkCruit == false {
            arr.append(1)
        } else if checkFindJob == false {
            arr.append(2)
        } else if checkFindJob == false && checkCruit == false {
            arr.append(1)
            arr.append(2)
        }
        
        return arr
    }
    
    func pickerDate1() {
        let mapPickerViewController = MapPickerViewController()
        mapPickerViewController.location = Authenticator.shareInstance.getLocation()
        mapPickerViewController.onDismissCallback = {(location) in
            AdsNotifi.locationMap = location!
        }
        navigationController?.pushViewController(mapPickerViewController, animated: true)
    }
    
    func checkValidate() -> Bool {
        if AdsNotifi.gender.count == 0 || AdsNotifi.location.count == 0 || String(AdsNotifi.locationMap.coordinate.latitude) == ""{
            return false
        }
        return true
    }
    
    @IBAction func ChooseSex(_ sender: UIButton) {
        if sender.tag == 0 {
            bt1.setImage(UIImage(named: "icon_check"), for: .normal)
            bt2.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            bt3.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            checkSex.removeAll()
            checkSex.append(1)
        } else if sender.tag == 1 {
            bt1.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            bt2.setImage(UIImage(named: "icon_check"), for: .normal)
            bt3.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            checkSex.removeAll()
            checkSex.append(2)
        } else {
            bt1.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            bt3.setImage(UIImage(named: "icon_check"), for: .normal)
            bt2.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            checkSex.removeAll()
            checkSex.append(1)
            checkSex.append(2)
        }
    }
    
    @IBAction func Choose(_ sender: UIButton) {
        if sender.tag == 0 {
            if checkCruit == true {
            btScruit.setTitleColor(UIColor.white, for: .normal)
            btScruit.backgroundColor = backGroundColor
            } else {
                btScruit.setTitleColor(backGroundColor, for: .normal)
                btScruit.backgroundColor = UIColor.white
            }
            checkCruit = !checkCruit
        } else {
            if checkFindJob == true {
            btFindJob.setTitleColor(UIColor.white, for: .normal)
            btFindJob.backgroundColor = backGroundColor
            } else {
                btFindJob.backgroundColor = UIColor.white
                btFindJob.setTitleColor(backGroundColor, for: .normal)
            }
            checkFindJob = !checkFindJob
        }
    }
    
    @IBAction func btNext(_ sender: UIButton) {
        AdsNotifi.location = self.checkFindAndBook()
        AdsNotifi.gender = checkSex
        
        if checkValidate() == true {
            
            ServiceManager.adsService.buyPromotion(completion: { (result) in
                switch result {
                case .success(let data):
                    if let id = data.id {
                        let vc = PaymentAdsViewController(id: String(describing: id), totalMoney: 2)
                        self.navigationController?.pushViewController(vc, animated: true)
                        AdsLocation.clearData()
                    }
                case .failure( _):
                    self.showDialog(title: "Error", message: "Có lỗi xảy ra khi đăng banner, vui lòng thử lại", handler:nil)
                }
            })

        } else {
            self.showDialog(title: "Error", message: "Vui lòng nhập đầy đủ thông tin", handler:nil)
        }
        
    }
    
}
