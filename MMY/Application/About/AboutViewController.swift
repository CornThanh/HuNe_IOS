//
//  AboutViewController.swift
//  MMY
//
//  Created by Blue R&D on 3/6/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupView()
    }
    
    func setupNavigationItem() {
        let dismiss = UIBarButtonItem(image: UIImage(named: "ic_close_white"), style: .done, target: self, action: #selector(dissmissAboutViewController))
        navigationItem.leftBarButtonItem = dismiss
        navigationItem.title = "About".localized()
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func dissmissAboutViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupView() {
        /*let label = UILabel(frame: CGRect.zero)
        let text = SettingsManager.shared.appDescription
        label.text = text
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(10)
            make.top.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
        }*/
        let text = SettingsManager.shared.appDescription
        let textView = UITextView(frame: .zero)
        textView.text = text
        textView.isEditable = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.dataDetectorTypes = .link
        
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(view)
        }
    }
}
