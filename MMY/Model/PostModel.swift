
//  PostModel.swift
//  MMY
//
//  Created by Blue R&D on 2/28/17.

import UIKit
import SwiftyJSON
import CoreLocation
import Localize_Swift

class PostModel: BaseModel {
    var categoriesId: [String]?
    var postType: PostType?
    var postID: String?
    var category: [CategoryModel]?
    var category_id: String?
    var category_title: String? {
        if Localize.currentLanguage() == "vi" {
            return category_title_vi
        }
        return category_title_en
    }
    var category_title_vi: String?
    var category_title_en: String?
    var category_parent_id: String?
    var category_parent_title: String? {
        if Localize.currentLanguage() == "vi" {
            return category_parent_title_vi
        }
        return category_parent_title_en
    }
    var category_parent_title_vi: String?
    var category_parent_title_en: String?
    var quantity: String?
    var title: String?
    var description: String?
    var location: CLLocation?
    var address: String?
    var amount: Int?
    var userId: String?
    var userModel: UserModel?
    var rating: CGFloat?
    var thumbnail: String?
    var images: [String]?
    var start_date: String?
    var end_date: String?
    var _salary: String?
    var salary_type: String?
    var status: String?
    var full_name: String?
    
    var salary: String {
        guard let salary = _salary else {
            return ""
        }
        if let period = TempPostModel.PaymentPeriod(rawValue: salary_type!) {
            if let intSalary = Int(salary) {
                return intSalary.stringWithSepator + "/" + period.title()
            }
            return salary + "/" + period.title()
        }
        return salary
    }
    
    var salaryWithoutPeriod: String {
        guard let salary = _salary else {
            return ""
        }
        if let intSalary = Int(salary) {
            return intSalary.stringWithSepator
        }
        return salary
    }
    
    required init?(json: JSON) {
        guard json.error == nil else {
            return nil
        }
        super.init(json: json)
        print(json)
        let typeString = json["type"].stringValue
        if typeString == "1" {
            postType = .findPeople
        }
        else {
            postType = .findJob
        }
        title       = json["title"].string
        postID      = json["id"].stringValue
        description = json["description"].string
        address     = json["address"].string
        amount      = json["quantity"].int
        _salary     = json["salary"].string
        salary_type = json["salary_type"].stringValue
        userId      = json["user_id"].stringValue
        rating      = CGFloat(json["rating"].floatValue)
        userModel   = UserModel(json: json["user"])
        location    = CLLocation(latitude: CLLocationDegrees(json["latitude"].floatValue), longitude: CLLocationDegrees(json["longitude"].floatValue))
        category_id = json["category_id"].stringValue
        category_parent_id = json["category_parent_id"].stringValue
        thumbnail   = json["thumbnail"].stringValue
        images = json["images"].arrayObject as? [String]
        category = [CategoryModel]()
        let categoryModel = CategoryModel(json: json)
        categoryModel?.categoryId = category_id
        category?.safeAppend(categoryModel)
        categoriesId?.safeAppend(category_id)
        category_title_en = json["category"]["name_en"].stringValue
        category_title_vi = json["category"]["name_vi"].stringValue
        category_parent_title_vi = json["parent_category"]["name_vi"].stringValue
        category_parent_title_en = json["parent_category"]["name_en"].stringValue
        start_date = json["start_date"].stringValue
        end_date = json["end_date"].stringValue
        status = json["status"].stringValue
        full_name = json["user"]["full_name"].stringValue
        quantity = json["quantity"].stringValue
    }
}

struct Number {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "." // or possibly "." / ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}
extension Integer {
    var stringWithSepator: String {
        return Number.withSeparator.string(from: NSNumber(value: hashValue)) ?? ""
    }
}
