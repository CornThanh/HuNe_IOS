//
//  ProfileHeaderView.swift
//  MMY
//
//  Created by Blue R&D on 3/9/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class ProfileHeaderView: UIView, UIGestureRecognizerDelegate {
    
    //MARK: - Properties
    var imageSize = 100
    var backImageView = UIImageView(frame: CGRect.zero)
    var blurView: UIVisualEffectView?
    var imageView = UIImageView(frame: CGRect.zero)
    var nameLabel = UILabel(frame: CGRect.zero)
    var imageTouchedCallback: (()->Void)?
    var headerTouchedCallback: (()->Void)?
    var cornerRadius : Int {
        return imageSize/2
    }
    
    //MARK: - Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        createBackImageView()
        //createBlurView()
        createImageView()
        createLabel()
    }
    
    func createBackImageView() {
        addSubview(backImageView)
        backImageView.contentMode = .scaleToFill
        backImageView.image = UIImage(named: "background_profile")
        backImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(self)
        }
    }
    
    func createBlurView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        safeAddSubview(blurView)
        blurView?.snp.makeConstraints({ (make) in
            make.center.equalTo(self)
            make.width.equalTo(self)
            make.height.equalTo(self)
        })
    }
    
    func createImageView() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "no_image_available")
        imageView.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(20)
        }
        imageView.layer.cornerRadius = CGFloat(cornerRadius)
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.white.cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    func createLabel() {
        nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        nameLabel.text = " "
        nameLabel.textColor = UIColor.black
        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(imageView.snp.bottom).offset(5)
        }
    }
    
    func setImage(with urlString: String?) {
        if let urlString = urlString {
            let url = URL(string: urlString)
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "no_image_available"))
            //backImageView.kf.setImage(with: url)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        imageView.snp.updateConstraints() { (make) in
            make.width.equalTo(imageSize)
            make.height.equalTo(imageSize)
        }
        imageView.layer.cornerRadius = CGFloat(cornerRadius)
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        imageTouchedCallback?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        headerTouchedCallback?()
    }
}
