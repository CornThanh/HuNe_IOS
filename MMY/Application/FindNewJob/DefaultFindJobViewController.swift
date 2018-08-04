//
//  DefaultFindJobViewController.swift
//  MMY
//
//  Created by Apple on 4/20/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import NVActivityIndicatorView

class DefaultFindJobViewController: UIViewController {
    
    @IBOutlet weak var lbAds: UILabel!
    @IBOutlet weak var btUpload: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageBanner: UIImageView!
    @IBOutlet weak var constraintHeightBanner: NSLayoutConstraint!
    
    var activityIndicator: NVActivityIndicatorView?
    var postModel : PostModel?
    var postModelArr = [PostModel]()
    var selectedCategories = [CategoryModel]()
    fileprivate var categoryTableView: CategoryModel?
    fileprivate var paymentPeriod = TempPostModel.PaymentPeriod.hour
    private var location: CLLocation?
    private let geoCoder = GMSGeocoder()
    fileprivate var quality: Int = 1
    var arrButtonCheck: [Int] = [Int]()
    var checkChoice = false
    var indexItem: Int = 1
    var countCatelogies : Int?
    var indexCell: Int = -1
    var address : String = ""
    var postDataArray: [TempPostModel] = [TempPostModel]()
    let locationManager = CLLocationManager()
    var countPost = 0
    var jobPosted = [String: [String]]()
    var categoryDefault: CategoryModel?
    var backGround: UIColor?
    var postId = [Int: String]()
    var linkBanner: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btUpload.setTitle("Post".localized(), for: .normal)
        btUpload.layer.cornerRadius = btUpload.frame.size.height/2
        btUpload.backgroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        self.navigationController?.navigationBar.topItem?.title = " "
        collectionView.register(UINib(nibName: "DefaultFindJobCollectionViewCell" , bundle: nil), forCellWithReuseIdentifier: "collect")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.register(UINib(nibName: "DefaultFindJobTableViewCell" , bundle: nil), forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        title = "Find jobs".localized()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        if let postModel = postModel {
            ServiceManager.postService.get(postId: postModel.postID!, handler: { (result) in
                switch result {
                case let .success(postModel):
                    self.postModel = postModel
                    self.setUpWithPostModel(postModel: postModel)
                case let .failure(error):
                    log.debug(error.errorMessage)
                }
            })
        }
        
        if location == nil {
            if let location = Authenticator.shareInstance.getLocation() {
                self.locationChanged(to: location)
            }
        }
        
        ServiceManager.postService.getMyPost(type: "2") { [unowned self] (posts, error) in
            self.activityIndicator?.stopAnimating()
            if let posts = posts {
                self.postModelArr = posts
                for index in 0..<posts.count {
                    if self.jobPosted[posts[index].category_parent_title!] == nil {
                        self.jobPosted[posts[index].category_parent_title!] = [String]()
                        self.jobPosted[posts[index].category_parent_title!]?.append(posts[index].category![0].name_vi!)
                    } else {
                        self.jobPosted[posts[index].category_parent_title!]?.append(posts[index].category![0].name_vi!)
                    }
                    
                }
                
                if let categoryTable = Authenticator.shareInstance.getCategoryList() {
                    let category = categoryTable[0]
                    print(category)
                    self.categoryTableView = category
                    self.selectedCategories.removeAll()
                    self.selectedCategories.append(category)
                    self.tableView.reloadData()
                }
            }
        }
        
        self.lbAds.isHidden = true
        constraintHeightBanner.constant = 0.0
        imageBanner.layoutIfNeeded()
        self.showBannerPromotionPostJob(position: "2", image: self.imageBanner, constrain: self.constraintHeightBanner)
        Timer.scheduledTimer(withTimeInterval: 450.0 , repeats: true) { (timer) in
            self.showBannerPromotionPostJob(position: "2", image: self.imageBanner, constrain: self.constraintHeightBanner)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(eventBanner))
        imageBanner.addGestureRecognizer(tap)
        imageBanner.isUserInteractionEnabled = true

    }
    
    func eventBanner() {
        UIApplication.shared.open(URL(string: linkBanner)!, options: [:], completionHandler: nil)
    }
    
    func setUpWithPostModel(postModel: PostModel) {
        self.selectedCategories = [CategoryModel]()
        if let parentCategory = Authenticator.shareInstance.getCategoryFromId(id: postModel.category_parent_id!) {
            self.selectedCategories.append(parentCategory)
        }
        if let category = Authenticator.shareInstance.getCategoryFromId(id: postModel.category_id!) {
            self.selectedCategories.append(category)
        }
        
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btTapUpload(_ sender: Any) {
        //newPost.categories = selectedCategories
        
        for key in ShareData.arrNewPost.keys {
            if ShareData.arrNewPost[key]?.address == nil {
                if let postType = Authenticator.shareInstance.getPostType() {
                    ShareData.arrNewPost[key]?.postType = postType
                }
                ShareData.arrNewPost[key]?.description = "abcdf"
                ShareData.arrNewPost[key]?.title = "abc"
                ShareData.arrNewPost[key]?.address = address
                ShareData.arrNewPost[key]?.location = location
                ShareData.arrNewPost[key]?.amount = quality
                ShareData.arrNewPost[key]?.paymentPeriod = paymentPeriod
                ShareData.arrNewPost[key]?.images = [UIImage]()
                ShareData.arrNewPost[key]?.avatar = nil
                postDataArray.append(ShareData.arrNewPost[key]!)
            } else {
                postDataArray.append(ShareData.arrNewPost[key]!)
            }
        }
        
        if postDataArray.count > 0 {
            self.postNewJobToServer(postModel: postDataArray, count: postDataArray.count - 1)
        } else {
            UIAlertController.showSimpleAlertView(in: self, title: "Error".localized(), message: "Something happens while creating new post. Please try again later.".localized())
        }
    }
    
    func locationChanged(to newLocation: CLLocation?) {
        guard let newLocation = newLocation else {
            return
        }
        location = newLocation
        geoCoder.reverseGeocodeCoordinate(newLocation.coordinate) { [weak self] (response, error) in
            guard let _ = self,
                let location = response?.firstResult() else {
                    return
            }
            if let address = location.lines?.joined(separator: ", ") {
                self?.address = address
            }
        }
    }
    
    func postNewJobToServer(postModel: [TempPostModel], count: Int) {
        countPost = count
        if count >= 0 {
            activityIndicator?.startAnimating()
            print(count - 1)
            ServiceManager.postService.post(postModel[count]) { (categoryModel) in
                self.activityIndicator?.stopAnimating()
                self.view.isUserInteractionEnabled = true
                switch categoryModel {
                case .success(_):
                    self.countPost = count - 1
                    self.postNewJobToServer(postModel: postModel, count: self.countPost)
                    
                case let .failure(error):
                    self.postDataArray = [TempPostModel]()
                    ShareData.arrNewPost = [Int : TempPostModel]()
                    UIAlertController.showSimpleAlertView(in: self, title: "Error".localized(), message: "Something happens while creating new post. Please try again later.".localized())
                    log.debug(error.errorMessage)
                    print(error.errorMessage.description)
                }
            }
        } else {
            UIAlertController.showSimpleAlertView(in: self, title: "Bạn đã đăng tin thành công, bấm vào ok để xem ngay các tin của người dùng HuNe Blue phù hợp.", message: "", buttonTitle: "Ok", action: { (action) in
                self.postDataArray = [TempPostModel]()
                ShareData.arrNewPost = [Int : TempPostModel]()
                self.backToPreviousController()
            })
            
        }
    }
    
    
    
    
    @IBAction func btNext(_ sender: UIButton) {
        if sender.tag == 0 {
            if indexItem >= countCatelogies!{
                indexItem = countCatelogies! - 1
            } else {
                self.collectionView.scrollToItem(at:IndexPath(item: indexItem, section: 0), at: .right, animated: false)
                indexItem = indexItem + 1
            }
        } else {
            if indexItem <= 0 {
                indexItem = 1
            } else {
                indexItem = indexItem - 1
                self.collectionView.scrollToItem(at:IndexPath(item: indexItem, section: 0), at: .left, animated: false)
            }
        }
    }
    
    func btCheck(sender: UIButton) {
        if !(arrButtonCheck.contains(sender.tag)) {
            sender.setImage(UIImage(named: "icon_check"), for: .normal)
            arrButtonCheck.append(sender.tag)
            if let category = self.categoryTableView?.children![sender.tag] {
                print(category)
                selectedCategories.append(category)
                print(selectedCategories.count)
                ShareData.arrNewPost[sender.tag] = TempPostModel()
                ShareData.arrNewPost[sender.tag]?.categories = selectedCategories
                selectedCategories.remove(at: 1)
                
            }
            indexCell = sender.tag
            tableView.reloadData()
        } else {
            sender.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            for index in 0..<arrButtonCheck.count {
                if arrButtonCheck[index] == sender.tag {
                    arrButtonCheck.remove(at: index)
                    break;
                }
            }
            ShareData.arrNewPost.removeValue(forKey: sender.tag)
            tableView.reloadData()
        }
        print(selectedCategories.count)
    }
    
    func btTapEdit(sender: UIButton) {
        var postId = ""
        if arrButtonCheck.contains(sender.tag) {
            if ShareData.arrNewPost[sender.tag] == nil {
                if let category = self.categoryTableView?.children![sender.tag] {
                    selectedCategories.append(category)
                    ShareData.arrNewPost[sender.tag] = TempPostModel()
                    ShareData.arrNewPost[sender.tag]?.categories = selectedCategories
                    
                    for data in postModelArr {
                        if data.category![0].name_vi == category.name {
                            postId = data.postID!
                        }
                    }
                }
            
            }
            
            self.navigationController?.pushViewController(FindJobViewController( sender.tag, postModelID: postId, arrCheck: arrButtonCheck), animated: true)
        }
    }
    
    func backToPreviousController () {
        // _ = navigationController?.popViewController(animated: true)
        let vc = PostsViewController(nibName: "PostsViewController", bundle: nil)
        vc.type = .suitableList
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showBannerPromotionPostJob(position: String, image: UIImageView, constrain: NSLayoutConstraint) {
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

extension DefaultFindJobViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let categories = Authenticator.shareInstance.getCategoryList() {
            countCatelogies = categories.count
            return categories.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collect", for: indexPath) as! DefaultFindJobCollectionViewCell
        if let categories = Authenticator.shareInstance.getCategoryList() {
            let category = categories[indexPath.row]
            cell.updateCategoryCell(category: category)
        }
        cell.backgroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        cell.layer.cornerRadius = 10.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let categoryTable = Authenticator.shareInstance.getCategoryList() {
            let category = categoryTable[indexPath.row]
            print(category)
            categoryTableView = category
            selectedCategories.removeAll()
            selectedCategories.append(category)
            arrButtonCheck.removeAll()
            tableView.reloadData()
        }
        
    }
    
}

extension DefaultFindJobViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}

extension DefaultFindJobViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let catelogies = categoryTableView {
            return (catelogies.children?.count)!
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DefaultFindJobTableViewCell
        cell.lbName.text = categoryTableView?.children![indexPath.row].name
        cell.btEdit.setTitle("Edit".localized(), for: .normal)
        cell.btEdit.addTarget(self, action: #selector(btTapEdit), for: .touchUpInside)
        cell.btCheck.addTarget(self, action: #selector(btCheck), for: .touchUpInside)
        cell.btCheck.tag = indexPath.row
        cell.btEdit.tag = indexPath.row
        cell.lbOn.isHidden = true
        
        if let value = jobPosted[(categoryTableView?.name)!] {
            if value.contains((categoryTableView?.children![indexPath.row].name)!) {
                cell.lbOn.isHidden = false
                cell.btCheck.setImage(UIImage(named: "icon_check"), for: .normal)
                arrButtonCheck.append(indexPath.row)
            }
        }
        
        if arrButtonCheck.contains(indexPath.row) {
            cell.btCheck.setImage(UIImage(named: "icon_check"), for: .normal)
        } else {
            cell.btCheck.setImage(UIImage(named: "icon_uncheck"), for: .normal)
        }
        
        cell.selectionStyle = .none
        return cell
    }
}

extension DefaultFindJobViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let _:CLLocationCoordinate2D = manager.location!.coordinate
        if let location = manager.location {
            self.locationChanged(to: location)
        }
    }
}
