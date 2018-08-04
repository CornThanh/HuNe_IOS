//
//  PlaceAdsViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/22/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class PlaceAdsViewController: BaseViewController {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbHeader: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbLink: UILabel!
    
    @IBOutlet weak var btNext: UIButton!
    @IBOutlet weak var tfLocation: UITextView!
    // tfLocation
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfLink: UITextField!
    @IBOutlet weak var btUploadImage: UIButton!
    @IBOutlet weak var imageBaner: UIImageView!
    @IBOutlet weak var lbLocation: UILabel!
    
    var backGroundColor: UIColor?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PlaceAds".localized()
        addLeftBarButton()
        lbTitle.text = "PlaceAdsViewController".localized()
        lbHeader.text = "PlaceAdsViewController1".localized()
        lbDescription.text = "PlaceAdsViewController2".localized()
        lbLocation.text = "PlaceAdsViewController3".localized()
        lbLink.text = "PlaceAdsViewController9".localized()
        btNext.setTitle("PlaceAdsViewController4".localized(), for: .normal)
        btUploadImage.setTitle("PlaceAdsViewController5".localized(), for: .normal)
        tfTitle.placeholder = "PlaceAdsViewController6".localized()
        tfDescription.placeholder = "PlaceAdsViewController7".localized()
        tfLocation.placeholder = "PlaceAdsViewController8".localized()
        tfLink.placeholder = "PlaceAdsViewController10".localized()
        
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        } else {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
    
        tfDescription.layer.cornerRadius = 20.0
        tfTitle.layer.borderWidth = 1.0
        tfDescription.layer.borderWidth = 1.0
        tfLocation.layer.borderWidth = 1.0
        tfLink.layer.borderWidth = 1.0
        tfTitle.layer.borderColor = backGroundColor?.cgColor
        tfDescription.layer.borderColor = backGroundColor?.cgColor
        tfLocation.layer.borderColor = backGroundColor?.cgColor
        tfLink.layer.borderColor = backGroundColor?.cgColor
        tfTitle.layer.masksToBounds = true
        tfDescription.layer.masksToBounds = true
        tfLocation.layer.masksToBounds = true
        tfLink.layer.masksToBounds = true
        
        btUploadImage.backgroundColor = backGroundColor
        btNext.backgroundColor = backGroundColor
        
        DispatchQueue.main.async {
            self.btUploadImage.layer.cornerRadius = self.btUploadImage.frame.size.height/2
            self.btNext.layer.cornerRadius = self.btNext.frame.size.height/2
            self.tfLocation.layer.cornerRadius = 10.0
            self.tfTitle.layer.cornerRadius = self.tfTitle.frame.size.height/2
            self.tfLink.layer.cornerRadius = self.tfLink.frame.size.height/2
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ShareData.totalDateChoose = 0
        ShareData.arrDates = [String]()
    }
    
    @IBAction func btTapNext(_ sender: Any) {
        if lbHeader.text! == "" || lbDescription.text == "" || lbLocation.text == "" || AdsLocation.logo == "" {
            self.showDialog(title: "Error", message: "Vui lòng nhập đầy đủ thông tin", handler:nil)
        } else {
            AdsLocation.name = lbHeader.text!
            AdsLocation.description = lbDescription.text!
            AdsLocation.branch.append(lbLocation.text!)
            let vc = NextPlaceAdsViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btTapUpload(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension PlaceAdsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageBaner.contentMode = .scaleAspectFit
            imageBaner.image = pickedImage
            dismiss(animated: true, completion: nil)
            
            // upload image to get url
            var avatar = imageBaner.image
            let imageSize = avatar?.size
            if imageSize!.width > 500.0 {
                let newSize = CGSize(width: 500.0, height: (imageSize?.height)!/(imageSize?.width)!*500)
                avatar = avatar?.imageScaled(to: newSize)
            }
            ServiceManager.postService.uploadFile(dataFile: UIImagePNGRepresentation(avatar!)!, name: "avatar", completion: { (url) in
                if let url = url, url.characters.count > 0 {
                    AdsLocation.logo = url
                } else {
                    self.showDialog(title: "Error", message: "Có lỗi xảy ra khi đăng ảnh, vui lòng thử lại", handler:nil)
                }
            })
        }
        
    }
}
