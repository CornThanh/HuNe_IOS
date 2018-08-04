//
//  PaymentViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/29/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class PaymentViewController: BaseViewController {

    var task: TaskModel?
    var paymentMethod = 2 {
        didSet {
            updateLayout()
        }
    }
    @IBOutlet weak var tfAmout: UITextField!

    @IBOutlet weak var btnHuneCash: UIButton! {
        didSet {
            btnHuneCash.imageView?.contentMode = .scaleAspectFit
            btnHuneCash.setTitle("HuneCash".localized().uppercased(), for: .normal)
        }
    }
    @IBOutlet weak var btnCash: UIButton! {
        didSet {
            btnCash.imageView?.contentMode = .scaleAspectFit
            btnCash.setTitle("Cash".localized().uppercased(), for: .normal)
        }
    }
    @IBOutlet weak var btnConfirm: UIButton! {
        didSet {
            btnConfirm.setTitle("Pay".localized().uppercased(), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment".localized()
        addLeftBarButton()
        btnConfirm.layer.cornerRadius = btnConfirm.bounds.size.height / 2
        updateLayout()
    }

    func updateLayout() {
        if let cost = task?.cost {
            tfAmout.text = cost.stringWithSepator + " " + "VND".localized()
        }
        if paymentMethod == 1 {
            btnHuneCash.setImage(UIImage(named: "icon_check"), for: .normal)
            btnCash.setImage(UIImage(named: "icon_uncheck"), for: .normal)
        }
        else {
            btnHuneCash.setImage(UIImage(named: "icon_uncheck"), for: .normal)
            btnCash.setImage(UIImage(named: "icon_check"), for: .normal)
        }
    }

    @IBAction func handleBtnCheckBookTouched(_ sender: UIButton) {
        paymentMethod = sender.tag
    }

    @IBAction func handleBtnConfirmTouched(_ sender: Any) {
        guard let task = task else {
            return
        }

        showLoading()
        ServiceManager.taskService.pay(id: task.id, amount: tfAmout.text ?? "", method: paymentMethod) { (result) in
            self.hideLoading()
            switch (result) {
            case .success:
                self.showDialog(title: "", message: "Successful".localized(), handler: { (action) in
                    let nvc = self.navigationController
                    nvc?.popToRootViewController(animated: false)
                    
//                    if task.ownerId == task.candidate?.userId {
//                        let vc = AddCommentViewController.loadFromNib()
//                        vc.postModel = task.post
//                        vc.userModel = task.candidate
//                        nvc?.pushViewController(vc, animated: true)
//                    }
                    // cuong test
                    if task.ownerId != task.candidate?.userId {
                        let vc = AddCommentViewController.loadFromNib()
                        vc.postModel = task.post
                        vc.userModel = task.candidate
                        nvc?.pushViewController(vc, animated: true)
                    }
                })
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
