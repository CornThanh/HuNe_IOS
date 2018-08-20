//
//  PostNewsViewController.swift
//  MMY
//
//  Created by Apple on 7/19/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import DropDown
import CoreLocation
import GoogleMaps
import SDWebImage

class PostNewsViewController: UIViewController {
    
    @IBOutlet weak var lbUnit: UILabel!
    @IBOutlet weak var lbTypeProduct: UILabel!
    @IBOutlet weak var lbType: UILabel!
    
    @IBOutlet weak var btUnit: UIButton!
    @IBOutlet weak var btTypeProduct: UIButton!
    @IBOutlet weak var btType: UIButton!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var lbDescription: UITextField!
    
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var tfFeeShip: UITextField!
    @IBOutlet weak var imageAvatar: UIImageView!
    
    @IBOutlet weak var imageSubThree: UIImageView!
    @IBOutlet weak var imageSubTwo: UIImageView!
    @IBOutlet weak var imageSubOne: UIImageView!
    @IBOutlet weak var btPost: UIButton!
    
    let typeDropDown1 = DropDown()
    let typeDropDown2 = DropDown()
    let typeDropDown3 = DropDown()
    let imagePicker = UIImagePickerController()
    var checkTypeImage = 0
    
    private let overLapView = UIView()
    private let contentPickerView = UIView()
    private let pickerView = UIPickerView()
    private let datePickerView = UIDatePicker()
    let dateFormatter = DateFormatter()
    var startdate: Date?
    
    private var location: CLLocation?
    private let geoCoder = GMSGeocoder()
    
    var postNewsModel = PostNewsModel()
    var arrType = [ConfigTypeOrProductTypeModel]()
    var arrProductType = [ConfigTypeOrProductTypeModel]()
    var arrUnit = [ConfigTypeOrProductTypeModel]()
    
    var checkEdit: Bool?
    var dataEdit: ManageStoreModel?
    
     let group = DispatchGroup()
    
    init(checkEdit: Bool, dataEdit: ManageStoreModel) {
        super.init(nibName: "PostNewsViewController", bundle: nil)
        self.checkEdit = checkEdit
        self.dataEdit = dataEdit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Error file nib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "MartSellerViewController1".localized()
        self.setupGesture()
        self.pickerDate()
        self.getLocation()
        self.getConfig()
        if checkEdit == true {
            editData()
            editImage()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupTextFiled()
        self.setupImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func editImage() {
        if dataEdit?.image0 != "" {
            imageSubOne.sd_setImage(with: URL(string: (dataEdit?.image0)!), placeholderImage: UIImage(named: "placeholder0.png"), options: [], completed: nil)
        }
        
        if dataEdit?.image1 != "" {
            imageSubTwo.sd_setImage(with: URL(string: (dataEdit?.image1)!), placeholderImage: UIImage(named: "placeholder1.png"), options: [], completed: nil)
        }
        
        if dataEdit?.image2 != "" {
            imageSubThree.sd_setImage(with: URL(string: (dataEdit?.image2)!), placeholderImage: UIImage(named: "placeholder2.png"), options: [], completed: nil)
        }
    }
    
    func getConfig() {
        self.arrType = ShareData.arrType
        self.arrUnit = ShareData.arrUnit
        self.arrProductType = ShareData.arrProductType
        self.setupDropDown()
    }
    
    func editData() {
        if let price = dataEdit?.price, let amount = dataEdit?.quantity, let feeShip = dataEdit?.transport_fee, let time = dataEdit?.end_date {
            tfPrice.text = String(price)
            tfAmount.text = String(amount)
            tfFeeShip.text = String(feeShip)
            lbTime.text = String(time)
        }
        
        for data in ShareData.arrType {
            if data.id == dataEdit?.type {
                lbType.text = data.name!
            }
        }
        
        for data in ShareData.arrUnit {
            if data.id == dataEdit?.unit {
                lbUnit.text = data.name!
            }
        }
        
        for data in ShareData.arrProductType {
            if data.id == dataEdit?.product_type {
                lbTypeProduct.text = data.name!
            }
        }
        
        lbDescription.text = dataEdit?.description
        lbAddress.text = dataEdit?.address
        
        if postNewsModel.dataThumbnail == nil {
            imageAvatar.sd_setImage(with: URL(string: (self.dataEdit?.thumbnail)!), placeholderImage: UIImage(named: "placeholder.png"), options: [], completed: nil)
        } else {
            imageAvatar.image = postNewsModel.dataThumbnail
        }
        
    }
    
    func checkData() -> Bool{
        if tfPrice.text == "" || lbDescription.text == "" || tfAmount.text == "" || lbTime.text == "" || lbAddress.text == "" || tfFeeShip.text == "" || postNewsModel.dataThumbnail == nil  {
            return false
        } else {
            postNewsModel.name = "test"
            postNewsModel.status = 1
            postNewsModel.price = tfPrice.text
            postNewsModel.description = lbDescription.text
            postNewsModel.quantity = Int(tfAmount.text!)
            postNewsModel.transport_fee = Int(tfFeeShip.text!)
        }
        
        return true
    }
    
    func checkDataEdit() -> Bool {
        if tfPrice.text == "" || lbDescription.text == "" || tfAmount.text == "" || lbTime.text == "" || lbAddress.text == "" || tfFeeShip.text == "" || imageAvatar.image == nil  {
            return false
        }
        
        return true
    }
    
    func pickerDate() {
        let pickerHeight = CGFloat(120)
        overLapView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        overLapView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        contentPickerView.frame = CGRect(x: 0, y:  UIScreen.main.bounds.size.height - 20 - pickerHeight , width: UIScreen.main.bounds.size.width, height: pickerHeight + 20)
        contentPickerView.backgroundColor = UIColor(hexString: "00AB4E")
        
        pickerView.frame = CGRect(x: 0, y:  20 , width: UIScreen.main.bounds.size.width, height: pickerHeight)
        contentPickerView.addSubview(pickerView)
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.backgroundColor = UIColor.clear
        pickerView.isHidden = true
        
        datePickerView.frame = CGRect(x: 0, y:  20 , width: UIScreen.main.bounds.size.width, height: pickerHeight)
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
        datePickerView.isHidden = true
        datePickerView.setValue(UIColor.white, forKeyPath: "textColor")
        contentPickerView.addSubview(datePickerView)
        
        let pickerDoneBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 70, y: 5, width: 50, height: 15))
        pickerDoneBtn.setTitle("Done", for: .normal)
        pickerDoneBtn.setTitleColor(UIColor.white, for: .normal)
        pickerDoneBtn.backgroundColor = UIColor.clear
        pickerDoneBtn.addTarget(self, action: #selector(onBtnPickerDone), for: .touchUpInside)
        contentPickerView.addSubview(pickerDoneBtn)
        
        overLapView.addSubview(contentPickerView)
        
        navigationController?.view.addSubview(overLapView)
        overLapView.isHidden = true
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func datePickerChanged(datePicker:UIDatePicker){
        print(datePicker.date)
        let date = datePicker.date
        let dateString = dateFormatter.string(from: date)
        startdate = date
        lbTime.text = "   " + dateString
        postNewsModel.end_date = dateString
    }
    
    func onBtnPickerDone() {
        self.overLapView.isHidden = true
        let date = datePickerView.date
        let dateString = dateFormatter.string(from: date)
        lbTime.text = "   " + dateString
        startdate = date
        postNewsModel.end_date = dateString
    }
    
    func setupGesture() {
        
        let tapFour = UITapGestureRecognizer(target:self,action:#selector(tapLbTime))
        self.lbTime.isUserInteractionEnabled = true
        self.lbTime.addGestureRecognizer(tapFour)
        
        let tapFive = UITapGestureRecognizer(target:self,action:#selector(tapLbAddress))
        self.lbAddress.isUserInteractionEnabled = true
        self.lbAddress.addGestureRecognizer(tapFive)
        
        let tapSix = UITapGestureRecognizer(target:self,action:#selector(tapIamgeAvatar))
        self.imageAvatar.isUserInteractionEnabled = true
        self.imageAvatar.addGestureRecognizer(tapSix)
        
        let tapSeven = UITapGestureRecognizer(target:self,action:#selector(tapIamgeSubAvatarOne))
        self.imageSubOne.isUserInteractionEnabled = true
        self.imageSubOne.addGestureRecognizer(tapSeven)
        
        let tapNine = UITapGestureRecognizer(target:self,action:#selector(tapIamgeSubAvatarTwo))
        self.imageSubTwo.isUserInteractionEnabled = true
        self.imageSubTwo.addGestureRecognizer(tapNine)
        
        let tapTen = UITapGestureRecognizer(target:self,action:#selector(tapIamgeSubAvatarThree))
        self.imageSubThree.isUserInteractionEnabled = true
        self.imageSubThree.addGestureRecognizer(tapTen)
    }
    
    func setupTextFiled() {
        tfPrice.layer.cornerRadius = self.tfPrice.frame.size.height/2
        tfFeeShip.layer.cornerRadius = self.tfFeeShip.frame.size.height/2
        lbDescription.layer.cornerRadius = 10.0
        btPost.layer.cornerRadius = self.btPost.frame.size.height/2
        tfAmount.layer.cornerRadius = self.tfAmount.frame.size.height/2
        lbUnit.layer.cornerRadius = self.lbUnit.frame.size.height/2
        lbType.layer.cornerRadius = self.lbType.frame.size.height/2
        lbTypeProduct.layer.cornerRadius = self.lbTypeProduct.frame.size.height/2
        lbTime.layer.cornerRadius = self.lbTime.frame.size.height/2
        lbAddress.layer.cornerRadius = self.lbTime.frame.size.height/2
        
        tfPrice.layer.borderWidth = 1.0
        tfFeeShip.layer.borderWidth = 1.0
        lbDescription.layer.borderWidth = 1.0
        tfAmount.layer.borderWidth = 1.0
        lbUnit.layer.borderWidth = 1.0
        lbType.layer.borderWidth = 1.0
        lbTypeProduct.layer.borderWidth = 1.0
        lbTime.layer.borderWidth = 1.0
        lbAddress.layer.borderWidth = 1.0
        
        tfAmount.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        tfPrice.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        tfFeeShip.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        lbDescription.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        btPost.backgroundColor = UIColor(hexString: "00AB4E")
        lbUnit.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        lbType.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        lbTypeProduct.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        lbTime.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        lbAddress.layer.borderColor = UIColor(hexString: "00AB4E")?.cgColor
        
        tfAmount.layer.masksToBounds = true
        tfPrice.layer.masksToBounds = true
        tfFeeShip.layer.masksToBounds = true
        lbDescription.layer.masksToBounds = true
        
        btPost.setTitle("Recruit".localized(), for: .normal)
    }
    
    func setupImage() {
        imageSubOne.layer.cornerRadius = imageSubOne.frame.size.height/2
        imageSubTwo.layer.cornerRadius = imageSubTwo.frame.size.height/2
        imageSubThree.layer.cornerRadius = imageSubThree.frame.size.height/2
    }
    
    func setupDropDown() {
        if arrProductType.count > 0 {
            postNewsModel.product_type = arrProductType[0].id!
            DispatchQueue.main.async {
                self.lbTypeProduct.text = "  " + self.arrProductType[0].name!
            }
            self.setupTypeProduct()
        }
        if arrType.count > 0 {
            postNewsModel.type = arrType[0].id!
            DispatchQueue.main.async {
                self.lbType.text = "  " + self.arrType[0].name!
            }
            self.setupTypeDropDown()
        }
        
        if arrUnit.count > 0 {
            postNewsModel.unit = arrUnit[0].id!
            DispatchQueue.main.async {
                self.lbUnit.text = "  " + self.arrUnit[0].name!
            }
            self.setupUnitDropDown()
        }
    }
    
    func tapLbTime() {
        self.overLapView.isHidden = false
        pickerView.isHidden = true
        datePickerView.isHidden = false
        if let startdate = startdate {
            datePickerView.setDate(startdate, animated: true)
        }
        else {
            self.startdate = Date()
            datePickerView.setDate(self.startdate!, animated: true)
        }
        view.endEditing(true)
    }
    
    func tapLbAddress() {
        let mapPickerViewController = MapPickerViewController()
        mapPickerViewController.location = Authenticator.shareInstance.getLocation()
        mapPickerViewController.onDismissCallback = {[weak self](location) in
            self?.locationChanged(to: location)
        }
        navigationController?.pushViewController(mapPickerViewController, animated: true)
    }
    
    func getLocation() {
        if let location = Authenticator.shareInstance.getLocation() {
            self.location = location
            self.locationChanged(to: location)
        }
    }
    
    func locationChanged(to newLocation: CLLocation?) {
        guard let newLocation = newLocation else {
            return
        }
        location = newLocation
        geoCoder.reverseGeocodeCoordinate(newLocation.coordinate) { [weak self] (response, error) in
            guard let weakSelf = self,
                let location = response?.firstResult() else {
                    return
            }
            let address = location.lines?.joined(separator: ", ")
            weakSelf.lbAddress.text = "   " + address!
            weakSelf.postNewsModel.address = address!
        }
    }
    
    
    func tapIamgeAvatar() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        checkTypeImage = 0
        present(imagePicker, animated: true, completion: nil)
    }
    
    func tapIamgeSubAvatarOne() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        checkTypeImage = 1
        present(imagePicker, animated: true, completion: nil)
    }
    
    func tapIamgeSubAvatarThree() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        checkTypeImage = 3
        present(imagePicker, animated: true, completion: nil)
    }
    
    func tapIamgeSubAvatarTwo() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        checkTypeImage = 2
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setupTypeDropDown() {
        typeDropDown1.anchorView = btType
        typeDropDown1.bottomOffset = CGPoint(x: 0, y: btType.bounds.height)
        var typeDataSource = [String]()
        for data in arrType {
            typeDataSource.append(data.name!)
        }
        typeDropDown1.dataSource = typeDataSource
        typeDropDown1.selectionAction = { [unowned self] (index, item) in
            self.lbType.text = "  " + item
            if self.checkEdit == false {
                self.postNewsModel.type = self.arrType[index].id!
            } else {
                self.dataEdit?.type = self.arrType[index].id!
            }
        }
    }
    
    func setupUnitDropDown() {
        typeDropDown2.anchorView = btUnit
        typeDropDown2.bottomOffset = CGPoint(x: 0, y: btUnit.bounds.height)
        var unitDataSource = [String]()
        for data in arrUnit {
            unitDataSource.append(data.name!)
        }
        typeDropDown2.dataSource = unitDataSource
        typeDropDown2.selectionAction = { [unowned self] (index, item) in
            self.lbUnit.text = "  " + item
            if self.checkEdit == false {
                self.postNewsModel.unit = self.arrUnit[index].id!
            } else {
                self.dataEdit?.unit = self.arrUnit[index].id!
            }
        }
    }
    
    func setupTypeProduct() {
        typeDropDown3.anchorView = btTypeProduct
        DispatchQueue.main.async {
            self.typeDropDown3.bottomOffset = CGPoint(x: 0, y: self.btTypeProduct.bounds.height)
        }
        var typeDataSource = [String]()
        for data in arrProductType {
            typeDataSource.append(data.name!)
        }
        typeDropDown3.dataSource = typeDataSource
        typeDropDown3.selectionAction = { [unowned self] (index, item) in
            self.lbTypeProduct.text = "  " + item
            if self.checkEdit == false {
                self.postNewsModel.product_type = self.arrProductType[index].id!
            } else {
                self.dataEdit?.product_type = self.arrProductType[index].id!
            }
        }
    }
    
    func uploadData() {
        if checkData() == true {
            // upload image
            ServiceManager.postService.uploadFile(dataFile: UIImageJPEGRepresentation(postNewsModel.dataThumbnail!, 0.2)!, name: "dataT.jpg", completion: { (link) in
                self.postNewsModel.thumbnail = link
                
                if self.postNewsModel.arrImage.count > 0 {
                    let count = self.self.postNewsModel.arrImage.count - 1
                    self.uploadSubImage(numberImage: count)
                } else {
                    ServiceManager.martService.addPostNews(self.postNewsModel, completion: { (result) in
                        switch result {
                        case .success( _):
                            print("Okkkkkkkkkkkkkkk")
                            self.showDialog(title: "HuNe Mart", message: "PostNewsSuccess".localized(), handler: { (action) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        case .failure( _):
                            print("Erorrrrrrrrrrrr")
                            self.showDialog(title: "HuNe Mart", message: "PostNewsError".localized(), handler:nil)
                        }
                    })
                }
            })
            
        } else {
            self.showDialog(title: "Empty Field".localized(), message: "Vui lòng nhập đầy đủ thông tin", handler:nil)
        }
        
    }
    
    func uploadSubImage(numberImage : Int) {
        var count = numberImage
        if count >= 0 {
            ServiceManager.postService.uploadFile(dataFile: UIImageJPEGRepresentation(postNewsModel.arrImage[count], 0.2)!, name: "subThumbnail.jpg", completion: { (link) in
                print("/////////////////////////////////////////",link!)
                if count == 0 {
                    self.postNewsModel.image1 = link
                } else if count == 1 {
                    self.postNewsModel.image2 = link
                } else {
                    self.postNewsModel.image3 = link
                }
                count = count - 1
                self.uploadSubImage(numberImage: count)
            })
        } else {
            ServiceManager.martService.addPostNews(self.postNewsModel, completion: { (result) in
                switch result {
                case .success( _):
                    print("Okkkkkkkkkkkkkkk")
                    self.showDialog(title: "HuNe Mart", message: "PostNewsSuccess".localized(), handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                case .failure( _):
                    print("Erorrrrrrrrrrrr")
                    self.showDialog(title: "HuNe Mart", message: "PostNewsError".localized(), handler:nil)
                }
            })
        }
    }
    
    func editUpload() {
        if checkDataEdit() == true {
            let group = DispatchGroup()
            group.enter() // uploadFile
            ServiceManager.postService.uploadFile(dataFile: UIImageJPEGRepresentation(imageAvatar.image!, 0.2)!, name: "dataT.jpg", completion: { (link) in
                self.dataEdit?.thumbnail = link
                group.leave()
            })
            group.notify(queue: .global(qos: .background), execute: {
                ServiceManager.martService.updateSellerProduct(self.dataEdit!, product_id: (self.dataEdit?.product_id)! , completion: { (result) in
                    switch result {
                    case .success( _):
                        print("Okkkkkkkkkkkkkkk")
                        self.showDialog(title: "HuNe Mart", message: "EditNewsSuccess".localized(), handler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        })
                    case .failure(let error):
                        print("Erorrrrrrrrrrrr", error)
                        self.showDialog(title: "HuNe Mart", message: "EditNewsError".localized(), handler:nil)
                    }
                })
            })
            
        }else {
            self.showDialog(title: "Empty Field".localized(), message: "Vui lòng nhập đầy đủ thông tin", handler:nil)
        }
    }
    
    @IBAction func actionPost(_ sender: Any) {
        if checkEdit == false {
            self.uploadData()
        } else {
            dataEdit?.price = Int(tfPrice.text!)
            dataEdit?.quantity = Int(tfAmount.text!)
            dataEdit?.transport_fee =  Int(tfFeeShip.text!)
            dataEdit?.end_date = lbTime.text
            self.editUpload()
        }
    }
    @IBAction func actionShowType(_ sender: Any) {
        typeDropDown1.show()
    }
    
    @IBAction func actionShowProduct(_ sender: Any) {
        typeDropDown3.show()
    }
    
    @IBAction func actionShowUnit(_ sender: Any) {
        typeDropDown2 .show()
    }
}

extension PostNewsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if checkTypeImage == 0 {
                imageAvatar.contentMode = .scaleAspectFit
                imageAvatar.image = pickedImage
                postNewsModel.dataThumbnail = pickedImage
            } else if checkTypeImage == 1 {
                imageSubOne.contentMode = .scaleAspectFit
                imageSubOne.image = pickedImage
                postNewsModel.arrImage.append(pickedImage)
            } else if checkTypeImage == 2 {
                imageSubTwo.contentMode = .scaleAspectFit
                imageSubTwo.image = pickedImage
                postNewsModel.arrImage.append(pickedImage)
            } else if checkTypeImage == 3 {
                imageSubThree.contentMode = .scaleAspectFit
                imageSubThree.image = pickedImage
                postNewsModel.arrImage.append(pickedImage)
            }
            
            dismiss(animated: true, completion: nil)
        }
        
    }
}


