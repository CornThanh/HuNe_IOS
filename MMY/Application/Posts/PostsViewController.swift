//
//  PostsViewController.swift
//  MMY
//
//  Created by Minh tuan on 7/30/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage

enum PostsViewType {
    case suitableList
    case postJobManagement      //My job
}

class PostsViewController: BaseViewController {
    
    @IBOutlet weak var lbAds: UILabel!
    @IBOutlet weak var imgBannerPromotion: UIImageView!
    @IBOutlet weak var addBtn: PushButtonView!
    fileprivate var posts = [PostModel]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintHeightBanner: NSLayoutConstraint!
    var linkBanner: String = ""
    var type : PostsViewType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupActivityIndicator()
        self.configNavigaton()
        
        getDataFromServer()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "RecruitmentTableViewCell", bundle: nil), forCellReuseIdentifier: "RecruitmentTableViewCell")
        
//        if let color = Authenticator.shareInstance.getPostType()?.color() {
//            addBtn.fillColor = color
//        }
        
        if ShareData.typeManager == "2" {
            addBtn.fillColor = UIColor(hexString: "#33CCFF") ?? .appColor // blue
        } else {
            addBtn.fillColor = UIColor(hexString: "#CC3333") ?? .appColor // red
        }
        
        lbAds.isHidden = true
        constraintHeightBanner.constant = 0.0
        imgBannerPromotion.layoutIfNeeded()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(eventBanner))
        imgBannerPromotion.addGestureRecognizer(tap)
        imgBannerPromotion.isUserInteractionEnabled = true
        
    }
    
    func eventBanner() {
        UIApplication.shared.open(URL(string: linkBanner)!, options: [:], completionHandler: nil)
    }
    
    func configNavigaton()  {
        
        // Add left bar button
        self.addLeftBarButton()
        
        // Add right bar button
        if type == PostsViewType.postJobManagement {
            // Add right bar button
            let rightMenuButton = UIBarButtonItem(image: UIImage(named: "icon_notification"), style: .done, target: self, action: #selector(displayNotification))
            rightMenuButton.image = UIImage(named: "icon_notification")?.withRenderingMode(.alwaysTemplate)
            rightMenuButton.tintColor = .white
            
            let storeMenuButton = UIBarButtonItem(image: UIImage(named: "icHuneStore"), style: .done, target: self, action: #selector(displayHuneStore))
            storeMenuButton.image = UIImage(named: "icHuneStore")?.withRenderingMode(.alwaysTemplate)
            storeMenuButton.tintColor = .white
            
            navigationItem.rightBarButtonItems = [rightMenuButton, storeMenuButton]
        }
        else {
        }
        
        // Title
        if type == nil || type == PostsViewType.suitableList {
            if ShareData.typeManager == "1" {
                title = "ListOfJobs".localized()
            }
            else {
                title = "ListOfCandidates".localized()
            }
        }
        else if type == PostsViewType.postJobManagement {
            title = "ManagePostings".localized()
        }
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 17)!]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if type == PostsViewType.postJobManagement {
            getDataFromServer()
        }
    }
    
    func displayNotification() {
        print("displayNotification")
        let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    func displayHuneStore() {
        let vc = HuneStoreViewController.loadFromNib()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openFilter() {
        print("openFilter")
    }
    
    @IBAction func onBtnAdd(_ sender: Any) {
        if ShareData.typeManager == "2" {
            let postJobViewController = PostJobViewController(nibName: "PostJobViewController", bundle: nil)
            navigationController?.pushViewController(postJobViewController, animated: true)
        }
        else {
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
                    navigationController?.pushViewController(DefaultFindJobViewController(), animated: true)
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
    }
    
    //MARK: - GET data
    func getDataFromServer() {
        
        if type == PostsViewType.postJobManagement {
            //            ServiceManager.postService.getMyPost(type: "\(Authenticator.shareInstance.getPostType()?.rawValue ?? 1)") { [unowned self] (posts, error) in
            //                if let posts = posts {
            //                    self.posts = posts
            //                    self.tableView.reloadData()
            //                }
            //            }
            
            if ShareData.typeManager == "2" {
                ServiceManager.postService.getMyPost(type: "1") { [unowned self] (posts, error) in
                    if let posts = posts {
                        self.posts = posts
                        self.tableView.reloadData()
                    }
                }
            } else {
                ServiceManager.postService.getMyPost(type: "2") { [unowned self] (posts, error) in
                    if let posts = posts {
                        self.posts = posts
                        self.tableView.reloadData()
                    }
                }
            }
        }
        else if type == PostsViewType.suitableList {
            //if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            if ShareData.typeManager == "2" {
                ServiceManager.postService.getRelatePosts(location: Authenticator.shareInstance.getLocation(), type: "2", radius: 10, completion: { [unowned self] (posts) in
                    if let posts = posts {
                        self.posts = posts
                        self.tableView.reloadData()
                        //
                    }
                    
                    self.showBannerPromotion(position: "3", image: self.imgBannerPromotion, constrain: self.constraintHeightBanner)
//                    Timer.scheduledTimer(withTimeInterval: 450.0 , repeats: true) { (timer) in
//                        self.showBannerPromotion(position: "3", image: self.imgBannerPromotion, constrain: self.constraintHeightBanner)
//                    }
                    
                    
                })
            }
            else {
                ServiceManager.postService.getRelatePosts(location: Authenticator.shareInstance.getLocation(), type: "1", radius: 10, completion: { [unowned self] (posts) in
                    if let posts = posts {
                        self.posts = posts
                        self.tableView.reloadData()
                    
                    }
                    
                    //
                    self.showBannerPromotion(position: "4", image: self.imgBannerPromotion, constrain: self.constraintHeightBanner)
//                    Timer.scheduledTimer(withTimeInterval: 450.0 , repeats: true) { (timer) in
//                        self.showBannerPromotion(position: "4", image: self.imgBannerPromotion, constrain: self.constraintHeightBanner)
//                    }
                })
            }
        }
    }
    
    func showBannerPromotion(position: String, image: UIImageView, constrain: NSLayoutConstraint) {
        ServiceManager.adsService.getBanners(position) { (result) in
            switch result {
            case .success(let arrBanner, _):
                if arrBanner.count > 0  {
                    self.lbAds.isHidden = false
                    constrain.constant = 60.0
                    image.layoutIfNeeded()
                    
                    image.sd_setImage(with: URL(string: arrBanner[0].cover!) , placeholderImage: UIImage(named: "placeholder.png"), options: [], completed: nil)
                    self.linkBanner = arrBanner[0].url!
                }
            case .failure(let error):
                print(error.errorCode)
            }
        }
    }
    
}

//MARK : - UITableViewDataSource
extension PostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == PostsViewType.postJobManagement || type == PostsViewType.suitableList {
            return posts.count
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if type == PostsViewType.postJobManagement {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecruitmentTableViewCell") as! RecruitmentTableViewCell
            let postModel = posts[indexPath.row]
            cell.updateWithData(post: postModel)
            cell.selectionStyle = .none            
            cell.deleteBlock = {[unowned self] in
                self.activityIndicator?.startAnimating()
                ServiceManager.postService.deletePost(postId: postModel.postID!, completion: {[unowned self] (resultCode) in
                    self.activityIndicator?.stopAnimating()
                    if resultCode == ErrorCode.success.rawValue {
                        self.showDialog(title: "Thành công", message: "Bạn đã xóa công việc đăng tuyển thành công", handler: { (alert) in
                            self.posts.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        })
                    }
                    else {
                        self.showDialog(title: "Error", message: "Có lỗi khi xóa công việc đăng tuyển, vui lòng thử lại", handler:nil)
                    }
                })
            }
            return cell
        }
            
        else if type == PostsViewType.suitableList {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecruitmentTableViewCell") as! RecruitmentTableViewCell
            let postModel = posts[indexPath.row]
            if Authenticator.shareInstance.getPostType() == PostType.findJob {
                cell.updateWithData(post: postModel, type: 1)
            }
            else {
                cell.updateWithData(post: postModel, type: 2)
            }
            cell.selectionStyle = .none
            cell.deleteBtn.isHidden = true
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecruitmentTableViewCell") as! RecruitmentTableViewCell
        cell.selectionStyle = .none
        cell.deleteBtn.isHidden = true
        return cell
    }
}

//MARK : - UITableViewDelegate
extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == PostsViewType.postJobManagement {
            let postModel = posts[indexPath.row]
            if Authenticator.shareInstance.getPostType() == PostType.findPeople {
                let postJobViewController = PostJobViewController(nibName: "PostJobViewController", bundle: nil)
                postJobViewController.postModel = postModel
                navigationController?.pushViewController(postJobViewController, animated: true)
            }
            else {
                let candidateDetailViewController = CandidateDetailViewController(nibName: "CandidateDetailViewController", bundle: nil)
                candidateDetailViewController.postModel = postModel
                navigationController?.pushViewController(candidateDetailViewController, animated: true)
            }
        }
        else {
            let postModel = posts[indexPath.row]
            if Authenticator.shareInstance.getPostType() == PostType.findPeople {
                if postModel.status == "2" { // Post is off
                    // Do nothing
                }
                else {
                    let candidateDetailViewController = CandidateDetailViewController(nibName: "CandidateDetailViewController", bundle: nil)
                    candidateDetailViewController.postModel = postModel
                    navigationController?.pushViewController(candidateDetailViewController, animated: true)
                }
            }
            else {
                let jobDetailViewController = JobDetailViewController(nibName: "JobDetailViewController", bundle: nil)
                jobDetailViewController.postModel = postModel
                navigationController?.pushViewController(jobDetailViewController, animated: true)
            }
        }
    }
}

