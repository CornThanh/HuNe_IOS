

import UIKit

class InforSavedViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var posts = [PostModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupActivityIndicator()
        self.setNavigationTitlte(title: "Saved")
        self.addLeftBarButton()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "RecruitmentTableViewCell", bundle: nil), forCellReuseIdentifier: "RecruitmentTableViewCell")
        getDataFromServer()
    }

    //MARK: - GET data
    func getDataFromServer() {
        var type_post = "1"
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            type_post = "2"
        }
        activityIndicator?.startAnimating()
        ServiceManager.favoriteService.getFavoritePost(type_post: type_post, completion: {[unowned self] (posts, error) in
            self.activityIndicator?.stopAnimating()
            if let posts = posts {
                self.posts = posts
            }
            self.tableView.reloadData()
        })
    }

}

//MARK : - UITableViewDataSource
extension InforSavedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecruitmentTableViewCell") as! RecruitmentTableViewCell
        let postModel = posts[indexPath.row]
        cell.updateWithData(post: postModel)
        cell.selectionStyle = .none
        cell.deleteBlock = {[unowned self] in
            self.activityIndicator?.startAnimating()
            ServiceManager.favoriteService.deleteFavorite(type: "2", source_id: postModel.postID!, completion: {[unowned self] (resultCode) in
                self.activityIndicator?.stopAnimating()
                if resultCode == ErrorCode.success.rawValue {
                    self.showDialog(title: "Thành công", message: "Bạn đã xóa thông tin đã lưu thành công", handler: { (alert) in
                        self.posts.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    })
                }
                else {
                    self.showDialog(title: "Error", message: "Có lỗi khi xóa thông tin đã lưu, vui lòng thử lại", handler:nil)
                }
            })
        }
        return cell
    }
}

//MARK : - UITableViewDelegate
extension InforSavedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postModel = posts[indexPath.row]
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            if postModel.status == "2" { // Post is off
                // Do nothing
            }
            else {
                let candidateDetailViewController = CandidateDetailViewController(nibName: "CandidateDetailViewController", bundle: nil)
                candidateDetailViewController.postModel = postModel
                navigationController?.pushViewController(candidateDetailViewController, animated: true)
            }            
        }
        else {
            let jobDetailViewController = JobDetailViewController(nibName: "JobDetailViewController", bundle: nil)
            jobDetailViewController.postModel = postModel
            navigationController?.pushViewController(jobDetailViewController, animated: true)
        }
    }
}
