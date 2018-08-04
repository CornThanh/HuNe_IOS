
import UIKit
import DropDown
import NVActivityIndicatorView
import Kingfisher
import RSKImageCropper

class EditPersonInfoViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var genderLB: UILabel!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var genderDownImage: UIImageView!
    @IBOutlet weak var dateOfBirthLB: UILabel!
    @IBOutlet weak var dateOfBirthBtn: UIButton!
    @IBOutlet weak var dateOfBirthImage: UIImageView!
//    @IBOutlet weak var phoneNumberLB: UILabel!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    
    var activityIndicator: NVActivityIndicatorView?
    
    let genderDropDown = DropDown()
    
    // For date picker
    private let datePickerView = UIDatePicker()
    private let contentPickerView = UIView()
    private let overLapView = UIView()
    let dateFormatter = DateFormatter()
    
    var userModel: UserModel?
    var cloneUser: UserModel?
    var avatarIsChanged = false
    
    var backGroundColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloneUser = userModel?.copy()
        
        configNavigaton()
        
        if let color =  Authenticator.shareInstance.getPostType()?.color(){
            backGroundColor = color
        }
        
        nameTF.layer.cornerRadius = nameTF.frame.height/2.0
        nameTF.clipsToBounds = true
        nameTF.layer.borderWidth = 1
        nameTF.layer.borderColor = backGroundColor.cgColor
        let nameTFPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: nameTF.frame.height))
        nameTF.leftView = nameTFPaddingView
        nameTF.leftViewMode = .always
        nameTF.text = userModel?.full_name
        
        avatarImage.layer.cornerRadius = avatarImage.frame.height/2
        avatarImage.clipsToBounds = true
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(self.tapAvatar(_:)))
        avatarImage.addGestureRecognizer(tapAvatar)
        avatarImage.isUserInteractionEnabled = true
        
        if let urlString = userModel?.avatarURL {
            let url = URL(string: urlString)
            avatarImage.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        genderBtn.layer.cornerRadius = genderBtn.frame.height/2.0
        genderBtn.clipsToBounds = true
        genderBtn.layer.borderWidth = 1
        genderBtn.layer.borderColor = backGroundColor.cgColor
        genderDownImage.image = genderDownImage.image?.withRenderingMode(.alwaysTemplate)
        genderDownImage.tintColor = backGroundColor
        if userModel?.gender == "1" {
            genderLB.text = "Nữ"
        }
        else {
            genderLB.text = "Nam"
        }
        
        dateOfBirthBtn.layer.cornerRadius = dateOfBirthBtn.frame.height/2.0
        dateOfBirthBtn.clipsToBounds = true
        dateOfBirthBtn.layer.borderWidth = 1
        dateOfBirthBtn.layer.borderColor = backGroundColor.cgColor
        dateOfBirthImage.image = dateOfBirthImage.image?.withRenderingMode(.alwaysTemplate)
        dateOfBirthImage.tintColor = backGroundColor
        dateOfBirthLB.text = userModel?.birthday
        
        doneBtn.layer.cornerRadius = doneBtn.frame.height/2.0
        doneBtn.backgroundColor = backGroundColor
        doneBtn.clipsToBounds = true
        
//        phoneNumberLB.text = userModel?.phone
        phoneNumberTF.layer.cornerRadius = phoneNumberTF.frame.height/2.0
        phoneNumberTF.clipsToBounds = true
        phoneNumberTF.layer.borderWidth = 1
        phoneNumberTF.layer.borderColor = Authenticator.shareInstance.getPostType()?.color().cgColor
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: phoneNumberTF.frame.height))
        phoneNumberTF.leftView = paddingView
        phoneNumberTF.leftViewMode = .always
        phoneNumberTF.text = userModel?.phone
        
        phoneNumberTF.isUserInteractionEnabled = (phoneNumberTF.text?.characters.count)! == 0
        phoneNumberTF.keyboardType = .phonePad
        
        // For PickerView
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let pickerHeight = CGFloat(120)
        overLapView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        overLapView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        contentPickerView.frame = CGRect(x: 0, y:  UIScreen.main.bounds.size.height - 20 - pickerHeight , width: UIScreen.main.bounds.size.width, height: pickerHeight + 20)
        contentPickerView.backgroundColor = backGroundColor
        datePickerView.frame = CGRect(x: 0, y:  20 , width: UIScreen.main.bounds.size.width, height: pickerHeight)
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
        datePickerView.minimumDate = dateFormatter.date(from: "1920-01-01")
        datePickerView.maximumDate = Date()
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

        setupGenderDropDown()
        setupActivityIndicator()
        
    }

    func configNavigaton()  {
        
        // Add left bar button
        let leftButton = UIButton.init(type: .custom)
        leftButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftButton.addTarget(self, action:#selector(onBtnBack), for: UIControlEvents.touchUpInside)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20)
        leftButton.tintColor = .white
        leftButton.backgroundColor = .clear
        let leftBarButton = UIBarButtonItem.init(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        // Add right bar button
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "icon_notification"), style: .done, target: self, action: #selector(displayNotification))
        rightMenuButton.image = UIImage(named: "icon_notification")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightMenuButton
        
        // Title
        title = "Sửa thông tin cá nhân".localized()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
    }
    
    func setupGenderDropDown() {
        genderDropDown.anchorView = genderBtn
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        genderDropDown.bottomOffset = CGPoint(x: 0, y: genderBtn.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        genderDropDown.dataSource = [
            "Nam",
            "Nữ"
        ]
        
        // Action triggered on selection
        genderDropDown.selectionAction = { [unowned self] (index, item) in
            self.genderLB.text = item
            if index == 0 {
                self.cloneUser?.gender = "2"
            }
            else {
                self.cloneUser?.gender = "1"
            }
        }
    }
    
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
    }

    // MARK: - handle user action
    func displayNotification() {
        print("displayNotification")
        let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    func tapAvatar(_ sender: UITapGestureRecognizer) {
        func showSelectAvatarOption(with sourceType: UIImagePickerControllerSourceType) {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
        
        let controller = UIAlertController(title: "", message: "Choose action".localized(), preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera".localized(), style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                showSelectAvatarOption(with: .camera)
            }
            
        }
        let photoAction = UIAlertAction(title: "Photo".localized(), style: .default) { (_) in
            showSelectAvatarOption(with: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        controller.addAction(cameraAction)
        controller.addAction(photoAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onBtnGender(_ sender: Any) {
        genderDropDown.show()
    }
    
    
    @IBAction func onBtnDateOfBirth(_ sender: Any) {
        self.overLapView.isHidden = false
        if let date = dateFormatter.date(from: dateOfBirthLB.text!) {
            datePickerView.setDate(date, animated: true)
        }
        else {
            datePickerView.setDate(Date(), animated: true)
        }
        datePickerView.isHidden = false
        view.endEditing(true)
    }
    
    @IBAction func onBtnDone(_ sender: Any) {
        if nameTF.text?.characters.count == 0 {
            showDialog(title: "Empty Field".localized(), message: "FullName".localized(), handler: nil)
        }
        else if dateOfBirthLB.text?.characters.count == 0 {
            showDialog(title: "Empty Field".localized(), message: "DateOfBirth".localized(), handler: nil)
        }
        else if phoneNumberTF.text?.characters.count == 0 {
            showDialog(title: "Empty Field".localized(), message: "PhoneNumber".localized(), handler: nil)
        }
        else {
            cloneUser?.birthday = dateOfBirthLB.text
            cloneUser?.full_name = nameTF.text
            cloneUser?.phone = phoneNumberTF.text
            if let cloneUser = self.cloneUser {
                activityIndicator?.startAnimating()
                let maxWidth: CGFloat = 500
                if avatarIsChanged, var image = avatarImage.image {
                    let imageSize = image.size
                    if imageSize.width > maxWidth {
                        let newSize = CGSize(width: maxWidth, height: imageSize.height/imageSize.width*maxWidth)
                        image = image.imageScaled(to: newSize)
                    }
                    ServiceManager.postService.uploadFile(dataFile: UIImageJPEGRepresentation(image, 1.0)!, name: "avatar.jpg", completion: { (url) in
                        if let url = url, url.characters.count > 0 {
                            self.cloneUser?.avatarURL = url
                            ServiceManager.userService.updateProfile(user: cloneUser, avatarIsChanged: true, completion: { [weak self] (resultCode) in
                                self?.activityIndicator?.stopAnimating()
                                if resultCode == ErrorCode.success.rawValue {
                                    self?.showDialog(title: "Thành công", message: "Bạn đã thay đổi thông tin cá nhân thành công", handler: { (alert) in
                                        self?.userModel?.full_name = self?.cloneUser?.full_name
                                        self?.userModel?.birthday = self?.cloneUser?.birthday
                                        self?.userModel?.gender = self?.cloneUser?.gender
                                        self?.userModel?.avatarURL = self?.cloneUser?.avatarURL
                                        self?.userModel?.phone = self?.cloneUser?.phone
                                        self?.navigationController?.popViewController(animated: true)
                                    })
                                    
                                    ServiceManager.userService.get(userId: "") { (result) in
                                        switch result {
                                        case .success(let user):
                                            self?.cloneUser?.avatarURL = user.avatarURL
                                        case .failure(let error):
                                            log.debug(error.errorMessage)
                                        }
                                    }
                                }
                                else {
                                    self?.showDialog(title: "Error", message: "Có lỗi khi thay đổi thông tin cá nhân, vui lòng thử lại", handler:nil)
                                }
                            })
                        }
                        else {
                            self.activityIndicator?.stopAnimating()
                            self.showDialog(title: "Error", message: "Có lỗi khi thay đổi hình đại diên, vui lòng thử lại", handler:nil)
                        }
                        
                    })
                }
                else {
                    ServiceManager.userService.updateProfile(user: cloneUser, completion: { [weak self] (resultCode) in
                        self?.activityIndicator?.stopAnimating()
                        if resultCode == ErrorCode.success.rawValue {
                            self?.showDialog(title: "Thành công", message: "Bạn đã thay đổi thông tin cá nhân thành công", handler: { (alert) in
                                self?.userModel?.full_name = self?.cloneUser?.full_name
                                self?.userModel?.birthday = self?.cloneUser?.birthday
                                self?.userModel?.gender = self?.cloneUser?.gender
                                self?.userModel?.phone = self?.cloneUser?.phone
                                self?.navigationController?.popViewController(animated: true)
                            })
                        }
                        else {
                            self?.showDialog(title: "Error", message: "Có lỗi khi thay đổi thông tin cá nhân, vui lòng thử lại", handler:nil)
                        }
                    })
                }
            }
        }
    }
    
    
    // Mark: handle date picker event
    func datePickerChanged(datePicker:UIDatePicker){
        print(datePicker.date)
        let date = datePicker.date
        let dateString = dateFormatter.string(from: date) //pass Date here
        dateOfBirthLB.text = dateString
    }
    
    func onBtnPickerDone() {
        self.overLapView.isHidden = true
        let date = datePickerView.date
        let dateString = dateFormatter.string(from: date) //pass Date here
        dateOfBirthLB.text = dateString
    }
}

//MARK: - ImagePickerDelegate
extension EditPersonInfoViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImage.image = pickedImage
            avatarIsChanged = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
