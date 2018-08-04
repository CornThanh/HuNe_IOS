
import UIKit

class JodHeaderCell: UITableViewCell {
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var isFavoriteButton: UIButton!

    var callBlock: (() -> ())?
    var favoriteBlock: (() -> ())?
    var shareBlock: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        callBtn.layer.cornerRadius = callBtn.frame.height/2
        callBtn.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func onBtnCall(_ sender: Any) {
        if let callBlock = self.callBlock {
            callBlock()
        }
    }
    
    func updateWithUsermodel(userModel: UserModel) {
        nameLB.text = userModel.full_name
        if let is_favorite = userModel.is_favourite  {
            if is_favorite {
                self.isFavoriteButton.setImage(UIImage(named: "icon_heart_red"), for: .normal)
            }
            else {
                self.isFavoriteButton.setImage(UIImage(named: "icon_heart_red_empty"), for: .normal)
            }
        }
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
}
