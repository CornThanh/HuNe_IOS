
import UIKit
import NVActivityIndicatorView
import CoreLocation

class JobDetailViewController: UIViewController {
    
    @IBOutlet weak var lbAds: UILabel!
    @IBOutlet weak var constraintHeighBanner: NSLayoutConstraint!
    @IBOutlet weak var imageBanner: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: NVActivityIndicatorView?
    var postModel: PostModel? {
        didSet {
            postID = postModel?.postID
            
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    var postID: String?
    var userID: String?
    var userModel: UserModel? {
        didSet {
            userID = userModel?.userId
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    var votes = [VoteModel]()
    var linkBanner: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigaton()
        setupActivityIndicator()
        if let userModel = self.postModel?.userModel {
            self.userModel = userModel
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "JodHeaderCell", bundle: nil), forCellReuseIdentifier: "JodHeaderCell")
        tableView.register(UINib.init(nibName: "JobDetailCell", bundle: nil), forCellReuseIdentifier: "JobDetailCell")
        tableView.register(UINib.init(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        self.tableView.isHidden = true
        
        let group = DispatchGroup()
        if let userID = userID {
            ServiceManager.userService.get(userId: userID) { (result) in
                group.enter()
                switch result {
                case .success(let user):
                    self.userModel = user
                case .failure(let error):
                    log.debug(error.errorMessage)
                }
                group.leave()
            }
        }
        
        group.enter()
        if let postID = postID {
            ServiceManager.postService.get(postId: postID) { (result) in
                switch result {
                case let .success(postModel):
                    self.postModel = postModel
                case let .failure(error):
                    log.debug(error.errorMessage)
                }
                group.leave()
            }
        }
        
        group.enter()
        if let userID = userID {
            ServiceManager.voteService.getVote(soureID: userID, type: "1") { (votes, error) in
                if let votes = votes {
                    self.votes = votes
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global(qos: .background)) {
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.reloadData()
                self.tableView.isHidden = false
            }
            
            self.lbAds.isHidden = true
            self.constraintHeighBanner.constant = 0.0
            self.imageBanner.layoutIfNeeded()
            self.showBannerPromotionDeatilJob(position: "6", image: self.imageBanner, constrain: self.constraintHeighBanner)
            Timer.scheduledTimer(withTimeInterval: 450.0 , repeats: true) { (timer) in
                self.showBannerPromotionDeatilJob(position: "6", image: self.imageBanner, constrain: self.constraintHeighBanner)
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(eventBanner))
        imageBanner.addGestureRecognizer(tap)
        imageBanner.isUserInteractionEnabled = true
    }
    
    func eventBanner() {
        UIApplication.shared.open(URL(string: linkBanner)!, options: [:], completionHandler: nil)
    }
    
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
    }
    
    func showBannerPromotionDeatilJob(position: String, image: UIImageView, constrain: NSLayoutConstraint) {
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
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "icon_save_info"), style: .done, target: self, action: #selector(saveInfo))
        rightMenuButton.image = UIImage(named: "icon_save_info")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightMenuButton
        
        // Title
        title = "Job details".localized()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
    }
    
    //MARK : - handle user action
    func saveInfo() {
        self.activityIndicator?.startAnimating()
        ServiceManager.favoriteService.addFavorite(type: "2", source_id: (self.postModel?.postID)!) { (resultCode) in
            self.activityIndicator?.stopAnimating()
            if resultCode == ErrorCode.success.rawValue {
                self.showDialog(title: "Thành công", message: "Lưu tin thành công", handler: nil)
            }
            else {
                self.showDialog(title: "Error", message: "Có lỗi khi lưu thông tin, vui lòng thử lại", handler:nil)
            }
        }
    }
    
    @IBAction func onBtnAddComment(_ sender: Any) {
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
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
    
    func addComment() {
        let addCommentViewController = AddCommentViewController(nibName: "AddCommentViewController", bundle: nil)
        addCommentViewController.userModel = self.userModel
        addCommentViewController.postModel = self.postModel
        navigationController?.pushViewController(addCommentViewController, animated: true)
    }
    
    func handleCreateTaskAction() {
        let vc = TaskCreateViewController(nibName: "TaskCreateViewController", bundle: nil)
        vc.postModel = postModel
        navigationController?.pushViewController(vc, animated: true)
    }
}



extension JobDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else {
            return self.votes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "JodHeaderCell") as!JodHeaderCell
                if let userModel = self.userModel {
                    cell.updateWithUsermodel(userModel: userModel)
                }
                cell.callBlock = {
                    
                    if let phoneNumber = self.userModel?.phone {
                        if let number = URL(string: "tel://" + phoneNumber) {
                            UIApplication.shared.open(number, options: [:], completionHandler: { (completion) in
                                self.showDialog(title: "", message: "CanCreateTask".localized(), buttonTitle: "OK".localized(), cancelTitle: "Cancel".localized(), handler: { (action) in
                                    if action.style == UIAlertActionStyle.default {
                                        self.handleCreateTaskAction()
                                    }
                                })
                            })
                        }
                    }
                    
                }
                
                cell.favoriteBlock = {[unowned self] in
                    if let userModel = self.userModel {
                        if let is_favorite = userModel.is_favourite {
                            
                            // add favorite
                            if !is_favorite {
                                self.activityIndicator?.startAnimating()
                                ServiceManager.favoriteService.addFavorite(type: "1", source_id: (self.postModel?.userModel?.userId)!, completion: { (resultCode) in
                                    self.activityIndicator?.stopAnimating()
                                    if resultCode == ErrorCode.success.rawValue {
                                        self.userModel?.is_favourite = true
                                        self.tableView.reloadRows(at: [indexPath], with: .none)
                                    }
                                    else {
                                        
                                    }
                                })
                            }
                                
                                // delete favorite
                            else {
                                self.activityIndicator?.startAnimating()
                                ServiceManager.favoriteService.deleteFavorite(type: "1", source_id: (self.postModel?.userModel?.userId)!, completion: { (resultCode) in
                                    self.activityIndicator?.stopAnimating()
                                    if resultCode == ErrorCode.success.rawValue {
                                        self.userModel?.is_favourite = false
                                        self.tableView.reloadRows(at: [indexPath], with: .none)
                                    }
                                    else {
                                        
                                    }
                                })
                            }
                            
                        }
                        
                    }
                }
                
                cell.shareBlock = {
                    self.activityIndicator?.startAnimating()
                    ServiceManager.shareService.getShare(type: "post", post_id: self.postModel?.postID, completion: { [unowned self] (shareModel) in
                        self.activityIndicator?.stopAnimating()
                        if let shareModel = shareModel, let urlString = shareModel.url  {
                            guard let url = NSURL(string: urlString) else {
                                return
                            }
                            let shareItems:Array = [url]
                            let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                            activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
                            self.present(activityViewController, animated: true, completion: nil)
                        }
                    })
                }
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "JobDetailCell") as!JobDetailCell
                if let postModel = postModel {
                    cell.updateCellwithData(postModel: postModel)
                }
                cell.selectionStyle = .none
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            let vote = self.votes[indexPath.row]
            cell.update(vote: vote)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
            let titleLB = UILabel()
            headerView.addSubview(titleLB)
            titleLB.font = UIFont(name: "Lato-Bold", size: 13)
            titleLB.text = "Đánh giá"
            titleLB.snp.makeConstraints({ (make) in
                make.left.equalTo(headerView).offset(20)
                make.centerY.equalTo(headerView)
            })
            let imageView = UIImageView(image: UIImage(named: "icon_arrow_down"))
            headerView.addSubview(imageView)
            imageView.snp.makeConstraints({ (make) in
                make.left.equalTo(titleLB.snp.right).offset(10)
                make.centerY.equalTo(headerView)
                make.height.equalTo(10)
                make.width.equalTo(10)
            })
            
            let addCommentBtn = UIButton(type: .custom)
            addCommentBtn.setTitle("Thêm", for: .normal)
            addCommentBtn.titleLabel?.font = UIFont(name: "Lato-Bold", size: 13)
            addCommentBtn.setTitleColor(Authenticator.shareInstance.getPostType()?.color(), for: .normal)
            addCommentBtn.addTarget(self, action: #selector(self.addComment), for: .touchUpInside)
            headerView.addSubview(addCommentBtn)
            addCommentBtn.snp.makeConstraints({ (make) in
                make.right.equalTo(headerView.snp.right).offset(-20)
                make.centerY.equalTo(headerView)
            })
            
            return headerView
        }
        else {
            return nil
        }
    }
}


extension JobDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20
        }
        else {
            return 0
        }
        
    }
}
