//
//  CoinTransactionHistoryViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/7/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class CoinTransactionHistoryViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        title = "History".localized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
