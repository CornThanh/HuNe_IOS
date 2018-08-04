//
//  PopupViewController.swift
//  MMY
//
//  Created by Blue R&D on 2/28/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import Eureka
import NVActivityIndicatorView

class PopupViewController: FormViewController {
    
    var headerView: ProfileHeaderView?
    var closeButton: UIButton?
    let headerViewHeight: CGFloat = 100
    var postModel: PostModel?
    var userModel: UserModel?
    var postId: String?
    let activityIndicator = NVActivityIndicatorView(frame: CGRect.zero, type: .ballSpinFadeLoader, color: .black, padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        setupTableView()
        setupCloseButton()
        animateViewIn()
        if let postId = postId {
            setupActivitiIndicator()
            getPost(with: postId)
        } else {
            setupHeaderView()
            setupForm()
        }
        
    }
    
    static func present(in controller: UIViewController, with post: PostModel? = nil, id postId: String? = nil) {
        let popupVC = PopupViewController()
        popupVC.postModel = post
        popupVC.userModel = post?.userModel
        popupVC.postId = postId
        controller.display(controller: popupVC)
    }
}

//MARK: - Setup views
extension PopupViewController {
    func setupHeaderView() {
        headerView = PopupHeaderView(frame: CGRect(x: 0, y: 0, width: 400, height: headerViewHeight))
        headerView?.imageSize = 70
        headerView?.nameLabel.text = userModel?.userName()
        headerView?.imageView.isUserInteractionEnabled = false
        headerView?.setImage(with: userModel?.avatarURL)
        headerView?.headerTouchedCallback = { [weak self] in
            self?.presentProfileViewController()
        }
    }
    
    func setupTableView() {
        let parentSize = presentingViewController != nil ? presentingViewController!.view.frame.size : view.frame.size
        let tableViewWidth = parentSize.width * 9.0/10
        let tableViewHeight = parentSize.height * 8.0/10
        tableView?.layer.cornerRadius = 5
        tableView?.snp.remakeConstraints({ (make) in
            make.width.equalTo(tableViewWidth)
            make.height.equalTo(tableViewHeight)
            make.center.equalTo(view)
        })
    }
    
    func setupCloseButton() {
        closeButton = UIButton(type: .custom)
        guard let tableView = tableView else {
            return
        }
        closeButton?.setImage(UIImage(named: "ic_close_white"), for: .normal)
        closeButton?.backgroundColor = UIColor.clear
        closeButton?.setTitleColor(UIColor.white, for: .normal)
        closeButton?.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        //closeButton?.layer.cornerRadius = 20
        closeButton?.addTarget(self, action: #selector(closeViewController), for: .touchUpInside)
        view.safeAddSubview(closeButton)
        closeButton?.snp.makeConstraints { (make) in
            make.right.equalTo(tableView).offset(-5)
            make.top.equalTo(tableView).offset(5)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    func setupActivitiIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
    }
    
    func setupForm() {
        tableView?.backgroundColor = .white
        tableView?.separatorColor = UIColor.separatorColor
        form = Form()
        addFirstSection()
        addJobDetailSection()
    }
    
    //MARK: - Setup form
    func addFirstSection() {
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
    }
    
    func addJobDetailSection() {
        guard let postModel = postModel else {
            return
        }
        let jobSection = Section("Job details".localized())
        //Type
        let typeRow = TextRow("type").cellSetup({ (cell, row) in
            row.title = "I need to".localized()
            row.value = postModel.postType?.title()
            cell.isUserInteractionEnabled = false
        })
        jobSection.append(typeRow)

        //Category
        let categoryRow = TextRow("category").cellSetup({ (cell, row) in
            row.title = "Category".localized()
            row.value = CategoryModel.makeString(from: postModel.category)
            cell.textField.adjustsFontSizeToFitWidth = true
            cell.isUserInteractionEnabled = false
        })
        jobSection.append(categoryRow)

        let titleRow = TextAreaRow("title"){ row in
            row.value = postModel.title
            row.textAreaHeight = .dynamic(initialTextViewHeight: 30)
            }.cellSetup { (cell, _) in
                cell.isUserInteractionEnabled = false
        }
        jobSection.append(titleRow)
        
        //Description
        let descriptionRow = TextAreaRow("description") { row in
            row.value = postModel.description
            row.textAreaHeight = .dynamic(initialTextViewHeight: 30)
            }.cellSetup { (cell, _) in
                cell.isUserInteractionEnabled = false
        }
        jobSection.append(descriptionRow)
        
        //Address
        let addressRow = TextAreaRow("address"){ row in
            row.value = postModel.address == nil ? "..." : postModel.address
            row.textAreaHeight = .dynamic(initialTextViewHeight: 30)
            }.cellSetup { (cell, _) in
                cell.isUserInteractionEnabled = false
        }
        jobSection.append(addressRow)
        form.append(jobSection)
        
        if postModel.postType == .findJob {
            return
        }
        //Amount
        let amountRow = TextRow("amount").cellSetup({ (cell, row) in
            row.title = "Amount".localized()
            if let amount = postModel.amount {
                row.value = String(amount)
            }
            cell.isUserInteractionEnabled = false
        })
        jobSection.append(amountRow)
        
        //Salary
        let salaryRow = TextRow("salary").cellSetup({ (cell, row) in
            row.title = "Salary".localized() + " (VND)"
            row.value = postModel.salary
            cell.isUserInteractionEnabled = false
        })
        jobSection.append(salaryRow)
    }
}

//MARK: - Methods
extension PopupViewController {
    func getPost(with postId: String) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        ServiceManager.postService.get(postId: postId) { (result) in
            self.activityIndicator.stopAnimating()
            switch result {
            case let .success(postModel):
                self.postModel = postModel
                self.userModel = postModel.userModel
                self.setupHeaderView()
                self.setupForm()
            case let .failure(error):
                log.debug(error.errorMessage)
            }
        }
    }
    
    func presentProfileViewController() {
        if Authenticator.shareInstance.loginType == .guest{
            Authenticator.shareInstance.popupAuthSignInViewCtl(in: self)
        }else{
            let profileVC = ControllerFactory.shared.makeController(type: .profile, with: ["user": userModel as Any])
            if presentingViewController == nil {
                present(profileVC, animated: true, completion: nil)
            }
        }
    }
    
    
    func animateViewIn() {
        guard let tableView = tableView, let closeButton = closeButton else {
            return
        }
        //Animate
        let screenSize = UIScreen.main.bounds.size
        let closeButtonSize = closeButton.frame.size
        let tableViewSize = tableView.frame.size
        
        let tableViewPositionY = tableView.frame.origin.y
        let closeButtonPositionY = closeButton.frame.origin.y
        tableView.frame = CGRect(x: 0, y: screenSize.height, width: tableViewSize.width, height: tableViewSize.height)
        closeButton.frame = CGRect(x: 0, y: screenSize.height, width: closeButtonSize.width, height: closeButtonSize.height)
        UIView.animate(withDuration: 0.2){
            tableView.frame = CGRect(x: 0, y: CGFloat(tableViewPositionY), width: tableViewSize.width, height: tableViewSize.height)
            closeButton.frame = CGRect(x: 0, y: CGFloat(closeButtonPositionY), width: closeButtonSize.width, height: closeButtonSize.height)
        }
    }
    
    func closeViewController() {
        guard let tableView = tableView, let closeButton = closeButton else {
            return
        }
        let screenSize = UIScreen.main.bounds.size
        let closeButtonSize = closeButton.frame.size
        let tableViewSize = tableView.frame.size
        
        UIView.animate(withDuration: 0.2, animations: {
            tableView.frame = CGRect(x: tableView.frame.origin.x, y: screenSize.height, width: tableViewSize.width, height: tableViewSize.height)
            closeButton.frame = CGRect(x: closeButton.frame.origin.x, y: screenSize.height, width: closeButtonSize.width, height: closeButtonSize.height)
        }) { (finish) in
            self.hide(controller: self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeViewController()
    }
}

//MARK: - PopHeaderView
extension PopupViewController {
    class PopupHeaderView: ProfileHeaderView {
        override func initView() {
            super.initView()
            imageView.snp.remakeConstraints { (make) in
                make.width.equalTo(100)
                make.height.equalTo(100)
                make.centerY.equalTo(self)
                make.left.equalTo(self).offset(20)
            }
            nameLabel.snp.remakeConstraints { (make) in
                make.centerY.equalTo(imageView)
                make.left.equalTo(imageView.snp.right).offset(10)
            }
            
            let indicator = UIButton(type: .custom)
            indicator.setImage(UIImage(named: "ic_next_white"), for: .normal)
            addSubview(indicator)
            indicator.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel)
                make.bottom.equalTo(nameLabel)
                make.left.equalTo(nameLabel.snp.right).offset(5)
            }
            
        }
    }
}

