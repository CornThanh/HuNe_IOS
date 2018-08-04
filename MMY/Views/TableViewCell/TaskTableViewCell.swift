

import UIKit
import Kingfisher

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbCost: UILabel!
    @IBOutlet weak var ratingView: TPFloatRatingView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbStartTitle: UILabel!
    @IBOutlet weak var lbStartValue: UILabel!
    @IBOutlet weak var lbEndTitle: UILabel!
    @IBOutlet weak var lbEndValue: UILabel!

    @IBOutlet weak var lbNotRating: UILabel! {
        didSet {
            lbNotRating.text = "NotRating".localized()
        }
    }
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

    func updateWithData(_ task: TaskModel) {
        guard let post = task.post else {
            return
        }

        if let rating = post.rating, rating > 0 {
            ratingView.rating = rating
            ratingView.isHidden = false
        }
        else {
            ratingView.isHidden = true
        }
        lbNotRating.isHidden = !ratingView.isHidden

        lbTitle.text = task.name
        lbAddress.text = post.address

        lbCost.text = task.cost.stringWithSepator + " " + "VND".localized()
        lbStartValue.text = (task.startHour ?? "00:00") + " - " + (task.startDate ?? "")
        lbEndValue.text = (task.endHour ?? "00:00") + " - " + (task.endDate ?? "")

        ivStatus.image = task.status.icon
        lbStatus.text = task.status.description
    }
    
    @IBAction func onBtnDelete(_ sender: Any) {
        if let deleteBlock = self.deleteBlock{
            deleteBlock()
        }
    }
    
}
