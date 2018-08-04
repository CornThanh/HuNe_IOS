
import UIKit
import NVActivityIndicatorView

class MMYNotificationViewController: UIViewController {
    @IBOutlet weak var recruitmentLB: UILabel!
    @IBOutlet weak var recruitmentNumberLB: UILabel!
    @IBOutlet weak var systemLB: UILabel!
    @IBOutlet weak var systemNumberLB: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    
    var notifications = [NotificationModel]()
    var systemNotifications = [NotificationModel]()         // type 3
    var findPeopleNotifications = [NotificationModel]()     // type 1
    var findJobNotifications = [NotificationModel]()        // type 2
    var displayNotifications = [NotificationModel]()
    
    var activityIndicator: NVActivityIndicatorView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        
        self.setupView()
        self.configNavigaton()
        setupActivityIndicator()
        
        recruitmentNumberLB.text = "0"
        systemNumberLB.text = "0"
        bottomView.isHidden = true
        
        activityIndicator?.startAnimating()
        ServiceManager.notificationService.getAllNotification { (notificaitons, error) in
            self.activityIndicator?.stopAnimating()
            self.bottomView.isHidden = false
            if (notificaitons != nil) && (notificaitons?.count)! > 0 {
                self.notifications = notificaitons!
                self.displayNotifications = self.notifications
                self.tableView.reloadData()
                self.tableView.isHidden = false
                
                var enrollmentNumber: Int = 0
                var searchJobNumber: Int = 0
                var systemNumber: Int = 0
                
                self.systemNotifications.removeAll()
                self.findPeopleNotifications.removeAll()
                self.findJobNotifications.removeAll()
                
                for notification: NotificationModel in self.notifications {
                    print(notification)
                    if notification.type == "1" {
                        enrollmentNumber += 1
                        self.findJobNotifications.append(notification)
                    }
                    else if notification.type == "2" {
                        searchJobNumber += 1
                        self.findPeopleNotifications.append(notification)
                    }
                    else if notification.type == "3" {
                        systemNumber += 1
                        self.systemNotifications.append(notification)
                    }
                }
                if Authenticator.shareInstance.getPostType() == PostType.findJob {
                    self.recruitmentNumberLB.text = "\(searchJobNumber)"
                }
                else {
                    self.recruitmentNumberLB.text = "\(enrollmentNumber)"
                }
                self.systemNumberLB.text = "\(systemNumber)"
                
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
    
    func setupView() {
        if Authenticator.shareInstance.getPostType() == PostType.findJob {
            recruitmentLB.text = "Tìm việc"
        }
        else {
            recruitmentLB.text = "Recruitment".localized()
        }
        
        recruitmentNumberLB.text = "3"
        recruitmentNumberLB.backgroundColor = UIColor.red
        recruitmentNumberLB.layer.cornerRadius = recruitmentNumberLB.frame.size.height/2.0
        recruitmentNumberLB.clipsToBounds = true
        
        systemLB.text = "System".localized()
        systemNumberLB.text = "12"
        systemNumberLB.backgroundColor = UIColor.red
        systemNumberLB.layer.cornerRadius = systemNumberLB.frame.size.height/2.0
        systemNumberLB.clipsToBounds = true
        
        bottomView.backgroundColor = Authenticator.shareInstance.getPostType()?.color()
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
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "ic_done"), style: .done, target: self, action: #selector(markAllRead))
        rightMenuButton.image = UIImage(named: "ic_done")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightMenuButton
        
        // Title
        title = "Notification".localized()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 17)!]
    }
    
    func markAllRead() {
        let alertView = CustomIOSAlertView()
        let frame = CGRect(x: 0 , y: 0 , width: 270, height: 150)
        let containerView = AllReadAlertView.instanceFromNib()
        containerView.donePress = {
            alertView?.close()
            self.activityIndicator?.startAnimating()
            ServiceManager.notificationService.markReadAllNotification(completion: { (resutlCode) in
                self.activityIndicator?.stopAnimating()
                if resutlCode == ErrorCode.success.rawValue {
                    self.showDialog(title: "Thành công", message: "", handler: { (alert) in

                    })
                }
                else {
                    self.showDialog(title: "Error", message: "Có lỗi, vui lòng thử lại", handler:nil)
                }
            })
        }
        containerView.frame = frame
        alertView?.containerView = containerView
        alertView?.buttonTitles = nil
        alertView?.showOverView(self.navigationController?.view)
    }


    @IBAction func onBtnRecruitmentNoti(_ sender: Any) {
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            displayNotifications = findPeopleNotifications
        }
        else {
            displayNotifications = findJobNotifications
        }
        tableView.reloadData()
    }
    
    @IBAction func onBtnSystemNo(_ sender: Any) {
        displayNotifications = systemNotifications
        tableView.reloadData()
    }
}


//MARK: - UITableViewDataSource
extension MMYNotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as! NotificationTableViewCell
        let notification = displayNotifications[indexPath.row]
        cell.updateWithNotification(notification: notification)
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MMYNotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let notification = displayNotifications[indexPath.row]
		if let postID = notification.postID {
			if notification.type == "1" {
				// recruiment
	
				let candidateDetailViewController = CandidateDetailViewController(nibName: "CandidateDetailViewController", bundle: nil)
				candidateDetailViewController.postID = postID
                candidateDetailViewController.userId = notification.postOwner
				navigationController?.pushViewController(candidateDetailViewController, animated: true)
			}
			else if notification.type == "2" {
				// find job

				let jobDetailViewController = JobDetailViewController(nibName: "JobDetailViewController", bundle: nil)
				jobDetailViewController.postID = postID
				jobDetailViewController.userID = notification.postOwner
				navigationController?.pushViewController(jobDetailViewController, animated: true)			}
		}
	}
}





