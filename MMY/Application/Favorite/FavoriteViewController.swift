
import UIKit

class FavoriteViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var posts = [PostModel]()
    var favoritesUsers = [UserModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitlte(title: "FavoriteList".localized())
        addLeftBarButton()
        setupActivityIndicator()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "FavoriteUserCell", bundle: nil), forCellReuseIdentifier: "FavoriteUserCell")
        
        getDataFromServer()
        
    }
    
    //MARK: - GET data
    func getDataFromServer() {
        ServiceManager.favoriteService.getFavorite(type: "1") {[unowned self] (favorites, error) in
            if let favorites = favorites {
                self.favoritesUsers = favorites
                self.tableView.reloadData()
            }
        }
    }
}



//MARK : - UITableViewDataSource
extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteUserCell") as! FavoriteUserCell
        let user = favoritesUsers[indexPath.row]
        cell.updateWithUsermodel(userModel: user)
        cell.favoriteBlock = {[unowned self] in
            if let _ = user.is_favourite {
                // delete favorite
                self.activityIndicator?.startAnimating()
                ServiceManager.favoriteService.deleteFavorite(type: "1", source_id: (user.userId)!, completion: { (resultCode) in
                    self.activityIndicator?.stopAnimating()
                    if resultCode == ErrorCode.success.rawValue {
                        self.favoritesUsers.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                    else {
                        
                    }
                })
                
            }
        }
        cell.selectionStyle = .none
        return cell
    }
}

//MARK : - UITableViewDelegate
extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
