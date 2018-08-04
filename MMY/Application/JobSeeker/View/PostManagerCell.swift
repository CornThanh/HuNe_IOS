//
//  PostManagerCell.swift
//  MMY
//
//  Created by Minh tuan on 8/18/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class PostManagerCell: UITableViewCell {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    var status = true
    
    var setStatusBlock: (() -> ())?
    var editBlock :(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func updateWithPost(post: PostModel) {
        titleLB.text = Authenticator.shareInstance.getCategoryTitle(id: post.category_id!)
//        titleLB.text = post.title
    }
    
    @IBAction func onBtnStatus(_ sender: Any) {
        if let setStatusBlock = self.setStatusBlock {
            setStatusBlock()
        }
    }
    
    @IBAction func onBtnEdit(_ sender: Any) {
        if let editBlock = self.editBlock {
            editBlock()
        }
    }
    
}
