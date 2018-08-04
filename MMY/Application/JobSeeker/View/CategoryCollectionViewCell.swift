

import UIKit
import Kingfisher

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLB: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateWithCategory(category: CategoryModel) {
        self.categoryTitleLB.text = category.name
        let url = URL(string: (category.icon?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed))!)
        self.categoryImageView.kf.setImage(with: url, placeholder: UIImage(named: "default_category_white"))
    }
}
