//
//  FBLoginTableViewCell.swift
//  MMY
//
//  Created by Minh Tuan on 7/3/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class FBLoginTableViewCell: UITableViewCell {

    @IBOutlet weak var btnContentView: UIView!
    @IBOutlet weak var titleLB: UILabel!
    var loginWithFB: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        btnContentView.layer.cornerRadius = 5
        btnContentView.clipsToBounds = true
        btnContentView.layer.borderColor = UIColor(red: 24/255.0, green: 42/255.0, blue: 93/255.0, alpha: 1).cgColor
        btnContentView.layer.borderWidth = 1
        titleLB.font = UIFont(name: "Lato-Bold", size: 14)
        titleLB.textAlignment = .justified
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func onBtnLoginFB(_ sender: Any) {
        if let loginBlock = loginWithFB {
            loginBlock()
        }
    }
    
}
