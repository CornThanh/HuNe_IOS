
import UIKit

class FavoriteUserCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var numberLikeLB: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var ratingView: TPFloatRatingView!
    @IBOutlet weak var isFavoriteButton: UIButton!
    var userModel : UserModel?
    
    
    var favoriteBlock: (() -> ())?
    var shareBlock: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImage.layer.cornerRadius = avatarImage.frame.size.height/2.0
        avatarImage.clipsToBounds = true
        
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            ratingView.emptySelectedImage = UIImage(named: "star_empty_yellow")
            ratingView.fullSelectedImage = UIImage(named:"star_full_yellow")
        }
        else {
            ratingView.emptySelectedImage = UIImage(named: "star_empty_red")
            ratingView.fullSelectedImage = UIImage(named:"star_full_red")
        }
        
        ratingView.contentMode =  .scaleAspectFill
        ratingView.maxRating = 5
        ratingView.minRating = 1
        ratingView.halfRatings = true
        ratingView.floatRatings = true
        ratingView.rating = 2
        ratingView.editable = false
        
        callBtn.layer.cornerRadius = callBtn.frame.height/2
        callBtn.clipsToBounds = true
        
    }
    
    @IBAction func onBtnShare(_ sender: Any) {
        if let shareBlock = self.shareBlock {
            shareBlock()
        }
    }
    
    @IBAction func onBtnFavorite(_ sender: Any) {
        if let favoriteBlock = self.favoriteBlock{
            favoriteBlock()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateWithUsermodel(userModel: UserModel) {
        self.userModel = userModel
        nameLB.text = userModel.full_name
        numberLikeLB.text = "\(userModel.favourite_count ?? 0)"
        if let rating =  userModel.rating{
            ratingView.rating = rating
        }
        else {
            ratingView.rating = 1
        }
        
        let avatarURL = userModel.avatarURL?.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: avatarURL!)
        avatarImage?.kf.setImage(with: url, placeholder: UIImage(named: "no_image_available"))
        if let is_favorite = userModel.is_favourite  {
            if is_favorite {
                self.isFavoriteButton.setImage(UIImage(named: "icon_heart_red"), for: .normal)
            }
            else {
                self.isFavoriteButton.setImage(UIImage(named: "icon_heart_red_empty"), for: .normal)
            }
        }
        
    }
    
    @IBAction func onBtnCall(_ sender: Any) {
        if let phoneNumber = self.userModel?.phone {
            guard let number = URL(string: "tel://" + phoneNumber) else {
                return
            }
            UIApplication.shared.openURL(number)
        }
    }


}
