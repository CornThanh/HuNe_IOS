//
//  BaseModel.swift
//  MMY
//
//  Created by Apple on 8/4/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseModel {
    required init?(json: JSON) {
        guard json.error == nil else {
            return nil
        }
    }
}

