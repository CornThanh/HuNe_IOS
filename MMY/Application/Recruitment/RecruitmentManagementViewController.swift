//
//  RecruitmentManagementViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 12/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import Eureka

class RecruitmentManagementViewController: FormViewController {

    var posts: [PostModel]? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    var backGroundColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "RecruitmentManagement".localized().uppercased()
        
        backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
        navigationController?.navigationBar.barTintColor = backGroundColor

        let section = Section()
        let suitableRow = LabelRow().cellSetup { (cell, row) in
            row.title = "ListOfCandidates".localized()
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "icon_list")
            // Add badge
            var count = 0
            if let posts = self.posts {
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
        }
        suitableRow.onCellSelection { (_, _) in
            let vc = PostsViewController(nibName: "PostsViewController", bundle: nil)
            vc.type = .suitableList
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(suitableRow)

        let workingRow = LabelRow().cellSetup { (cell, row) in
            row.title = "JobsDoingList".localized()
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "icContacts")
        }
        workingRow.onCellSelection { (_, _) in
            let vc = TaskListViewController(nibName: "TaskListViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(workingRow)

        let postRow = LabelRow().cellSetup { (cell, row) in
            row.title = "CandidatePostManagement".localized()
            cell.imageView?.contentMode = .scaleAspectFit
            cell.imageView?.image = UIImage(named: "icon_write")
        }
        postRow.onCellSelection { (_, _) in
            let vc = PostsViewController(nibName: "PostsViewController", bundle: nil)
            vc.type = .postJobManagement
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(postRow)
        form +++ section
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
