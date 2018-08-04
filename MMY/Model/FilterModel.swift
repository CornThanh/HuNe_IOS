//
//  FilterModel.swift
//  MMY
//
//  Created by Blue R&D on 2/21/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class FilterModel {
    var postType: PostType
    var categories: [CategoryModel]?
    var geoLocation: CLLocation?
    var radius: CGFloat?
    var isSubCategory: Bool?
    
    init() {
        postType = .findPeople
        isSubCategory = false
    }
    
    func makeParams() -> [String: Any] {
        var result = [String: Any]()
//        result["type"]          = postType.rawValue
//        case employee = 1
//        case job = 2
        if postType == .findPeople {
            result["type"] = 2
        }
        else {
            result["type"] = 1
        }
        if isSubCategory! {
            result["category_id"]      = getCategoriesId()
        }
        else {
            result["category_parent_id"]      = getCategoriesId()
        }
        
        result["latitude"]      = geoLocation?.coordinate.latitude
        result["longitude"]     = geoLocation?.coordinate.longitude
        if let radius = radius {
            result["radius"]    = radius/1000    // meter to Km
        }
        return result
    }
    
    func getCategoriesId() -> String {
        var result: String = ""
        if let categories = categories {
            if categories.count > 0 {
                let category = categories[0]
                result = category.categoryId!
            }
//            for category in categories {
//                if result.characters.count == 0 {
//                    result.append(",\(category.categoryId)")
//                }
//                else {
//                    result.append(category.categoryId!)
//                }
//            }
        }
        return result
        
    }
}
