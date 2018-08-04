//
//  HuneAdsViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/22/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import Eureka

class HuneAdsViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addLeftBarButton()
        let section = Section()
        let rowBanner = LabelRow().cellSetup { (cell, row) in
            row.title = "BannerAds".localized()
            cell.imageView?.image = UIImage(named: "ic_ads_banner")
            //cell.layoutMargins.left = 32
        }
        rowBanner.onCellSelection { (_, _) in
            let vc = BannerAdsViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowBanner)

        let rowPlace = LabelRow().cellSetup { (cell, row) in
            row.title = "PlaceAds".localized()
            cell.imageView?.image = UIImage(named: "ic_ads_location")
            //cell.layoutMargins.left = 32
        }
        rowPlace.onCellSelection { (_, _) in
            let vc = PlaceAdsViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowPlace)

        let rowNoti = LabelRow().cellSetup { (cell, row) in
            row.title = "NotiAds".localized()
            cell.imageView?.image = UIImage(named: "ic_ads_notification")
           // cell.layoutMargins.left = 32
        }
        rowNoti.onCellSelection { (_, _) in
            let vc = NotiAdsViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowNoti)
        let rowManage = LabelRow().cellSetup { (cell, row) in
            row.title = "AdsManagement".localized().uppercased()
            cell.imageView?.image = UIImage(named: "ic_hune_ads")
        }
        rowManage.onCellSelection { (_, _) in
            let vc = AdsManagementViewController.loadFromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        section.append(rowManage)
        form +++ section

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
