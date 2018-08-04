//
//  TableViewCell.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/13/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Kingfisher
import Localize_Swift

class TableViewCell {
    
    
    class LoadingCell : UITableViewCell {
        
        var activityIndicator: NVActivityIndicatorView?
        
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0), type: .ballSpinFadeLoader, color: UIColor.black, padding: 0)
            if let activityIndicator = activityIndicator {
                contentView.addSubview(activityIndicator)
                activityIndicator.snp.makeConstraints({ (make) in
                    make.center.equalTo(contentView)
                })
            }
            
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // MARK: - Menu Cell
    class MenuCell : UITableViewCell {
        
        var icon: UIImageView?
        var title: UILabel?
        var detail: UILabel?
        var hasIcon: Bool?
        
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            hasIcon = false
            icon = UIImageView()
            icon?.contentMode = .scaleAspectFill
            icon?.clipsToBounds = true
            if let newsImage = icon {
                contentView.addSubview(newsImage)
            }
            icon?.snp.makeConstraints({ (make) in
                make.left.equalTo(contentView).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.height.equalTo(40)
                make.width.equalTo(40)
                make.bottom.equalTo(contentView).offset(-10)
            })
            
            title = UILabel()
            if let title = title {
                title.numberOfLines = 0
                title.font = UIFont.preferredFont(forTextStyle: .body)
                contentView.addSubview(title)
            }
            title?.snp.makeConstraints({ (make) in
                make.left.equalTo((icon?.snp.right)!).offset(10)
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-50)
                make.bottom.equalTo(contentView).offset(-10)
            })
            
            detail = UILabel()
            if let detail = detail {
                contentView.addSubview(detail)
                detail.font = UIFont.preferredFont(forTextStyle: .body)
            }
            detail?.snp.makeConstraints({ (make) in
                make.top.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView).offset(-10)
            })
        }
        
        override func updateConstraints() {
            super.updateConstraints()
            icon?.snp.updateConstraints({ (make) in
                make.height.equalTo(40)
                if hasIcon! {
                    make.width.equalTo(40)
                } else {
                    make.width.equalTo(0)
                }
            })
        }
        
//        func populateData(with data: MenuItemProtocol) {
//            title?.text = data.title()?.localized()
//            detail?.text = data.detail()?.localized()
//
//            if let imageUrl = data.iconUrl() {
//                let url = URL(string: imageUrl)
//                icon?.kf.setImage(with: url)
//                
//                hasIcon = true
//            } else {
//                hasIcon = false
//            }
//            
//            let hasIndicator = data.hasIndicator()
//            accessoryType = hasIndicator ? .disclosureIndicator : .none
//            
//        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

