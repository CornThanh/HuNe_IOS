//
//  TaskDetailViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 11/20/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class TaskDetailViewController: BaseViewController {

    var task: TaskModel? {
        didSet {
            self.updateView()
        }
    }

    var taskID: String!

    @IBOutlet weak var vCandidate: TaskCandidateView!
    @IBOutlet weak var lbTitle: UILabel! {
        didSet {
            lbTitle.text = "Title".localized()
        }
    }
    @IBOutlet weak var lbJobTitle: UILabel!
    @IBOutlet weak var lbCateTitle: UILabel! {
        didSet {
            lbCateTitle.text = "Job".localized()
        }
    }
    @IBOutlet weak var lbCateValue: UILabel!

    @IBOutlet weak var lbSalaryTitle: UILabel! {
        didSet {
            lbSalaryTitle.text = "Salary".localized()
        }
    }

    @IBOutlet weak var lbLocationTitle: UILabel! {
        didSet {
            lbLocationTitle.text = "Address".localized()
        }
    }
    @IBOutlet weak var lbLocationValue: UILabel!

    @IBOutlet weak var lbSalary: UITextField!
    @IBOutlet weak var lbStartTime: UILabel! {
        didSet {
            lbStartTime.text = "Start".localized()
        }
    }
    @IBOutlet weak var lbStartDate: UILabel!
    @IBOutlet weak var lbEndTime: UILabel! {
        didSet {
            lbEndTime.text = "End".localized()
        }
    }
    @IBOutlet weak var lbEndDate: UILabel!

    @IBOutlet weak var lbDescription: UILabel! {
        didSet {
            lbDescription.text = "Description".localized()
        }
    }
    @IBOutlet weak var tfDescription: UITextView!

    @IBOutlet weak var btnDone: UIButton!  {
        didSet {
            btnDone.setTitle("Done".localized().uppercased(), for: .normal)
        }
    }

    var backGroundColor = UIColor(hexString: "#33CCFF")

    override func viewDidLoad() {
        super.viewDidLoad()
        btnDone.layer.cornerRadius = btnDone.bounds.size.height / 2
        addLeftBarButton()
        getTask()
    }

    func getTask() {
        showLoading()
        ServiceManager.taskService.getDetail(taskID) { (result) in
            self.task = result.value
            self.hideLoading()
        }
    }

    func updateView() {
        guard let task = task, let post = task.post else {
            return
        }
        lbJobTitle.text = task.name
        lbSalary.text = task.cost.stringWithSepator + " " + "VND".localized()
        lbStartDate.text = (task.startHour ?? "00:00") + " - " + (task.startDate ?? "")
        lbEndDate.text = (task.endHour ?? "00:00") + " - " + (task.endDate ?? "")
        tfDescription.text = task.note
        lbCateValue.text = post.category_title
        lbLocationValue.text = post.address ?? ""
        tfDescription.text = post.description

        vCandidate.updateData(task)

        if task.status == .waiting {
            // confirm
            btnDone.setTitle("Confirm".localized().uppercased(), for: .normal)
            btnDone.isHidden = task.ownerId == Authenticator.shareInstance.getAuthSession()?.user?.id
        }
        else if task.status == .working {
            // Pay
            btnDone.setTitle("Pay".localized().uppercased(), for: .normal)
            if post.postType == PostType.findPeople {
                btnDone.isHidden = task.ownerId == Authenticator.shareInstance.getAuthSession()?.user?.id
            }
            else {
//                btnDone.isHidden = task.ownerId != Authenticator.shareInstance.getAuthSession()?.user?.id
                // cuong test
                 btnDone.isHidden = task.ownerId == Authenticator.shareInstance.getAuthSession()?.user?.id
            }
        }
//        else if task.status == .completed, task.statusPayment == 0 {
//            // Rate
//            btnDone.setTitle("Rate".localized().uppercased(), for: .normal)
//        }
        else {
            btnDone.isHidden = true
        }
    }

    @IBAction func onBtnCall(_ sender: Any) {
        if let phoneNumber = task?.candidate?.phone {
            guard let number = URL(string: "tel://" + phoneNumber) else {
                return
            }
            UIApplication.shared.openURL(number)
        }
    }

    @IBAction func handleBtnDoneTouched(_ sender: Any) {
        guard let task = task else {
            return
        }
        if task.status == .waiting {
            // confirm
            showLoading()
            ServiceManager.taskService.updateStatus(task.id, status: TaskStatus.working.rawValue, completion: { (result) in
                self.hideLoading()
                self.showDialog(title: "", message: "Successful".localized(), handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
            })
        }
        else if task.status == .working {
            let vc = PaymentViewController.loadFromNib()
            vc.task = task
            navigationController?.pushViewController(vc, animated: true)
        }
        else if task.status == .completed {
            let vc = AddCommentViewController.loadFromNib()
            vc.postModel = task.post
            vc.userModel = task.candidate
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
