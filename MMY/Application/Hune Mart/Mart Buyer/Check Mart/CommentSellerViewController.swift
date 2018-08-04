//
//  CommentSellerViewController.swift
//  MMY
//
//  Created by Apple on 7/19/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class CommentSellerViewController: UIViewController {

    @IBOutlet weak var viewStart: TPFloatRatingView!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btDone: UIButton!
    
    var orderData: OrderModel?
    
    init(orderData: OrderModel) {
        super.init(nibName: "CommentSellerViewController", bundle: nil)
        self.orderData = orderData
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error loab nib")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "Comment".localized()
        setupUI()
        setupStar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        tvComment.layer.cornerRadius = 10.0
        tvComment.layer.borderWidth = 1.0
        
        btDone.layer.cornerRadius = btDone.frame.size.height/2
        btDone.backgroundColor = UIColor(hexString: "00AB4E")
        btDone.setTitle("Done".localized(), for: .normal)
    }
    
    func setupStar() {
        viewStart.emptySelectedImage = UIImage(named: "star_empty_yellow")
        viewStart.fullSelectedImage = UIImage(named:"star_full_yellow")
        viewStart.contentMode =  .scaleAspectFill
        viewStart.maxRating = 5
        viewStart.minRating = 1
        viewStart.halfRatings = false
        viewStart.floatRatings = false
        viewStart.rating = 1
        viewStart.editable = true
    }
    
    @IBAction func actionDone(_ sender: Any) {
        ServiceManager.martService.postComment(orderData!, rating: Int(viewStart.rating), comment: tvComment.text) { (result) in
            switch result {
            case .success( _):
                self.showDialog(title: "HuNe Mart", message: "CommentSuccess".localized(), handler: { (action) in
                    self.navigationController?.popToViewController( (self.navigationController?.viewControllers[3])!, animated: true)
                })
            case .failure(let error):
                print("error", error.errorCode)
                self.showDialog(title: "HuNe Mart", message: "CommentError".localized(), handler: nil)
            }
        }
    }
}
