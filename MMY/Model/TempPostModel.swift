//
//  PostModel.swift
//  MMY
//
//  Created by Blue R&D on 2/27/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class TempPostModel {

    var postType: PostType
    var categories: [CategoryModel]?
    var title: String?
    var description: String?
    var location: CLLocation?
    var address: String?
    var amount: Int
    var salary: String?
    var paymentPeriod: PaymentPeriod
    var rating: CGFloat?
    var start_date: String?
    var end_date: String?
    var avatar: UIImage?
    var images = [UIImage]()
    var postID : String?
    
    init() {
        postType        = .findJob
        paymentPeriod   = .hour
        amount          = 1
    }
    
    func makeParams() -> [String:Any] {
        var result              = [String:Any]()
        result["type"]          = postType.rawValue
        if categories?.count == 2 {
            result["category_parent_id"] = categories?[0].categoryId
            result["category_id"] = categories?[1].categoryId
        }
        else if categories?.count == 1 {
            result["category_parent_id"] = categories?[0].categoryId
        }
        result["rating"] = rating
        result["quantity"] = amount
        result["address"] = address
        result["latitude"] = location?.coordinate.latitude
        result["longitude"] = location?.coordinate.longitude
        if let salary = salary {
            result["salary"] = salary
            result["salary_type"] = paymentPeriod.rawValue
        }
        
        result["start_date"] = start_date
        result["end_date"] = end_date
        result["description"] = description
        result["title"] = title
        return result
    }
    
    private func makeCategoryIdArray() -> [String]? {
        guard let categories = categories else {
            return nil
        }
        var result = [String]()
        for category in categories {
            result.safeAppend(category.categoryId)
        }
        return result
    }
    
    func makeSalaryString() -> String? {
        guard let salary = salary else {
            return nil
        }
        return salary + "/" + paymentPeriod.rawValue
    }
    
    func validate() -> Bool {
        guard let title = title,
            let description = description,
            let _ = location,
            let categories = categories else {
                return false
        }
        
        guard title.characters.count > 0
            && description.characters.count > 0
            && categories.count > 0 else {
                return false
        }
        return true
    }
}

//MARK: - Payment Period
extension TempPostModel {
    enum PaymentPeriod: String {
        case hour   = "1"
        case day    = "2"
        case week   = "3"
        case month  = "4"
        case time   = "5"
        case agreement   = "6"
        
        static let allValues = [hour, day, week, month, time, agreement]
        
        func title() -> String {
            switch self {
            case .day:  return "Day".localized()
            case .week: return "Week".localized()
            case .month: return "Month".localized()
            case .time: return "Time".localized()
            case .hour: return "Hour".localized()
            case .agreement: return "Agreement".localized()
            }
        }
        static func allTitles() -> [String] {
            return ["Hour".localized(), "Day".localized(), "Week".localized(), "Month".localized(), "Time".localized(), "Agreement".localized()]
        }
    }
}
