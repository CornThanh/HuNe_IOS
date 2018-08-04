//
//  SignInModel.swift
//  MMY
//
//  Created by Blue R&D on 2/23/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class SignInModel: BaseModel {
    var accessToken: String?
    var created_at: String?
    var user: UserModel?
    var userId: String? {
        return user?.userId
    }
    var verified: Bool {
        return user?.status == 2
    }
    
    required init?(json: JSON) {
        super.init(json: json)
        accessToken = json["token"].string
        created_at = json["created_at"].string
        user        = UserModel(json: json)
    }
}
