//
//  FindJobManagerViewController.swift
//  MMY
//
//  Created by Minh tuan on 8/18/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import CoreLocation

class FindJobManagerViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var posts = [PostModel]()
    var displayPosts = [PostModel]()
    
    var selectedCategories = [CategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupActivityIndicator()
        self.setNavigationTitlte(title: "Quản lý tin đăng")
        self.addLeftBarButton()
        
        if let categories = Authenticator.shareInstance.getCategoryList() {
            for category in categories {
                selectedCategories.append(category)
            }
        }
        
        collectionView.register(UINib.init(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        
        tableView.register(UINib.init(nibName: "PostManagerCell", bundle: nil), forCellReuseIdentifier: "PostManagerCell")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        getDataFromServer()
        
        // Define identifier
        let notificationName = Notification.Name("listFindJogChange")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(listFindJogChange), name: notificationName, object: nil)
    }
    
    deinit {
        print("deinit called")
        let notificationName = Notification.Name("listFindJogChange")
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }
    
    func listFindJogChange() {
        getDataFromServer()
    }
    
    func getDataFromServer() {
        activityIndicator?.startAnimating()
        ServiceManager.postService.getMyPost(type: "2") { [unowned self] (posts, error) in
            self.activityIndicator?.stopAnimating()
            if let posts = posts {
                self.posts = posts
                self.getDisplayPosts()
                self.tableView.reloadData()
            }
        }
    }
    
    func getDisplayPosts() {
        self.displayPosts.removeAll()
        for selectCategory in selectedCategories {
            for post in self.posts {
                if post.category_parent_id == selectCategory.categoryId {
                    displayPosts.append(post)
                }
            }
        }
    }
    
    func createBannerMapEmpty() {
        
    }
}

extension FindJobManagerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let categories = Authenticator.shareInstance.getCategoryList() {
            return categories.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as!CategoryCollectionViewCell
        if let categories = Authenticator.shareInstance.getCategoryList() {
            let category = categories[indexPath.row]
            cell.updateWithCategory(category: category)
            cell.checkImage.image = UIImage(named: "icon_uncheck")
            for selectCategory in selectedCategories {
                if category.categoryId == selectCategory.categoryId {
                    cell.checkImage.image = UIImage(named: "icon_check")
                    break
                }
            }
        }
        cell.backgroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        cell.layer.cornerRadius = 10.0
        return cell
    }
}

extension FindJobManagerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let categories = Authenticator.shareInstance.getCategoryList() {
            let category = categories[indexPath.row]
            var isChecked = false
            for selectCategory in selectedCategories {
                if category.categoryId == selectCategory.categoryId {
                    if let index = selectedCategories.index(where: {$0.categoryId == selectCategory.categoryId}) {
                        selectedCategories.remove(at: index)
                    }
                    isChecked = true
                    break
                }
            }
            if isChecked == false {
                selectedCategories.append(category)
            }
            collectionView.reloadData()
            getDisplayPosts()
            tableView.reloadData()
        }
    }
}

extension FindJobManagerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostManagerCell") as! PostManagerCell
        let post = self.displayPosts[indexPath.row]
        cell.updateWithPost(post: post)
        cell.selectionStyle = .none
        if post.status == "1" {
            cell.statusImage.image = UIImage(named: "icon_check")
        }
        else {
            cell.statusImage.image = UIImage(named: "icon_uncheck")
        }
        cell.setStatusBlock = {
            var message = "Mở nhận việc"
            if post.status == "1" {
                message = "Tắt nhận việc"
            }
            
            UIAlertController.showSimpleAlertView(in: self, title: message, message: "", buttonTitle: "Ok", action: { (action) in
                self.activityIndicator?.startAnimating()
                ServiceManager.postService.changePostStatus(post: post, completion: { [unowned self](resultCode) in
                    
                    self.activityIndicator?.stopAnimating()
                    if resultCode == ErrorCode.success.rawValue {
                        UIAlertController.showSimpleAlertView(in: self, title: "Thành công", message: "", buttonTitle: "Ok", action: { (action) in
                            self.getDataFromServer()
                        })
                    }
                    else {
                        UIAlertController.showSimpleAlertView(in: self, title: "Error".localized(), message: "")
                    }
                })
            })
        }
        cell.editBlock = {
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    UIAlertController.showSimpleAlertView(in: self, title: "Không tìm thấy địa điểm", message: "Vui lòng cho ứng dụng sử dụng vị trí của bạn", buttonTitle: "OK", action: { (action) in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    })
                    print("No access")
                case .authorizedAlways, .authorizedWhenInUse:
                    self.navigationController?.pushViewController(DefaultFindJobViewController(), animated: true)
                    print("Access")
                }
            } else {
                UIAlertController.showSimpleAlertView(in: self, title: "Không tìm thấy địa điểm", message: "Vui lòng cho ứng dụng sử dụng vị trí của bạn", buttonTitle: "OK", action: { (action) in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                })
                print("Location services are not enabled")
            }
        }
        return cell
    }
}

extension FindJobManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}



