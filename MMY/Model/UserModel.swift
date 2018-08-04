//
//  UserModel.swift
//  MMY
//
//  Created by Blue R&D on 2/23/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserModel: BaseModel {
//    var createdTime: Int?
    var created_at: String?
    var phone: String?
    var userId: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var avatar: AvatarModel?
    var avatarURL: String?
    var full_name: String?
    var gender: String? //1: female, 2: male
    var birthday: String?
    var address: String?
    var rating: CGFloat?
    var favourite_count: Int?
    var is_favourite: Bool?
    var status: Int?
    var remainCash: Int?
    var remainCoin: Int?
    
    required init?(json: JSON) {
        super.init(json: json)
        created_at      = json["created_at"].stringValue
        phone           = json["phone"].stringValue
        userId          = json["id"].stringValue
        firstName       = json["firstName"].stringValue
        lastName        = json["lastName"].stringValue
        email           = json["email"].stringValue
        avatarURL       = json["avatar"].stringValue
        full_name       = json["full_name"].stringValue
        gender          = json["sex"].stringValue
        birthday        = json["birthday"].stringValue
        address         = json["address"].stringValue
        rating          = CGFloat(json["rating"].floatValue)
        favourite_count = json["favourite_count"].intValue
        is_favourite    = json["is_favourite"].boolValue
        status          = json["status"].intValue
        remainCash      = json["balance_cash"].intValue
        remainCoin      = json["balance_coin"].intValue
    }
    
    func userName() -> String {
        if let full_name = full_name {
            return full_name
        }
        return ""
    }
    
    func makeParams() -> [String:Any] {
        var result = [String:Any]()
        result["firstName"] = firstName
        result["lastName"]  = lastName
        result["phone"]     = phone
        result["email"]     = email
        result["avatarId"]  = avatar?.mediaId
        return result
    }
    
    func copy() -> UserModel? {
        let clone           = UserModel(json: JSON(true))
        clone?.created_at      = created_at
        clone?.phone           = phone
        clone?.userId          = userId
        clone?.firstName       = firstName
        clone?.lastName        = lastName
        clone?.email           = email
        clone?.avatarURL       = avatarURL
        clone?.full_name       = full_name
        clone?.gender          = gender
        clone?.birthday        = birthday
        clone?.address         = address
        clone?.rating          = rating
        clone?.favourite_count = favourite_count
        clone?.is_favourite    = is_favourite
        clone?.status = status
        return clone
    }
}
