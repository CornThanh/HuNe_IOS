//
//  SplashScreenController.swift
//  MMY
//
//  Created by Blue R&D on 3/2/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SnapKit
import Firebase
import GoogleMaps
import GooglePlaces
import Localize_Swift

class SplashScreenController: UIViewController {
    let activityIndicator = NVActivityIndicatorView(frame: CGRect.zero, type: .ballSpinFadeLoader, color: .white, padding: 0)
//    let backgroundImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.addSubview(backgroundImageView)
//        backgroundImageView.snp.makeConstraints { (make) in
//            make.size.equalTo(view)
//            make.center.equalTo(view)
//        }
        view.backgroundColor = hexStringToUIColor(hex: "#33ccffff")
//        backgroundImageView.image = UIImage(named: "ic_login_background")

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.activityIndicator.startAnimating()
            GMSServices.provideAPIKey("AIzaSyAQb2DWUSukaD9C0rd5ZbdP3eFzyaU3BgM")
//            GMSPlacesClient.provideAPIKey("AIzaSyAQb2DWUSukaD9C0rd5ZbdP3eFzyaU3BgM")
            GMSPlacesClient.provideAPIKey("AIzaSyCDKXUPnKcx8iG6bUMPBNdIRDPFbVDWvHI")
        }
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            (UIApplication.shared.delegate as? AppDelegate)?.makeCenterView(true)
        }
    }

    func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.characters.count) != 8) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            blue: CGFloat((rgbValue & 0xFF00) >> 8) / 255.0,
            alpha:CGFloat(rgbValue & 0xFF)/255.0
        )
    }
}
