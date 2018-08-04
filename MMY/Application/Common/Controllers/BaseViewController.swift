//
//  BaseViewController.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/13/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import ChameleonFramework
import NVActivityIndicatorView

class BaseViewController: UIViewController {
    var activityIndicator: NVActivityIndicatorView?
    let item = ["Hune Red","Hune Blue"]
    var segment: UISegmentedControl? = nil
    var postType1: PostType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        segment = UISegmentedControl(items: item)
    }
    
    //MARK: - Setup views
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
        view.addSubview(activityIndicator!)
        activityIndicator?.snp.makeConstraints({ (make) in
            make.center.equalTo(view)
        })
    }
    
    func showLoading() {
        if activityIndicator == nil {
            setupActivityIndicator()
        }
        activityIndicator?.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator?.stopAnimating()
    }
    
    // add action title to change hune blue and hune red
    func addTargetTitle(typePost: PostType) {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.segment
        }
        self.segment?.tintColor = UIColor.white
        if typePost == PostType.findJob {
            self.segment?.selectedSegmentIndex = 0
            self.segment?.backgroundColor = UIColor(hexString: "#CC3333") ?? .appColor
        }
        else {
            self.segment?.selectedSegmentIndex = 1
            self.segment?.backgroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        }
        segment?.addTarget(self, action: #selector(self.handleSegment(sender:)), for: .valueChanged)
        
    }
    
    func handleSegment(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            DispatchQueue.main.async {
                Authenticator.shareInstance.setPostType(postType: PostType.findJob)
                let recruitmentVC = RecruitmentViewController()
                recruitmentVC.postType = PostType.findJob
                let nav = UINavigationController(rootViewController: recruitmentVC)
                
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                UIApplication.shared.keyWindow?.rootViewController = nav
            }
            break
        case 1:
            DispatchQueue.main.async {
                Authenticator.shareInstance.setPostType(postType: PostType.findPeople)
                let recruitmentVC = RecruitmentViewController()
                recruitmentVC.postType = PostType.findPeople
                let nav = UINavigationController(rootViewController: recruitmentVC)
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                UIApplication.shared.keyWindow?.rootViewController = nav
            }
            break
        default:
            break
        }
    }
}

extension UIViewController {
    
    static func loadFromNib() -> Self {
        let name = String(describing: self)
        let vc = self.init(nibName: name, bundle: nil)
        return vc
    }
    
    func showErrorDialog(_ error: ErrorModel, handler: ((_ alertAction: UIAlertAction) -> Void)? = nil) {
        showDialog(title: "Error".localized(), message: error.errorMessage, handler: handler)
    }
    
    func showDialog(title: String, message: String, buttonTitle: String = "OK", cancelTitle: String? = nil, handler: ((_ alertAction: UIAlertAction) -> Void)?){
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: buttonTitle.localized(), style: UIAlertActionStyle.default, handler: handler))
        if let cancelTitle = cancelTitle {
            alertController.addAction(UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.cancel,handler: handler))
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func setNavigationTitlte(title: String) {
        self.title = title
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white,
             NSFontAttributeName: UIFont(name: "Lato-Regular", size: 17)!]
    }
    
    func addLeftBarButton() {
        // Add left bar button
        let leftButton = UIButton.init(type: .custom)
        leftButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftButton.addTarget(self, action:#selector(onBtnBack), for: UIControlEvents.touchUpInside)
        //leftButton.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20)
        leftButton.tintColor = .white
        leftButton.backgroundColor = .clear
        let leftBarButton = UIBarButtonItem.init(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        //
        let tapViewOut = UISwipeGestureRecognizer(target:self,action:#selector(tapViewSwipe))
        tapViewOut.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapViewOut)
    }
    
    func tapViewSwipe() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onBtnBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

