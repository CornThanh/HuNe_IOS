//
//  CategoryPickerVC.swift
//  MMY
//
//  Created by Minh tuan on 8/2/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class CategoryPickerVC: UIViewController {

//    public var onDismissCallback: ((UIViewController) -> ())?
    var selectionCallback: (([CategoryModel]?, [CategoryModel])->Void)?
    var selectedCategories: [CategoryModel]?
    var categories = [CategoryModel]()
    var tableView : UITableView?
    
    //MARK: - Init
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add done button
        let donebutton = UIBarButtonItem(image: UIImage(named: "ic_done"), style: .done, target: self, action: #selector(tappedDone))
        navigationItem.rightBarButtonItem = donebutton
        
        // Add back button
        let leftButton = UIButton.init(type: .custom)
        leftButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftButton.addTarget(self, action:#selector(backToPreviousController), for: UIControlEvents.touchUpInside)
        leftButton.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20)
        leftButton.tintColor = .white
        leftButton.backgroundColor = .clear
        let leftBarButton = UIBarButtonItem.init(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton

        // Title
        title = "Chọn loại hình"
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
        
        setupTableView()
        if CategoryModel.getSelectedCategory(in: categories) == nil {
            checkSingleSelection()
        }
    }
    
    //MARK: - Setup Views
    
    func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView?.backgroundColor = .white
        tableView?.separatorStyle = .none
        view.safeAddSubview(tableView)
        view.backgroundColor = tableView?.backgroundColor
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.description())
        tableView?.separatorColor = UIColor.separatorColor
        tableView?.snp.makeConstraints { (make) in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
    
    //MARK: - Methods
    
    func tappedDone(){
        selectedCategories = CategoryModel.getSelectedCategory(in: categories)
//        row.value = CategoryModel.makeString(from: selectedCategories)
//        onDismissCallback?(self)
        if let selectionCallback = self.selectionCallback {
            selectionCallback(self.selectedCategories, self.categories)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func backToPreviousController () {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func checkSingleSelection() {
        if let firstMain = categories.first {
            firstMain.isChosen = (firstMain.maxSelectedCategory == 1)
            if let firstSub = firstMain.children?.first {
                firstSub.isChosen = firstSub.maxSelectedChildren == 1
            }
        }
    }
    
    func getCategoryModel(at indexPath: IndexPath) -> CategoryModel {
        var result : CategoryModel
        let mainCategory = categories[indexPath.section]
        if indexPath.row == 0 {
            result = mainCategory
        } else {
            result = mainCategory.children?[indexPath.row-1] != nil ? (mainCategory.children?[indexPath.row-1])! : mainCategory
        }
        return result
    }
    
    func countSelectedMainCategory() -> Int {
        var count = 0
        for category in categories {
            count += category.isChosen ? 1 : 0
        }
        return count
    }
    
    func reloadDataWithAnimation() {
        guard let tableView = tableView else {
            return
        }
        UIView.transition(with: tableView,
                          duration: 0.1,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.tableView?.reloadData()
        })
    }
    
    func handleChooseCategory(at indexPath: IndexPath, isMain: Bool) {
        let selectedcategory = getCategoryModel(at: indexPath)
        let mainCategory = categories[indexPath.section]
        let numberOfChoices = isMain ? selectedcategory.maxSelectedCategory : selectedcategory.maxSelectedCategory
        switch numberOfChoices {
        case 0:
            selectedcategory.isChosen = !selectedcategory.isChosen
        case 1:
            let loopCategories = isMain ? categories : (mainCategory.children ?? [CategoryModel]())
            for category in loopCategories {
                category.isChosen = false
            }
            selectedcategory.isChosen = true
            if let firstChild = selectedcategory.children?.first {
                firstChild.isChosen = true
            }
        default:
            if isMain {
                if selectedcategory.isChosen || (countSelectedMainCategory() < selectedcategory.maxSelectedCategory) {
                    selectedcategory.isChosen = !selectedcategory.isChosen
                }
            } else {
                if selectedcategory.isChosen || (mainCategory.getSelectedChildren().count < mainCategory.maxSelectedChildren) {
                    selectedcategory.isChosen = !selectedcategory.isChosen
                }
            }
        }
    }
}


//MARK: - UITableViewDataSource
extension CategoryPickerVC : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        return (category.children == nil || !category.isChosen) ? 1 : (category.children?.count)! + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.description(), for: indexPath) as! CategoryCell
        let item = getCategoryModel(at: indexPath)
        cell.populateData(with: item, isMainCategory: (indexPath.row == 0))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 50 : 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}


//MARK: - UITableViewDelegate
extension CategoryPickerVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleChooseCategory(at: indexPath, isMain: (indexPath.row == 0))
        reloadDataWithAnimation()
    }
}


//MARK: - CategoryCell
extension CategoryPickerVC {
    class CategoryCell : UITableViewCell {
        var checkBox: UIImageView?
        var title: UILabel?
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            checkBox = UIImageView()
            checkBox?.contentMode = .scaleAspectFit
            checkBox?.clipsToBounds = true
            contentView.safeAddSubview(checkBox)
            checkBox?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(30)
                make.height.equalTo(25)
                make.width.equalTo(25)
                make.centerY.equalTo(contentView)
            })
            
            title = UILabel()
            title?.numberOfLines = 1
            title?.font = UIFont.preferredFont(forTextStyle: .headline)
            contentView.safeAddSubview(title)
            title?.snp.makeConstraints({ (make) in
                make.left.equalTo((checkBox?.snp.right)!).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView).offset(-10)
            })
        }
        
        func populateData(with data: CategoryModel, isMainCategory: Bool) {
            let fontSize: CGFloat = isMainCategory ? 16 : 14
            let offset = isMainCategory ? 20 : 40
            let size = isMainCategory ? 20 : 12
            let checkmark1 = data.isChosen ? "ic_sub_category_checked" : "ic_sub_category_unchecked"
            let checkmark2 = data.isChosen ? "ic_category_checked" : "ic_category_unchecked"
            let imageName = isMainCategory ? checkmark2 : checkmark1
            title?.text = data.name
            title?.font = UIFont(name: "Lato-Regular", size: fontSize)
            checkBox?.image = UIImage(named: imageName)
            checkBox?.snp.updateConstraints { (make) in
                make.left.equalTo(contentView).offset(offset)
                make.width.equalTo(size)
                make.height.equalTo(size)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
