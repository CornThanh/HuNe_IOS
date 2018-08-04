

import UIKit
import Kingfisher

class RecruitmentTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLB: UILabel!
    @IBOutlet weak var userLB: UILabel!
    @IBOutlet weak var contentLB: UILabel!
    @IBOutlet weak var ratingView: TPFloatRatingView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var deleteBlock: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ratingView.emptySelectedImage = UIImage(named: "star_empty")
        ratingView.fullSelectedImage = UIImage(named:"star_full")
        ratingView.contentMode =  .scaleAspectFill
        ratingView.maxRating = 5
        ratingView.minRating = 0;
        ratingView.halfRatings = false
        ratingView.floatRatings = false
        ratingView.rating = 4
        ratingView.editable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func updateWithData(post: PostModel) {
        if let rating = post.rating {
            ratingView.rating = rating
        }
        categoryNameLB.text = post.category_title
        userLB.text = post.title
        contentLB.text = post.description
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            if post.status == "2" { // Post is off
                contentLB.text = "Đã tắt"
            }
        }
        
        let iconURL = Authenticator.shareInstance.getCategoryIconURL(id: post.category_id!)
        let url = URL(string: iconURL!)
        categoryImageView?.kf.setImage(with: url, placeholder: UIImage(named: "default_category_white"))
    }
    
    // Type: 1 is job, 2 is people
    func updateWithData(post: PostModel, type: Int) {
        if type == 1 {
            if let rating = post.rating {
                ratingView.rating = rating
            }
            categoryNameLB.text = post.category_title
            userLB.text = post.title
            contentLB.text = post.description
        }
        else {
            if let rating = post.rating {
                ratingView.rating = rating
            }
            if let categoryTitle = post.category_title, categoryTitle.characters.count > 0 {
                categoryNameLB.text = categoryTitle
            }
            else {
                categoryNameLB.text = Authenticator.shareInstance.getCategoryTitle(id: post.category_id!)
            }
            
            userLB.text = post.userModel?.full_name
            contentLB.text = post.description
        }
        
        let iconURL = Authenticator.shareInstance.getCategoryIconURL(id: post.category_id!)
        let url = URL(string: iconURL!)
        categoryImageView?.kf.setImage(with: url, placeholder: UIImage(named: "default_category_white"))
    }
    
    @IBAction func onBtnDelete(_ sender: Any) {
        if let deleteBlock = self.deleteBlock{
            deleteBlock()
        }
    }
    
}
