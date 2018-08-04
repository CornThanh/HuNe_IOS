//
//  ProfileViewController.swift
//  MMY
//
//  Created by Blue R&D on 2/20/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import Eureka
import NVActivityIndicatorView
import SwiftyJSON

class ProfileViewController: FormViewController {
    
    //MARK: - Properties
    var headerView: ProfileHeaderView?
    var closeButton: UIButton?
    var saveButton: UIButton?
    var isModifying = false
    var allowsEditing = false
    var wasImageChange = false
    var canBeDismissed = true
    let headerViewHeight: CGFloat =  200
    let info = ["Name".localized(), "Phone".localized(), "Email".localized()]
    var userModel: UserModel?
    var editedModel: UserModel?
    
    let activityIndicator = NVActivityIndicatorView(frame: CGRect.zero, type: .ballSpinFadeLoader, color: .black, padding: 0)
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupForm()
        setupActivityIndicator()
        setupCloseButton()
        if let userModel = userModel, allowsEditing {
            editedModel = userModel.copy()
        }
    }
    
    //MARK: - Methods
    func enableModifying() {
        isModifying = true
        saveButton?.isEnabled = true
        form.allSections.last?.reload()
    }
    
    func saveNewInfo() {
        guard let editedModel = editedModel,
            (editedModel.firstName != nil || editedModel.lastName != nil) && editedModel.phone != nil else {
                UIAlertController.showSimpleAlertView(in: self, title: "Update user failed".localized(), message: "First name or last name and phone is required".localized(), buttonTitle: "OK".localized())
                return
        }
        editedModel.phone = editedModel.phone == userModel?.phone ? nil : editedModel.phone
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        //wasImageChange ? uploadNewAvatar(of: editedModel) : update(editedModel)
        update(editedModel)
    }
    
    func uploadNewAvatar(of user: UserModel) {
        guard let image = headerView?.imageView.image else {
            return
        }
        ServiceManager.media.upload(image: image, handler: { (result) in
            switch result {
            case .success(let avatar):
                user.avatar = avatar
                self.update(user, isUpdateAvatar: true)
            case .failure(let error):
                log.debug(error.errorMessage)
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        })
    }
    
    func update(_ user: UserModel, isUpdateAvatar: Bool = false) {
//        ServiceManager.userService.update(user: user) { (result) in
//            self.activityIndicator.stopAnimating()
//            self.view.isUserInteractionEnabled = true
//            switch result {
//            case .success(_):
//                if !isUpdateAvatar {
//                    self.isModifying = false
//                    self.dismissProfileViewController()
//                }
//            case .failure(let error):
//                UIAlertController.showSimpleAlertView(in: self, title: "Update user failed".localized(), message: error.errorMessage.localized(), buttonTitle: "OK".localized())
//                log.debug(error.errorMessage)
//            }
//        }
    }
    
    func selectAvatar() {
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
    
    func dismissProfileViewController() {
        if !isModifying {
            dismiss(animated: true, completion: nil)
        } else {
            UIAlertController.showDiscardAlertView(in: self) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//MARK: - ImagePickerDelegate
extension ProfileViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            headerView?.imageView.image = pickedImage
            //wasImageChange = true
            //enableModifying()
            if let userID = userModel?.userId,
                let uploadImageModel = UserModel(json: JSON(true)) {
                uploadImageModel.userId = userID
                uploadNewAvatar(of: uploadImageModel)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Setup views
extension ProfileViewController {
    func setupHeaderView() {
        headerView = ProfileHeaderView(frame: CGRect(x: 0, y: 0, width: 400, height: headerViewHeight))
        headerView?.imageTouchedCallback = {[weak self] in self?.selectAvatar()}
        headerView?.setImage(with: userModel?.avatarURL)
    }
    
    func setupCloseButton() {
        closeButton = UIButton(type: .custom)
        closeButton?.setImage(UIImage(named: "ic_close_white"), for: .normal)
        closeButton?.addTarget(self, action: #selector(dismissProfileViewController), for: .touchUpInside)
        closeButton?.isHidden = !canBeDismissed
        view.safeAddSubview(closeButton)
        closeButton?.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view).offset(30)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
    }
    
    func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.width.equalTo(50)
            make.height.equalTo(50)
        }
    }
    
    func setupForm() {
        tableView?.backgroundColor = .white
        tableView?.isScrollEnabled = false
        tableView?.separatorStyle = .none
        form = Form()
        let firstSection = Section()
        var header = HeaderFooterView<UIView>(.class)
        header.height = { self.headerViewHeight }
        header.onSetupView = { [weak self] view, section in
            view.safeAddSubview(self?.headerView)
            self?.headerView?.snp.makeConstraints({ (make) in
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.top.equalTo(view)
                make.bottom.equalTo(view)
            })
        }
        firstSection.header = header
        form.append(firstSection)
        
        let basicSection = Section()
        
        //First name
        let firstNameRow = TextRow("firstName").cellSetup { [weak self] (cell, row) in
            row.value = self?.userModel?.firstName
            row.placeholder = "First name".localized()
            cell.imageView?.image = UIImage(named: "ic_profile_name")
            self?.offset(cell: cell)
            cell.addSeparator()
            }.onChange { [weak self] (row) in
                self?.editedModel?.firstName = row.value
                self?.enableModifying()
        }
        firstNameRow.disabled = .function([], { [weak self] form -> Bool in
            return self?.allowsEditing != nil ? !(self?.allowsEditing)! : true
        })
        basicSection.append(firstNameRow)
        
        //Last name
        let lastNameRow = TextRow("lastName").cellSetup { [weak self] (cell, row) in
            row.value = self?.userModel?.lastName
            row.placeholder = "Last name".localized()
            cell.imageView?.image = UIImage(named: "ic_profile_name")
            self?.offset(cell: cell)
            cell.addSeparator()
            }.onChange { [weak self] (row) in
                self?.editedModel?.lastName = row.value
                self?.enableModifying()
        }
        lastNameRow.disabled = .function([], { [weak self] form -> Bool in
            return self?.allowsEditing != nil ? !(self?.allowsEditing)! : true
        })
        basicSection.append(lastNameRow)
        
        //Phone
        let phoneRow = TextRow("phone").cellSetup({ [weak self] (cell, row) in
            row.value = self?.userModel?.phone
            row.placeholder = "Phone".localized()
            cell.imageView?.image = UIImage(named: "ic_profile_phone")
            self?.offset(cell: cell)
            cell.addSeparator()
        }).onChange { [weak self] (row) in
            self?.editedModel?.phone = row.value
            self?.enableModifying()
            }.onCellSelection { [weak self] (cell, row) in
                self?.phoneRowTapped(number: row.value)
        }
        phoneRow.disabled = .function([], { [weak self] form -> Bool in
            return self?.allowsEditing != nil ? !(self?.allowsEditing)! : true
        })
        basicSection.append(phoneRow)
        
        //Email
        let emailRow = TextRow("email").cellSetup({ [weak self] (cell, row) in
            row.value = self?.userModel?.email
            row.placeholder = "Email".localized()
            cell.imageView?.image = UIImage(named: "ic_profile_mail")
            self?.offset(cell: cell)
            cell.addSeparator()
        }).onChange { [weak self] (row) in
            self?.editedModel?.email = row.value
            self?.enableModifying()
            }.onCellSelection { (cell, row) in
                if let email = row.value {
                    if let url = URL(string: "message://" + email) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
        }
        emailRow.disabled = .function([], { [weak self] form -> Bool in
            return self?.allowsEditing != nil ? !(self?.allowsEditing)! : true
        })
        basicSection.append(emailRow)
        form.append(basicSection)
        
        let updateSection = Section()
        let updateRow = ButtonRow() {
            $0.title = "Update".localized()
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = UIColor.appColor
                let roundBorder = UIView(frame: CGRect.zero)
                roundBorder.layer.borderWidth = 2
                roundBorder.layer.cornerRadius = 22
                roundBorder.layer.borderColor = UIColor.appColor.cgColor
                cell.contentView.addSubview(roundBorder)
                roundBorder.snp.makeConstraints({ (make) in
                    make.center.equalTo(cell.contentView)
                    make.width.equalTo(cell.contentView).offset(-100)
                    make.height.equalTo(cell.contentView)
                })
                row.disabled = true
            }).onCellSelection { [weak self] (cell, row) in
                self?.saveNewInfo()
        }
        updateRow.hidden = .function([]) { [weak self] form -> Bool in
            return self?.allowsEditing != nil ? !(self?.allowsEditing)! : true
        }
        updateSection.append(updateRow)
        form.append(updateSection)
    }
    
    func offset(cell: UITableViewCell) {
        guard let imageView = cell.imageView else {
            return
        }
        imageView.snp.updateConstraints({ (make) in
            make.left.equalTo(cell.contentView).offset(50)
            make.centerY.equalTo(cell.contentView)
        })
        cell.textLabel?.snp.updateConstraints({ (make) in
            make.left.equalTo(imageView.snp.right).offset(20)
            make.centerY.equalTo(cell.contentView)
        })
    }
    
    func phoneRowTapped(number: String?) {
        guard let number = number else {
            return
        }
        func doPhoneAction(with url: URL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
        let controller = UIAlertController(title: "", message: "Choose action".localized(), preferredStyle: .actionSheet)
        let callAction = UIAlertAction(title: "Call".localized(), style: .default) { (_) in
            if let url = URL(string: "telprompt://" + number) {
                doPhoneAction(with: url)
            }
        }
        let smsAction = UIAlertAction(title: "Message".localized(), style: .default) { (_) in
            if let url = URL(string: "sms://" + number) {
                doPhoneAction(with: url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        controller.addAction(callAction)
        controller.addAction(smsAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
}

