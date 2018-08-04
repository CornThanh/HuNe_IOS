
import UIKit
import NVActivityIndicatorView
import CoreLocation

class CandidateDetailViewController: UIViewController {
    
    var postModel: PostModel? {
        didSet {
            postID = postModel?.postID
            userModel = self.postModel?.userModel
        }
    }
    var postID: String!
    var userId: String?
    var userModel: UserModel? {
        didSet {
            userId = userModel?.userId
        }
    }
    var votes = [VoteModel]()
    var linkBanner: String = ""
    
    @IBOutlet weak var lbAds: UILabel!
    @IBOutlet weak var imageBanner: UIImageView!
    @IBOutlet weak var constraintHeighbanner: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigaton()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.isHidden = true
        tableView.register(UINib.init(nibName: "CandidateHeaderCell", bundle: nil), forCellReuseIdentifier: "CandidateHeaderCell")
        tableView.register(UINib.init(nibName: "CandidateDetailCell", bundle: nil), forCellReuseIdentifier: "CandidateDetailCell")
        tableView.register(UINib.init(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 1
        lbAds.isHidden = true
        constraintHeighbanner.constant = 0.0
        imageBanner.layoutIfNeeded()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(eventBanner))
        imageBanner.addGestureRecognizer(tap)
        imageBanner.isUserInteractionEnabled = true
        
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
        }
        
        let group = DispatchGroup()
        if let userID = userId {
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
        ServiceManager.postService.get(postId: postID!) { (result) in
            switch result {
            case let .success(postModel):
                self.postModel = postModel
            case let .failure(error):
                log.debug(error.errorMessage)
            }
            group.leave()
        }
        
        group.enter()
        ServiceManager.voteService.getVote(soureID: postID!, type: "2") { (votes, error) in
            if let votes = votes {
                self.votes = votes
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global(qos: .background)) {
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.reloadData()
                self.tableView.isHidden = false
            }
            
            //
            self.showBannerPromotionDetail(position: "6", image: self.imageBanner, constrain: self.constraintHeighbanner)
            Timer.scheduledTimer(withTimeInterval: 450.0 , repeats: true) { (timer) in
                self.showBannerPromotionDetail(position: "6", image: self.imageBanner, constrain: self.constraintHeighbanner)
            }
            
        }
    }
    
    //MARK: - Setup views
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
    }
    
    func eventBanner() {
       UIApplication.shared.open(URL(string: linkBanner)!, options: [:], completionHandler: nil)
    }
    
    func configNavigaton()  {
        
        // Add left bar button
        addLeftBarButton()
        
        // Add right bar button
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "icon_save_info"), style: .done, target: self, action: #selector(saveInfo))
        rightMenuButton.image = UIImage(named: "icon_save_info")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightMenuButton
        
        // Title
        title = "CandidateInfo".localized()
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
    
    func showBannerPromotionDetail(position: String, image: UIImageView, constrain: NSLayoutConstraint) {
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
                    //                    let findJobViewController = FindJobViewController(nibName: "FindJobViewController", bundle: nil)
                    self.navigationController?.pushViewController(FindJobViewController(0, postModelID: "", arrCheck: [Int]()), animated: true)
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
    
    //MARK: - Open photo full screen
    func openPhotofull(index: Int) {
        if let images = postModel?.images, images.count > index {
            if let urlString = postModel?.images?[index] {
                let photoViewController = PhotoViewController(nibName: "PhotoViewController", bundle: nil)
                photoViewController.imageURLString = urlString
                navigationController?.pushViewController(photoViewController, animated: true)
            }
        }
    }
}


extension CandidateDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
            
            //            let addCommentBtn = UIButton(type: .custom)
            //            addCommentBtn.setTitle("Thêm", for: .normal)
            //            addCommentBtn.titleLabel?.font = UIFont(name: "Lato-Bold", size: 13)
            //            addCommentBtn.setTitleColor(Authenticator.shareInstance.getPostType()?.color(), for: .normal)
            //            addCommentBtn.addTarget(self, action: #selector(self.addComment), for: .touchUpInside)
            //            headerView.addSubview(addCommentBtn)
            //            addCommentBtn.snp.makeConstraints({ (make) in
            //                make.right.equalTo(headerView.snp.right).offset(-20)
            //                make.centerY.equalTo(headerView)
            //            })
            
            return headerView
        }
        else {
            return nil
        }
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
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CandidateHeaderCell") as! CandidateHeaderCell
                if let userModel = self.userModel, let postModel = self.postModel {
                    cell.updateWithUsermodel(userModel: userModel, postModel: postModel)
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
                cell.addTaskBlock = {
                    self.handleCreateTaskAction()
                }
                
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CandidateDetailCell") as! CandidateDetailCell
                if let userModel = self.userModel, let postModel = self.postModel {
                    cell.update(userModel: userModel, postModel: postModel)
                }
                cell.callBlock = {
                    if let phoneNumber = self.userModel?.phone {
                        //                        guard let number = URL(string: "tel://" + phoneNumber) else {
                        //                            return
                        //                        }
                        //UIApplication.shared.openURL(number)
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
                    
                    //                        self.showDialog(title: "", message: "CanCreateTask".localized(), buttonTitle: "OK".localized(), cancelTitle: "Cancel".localized(), handler: { (action) in
                    //                            if action.style == UIAlertActionStyle.default {
                    //                                self.handleCreateTaskAction()
                    //                            }
                    //                        })
                    
            }
            cell.tapImage1Block = {
                self.openPhotofull(index: 0)
            }
            cell.tapImage2Block = {
                self.openPhotofull(index: 1)
            }
            cell.tapImage3Block = {
                self.openPhotofull(index: 2)
            }
            cell.selectionStyle = .none
            return cell
            default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "CellDefault")
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

func handleCreateTaskAction() {
    let vc = TaskCreateViewController(nibName: "TaskCreateViewController", bundle: nil)
    vc.postModel = postModel
    navigationController?.pushViewController(vc, animated: true)
}
}

extension CandidateDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}






