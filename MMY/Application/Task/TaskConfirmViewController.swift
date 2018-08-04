//
//  TaskConfirmViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/25/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class TaskConfirmViewController: BaseViewController {

    var task: TaskModel?

//    var postModel: PostModel? {
//        didSet {
//            postID = postModel?.postID
//        }
//    }
    
    var postModel = [PostModel]()

    var postID: String!

    @IBOutlet weak var lbTitle: UILabel! {
        didSet {
            lbTitle.text = "Title".localized()
        }
    }
    @IBOutlet weak var lbJobTitle: UILabel!
    @IBOutlet weak var lbJob: UILabel! {
        didSet {
            lbJob.text = "Job".localized()
        }
    }
    @IBOutlet weak var jobLB: UILabel! {
        didSet {
            jobLB.text = "SelectJob".localized()
        }
    }

    @IBOutlet weak var lbSalary: UILabel! {
        didSet {
            lbSalary.text = "Salary".localized()
        }
    }
    @IBOutlet weak var salaryTF: UITextField! {
        didSet {
            salaryTF.placeholder = "InputSalary".localized()
        }
    }

    @IBOutlet weak var lbStartTime: UILabel! {
        didSet {
            lbStartTime.text = "Start".localized()
        }
    }

    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var startImage: UIImageView!
    @IBOutlet weak var startLB: UILabel! {
        didSet {
            startLB.text = "StartDate".localized()
        }
    }

    @IBOutlet weak var lbEndTime: UILabel! {
        didSet {
            lbEndTime.text = "End".localized()
        }
    }
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var endImage: UIImageView!
    @IBOutlet weak var endLB: UILabel! {
        didSet {
            endLB.text = "EndDate".localized()
        }
    }

    @IBOutlet weak var descriptionView: UIView!

    @IBOutlet weak var lbDescription: UILabel! {
        didSet {
            lbDescription.text = "Description".localized()
        }
    }
    @IBOutlet weak var descriptionTF: UITextView!

    @IBOutlet weak var lbStartHour: UILabel!
    @IBOutlet weak var btnStartHour: UIButton! {
        didSet {
            btnStartHour.layer.cornerRadius = btnStartHour.frame.height/2.0
            btnStartHour.layer.borderWidth = 1
            btnStartHour.layer.borderColor = backGroundColor?.cgColor
        }
    }

    @IBOutlet weak var lbEndHour: UILabel!
    @IBOutlet weak var btnEndHour: UIButton! {
        didSet {
            btnEndHour.layer.cornerRadius = btnEndHour.frame.height/2.0
            btnEndHour.layer.borderWidth = 1
            btnEndHour.layer.borderColor = backGroundColor?.cgColor
        }
    }

    @IBOutlet weak var doneBtn: UIButton!  {
        didSet {
            doneBtn.setTitle("Done".localized().uppercased(), for: .normal)
        }
    }

    var backGroundColor = UIColor(hexString: "#33CCFF")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
