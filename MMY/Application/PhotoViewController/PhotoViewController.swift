
import UIKit
import Kingfisher
import SnapKit

class PhotoViewController: BaseViewController {

    var imageURLString: String?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isHidden = true
        self.addLeftBarButton()
        
        if let urlString = imageURLString {
            let url = URL(string: urlString)
            imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { [unowned self] (image, error, cacheType, url) in
                if let image = image {
                    let width = UIScreen.main.bounds.width
                    var height = (image.size.height)/(image.size.width)*width
                    if height > UIScreen.main.bounds.height - 64 {
                        height = UIScreen.main.bounds.height - 64
                    }
                    DispatchQueue.main.async {
                        self.imageView.isHidden = false
                        self.imageView.snp.makeConstraints({ (make) in
                            make.center.equalTo(self.view)
                            make.width.equalTo(width)
                            make.height.equalTo(height)
                        })
                    }
                }
                
            })
        }

    }
    

}
