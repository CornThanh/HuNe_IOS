//
//  ResponseBuyViewController.swift
//  MMY
//
//  Created by Apple on 7/17/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class ResponseBuyViewController: UIViewController {
    @IBOutlet weak var lbResponse: UILabel!
    @IBOutlet weak var btCheckOrder: UIButton!
    @IBOutlet weak var btBuyContinue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        
        lbResponse.text = "ResponseBuyViewController1".localized()
        setupButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton()
    }
    
    func setupButton() {
        btCheckOrder.backgroundColor = UIColor(hexString: "00AB4E")
        btCheckOrder.layer.cornerRadius = self.btCheckOrder.frame.size.height/2
        btCheckOrder.setTitle("ResponseBuyViewController3".localized(), for: .normal)
        
        btBuyContinue.backgroundColor = UIColor(hexString: "00AB4E")
        btBuyContinue.layer.cornerRadius = self.btCheckOrder.frame.size.height/2
        btBuyContinue.setTitle("ResponseBuyViewController2".localized(), for: .normal)
    }
    
    @IBAction func actionCheckOrder(_ sender: Any) {
        self.navigationController?.pushViewController(CheckOrderViewController(), animated: true)
    }
    
    @IBAction func actionBuyContinue(_ sender: Any) {

        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: ProductMartViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
}
