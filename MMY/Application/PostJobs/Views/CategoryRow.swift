//
//  SelectableHeader.swift
//  MMY
//
//  Created by Blue R&D on 2/22/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import Eureka

final class CategoryRow: SelectorRow<PushSelectorCell<String>, CategoryPickerViewController>, RowType {
    var selectionCallback: (([CategoryModel]?, [CategoryModel])->Void)?
    var categories: [CategoryModel]?
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    convenience init(tag: String?, categories: [CategoryModel]? = nil) {
        self.init(tag: tag)
        self.categories = categories
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return CategoryPickerViewController(self.categories){ _ in }},
                                 onDismiss: {[weak self] vc in
                                    _ = vc.navigationController?.popViewController(animated: true)
                                    if let vc = vc as? CategoryPickerViewController {
                                        self?.selectionCallback?(vc.selectedCategories, vc.categories)
                                    }
        })
        displayValueFor = { return $0 }
    }
}

class CategoryPickerViewController: BaseViewController, TypedRowControllerType {
    
    //MARK: - Properties
    public var row: RowOf<String>!
    
    public var onDismissCallback: ((UIViewController) -> ())?
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
    
    convenience public init(_ _categories: [CategoryModel]?, _ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
        if let _categories = CategoryModel.copy(from: _categories) {
            categories = _categories
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let donebutton = UIBarButtonItem(image: UIImage(named: "ic_done"), style: .done, target: self, action: #selector(tappedDone))
        navigationItem.rightBarButtonItem = donebutton
        let backButton = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: self, action: #selector(backToPreviousController))
        navigationItem.leftBarButtonItem = backButton
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
        row.value = CategoryModel.makeString(from: selectedCategories)
        onDismissCallback?(self)
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
extension CategoryPickerViewController : UITableViewDataSource {
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
extension CategoryPickerViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleChooseCategory(at: indexPath, isMain: (indexPath.row == 0))
        reloadDataWithAnimation()
    }
}


//MARK: - CategoryCell
extension CategoryPickerViewController {
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
            let fontSize: CGFloat = isMainCategory ? 18 : 16
            let offset = isMainCategory ? 20 : 40
            let size = isMainCategory ? 25 : 15
            let checkmark1 = data.isChosen ? "ic_sub_category_checked" : "ic_sub_category_unchecked"
            let checkmark2 = data.isChosen ? "ic_category_checked" : "ic_category_unchecked"
            let imageName = isMainCategory ? checkmark2 : checkmark1
            title?.text = data.name
            title?.font = UIFont(name: "System", size: fontSize)
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



