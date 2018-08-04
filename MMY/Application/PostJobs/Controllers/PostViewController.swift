//
//  PostViewController.swift
//  MMY
//
//  Created by Blue R&D on 2/21/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import CoreLocation
import Eureka
import Localize_Swift
import NVActivityIndicatorView
import GoogleMaps

class PostViewController: FormViewController {
    
    var activityIndicator: NVActivityIndicatorView?
    var categories = [CategoryModel]()
    var isModifying = false
    var postModel = TempPostModel()
    let geoCoder = GMSGeocoder()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupActivityIndicator()
        setupForm()
    }
    
    //MARK: - Setup views
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
    }
    
    func setupNavigationItem() {
        let postButton = UIBarButtonItem(image: UIImage(named: "ic_done"), style: .done, target: self, action: #selector(postNewJob))
        navigationItem.rightBarButtonItem = postButton
        let backButton = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(cancelPost))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ".localized(), style: .done, target: self, action: nil)
        navigationItem.title = "Post".localized()
    }
    
    func setupForm() {
        tableView?.separatorColor = UIColor.separatorColor
        form = Form()
        addFirstSection()
        addCategorySection()
        addJobSection()
        addSalarySection()
        addLocationSection()
    }
    
    //MARK: - Methods
    func postNewJob() {
        guard postModel.validate() else {
            let title = "Missing required field".localized()
            let message = "Job title, job description, category, and location is required field".localized()
            UIAlertController.showSimpleAlertView(in: self, title: title, message: message)
            return
        }
        view.isUserInteractionEnabled = false
        postNewJobToServer()
    }
    
    func postNewJobToServer() {
        activityIndicator?.startAnimating()
        ServiceManager.postService.post(postModel) { (result) in
            self.activityIndicator?.stopAnimating()
            self.view.isUserInteractionEnabled = true
            switch result {
            case .success(_):
                UIAlertController.showSimpleAlertView(in: self, title: "Create new post successfully!".localized(), message: "", buttonTitle: "Back to home".localized(), action: { (action) in
                    self.backToPreviousController()
                })
            case let .failure(error):
                UIAlertController.showSimpleAlertView(in: self, title: "Error".localized(), message: "Something happens while creating new post. Please try again later.".localized())
                log.debug(error.errorMessage)
            }
        }
    }
    
    func cancelPost() {
        let backAction: ((UIAlertAction) -> Void) = { (action) in self.backToPreviousController() }
        isModifying ? UIAlertController.showDiscardAlertView(in: self, action: backAction) : backToPreviousController()
    }
    
    func backToPreviousController () {
        _ = navigationController?.popViewController(animated: true)
    }
}

//MARK: - TableViewDataSource
extension PostViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 50
    }
}

//MARK: - Setup Form
extension PostViewController {
    func addFirstSection() {
        let firstSection = Section()
        let postTypeRow = SegmentedRow<String>("typePicker").cellSetup({ [weak self] (cell, row) in
            let allTitles = PostType.allTitles()
            row.options = allTitles
            if let postModel = self?.postModel,
                let index = PostType.allTitles().index(of: postModel.postType.title()) {
                row.value = allTitles[index]
            } else {
                row.value = allTitles.first
            }
            row.title = "I need to".localized()
            cell.segmentedControl.tintColor = row.value == PostType.findJob.title() ? UIColor.redMarkerColor : UIColor.greenMarkerColor
            cell.segmentedControl.snp.makeConstraints({ (make) in
                make.width.equalTo(200)
                make.top.equalTo(cell.contentView).offset(5)
                make.bottom.equalTo(cell.contentView).offset(-5)
            })
        }).onChange { [weak self] (row) in
            self?.isModifying = true
            if let newPostType = row.value,
                let index = PostType.allTitles().index(of: newPostType) {
                self?.postModel.postType = PostType.allValues[index]
            }
            let segmentColor = row.value == PostType.findJob.title() ? UIColor.redMarkerColor : UIColor.greenMarkerColor
            row.cell.segmentedControl.tintColor = segmentColor
            let sectionTitle = row.value == PostType.findJob.title() ? "JobWorkingLocation".localized() : "EmployeeWorkingLocation".localized()
            DispatchQueue.main.async {
                self?.form.rowBy(tag: "category")?.updateCell()
                self?.form.rowBy(tag: "category")?.reload()
                self?.form.sectionBy(tag: "locationSection")?.header = HeaderFooterView(title: sectionTitle)
                self?.form.sectionBy(tag: "locationSection")?.reload()
            }
        }
        firstSection.append(postTypeRow)
        form.append(firstSection)
    }
    
    func addCategorySection() {
        let categorySection = Section("Category".localized())
        addCategoryRow(in: categorySection)
        form.append(categorySection)
    }
    
    func addJobSection() {
        let jobSection = Section("Job details".localized())
        addTitleRow(in: jobSection)
        addDescriptionRow(in: jobSection)
        addAmountRow(in: jobSection)
        form.append(jobSection)
    }
    
    func addCategoryRow(in section: Section) {
        let categoryRow = CategoryRow(tag: "category", categories: categories)
        categoryRow.cellSetup { [weak self] (cell, row) in
            row.title = self?.postModel.postType == .findJob ? "I want to be".localized() : "I need".localized()
            row.value = CategoryModel.makeString(from: self?.postModel.categories)
            row.selectorTitle = "Choose category".localized()
            row.selectionCallback = { [weak self] (selectedCategories, categories) in
                self?.isModifying = true
                self?.postModel.categories = selectedCategories
                self?.categories = categories
                row.categories = categories
            }
        }.cellUpdate { [weak self] (cell, row) in
            row.title = self?.postModel.postType == .findJob ? "I want to be".localized() : "I need".localized()
        }
        section.append(categoryRow)
    }
    
    func addTitleRow(in section: Section) {
        let titleRow = TextAreaRow("title") { [weak self] row in
            row.placeholder = "Job title".localized()
            row.value = self?.postModel.title
            row.textAreaHeight = .dynamic(initialTextViewHeight: 30)
            }.onChange { [weak self] (row) in
                self?.isModifying = true
                self?.postModel.title = row.value
        }
        section.append(titleRow)
    }
    
    func addDescriptionRow(in section: Section) {
        let descriptionRow = TextAreaRow("description") { [weak self] row in
            row.placeholder = "Job description".localized()
            row.value = self?.postModel.description
            row.textAreaHeight = .dynamic(initialTextViewHeight: 44)
            }.onChange { [weak self] (row) in
                self?.isModifying = true
                self?.postModel.description = row.value
        }
        section.append(descriptionRow)
    }
    
    func addAmountRow(in section: Section) {
        let amountRow = StepperRow("amount").cellSetup({ [weak self] (cell, row) in
            cell.stepper.tintColor = UIColor.appColor
            cell.valueLabel?.textColor = UIColor.appColor
            cell.stepper.minimumValue = 1
            row.value = self?.postModel.amount != nil ? Double((self?.postModel.amount)!) : 1
            row.title = "Amount".localized()
            row.displayValueFor = { (value) -> String in
                value != nil ? String(Int(value!)) : ""
            }
        }).onChange { [weak self] (row) in
            self?.isModifying = true
            if let newAmount = row.value {
                self?.postModel.amount = Int(newAmount)
            }
        }
        amountRow.hidden = .function(["typePicker"], { form -> Bool in
            let segmentedRow = form.rowBy(tag: "typePicker") as! SegmentedRow<String>
            return segmentedRow.value == PostType.findJob.title()
        })
        section.append(amountRow)
    }
    
    func addSalarySection() {
        let salarySection = Section("Salary".localized())
        salarySection.hidden = .function(["typePicker"], { form -> Bool in
            let segmentedRow = form.rowBy(tag: "typePicker") as! SegmentedRow<String>
            return segmentedRow.value == PostType.findJob.title()
        })
        
        let salaryRow = TextRow("salary").cellSetup({ [weak self] (cell, row) in
            row.title = "Salary".localized() + " (VND)"
            row.value = self?.postModel.salary
            cell.textField.keyboardType = .numberPad
        }).onChange { [weak self] (row) in
            self?.isModifying = true
            self?.postModel.salary = row.value
        }
        salarySection.append(salaryRow)
        
        let periodRow = PushRow<String>("period") { [weak self] row in
            row.title = "Period".localized()
            row.selectorTitle = "Period".localized()
            row.options.removeAll()
            let allTitles = TempPostModel.PaymentPeriod.allTitles()
            row.options = allTitles
            if let postModel = self?.postModel,
                let index = TempPostModel.PaymentPeriod.allTitles().index(of: postModel.paymentPeriod.title()) {
                row.value = allTitles[index]
            } else {
                row.value = allTitles.first
            }
            
            }.onPresent({ (formController, selectorController) in
                selectorController.enableDeselection = false
                selectorController.view.layoutSubviews()
                selectorController.tableView?.backgroundColor = .white
                selectorController.tableView?.rowHeight = 50
                for section in selectorController.form.allSections {
                    section.header?.title = ""
                }
            }).onChange { [weak self] (row) in
                self?.isModifying = true
                if let newPeriod = row.value,
                    let index = TempPostModel.PaymentPeriod.allTitles().index(of: newPeriod) {
                    self?.postModel.paymentPeriod = TempPostModel.PaymentPeriod.allValues[index]
                }
        }
        salarySection.append(periodRow)
        form.append(salarySection)
    }
    
    func addLocationSection() {
        let typeValue = form.rowBy(tag: "typePicker")?.baseValue as! String
        let sectionTitle = typeValue == PostType.findJob.title() ? "JobWorkingLocation".localized() : "EmployeeWorkingLocation".localized()
        let locationSection = Section(sectionTitle) {
            $0.tag = "locationSection"
        }
        let locationRow = LocationRow("coordinate"){ [weak self] row in
            row.title = "Map location".localized()
            let location = self?.postModel.location
            row.value = location
            self?.locationChanged(to: location)
            }.onChange { [weak self] (row) in
                self?.isModifying = true
                self?.locationChanged(to: row.value)
        }
        locationSection.append(locationRow)
        
        let addressRow = TextAreaRow("address") { [weak self] row in
            row.tag = "address"
            row.value = self?.postModel.address
            row.placeholder = "Address".localized()
            row.textAreaHeight = .dynamic(initialTextViewHeight: 44)
            }.onChange { [weak self] (row) in
                self?.isModifying = true
                self?.postModel.address = row.value
        }
        locationSection.append(addressRow)
        form.append(locationSection)
    }
    
    //MARK: Handle Model Change
    func locationChanged(to newLocation: CLLocation?) {
        guard let newLocation = newLocation else {
            return
        }
        postModel.location = newLocation
        geoCoder.reverseGeocodeCoordinate(newLocation.coordinate) { [weak self] (response, error) in
            guard let weakSelf = self,
                let location = response?.firstResult(),
                let row = weakSelf.form.rowBy(tag: "address") as? TextAreaRow else {
                    return
            }
            let address = location.lines?.joined(separator: ", ")
            row.value = address
            weakSelf.postModel.address = address
            row.reload()
        }
    }
}





