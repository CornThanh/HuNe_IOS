//
//  BannerAdsViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/22/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import DropDown

enum ViewInfo: Int, CustomStringConvertible {
    case recruit = 1, booking
    
    var description: String {
        switch (self) {
        case .recruit:
            return "recruit".localized()
        case .booking:
            return "booking".localized()
        }
    }
    
    static var allValues : [ViewInfo] = [.booking, .recruit]
    
}

class BannerAdsViewController: BaseViewController {
    @IBOutlet weak var btFinnish: UIButton!
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var btPickerImage: UIButton!
    
    @IBOutlet weak var btUpload: UIButton!
    @IBOutlet weak var imageBanner: UIImageView!
    @IBOutlet weak var lbViewTitle: UILabel!
    @IBOutlet weak var lbOne: UILabel!
    @IBOutlet weak var lbTwo: UILabel!
    
    @IBOutlet weak var lbDaysCount: UILabel!
    @IBOutlet weak var lbViewName: UILabel!
    @IBOutlet weak var btnPickView: UIButton!
    @IBOutlet weak var lbDatesCount: UILabel!
    @IBOutlet weak var btnSelectDates: UIButton!
    @IBOutlet weak var lbLinkTitle: UILabel!
    @IBOutlet weak var tfLink: UITextField!
    @IBOutlet weak var btnConfirm: UIButton!
    
    var backGroundColor: UIColor?
    let locationDropDown = DropDown()
    let imagePicker = UIImagePickerController()
    var position = 1
    var urlImage = ""
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "BannerAdsViewControllerTitle".localized()
        lbViewTitle.text = "BannerAdsViewController".localized()
        lbOne.text = "BannerAdsViewController3".localized()
        lbDaysCount.text = "BannerAdsViewController1".localized()
        lbTwo.text = "BannerAdsViewController4".localized()
        lbLinkTitle.text = "BannerAdsViewController2".localized()
        tfLink.placeholder = "BannerAdsViewController5".localized()
        btFinnish.setTitle("BannerAdsViewController6".localized().uppercased(), for: .normal)
        btPickerImage.setTitle("BannerAdsViewController7".localized(), for: .normal)
        viewOne.layer.borderWidth = 1.0
        viewTwo.layer.borderWidth = 1.0
        tfLink.layer.borderWidth = 1.0
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        
        viewOne.layer.borderColor = backGroundColor?.cgColor
        viewTwo.layer.borderColor = backGroundColor?.cgColor
        tfLink.layer.borderColor = backGroundColor?.cgColor
        btPickerImage.backgroundColor = backGroundColor
        btFinnish.backgroundColor = backGroundColor
        tfLink.layer.masksToBounds = true
        
        let viewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 20.0, height: tfLink.frame.size.height/2))
        tfLink.leftViewMode = .always
        tfLink.leftView = viewLeft
        
        setupLocationDropDown()
        ShareData.arrDates = [String]()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ShareData.totalDateChoose != 0 {
            lbTwo.text = "BannerAdsViewController8".localized() + " " + String(ShareData.totalDateChoose) + " " + "BannerAdsViewController9".localized()
            ShareData.totalDateChoose = 0
        }
        DispatchQueue.main.async {
            self.viewOne.layer.cornerRadius = self.viewOne.frame.size.height/2
            self.viewTwo.layer.cornerRadius = self.viewTwo.frame.size.height/2
            self.tfLink.layer.cornerRadius = self.tfLink.frame.size.height/2
            self.btFinnish.layer.cornerRadius = self.btFinnish.frame.size.height/2
            self.btPickerImage.layer.cornerRadius = self.btPickerImage.frame.size.height/2
        }
    }
    
    func setupLocationDropDown() {
        locationDropDown.anchorView = viewOne
        locationDropDown.bottomOffset = CGPoint(x: 0, y: viewOne.bounds.height)
        let typeDataSource = ["Đặt Dịch Vụ","Đăng Tìm Việc", "Ứng Viên Phù Hợp","Việc Làm Phù Hợp", "Chi Tiết Công Việc","Chi Tiết Ứng Viên"]
        locationDropDown.dataSource = typeDataSource
        
        locationDropDown.selectionAction = { (index, item) in
            print(index, item)
            self.lbOne.text = item
            self.position = index + 1
        }
    }
    
    func validateAndPostBanner() {
        if tfLink.text == "" || ShareData.arrDates.count == 0 || lbViewName.text == "" || urlImage == "" {
            self.showDialog(title: "Error", message: "Vui lòng nhập đầy đủ thông tin", handler:nil)
        } else {
//            ServiceManager.bannerAds.addBannerAds(position: position, dates: ShareData.arrDates, url: tfLink.text!.lowercased(), cover: urlImage, completion: { (response) in
//                switch response {
//                    case 200:
//                        self.showDialog(title: "", message: "Đăng quảng cáo banner thành công", handler:nil)
//                    case 500:
//                        self.showDialog(title: "Error", message: "Có lỗi xảy ra khi đăng banner, vui lòng thử lại", handler:nil)
//                default:
//                    self.showDialog(title: "Error", message: "Có lỗi xảy ra khi đăng banner, vui lòng thử lại", handler:nil)
//                }
//            })
            ServiceManager.adsService.buyBanner(viewId: position, actionUrl: tfLink.text!.lowercased(), cover: urlImage, dates: ShareData.arrDates, completion: { (result) in
                switch result {
                case .success(let data):
                    if let id = data.id {
                        let vc = PaymentAdsViewController(id: String(describing: id), totalMoney: ShareData.arrDates.count)
                        self.navigationController?.pushViewController(vc, animated: true)
                        ShareData.arrDates = [String]()
                    }
                case .failure(let erorr):
                    self.showDialog(title: "Lỗi", message: erorr.errorMessage , handler:nil)
                }
            })
        }
    }
    
    @IBAction func handleBtnPickViewTouched(_ sender: Any) {
        locationDropDown.show()
    }
    
    @IBAction func handleBtnDateDatesTouched(_ sender: Any) {
        let vc = PickerDateViewController.loadFromNib()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func handleBtnConfirmTouched(_ sender: Any) {
        validateAndPostBanner()
    }
    
    @IBAction func handleImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension BannerAdsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if pickedImage.size.width == 640 && pickedImage.size.height == 100 {
                imageBanner.contentMode = .scaleAspectFit
                imageBanner.image = pickedImage
                dismiss(animated: true, completion: nil)
                
                // upload image to get url
                ServiceManager.postService.uploadFile(dataFile: UIImagePNGRepresentation(pickedImage)!, name: "ban", completion: { (url) in
                    if let url = url, url.characters.count > 0 {
                        self.urlImage = url
                    } else {
                        self.showDialog(title: "Error", message: "Có lỗi xảy ra khi đăng ảnh, vui lòng thử lại", handler:nil)
                    }
                })
            } else {
                dismiss(animated: true, completion: nil)
                let alertView = UIAlertController(title: "", message: "Hình ảnh của banner phải đúng kích thước 640x100", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                self.present(alertView, animated: true, completion: nil)
            }
        }
        
    }
}
