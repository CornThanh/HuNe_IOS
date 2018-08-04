//
//  AdsLocation.swift
//  MMY
//
//  Created by Apple on 5/22/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import CoreLocation

struct AdsLocation {
    static var name: String = ""
    static var description: String = ""
    static var branch: [String] = [String]()
    static var location = CLLocation()
    static var logo: String = ""
    static var gender: [Int] = [Int]()
    static var dates: [String] = [String]()
    
    static func clearData() {
        AdsLocation.name = ""
        AdsLocation.description = ""
        AdsLocation.branch = [String]()
        AdsLocation.logo = ""
        AdsLocation.location = CLLocation()
        AdsLocation.gender = [Int]()
        AdsLocation.dates = [String]()
    }
}
