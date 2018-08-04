
import UIKit
import Kingfisher

class CandidateDetailCell: UITableViewCell {

    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var genderLB: UILabel!
    @IBOutlet weak var dateOfBirthLB: UILabel!
    @IBOutlet weak var typeLB: UILabel!
    @IBOutlet weak var descriptionLB: UILabel!
    @IBOutlet weak var imageView1: UIView!
    @IBOutlet weak var imageView2: UIView!
    @IBOutlet weak var imageView3: UIView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    var userModel: UserModel?
    var postModel: PostModel?
    
    var callBlock: (() -> ())?
    var tapImage1Block: (() -> ())?
    var tapImage2Block: (() -> ())?
    var tapImage3Block: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        callBtn.layer.cornerRadius = callBtn.frame.height/2
        callBtn.clipsToBounds = true
        
        descriptionLB.text = ""
        
        imageView1.layer.borderWidth = 1
        imageView1.layer.borderColor = Authenticator.shareInstance.getPostType()?.color().cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView1(_:)))
        imageView1.addGestureRecognizer(tap)
        imageView1.isUserInteractionEnabled = true
        
        imageView2.layer.borderWidth = 1
        imageView2.layer.borderColor = Authenticator.shareInstance.getPostType()?.color().cgColor
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView2(_:)))
        imageView2.addGestureRecognizer(tap2)
        imageView2.isUserInteractionEnabled = true
        
        imageView3.layer.borderWidth = 1
        imageView3.layer.borderColor = Authenticator.shareInstance.getPostType()?.color().cgColor
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.tapImageView3(_:)))
        imageView3.addGestureRecognizer(tap3)
        imageView3.isUserInteractionEnabled = true
        
    }

    func tapImageView1(_ sender: UITapGestureRecognizer) {
        print("tapImageView1")
        if let block = self.tapImage1Block {
            block()
        }
        
    }
    
    func tapImageView2(_ sender: UITapGestureRecognizer) {
        print("tapImageView2")
        if let block = self.tapImage2Block {
            block()
        }
    }
    
    func tapImageView3(_ sender: UITapGestureRecognizer) {
        print("tapImageView3")
        if let block = self.tapImage3Block {
            block()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update(userModel: UserModel, postModel: PostModel) {
        self.userModel = userModel
        self.postModel = postModel
        if userModel.gender == "1" {
             genderLB.text = "Nữ"
        }
        else {
            genderLB.text = "Nam"
        }
        
        dateOfBirthLB.text = userModel.birthday
        typeLB.text = postModel.category_title!
        descriptionLB.text = postModel.description
        if postModel.images?.count == 1 {
            let url = URL(string: (postModel.images?[0])!)
            image1.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        else if postModel.images?.count == 2 {
            let url = URL(string: (postModel.images?[0])!)
            image1.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
            let url2 = URL(string: (postModel.images?[1])!)
            image2.kf.setImage(with: url2, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
        }
        else if postModel.images?.count == 3 {
            let url = URL(string: (postModel.images?[0])!)
            image1.kf.setImage(with: url, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
            let url2 = URL(string: (postModel.images?[1])!)
            image2.kf.setImage(with: url2, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
            let url3 = URL(string: (postModel.images?[2])!)
            image3.kf.setImage(with: url3, placeholder: UIImage(named : "no_image_available") , options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    @IBAction func onBtnCall(_ sender: Any) {
        if let callBlock = self.callBlock {
            callBlock()
        }
    }

}
