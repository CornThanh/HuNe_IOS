//
//  ErrorModel.swift
//  MMY
//
//  Created by Blue R&D on 2/15/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

class ErrorModel {
    var httpCode: Int
    var errorCode: ErrorCode
    var errorMessage: String = ""
    
    init(errorCode: ErrorCode, httpCode:Int = 200,  errorMessage: String? = nil) {
        self.httpCode = httpCode
        self.errorCode = errorCode
        self.errorMessage = errorMessage ?? ""
    }
    
    init(json: JSON) {
        if json.error == nil {
            httpCode     = json["statusCode"].intValue
            errorMessage = json["msg"].string ?? ""
            let code     = ErrorCode(rawValue: json["code"].intValue)
            errorCode = code == nil ? .invalidData : code!
        } else {
            httpCode = 200
            errorCode = .invalidData
        }
    }
}
