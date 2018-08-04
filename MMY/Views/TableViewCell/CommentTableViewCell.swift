//
//  CommentTableViewCell.swift
//  MMY
//
//  Created by Minh tuan on 8/9/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var ratingView: TPFloatRatingView!
    @IBOutlet weak var contentLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ratingView.emptySelectedImage = UIImage(named: "star_empty")
        ratingView.fullSelectedImage = UIImage(named:"star_full")
        ratingView.contentMode =  .scaleAspectFill
        ratingView.maxRating = 5
        ratingView.minRating = 1
        ratingView.halfRatings = false
        ratingView.floatRatings = false
        ratingView.rating = 1
        ratingView.editable = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func update(vote: VoteModel) {
        if let rate = vote.rate {
            ratingView.rating = rate
        }
        userNameLB.text = vote.nameUserVote
        contentLB.text = vote.comment
    }
    
}
