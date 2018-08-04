//
//  AdsNotifi.swift
//  MMY
//
//  Created by Apple on 5/23/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import CoreLocation

class AdsNotifi {
    static var name = ""
    static var description = ""
    static var branch = [String]()
    static var start_hour = ""
    static var end_hour = ""
    static var start_date = ""
    static var end_date = ""
    static var total_coupon = ""
    static var discount = ""
    static var price = ""
    static var logo = ""
    static var locationMap = CLLocation()
    static var gender = [Int]()
    static var location = [Int]()
    
    static func clearData() {
        AdsNotifi.name = ""
        AdsNotifi.description = ""
        AdsNotifi.branch = [String]()
        AdsNotifi.logo = ""
        AdsNotifi.location = [Int]()
        AdsNotifi.gender = [Int]()
        AdsNotifi.branch = [String]()
        AdsNotifi.start_hour = ""
        AdsNotifi.end_hour = ""
        AdsNotifi.start_date = ""
        AdsNotifi.end_date = ""
        AdsNotifi.total_coupon = ""
        AdsNotifi.discount = ""
        AdsNotifi.price = ""
        AdsNotifi.locationMap = CLLocation()
        AdsNotifi.gender = [Int]()

    }
}
