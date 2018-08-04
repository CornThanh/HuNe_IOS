//
//  CollectionViewCell.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/13/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CollectionViewCell: NSObject {
    // MARK: -CollectionView Cell

    class MyAdViewCell : UICollectionViewCell{
        
        override init(frame:CGRect){
            super.init(frame:frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class MyHeaderView : UICollectionReusableView{
        
        override init(frame:CGRect){
            super.init(frame:frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class MyFooterView : UICollectionReusableView{
        
        override init(frame:CGRect){
            super.init(frame:frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    class LoadingCell : UICollectionViewCell {
        
        var activityIndicator: NVActivityIndicatorView?
        
        override init(frame:CGRect){
            super.init(frame:frame)
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

}
