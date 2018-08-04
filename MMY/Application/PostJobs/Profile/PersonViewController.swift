//
//  PersonViewController.swift
//  MMY
//
//  Created by Minh tuan on 8/11/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class PersonViewController: UIViewController {

    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var genderLB: UILabel!
    @IBOutlet weak var birthdayLB: UILabel!
    var userModel: UserModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigaton()
//        updateViewWithData()
    }
    
    func updateViewWithData() {
        nameLB.text = userModel?.full_name
        if userModel?.gender == "1" {
            genderLB.text = "Nữ"
        }
        else {
            genderLB.text = "Nam"
        }
        birthdayLB.text = userModel?.birthday
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateViewWithData()
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
        title = "Trang cá nhân".localized()
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

    @IBAction func onBtnEdit(_ sender: Any) {
        let editPersonInfoViewController = EditPersonInfoViewController(nibName: "EditPersonInfoViewController", bundle: nil)
        editPersonInfoViewController.userModel = userModel
        navigationController?.pushViewController(editPersonInfoViewController, animated: true)
    }

}
