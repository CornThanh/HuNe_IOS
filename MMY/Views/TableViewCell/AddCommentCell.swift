//
//  AddCommentCell.swift
//  MMY
//
//  Created by Minh tuan on 8/9/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class AddCommentCell: UITableViewCell {

    @IBOutlet weak var ratingView: TPFloatRatingView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentTF: UITextView!
    @IBOutlet weak var doneBtn: UIButton!
    
    var doneBlock: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ratingView.emptySelectedImage = UIImage(named: "star_empty")
        if Authenticator.shareInstance.getPostType() == PostType.findPeople {
            ratingView.fullSelectedImage = UIImage(named:"star_full_yellow")
        }
        else {
            ratingView.fullSelectedImage = UIImage(named:"star_full_red")
        }
        
        ratingView.contentMode =  .scaleAspectFill
        ratingView.maxRating = 5
        ratingView.minRating = 1
        ratingView.halfRatings = false
        ratingView.floatRatings = false
        ratingView.rating = 1
        ratingView.editable = true
        
        commentView.layer.cornerRadius = 20
        commentView.clipsToBounds = true
        commentView.layer.borderColor = Authenticator.shareInstance.getPostType()?.color().cgColor
        commentView.layer.borderWidth = 1
        commentTF.placeholder = "Nhận xét"
        
        doneBtn.layer.cornerRadius = doneBtn.frame.height/2
        doneBtn.clipsToBounds = true
        doneBtn.backgroundColor = Authenticator.shareInstance.getPostType()?.color()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onBtnDone(_ sender: Any) {
        if let doneBlock = doneBlock {
            doneBlock()
        }
    }
}
