//
//  AllReadAlertView.swift
//  MMY
//
//  Created by Minh tuan on 7/29/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class AllReadAlertView: UIView {
    
    var donePress : (() -> ())?
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    
    class func instanceFromNib() -> AllReadAlertView {
        
        let view = UINib(nibName: "AllReadAlertView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AllReadAlertView
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.doneBtn.layer.cornerRadius = 20
        view.doneBtn.layer.borderWidth = 1
        view.doneBtn.layer.borderColor = UIColor(colorLiteralRed: 51/255.0, green: 204/255.0, blue: 255/255.0, alpha: 1).cgColor
        view.doneBtn.clipsToBounds = true
        return view
        
    }
    
    @IBAction func onBtnDone(_ sender: Any) {
        if let donePress = donePress {
            donePress()
        }
    }

}
