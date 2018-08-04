//
//  CandidateHeaderCell.swift
//  MMY
//
//  Created by Minh tuan on 8/9/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class CandidateHeaderCell: UITableViewCell {
    var addTaskBlock: (() -> ())? {
        didSet {
            vCandidate.addTaskBlock = addTaskBlock
        }
    }
    var favoriteBlock: (() -> ())? {
        didSet {
            vCandidate.favoriteBlock = favoriteBlock
        }
    }
    var shareBlock: (() -> ())? {
        didSet {
            vCandidate.shareBlock = shareBlock
        }
    }

    @IBOutlet weak var vCandidate: CandidateView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func updateWithUsermodel(userModel: UserModel, postModel: PostModel? = nil) {
        vCandidate.updateWithUsermodel(userModel: userModel, postModel: postModel)
    }

}
class TaskCandidateView: CandidateView {

    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbStatus: UILabel!

    func updateData(_ task: TaskModel) {
        ivStatus.image = task.status.icon
        lbStatus.text = task.status.description
        if let user = task.candidate {
            updateWithUsermodel(userModel: user)
        }
    }
}

class CandidateView: UIView {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var numberLikeLB: UILabel!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var ratingView: TPFloatRatingView?
    @IBOutlet weak var isFavoriteButton: UIButton?
    @IBOutlet weak var btnCall: UIButton?
    @IBOutlet weak var btnAddTask: UIButton!

    var addTaskBlock: (() -> ())?
    
    var favoriteBlock: (() -> ())?
    var shareBlock: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImage.layer.cornerRadius = avatarImage.frame.size.height/2.0
        avatarImage.clipsToBounds = true

        if let ratingView = ratingView {
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
        }
        if let btnCall = btnCall {
            btnCall.layer.cornerRadius = btnCall.bounds.size.height / 2
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
    
    func updateWithUsermodel(userModel: UserModel, postModel: PostModel? = nil) {
        nameLB.text = userModel.full_name
        numberLikeLB.text = "\(userModel.favourite_count ?? 0)"
        if let ratingView = ratingView {
            if let rating = userModel.rating{
                ratingView.rating = rating
            }
            else {
                ratingView.rating = 1
            }
        }

        let avatarStr = postModel?.thumbnail ?? userModel.avatarURL
        let avatarURL = avatarStr?.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: avatarURL!)
        avatarImage?.kf.setImage(with: url, placeholder: UIImage(named: "no_image_available"))
        if let is_favorite = userModel.is_favourite  {
            if is_favorite {
                self.isFavoriteButton?.setImage(UIImage(named: "icon_heart_red"), for: .normal)
            }
            else {
                self.isFavoriteButton?.setImage(UIImage(named: "icon_heart_red_empty"), for: .normal)
            }
        }
    }

    @IBAction func handleBtnAddTaskTouched(_ sender: Any) {
        addTaskBlock?()
    }
}
