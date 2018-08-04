//
//  NotiAdsViewController.swift
//  MMY
//
//  Created by Apple on 5/3/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class NotiAdsViewController: UIViewController {
    @IBOutlet weak var lb1: UILabel!
    @IBOutlet weak var lb2: UILabel!
    @IBOutlet weak var lb3: UILabel!
    @IBOutlet weak var lb4: UILabel!
    @IBOutlet weak var lb5: UILabel!
    @IBOutlet weak var lb6: UILabel!
    @IBOutlet weak var lb7: UILabel!
    @IBOutlet weak var lb8: UILabel!
    @IBOutlet weak var lb9: UILabel!
    @IBOutlet weak var lb10: UILabel!
    @IBOutlet weak var lb11: UILabel!
    @IBOutlet weak var lb12: UILabel!
    @IBOutlet weak var lb13: UILabel!
    @IBOutlet weak var lb14: UILabel!
    @IBOutlet weak var lb15: UILabel!
    @IBOutlet weak var imageUpload: UIImageView!
    
    @IBOutlet weak var tf5: UITextField!
    @IBOutlet weak var tf4: UITextField!
    @IBOutlet weak var tf3: UITextField!
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var btUpload: UIButton!
    @IBOutlet weak var btNext: UIButton!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hieghtTableView: NSLayoutConstraint!
    
    @IBOutlet weak var heightViewOfScroll: NSLayoutConstraint!
    
    @IBOutlet weak var imageDate1: UIImageView!
    @IBOutlet weak var imageDate2: UIImageView!
    var backGroundColor: UIColor?
    var countBranch: Int = 1
    let imagePicker = UIImagePickerController()
    var checkStart = true
    var checkEnd = true
    let datePickerStart = UIDatePicker()
    let datePickerEnd = UIDatePicker()
    var arrBranch = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NotiAds".localized()
        addLeftBarButton()
        tableView.register(UINib(nibName: "NotiAdsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        let tap1 = UITapGestureRecognizer(target:self,action:#selector(timeStart))
        view1.isUserInteractionEnabled = true
        view1.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target:self,action:#selector(timeEnd))
        view2.isUserInteractionEnabled = true
        view2.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target:self,action:#selector(dateStart))
        view3.isUserInteractionEnabled = true
        view3.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target:self,action:#selector(dateEnd))
        view4.isUserInteractionEnabled = true
        view4.addGestureRecognizer(tap4)
        
        let tap5 = UITapGestureRecognizer(target:self,action:#selector(addBranchStore))
        lb12.isUserInteractionEnabled = true
        lb12.addGestureRecognizer(tap5)
        
        let image1 = UITapGestureRecognizer(target:self,action:#selector(pickerDate1))
        imageDate1.isUserInteractionEnabled = true
        imageDate1.addGestureRecognizer(image1)
        
        let image2 = UITapGestureRecognizer(target:self,action:#selector(pickerDate2))
        imageDate2.isUserInteractionEnabled = true
        imageDate2.addGestureRecognizer(image2)
        
        let tapViewOut = UITapGestureRecognizer(target:self,action:#selector(tapView))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapViewOut)
        
        tableView.separatorStyle = .none
        
        setupView()
        setupString()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let value = ShareData.datePicker["start"] {
            lb9.text = value
            AdsNotifi.start_date = value
        }
        
        if let value = ShareData.datePicker["end"] {
            lb10.text = value
            AdsNotifi.end_date = value
        }
    }
    
    func tapView() {
        datePickerStart.isHidden = true
        datePickerEnd.isHidden = true
    }
    
    func pickerDate1() {
        ShareData.datePicker.removeAll()
        let vc = PickerDateNotiViewController(status: "start")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pickerDate2() {
        ShareData.datePicker.removeAll()
        let vc = PickerDateNotiViewController(status: "end")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func timeStart() {
        if checkStart == true {
            datePickerStart.isHidden = false
            datePickerEnd.isHidden = true
            createTimePickerStart()
        } else {
            datePickerStart.isHidden = true
        }
        
        checkStart = !checkStart
    }
    
    func timeEnd() {
        if checkEnd == true {
            datePickerEnd.isHidden = false
            datePickerStart.isHidden = true
            createTimePickerEnd()
        } else {
            datePickerEnd.isHidden = true
        }
        
        checkEnd = !checkEnd
    }
    
    func timePickerStart(sender: UIDatePicker) {
        let time = sender.countDownDuration
        let hour = (time/3600).rounded(.down)
        let minute = (((time/3600) - hour)*60).rounded(.down)
        lb7.text = "\( Int(hour)):\(Int(minute))"
        AdsNotifi.start_hour = "\( Int(hour)):\(Int(minute))"
    }
    
    func timePickerEnd(sender: UIDatePicker) {
        let time = sender.countDownDuration
        let hour = (time/3600).rounded(.down)
        let minute = (((time/3600) - hour)*60).rounded(.down)
        lb8.text = "\(Int(hour)):\(Int(minute))"
        AdsNotifi.end_hour = "\(Int(hour)):\(Int(minute))"
    }
    
    func dateStart() {
        
    }
    
    func dateEnd() {
        
    }
    
    func addBranchStore() {
        countBranch = countBranch + 1
        heightViewOfScroll.constant = CGFloat(850 + (countBranch - 1) * 50)
        hieghtTableView.constant = CGFloat(countBranch * 50)
        tableView.reloadData()
    }
    
    func deleteBranch() {
        countBranch = countBranch - 1
        heightViewOfScroll.constant = heightViewOfScroll.constant - 50.0
        hieghtTableView.constant = CGFloat(countBranch * 50)
        if countBranch == arrBranch.count {
            arrBranch.removeLast()
        }
        tableView.reloadData()
    }
    
    func createTimePickerStart() {
        datePickerStart.frame = CGRect(x: 0.0 , y: self.view.frame.height - 100, width: self.view.bounds.size.width, height: 100.0)
        datePickerStart.backgroundColor = backGroundColor
        datePickerStart.datePickerMode = .time
        datePickerStart.addTarget(self, action: #selector(timePickerStart(sender:)), for: .valueChanged)
        self.view.addSubview(datePickerStart)
    }
    
    func createTimePickerEnd() {
        datePickerEnd.frame = CGRect(x: 0.0 , y: self.view.frame.height - 100, width: self.view.bounds.size.width, height: 100.0)
        datePickerEnd.backgroundColor = backGroundColor
        datePickerEnd.datePickerMode = .time
        datePickerEnd.addTarget(self, action: #selector(timePickerEnd(sender:)), for: .valueChanged)
        self.view.addSubview(datePickerEnd)
    }
    
    func setupView() {
        btUpload.layer.cornerRadius = btUpload.frame.size.height/2
        btNext.layer.cornerRadius = btNext.frame.size.height/2
        tf1.layer.cornerRadius = tf1.frame.size.height/2
        tf2.layer.cornerRadius = 15.0
        tf3.layer.cornerRadius = tf3.frame.size.height/2
        tf4.layer.cornerRadius = tf4.frame.size.height/2
        tf5.layer.cornerRadius = tf5.frame.size.height/2
        view1.layer.cornerRadius = view1.frame.size.height/2
        view2.layer.cornerRadius = view2.frame.size.height/2
        view3.layer.cornerRadius = view3.frame.size.height/2
        view4.layer.cornerRadius = view4.frame.size.height/2
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        tf1.layer.borderWidth = 1.0
        tf2.layer.borderWidth = 1.0
        tf3.layer.borderWidth = 1.0
        tf4.layer.borderWidth = 1.0
        tf5.layer.borderWidth = 1.0
        view1.layer.borderWidth = 1.0
        view2.layer.borderWidth = 1.0
        view3.layer.borderWidth = 1.0
        view4.layer.borderWidth = 1.0
        
        btUpload.backgroundColor = backGroundColor
        btNext.backgroundColor = backGroundColor
        tf1.layer.borderColor = backGroundColor?.cgColor
        tf2.layer.borderColor = backGroundColor?.cgColor
        tf3.layer.borderColor = backGroundColor?.cgColor
        tf4.layer.borderColor = backGroundColor?.cgColor
        tf5.layer.borderColor = backGroundColor?.cgColor
        view1.layer.borderColor = backGroundColor?.cgColor
        view2.layer.borderColor = backGroundColor?.cgColor
        view3.layer.borderColor = backGroundColor?.cgColor
        view4.layer.borderColor = backGroundColor?.cgColor
        
        tf1.layer.masksToBounds = true
        tf2.layer.masksToBounds = true
        tf3.layer.masksToBounds = true
        tf4.layer.masksToBounds = true
        tf5.layer.masksToBounds = true
        
        tf1.placeholder = "PlaceAdsViewController6".localized()
        tf2.placeholder = "PlaceAdsViewController7".localized()
        tf3.placeholder = "NotiAdsViewController11".localized()
        
    }
    
    func setupString() {
        lb1.text = "PlaceAdsViewController".localized()
        lb2.text = "PlaceAdsViewController1".localized()
        lb3.text = "PlaceAdsViewController2".localized()
        lb4.text = "NotiAdsViewController".localized()
        lb5.text = "NotiAdsViewController1".localized()
        lb6.text = "NotiAdsViewController2".localized()
        lb7.text = "NotiAdsViewController3".localized()
        lb8.text = "NotiAdsViewController3".localized()
        lb9.text = "NotiAdsViewController4".localized()
        lb10.text = "NotiAdsViewController5".localized()
        lb11.text = "NotiAdsViewController6".localized()
        lb12.text = "NotiAdsViewController9".localized()
        lb13.text = "NotiAdsViewController11".localized()
        lb14.text = "NotiAdsViewController12".localized()
        lb15.text = "NotiAdsViewController13".localized()
        btUpload.setTitle("PlaceAdsViewController5".localized(), for: .normal)
        btNext.setTitle("PlaceAdsViewController4".localized(), for: .normal)
        lb12.textColor = backGroundColor
        
    }
    
    func checkValidate() -> Bool {
        if tf1.text == "" || tf2.text == "" || tf3.text == "" || tf4.text == "" || arrBranch.count == 0 || AdsNotifi.logo == "" || AdsNotifi.start_date == "" || AdsNotifi.start_hour == "" || AdsNotifi.end_date == "" || AdsNotifi.end_hour == "" || AdsNotifi.price == "" {
            return false
        }
        
        return true
    }
    
    @IBAction func btTapNext(_ sender: Any) {
        AdsNotifi.name = tf1.text!
        AdsNotifi.description = tf2.text!
        AdsNotifi.discount = tf5.text!
        AdsNotifi.total_coupon = tf4.text!
        AdsNotifi.price = tf3.text!
        AdsNotifi.branch = arrBranch
        
        if checkValidate() == true {
            let vc = NextNotiAdsViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showDialog(title: "Error", message: "Vui lòng nhập đầy đủ thông tin", handler:nil)
        }
    }
    
    @IBAction func btTapUpload(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    
    }
}

extension NotiAdsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countBranch
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NotiAdsTableViewCell
        cell.lbNameStore.text = "NotiAdsViewController7".localized() + " " + String(indexPath.row)
        cell.tfLocation.layer.borderColor = backGroundColor?.cgColor
        cell.tfLocation.layer.borderWidth = 1.0
        cell.tfLocation.layer.cornerRadius = cell.tfLocation.frame.size.height/2
        cell.tfLocation.placeholder = "NotiAdsViewController8".localized()
        cell.tfLocation.layer.masksToBounds = true
        cell.selectionStyle = .none
        cell.tfLocation.tag = indexPath.row
        cell.tfLocation.delegate = self
        if indexPath.row > 0 {
            let imageDelete = UIImageView(frame: CGRect(x:0, y:0, width:cell.tfLocation.frame.size.height, height: cell.tfLocation.frame.size.height))
            imageDelete.image = UIImage(named: "ic_delete")
            cell.tfLocation.rightViewMode = .always
            cell.tfLocation.rightView = imageDelete
            
            let tap = UITapGestureRecognizer(target:self,action:#selector(deleteBranch))
            imageDelete.isUserInteractionEnabled = true
            imageDelete.addGestureRecognizer(tap)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

extension NotiAdsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageUpload.contentMode = .scaleAspectFit
            imageUpload.image = pickedImage
            dismiss(animated: true, completion: nil)
            
            // upload image to get url
            var avatar = imageUpload.image
            let imageSize = avatar?.size
            if imageSize!.width > 500.0 {
                let newSize = CGSize(width: 500.0, height: (imageSize?.height)!/(imageSize?.width)!*500)
                avatar = avatar?.imageScaled(to: newSize)
            }
            ServiceManager.postService.uploadFile(dataFile: UIImagePNGRepresentation(avatar!)!, name: "avatar", completion: { (url) in
                if let url = url, url.characters.count > 0 {
                    AdsNotifi.logo = url
                } else {
                    self.showDialog(title: "Error", message: "Có lỗi xảy ra khi đăng ảnh, vui lòng thử lại", handler:nil)
                }
            })
        }
        
    }
}

extension NotiAdsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            arrBranch.append(text)
        } else {
            countBranch = countBranch - 1
        }
    }
}


