

import UIKit

class JobDetailCell: UITableViewCell {

    @IBOutlet weak var typeLB: UILabel!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var descrtiptionLB: UILabel!
    @IBOutlet weak var quantityLB: UILabel!
    @IBOutlet weak var placeLB: UILabel!
    @IBOutlet weak var salaryLB: UILabel!
    @IBOutlet weak var startDateLB: UILabel!
    @IBOutlet weak var endDateLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func updateCellwithData(postModel: PostModel) {
        typeLB.text = postModel.category_parent_title! + " - " + postModel.category_title!
        titleLB.text = postModel.title
        descrtiptionLB.text = postModel.description
        quantityLB.text = "\(postModel.amount ?? 0)"
        placeLB.text = postModel.address
        if placeLB.text?.characters.count == 0 {
            placeLB.text = ""
        }
        salaryLB.text = postModel.salary
        startDateLB.text = postModel.start_date
        endDateLB.text = postModel.end_date
    }
    
}
