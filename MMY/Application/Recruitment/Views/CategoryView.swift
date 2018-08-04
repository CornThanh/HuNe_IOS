//
//  BottomView.swift
//  MMY
//
//  Created by Blue R&D on 2/16/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class CategoryView: UIView {
    
    //MARK: - Properties
    let collectionView: UICollectionView
    let backButton = UIButton(type: .custom)
    let separatorView = UIView(frame: CGRect.zero)
    let backgroundViewColor = UIColor.white
    var cellSize = CGFloat(80)
    let interCellSpacing = CGFloat(10)
    
    var items = [CategoryModel]()
    var visibleItems = [CategoryModel]()
    var isShowingSubCategory = false
    var isReloading = false;
    var selectionCallback: (([CategoryModel]) -> Void)?
    var selectionCallbackSubcategory: (([CategoryModel]) -> Void)?
    
    //MARK: - Init
    override private init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupView()
    }
    
    convenience init(frame: CGRect, and data: [CategoryModel], _selectionCallback: ((([CategoryModel]) -> Void)?) = nil) {
        self.init(frame: frame)
        items = data
        visibleItems = data
        selectionCallback = _selectionCallback
        if data.count > 0 {
            let mainCategory = data[0]
            mainCategory.isChosen = true
            if let first = data.first?.children?.first {
                first.isChosen = true
                selectionCallback?([first])
            } else {
                selectionCallback?([mainCategory])
            }
        }
    }
    
    convenience init(frame: CGRect, and data: [CategoryModel], _selectionCallback: ((([CategoryModel]) -> Void)?) = nil, _selectionCallbackSubcategory: ((([CategoryModel]) -> Void)?) = nil) {
        self.init(frame: frame)
        items = data
        visibleItems = data
        selectionCallback = _selectionCallback
        selectionCallbackSubcategory = _selectionCallbackSubcategory
        if data.count > 0 {
            let mainCategory = data[0]
            mainCategory.isChosen = true
            if let first = data.first?.children?.first {
                first.isChosen = true
                selectionCallbackSubcategory?([first])
//                selectionCallback?([first])
            } else {
                selectionCallback?([mainCategory])
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = backgroundViewColor
        setupBackButton()
        setupCollectionView()
        setupSeparatorView()
    }
    
    //MARK: - Methods
    
    func handleChooseMainCategory(at indexPath: IndexPath) {
        let selectedCategory = visibleItems[indexPath.row]
        if selectedCategory.isChosen {
            collectionView.reloadData()
            showSubCategory(of: selectedCategory)
            return
        }
        for i in 0..<visibleItems.count {
            visibleItems[i].isChosen = (i == indexPath.row)
        }
        var callbackCategory = selectedCategory
        if let firstChild = selectedCategory.children?.first {
            firstChild.isChosen = true
            callbackCategory = firstChild
            selectionCallbackSubcategory?([callbackCategory])
        }
        else {
            selectionCallback?([callbackCategory])
        }
        collectionView.reloadData()
        showSubCategory(of: selectedCategory)
    }
    
    func handleChooseSubCategory(at indexPath: IndexPath) {
        let selectedCategory = visibleItems[indexPath.row]
        for category in visibleItems {
            category.isChosen = false
        }
        selectedCategory.isChosen = true
        collectionView.reloadData()
        if let selectedMainCategory = getSelectedMainCategory() {
            let selectedChildren = selectedMainCategory.getSelectedChildren()
//            selectedChildren.count != 0 ? selectionCallback?(selectedChildren) : selectionCallback?([selectedMainCategory])
            selectedChildren.count != 0 ? selectionCallbackSubcategory?(selectedChildren) : selectionCallback?([selectedMainCategory])
        }
    }
    
    func showSubCategory(of category: CategoryModel) {
        guard let sub = category.children else {
            return
        }
        if sub.count > 0 {
            guard !isReloading else {
                return
            }
            visibleItems = sub
            isShowingSubCategory = true
            showBackButton()
            reloadDataWithAnimation()
        }
    }
    
    func getSelectedMainCategory() -> CategoryModel? {
        for category in items {
            if category.isChosen {
                return category
            }
        }
        return nil
    }
    
    func showBackButton() {
        self.backButton.snp.updateConstraints({ (make) in
            make.width.equalTo(50)
        })
        self.separatorView.snp.updateConstraints { (make) in
            make.width.equalTo(1)
            make.top.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(-10)
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        }) { finished in
            self.collectionView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func hideBackButton() {
        self.backButton.snp.updateConstraints({ (make) in
            make.width.equalTo(0)
        })
        self.separatorView.snp.updateConstraints { (make) in
            make.width.equalTo(0)
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        }) { finished in
            self.collectionView.setContentOffset(CGPoint.zero, animated: true)
        }
        
    }
    
    func backToMainCategory() {
        guard !isReloading else {
            return
        }
        visibleItems = items
        hideBackButton()
        isShowingSubCategory = false
        reloadDataWithAnimation()
    }
    
    func reloadDataWithAnimation() {
        isReloading = true
        UIView.transition(with: collectionView,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.collectionView.reloadData()
        },
                          completion: { isFinished in
                            self.isReloading = false
        })
    }
}

//MARK: - Setup views
extension CategoryView {
    func setupCollectionView() {
        self.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.description())
        collectionView.snp.remakeConstraints({ (make) in
            make.top.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.left.equalTo(backButton.snp.right)
        })
    }
    
    func setupBackButton() {
        backButton.setTitleColor(UIColor.blue.withAlphaComponent(0.8), for: .normal)
        backButton.backgroundColor = UIColor.clear
        backButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        backButton.addTarget(self, action: #selector(backToMainCategory), for: .touchUpInside)
        backButton.setImage(UIImage(named: "icon_back_white"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFill
        backButton.imageView?.clipsToBounds = true
        addSubview(backButton)
        backButton.snp.remakeConstraints { (make) in
            make.height.equalTo(25)
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(5)
            make.width.equalTo(0)
        }
    }
    
    func setupSeparatorView() {
        addSubview(separatorView)
        separatorView.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        separatorView.snp.makeConstraints { (make) in
            make.right.equalTo(collectionView.snp.left)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(0)
        }
    }

}

//MARK: - UICollectionViewDataSource
extension CategoryView : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.description(), for: indexPath) as! CategoryCell
        if indexPath.row >= visibleItems.count {
            return cell
        }
        let item = visibleItems[indexPath.row]
        cell.populateData(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
}


//MARK: - UICollectionViewDelegate
extension CategoryView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        !isShowingSubCategory ? handleChooseMainCategory(at: indexPath) : handleChooseSubCategory(at: indexPath)
    }
}


//MARK: CategoryCell
extension CategoryView {
    
    class CategoryCell: UICollectionViewCell{
        var imageView: UIImageView?
        var title: UILabel?
        var selectedIndicator: UIView?
        let imageSize = CGFloat(30)
        
        override init(frame:CGRect){
            super.init(frame:frame)
            backgroundColor = UIColor.clear
            setupImageView()
            setupLabel()
            setupSelectedIndicator()
        }
        
        func setupImageView() {
            imageView = UIImageView(frame:CGRect.zero)
            contentView.safeAddSubview(imageView)
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
            imageView?.snp.makeConstraints({ (make) in
                make.width.equalTo(imageSize)
                make.height.equalTo(imageSize)
                make.centerX.equalTo(contentView)
                make.top.equalTo(contentView).offset(10)
            })
        }
        
        func setupLabel() {
            title = UILabel(frame:CGRect.zero)
            contentView.safeAddSubview(title)
            title?.numberOfLines = 0
            title?.textAlignment = .center
            title?.font = UIFont(name: "Lato-Regular", size: 12)
            title?.textColor = UIColor.white
            title?.sizeToFit()
            title?.adjustsFontSizeToFitWidth = true
            title?.snp.makeConstraints({ (make) in
                make.top.equalTo((imageView?.snp.bottom)!).offset(5)
                make.bottom.equalTo(contentView).offset(-5)
                make.centerX.equalTo(contentView)
                make.left.equalTo(contentView).offset(5)
                make.right.equalTo(contentView).offset(-5)
            })
            
        }
        
        func setupSelectedIndicator() {
            selectedIndicator = UIView(frame: .zero)
            contentView.safeAddSubview(selectedIndicator)
//            selectedIndicator?.backgroundColor = UIColor.appColor
            selectedIndicator?.backgroundColor = UIColor.white
            selectedIndicator?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(5)
                make.right.equalTo(contentView).offset(-5)
                make.bottom.equalTo(contentView)
                make.height.equalTo(5)
            })
        }
        
        func populateData(with data: CategoryModel) {
            title?.text = data.name
            selectedIndicator?.isHidden = !data.isChosen
            if let imageUrl = data.icon {
                let imageString = imageUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let url = URL(string: imageString!)
                imageView?.kf.setImage(with: url, placeholder: UIImage(named: "default_category_white"))
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
