//
//  MMYProfileViewController.swift
//  MMY
//
//  Created by Minh tuan on 7/29/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import CoreLocation
import Eureka

enum MenuProfileRow: Int {
    case profile = 0, managementBlue, managementRed, favorite, savedInfo, huneStore, hunePay, huneAds, promotion, huneMart

    static let all: [MenuProfileRow] = [.profile, .managementBlue, .managementRed , .hunePay, .huneAds, .huneStore, .promotion, .favorite, .savedInfo, .huneMart]
}


class MMYProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingBtn: UIButton!
	@IBOutlet weak var chatWithUs: UIButton!
    @IBOutlet weak var addBtn: PushButtonView!
    var userModel: UserModel?
    fileprivate var posts: [PostModel]? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    var backGroundColor: UIColor?
    var postType: PostType?

    let textColor = UIColor(hexString: "757575")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configNavigaton()
        self.setupView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.isHidden = true

        ServiceManager.userService.get(userId: "") { [unowned self] (result) in
            switch result {
            case .success(let user):
                self.userModel = user
                self.tableView.reloadData()
                self.tableView.isHidden = false
            case .failure(let error):
                log.debug(error.errorMessage)
            }
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCandidates()
        ShareData.typeManager = ""
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        else {
            backGroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        }
        navigationController?.navigationBar.barTintColor = backGroundColor
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
        //navigationItem.rightBarButtonItem = rightMenuButton
        
        // Adf right setting language
        let settingLanguage = UIBarButtonItem(image: UIImage(named: "ic_language"), style: .done, target: self, action: #selector(stLanguage))
        settingLanguage.tintColor = .white
        navigationItem.rightBarButtonItems = [rightMenuButton, settingLanguage]
        
        // Title
        title = "Profile".localized()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
    }
    
    func stLanguage() {
        let formVC = LanguageViewController()
        navigationController?.pushViewController(formVC, animated: true)
    }

    func setupView() {
        settingBtn.setImage(UIImage(named: "icon_setting")?.withRenderingMode(.alwaysTemplate), for: .normal)
        settingBtn.tintColor = textColor
        settingBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        settingBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10)
        settingBtn.titleLabel?.textColor = textColor
        settingBtn.setTitle("Settings".localized().uppercased(), for: .normal)
        settingBtn.sizeToFit()
        
        if let color = Authenticator.shareInstance.getPostType()?.color() {
            addBtn.fillColor = color
        }
		
		chatWithUs.setImage(UIImage(named: "icon_messenger")?.withRenderingMode(.alwaysTemplate), for: .normal)
		chatWithUs.tintColor = textColor
		chatWithUs.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
		chatWithUs.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10)
		chatWithUs.titleLabel?.textColor = textColor
		chatWithUs.setTitle("ChatWithUs".localized().uppercased(), for: .normal)
		chatWithUs.sizeToFit()
    }
    
    //MARK : - handle user action
    func displayNotification() {
        print("displayNotification")
        let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    @IBAction func onBtnSetting(_ sender: Any) {
//        print("onBtnSetting")
        let settingViewController = SettingViewController(nibName: "SettingViewController", bundle: nil)
        navigationController?.pushViewController(settingViewController, animated: true)
    }
	
	@IBAction func onChatWithUs(_ sender: Any) {
		if let url = URL(string: "http://m.me/hunegroup") {
			UIApplication.shared.openURL(url)
		}
	}
    
    @IBAction func onBtnAdd(_ sender: Any) {
        print("onBtnAdd")
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

    func getCandidates() {
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            ServiceManager.postService.getRelatePosts(location: Authenticator.shareInstance.getLocation(), type: "2", radius: 10, completion: { [unowned self] (posts) in
                if let posts = posts {
                    self.posts = posts
                }
            })
        }
        else {
            ServiceManager.postService.getRelatePosts(location: Authenticator.shareInstance.getLocation(), type: "1", radius: 10, completion: { [unowned self] (posts) in
                if let posts = posts {
                    self.posts = posts
                }
            })
        }
    }
}


//Mark : - UITableViewDataSource

extension MMYProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuProfileRow.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = MenuProfileRow.all[indexPath.row]
        switch menu {
        case .profile:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "subtitleCell")
            cell.textLabel?.text = self.userModel?.full_name
            cell.textLabel?.font = UIFont(name: "Lato-Bold", size: 15)
            cell.textLabel?.textColor = textColor
            cell.detailTextLabel?.text = "Personal page".localized()
            cell.detailTextLabel?.font = UIFont(name: "Lato-Regular", size: 13)
            cell.detailTextLabel?.textColor = textColor
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView?.tintColor = textColor
            cell.selectionStyle = .none
            return cell
        case .managementBlue:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "icon_list")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.textLabel?.text = "RecruitmentManagement".localized().uppercased()
            
            // Add badge
            var count = 0
            if let posts = posts {
                count = posts.count
            }
            if count > 0 {
                let badge = UILabel()
                let fontSize: CGFloat = 11.0
                badge.font = UIFont.systemFont(ofSize: fontSize)
                badge.textAlignment = .center
                badge.textColor = UIColor.white
                badge.backgroundColor = UIColor.red
                badge.text = "\(count)"
                badge.sizeToFit()
                var frame = badge.frame
                frame.size.height += 0.4 * fontSize
                frame.size.width = (count > 9) ? frame.size.height : frame.size.width + fontSize
                badge.frame = frame
                badge.layer.cornerRadius = frame.size.height/2.0
                badge.clipsToBounds = true
                cell.accessoryView = badge
            }
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        case .managementRed:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "icon_list")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.textLabel?.text = "JobSeekingManagement".localized().uppercased()
            
            //Add badge
            var count = 0
            if let posts = posts {
                count = posts.count
            }
            if count > 0 {
                let badge = UILabel()
                let fontSize: CGFloat = 11.0
                badge.font = UIFont.systemFont(ofSize: fontSize)
                badge.textAlignment = .center
                badge.textColor = UIColor.white
                badge.backgroundColor = UIColor.red
                badge.text = "\(count)"
                badge.sizeToFit()
                var frame = badge.frame
                frame.size.height += 0.4 * fontSize
                frame.size.width = (count > 9) ? frame.size.height : frame.size.width + fontSize
                badge.frame = frame
                badge.layer.cornerRadius = frame.size.height/2.0
                badge.clipsToBounds = true
                cell.accessoryView = badge
            }
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        case .favorite:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "icon_love")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.text = "FavoriteList".localized().uppercased()
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.selectionStyle = .none
            return cell
        case .savedInfo:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "icon_save_info")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.text = "Saved".localized().uppercased()
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.selectionStyle = .none
            return cell
        case .hunePay:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "icHunePay")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.text = "HunePay".localized().uppercased()
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.selectionStyle = .none
            return cell
        case .huneAds:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "icHuneAds")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.text = "HuneAds".localized().uppercased()
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.selectionStyle = .none
            return cell
        case .huneStore:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "icHuneStore")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.text = "RewardHune".localized().uppercased()
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.selectionStyle = .none
            return cell
        case .promotion:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "icPromotion")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.text = "Promotion".localized().uppercased()
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.selectionStyle = .none
            return cell
//        case .function:
//            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
//            cell.imageView?.image = UIImage(named: "icon_back")?.withRenderingMode(.alwaysTemplate)
//            cell.imageView?.tintColor = textColor
//            cell.textLabel?.text = "SelectFunction".localized().uppercased()
//            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
//            cell.textLabel?.textColor = textColor
//            cell.selectionStyle = .none
//            return cell
        case .huneMart:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.imageView?.image = UIImage(named: "ic_mart")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = textColor
            cell.textLabel?.text = "HuNe Mart".uppercased()
            cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)
            cell.textLabel?.textColor = textColor
            cell.selectionStyle = .none
            return cell
            
        }
    }
}

//Mark : - UITableViewDelegate
extension MMYProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 70
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = MenuProfileRow.all[indexPath.row]
        switch menu {
        case .profile:
            let personViewController = PersonViewController(nibName: "PersonViewController", bundle: nil)
            personViewController.userModel = self.userModel
            self.navigationController?.pushViewController(personViewController, animated: true)
            break
        case .managementBlue:
            ShareData.typeManager = "2"
            let vc = RecruitmentManagementViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .managementRed:
            ShareData.typeManager = "1";
            let vc = JobSeekerManagementViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .favorite:
            let favoriteViewController = FavoriteViewController(nibName: "FavoriteViewController", bundle: nil)
            self.navigationController?.pushViewController(favoriteViewController, animated: true)
        case .savedInfo:
            let inforSavedViewController = InforSavedViewController(nibName: "InforSavedViewController", bundle: nil)
            self.navigationController?.pushViewController(inforSavedViewController, animated: true)
        case .huneAds:
            let vc = HuneAdsViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        case .hunePay:
            let vc = WalletViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        case .huneStore:
            let vc = HuneStoreViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        case .promotion:
            let vc = PromotionViewController()
            self.navigationController?.pushViewController(vc, animated: true)
//        case .function:
//            let guestLoginViewController = GuestSignInViewController()
//            guestLoginViewController.isHiddenBackButton = true
//            let window :UIWindow = UIApplication.shared.keyWindow!
//            window.rootViewController = guestLoginViewController
        case .huneMart:
            let vc = HuneMartViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}




