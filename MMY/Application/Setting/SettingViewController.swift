//
//  SettingViewController.swift
//  MMY
//
//  Created by Minh tuan on 7/30/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import UserNotifications
import Localize_Swift
import Firebase

class SettingViewController: BaseViewController {

    let receiveNotificationKey = "receiveNotification"

    @IBOutlet weak var addPostBtn: PushButtonView!
    @IBOutlet weak var tableView: UITableView!
    let textColor = UIColor(hexString: "757575")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configNavigaton()
        self.handleReceiveNotificationChange()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func configNavigaton()  {
        
        // Add left bar button
        self.addLeftBarButton()
        self.setupActivityIndicator()
        
        // Add right bar button
        let rightMenuButton = UIBarButtonItem(image: UIImage(named: "ic_left_notification"), style: .done, target: self, action: #selector(displayNotification))
        rightMenuButton.image = UIImage(named: "ic_left_notification")?.withRenderingMode(.alwaysTemplate)
        rightMenuButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightMenuButton
        
        // Title
        title = "Setting".localized()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 17)!]
        
        addPostBtn.fillColor = (Authenticator.shareInstance.getPostType()?.color())!
        
    }
    
//    //MARK : - handle user action
//    func onBtnBack() {
//        self.navigationController?.popViewController(animated: true)
//    }
    
    func displayNotification() {
        print("displayNotification")
        let notificationVC = MMYNotificationViewController(nibName: "MMYNotificationViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    
    @IBAction func onBtnAdd(_ sender: Any) {
    }
}

//MARK : - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "defaultcell")
        cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15)


        cell.textLabel?.textColor = UIColor(red: 117/255.0, green: 117/255.0, blue: 117/255.0, alpha: 1)
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "About".localized().uppercased()
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView?.tintColor = textColor
        case 1:
            cell.textLabel?.text = "Rate our app".localized().uppercased()
            cell.accessoryType = .none
        case 2:
            cell.textLabel?.text = "Invite friends".localized().uppercased()
            cell.accessoryType = .none
        case 3:
            cell.textLabel?.text = "Language".localized().uppercased()
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView?.tintColor = textColor
        case 4:
            cell.textLabel?.text = "Receive push notification".localized().uppercased()
            let accessoryLB = UILabel()
            accessoryLB.textColor = UIColor(hexString: "33ccff")
            if UserDefaults.standard.bool(forKey: receiveNotificationKey) {
                accessoryLB.text = "On".localized().uppercased()
            } else {
                accessoryLB.text = "Off".localized().uppercased()
            }
            accessoryLB.sizeToFit()
            cell.accessoryView = accessoryLB
            cell.accessoryType = .none
        case 5:
            cell.textLabel?.text = "Help".localized().uppercased()
            cell.accessoryType = .none
        case 6:
            cell.textLabel?.text = "Log out".localized().uppercased()
            cell.accessoryType = .none
        default:
            break
        }

        return cell
    }

    func handleReceiveNotificationChange() {
        let newValue = !UserDefaults.standard.bool(forKey: receiveNotificationKey)
        if newValue {
            checkPushNotificationPermission()
            if let token = InstanceID.instanceID().token(){
                ServiceManager.userService.updateFcm_token(fcm_token: token, completion: { (resultCode) in
                    UserDefaults.standard.setValue(newValue, forKey: self.receiveNotificationKey)
                    UserDefaults.standard.synchronize()
                    self.tableView.reloadData()
                })
            }
        } else {
            // remove token
            if let _ = InstanceID.instanceID().token(){
                ServiceManager.userService.updateFcm_token(fcm_token: "", completion: { (resultCode) in
                    UserDefaults.standard.setValue(newValue, forKey: self.receiveNotificationKey)
                    UserDefaults.standard.synchronize()
                    self.tableView.reloadData()
                })
            }
        }
    }

    func checkPushNotificationPermission() {
        if  !UIApplication.shared.isRegisteredForRemoteNotifications {
            if #available(iOS 10.0, *) {
                // For iOS 10 display notification (sent via APNS)
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: {_, _ in })
            } else {
                let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
            }
            UIApplication.shared.registerForRemoteNotifications()
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus == .denied {
                    self.showGotoSettingDialog()
                }
            }
        } else {
            if UIApplication.shared.currentUserNotificationSettings?.types == .none {
                showGotoSettingDialog()
            }
        }
    }

    func showGotoSettingDialog() {
        DispatchQueue.main.async {
            UIAlertController.showDiscardAlertView(in: self, title: "Push notification is off".localized(), message: "Turn it on in settings?".localized(), buttonTitle: "Go to settings".localized(), action: { (action) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
        }
    }
}

//MARK : - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            break
        // Share application
        case 2:
            self.activityIndicator?.startAnimating()
            ServiceManager.shareService.getShare(type: "app", post_id: nil, completion: { [unowned self] (shareModel) in
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
        case 3:
            let formVC = LanguageViewController()
            navigationController?.pushViewController(formVC, animated: true)
            break
        case 4:
            break
        case 5:
            break
            
        // Sign out
        case 6:
            let authSessionIdKey = "vn.asquare.Authenticator.AuthSessionId"
            UserDefaults.standard.removeObject(forKey: authSessionIdKey)
            (UIApplication.shared.delegate as! AppDelegate).makeCenterView()
        default:
            break
        }
    }
}
