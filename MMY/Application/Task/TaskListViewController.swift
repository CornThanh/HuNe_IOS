//
//  TaskListViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 11/20/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class TaskListViewController: BaseViewController {

    @IBOutlet weak var tbvContent: UITableView!

    var tasks: [TaskModel] = [] {
        didSet {
            if isViewLoaded {
                tbvContent.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "JobsDoingList".localized()
        tbvContent.tableFooterView = UIView()
        tbvContent.register(UINib.init(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tbvContent.rowHeight = UITableViewAutomaticDimension
        tbvContent.estimatedRowHeight = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTasks()
    }

    func getTasks() {
        showLoading()
        ServiceManager.taskService.get { (result) in
            switch result {
            case .success(let value, _):
                self.tasks = value
            case .failure(let error):
                self.showErrorDialog(error)
            }
            self.hideLoading()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TaskListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TaskTableViewCell
        let task = tasks[indexPath.row]
        cell.updateWithData(task)
        cell.deleteBlock = { () -> Void in
            self.showDialog(title: "", message: "RemoveAlert".localized(), cancelTitle: "Cancel".localized(), handler: { (action) in
                if action.style != .cancel {
                    self.removeTask(task)
                }
            })
        }

        return cell
    }

    func removeTask(_ task: TaskModel) {
        showLoading()
        ServiceManager.taskService.remove(task.id) { (result) in
            self.hideLoading()
            self.getTasks()
        }
    }

}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let vc = TaskDetailViewController.loadFromNib()
        vc.taskID = task.id
        navigationController?.safePushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
