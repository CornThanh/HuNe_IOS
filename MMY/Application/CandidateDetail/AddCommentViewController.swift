
import UIKit
import NVActivityIndicatorView

class AddCommentViewController: UIViewController {
    
    var postModel: PostModel?
    var userModel: UserModel?
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        configNavigaton()
        
        tableView.dataSource = self
//        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(UINib.init(nibName: "CandidateHeaderCell", bundle: nil), forCellReuseIdentifier: "CandidateHeaderCell")
        tableView.register(UINib.init(nibName: "AddCommentCell", bundle: nil), forCellReuseIdentifier: "AddCommentCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    //MARK: - Setup views
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
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
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "icon_notification"), style: .done, target: self, action: #selector(displayNotification))
        rightMenuButton.image = UIImage(named: "icon_notification")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightMenuButton
        
        // Title
        title = "Đánh giá"
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
        
    }

    //MARK : - handle user action
    func displayNotification() {
        print("displayNotification")
        let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
}

extension AddCommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
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
                                    self.userModel?.is_favourite = true
                                    self.tableView.reloadRows(at: [indexPath], with: .none)
                                }
                                else {
                                    
                                }
                            })
                        }
                        
                    }
                    
                }
            }
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell") as! AddCommentCell
            cell.doneBlock = {
                if cell.commentTF.text.characters.count == 0 {
                    self.showDialog(title: "Empty Field".localized(), message: "Vui lòng nhập phần đánh giá", handler: nil)
                }
                else {
                    // cuong test
                    let rating = cell.ratingView.rating
                    let comment = cell.commentTF.text
                    print(rating)
                    print(comment!)
                    ServiceManager.voteService.addVote(source_id: (self.userModel?.userId)!, rate: "\(rating)", comment: comment!, type: "1") { [weak self] (resultCode) in
                        if resultCode == ErrorCode.success.rawValue {
                            self?.showDialog(title: "Thành công", message: "Bạn đã thêm đánh giá thành công", handler: { (alert) in
                                self?.navigationController?.popViewController(animated: true)
                            })
                        }
                        else {
                            self?.showDialog(title: "Error", message: "Có lỗi khi thêm đánh giá, vui lòng thử lại", handler:nil)
                        }
                    }
                }
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}

