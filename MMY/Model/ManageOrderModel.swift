//
//  ManageOrderModel.swift
//  MMY
//
//  Created by Apple on 7/29/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import SwiftyJSON

class ManageOrderModel: BaseModel {
    
    var order_id: String?
    var product_id: String?
    var seller_id: Int?
    var buyer_id: Int?
    var price: Int?
    var quantity: Int?
    var amount: Int?
    var status: Int?
    var buyer_address: String?
    var buyer_name: String?
    var buy_product: String?
    var type: Int?
    var product_type: Int?
    var phone: String?
    
    required init?(json: JSON) {
        super.init(json: json)
        guard json.error == nil else {
            return
        }
            order_id = json["order_id"].stringValue
            product_id = json["product_id"].stringValue
            seller_id = json["seller_id"].intValue
            buyer_id = json["buyer_id"].intValue
            price = json["price"].intValue
            quantity = json["quantity"].intValue
            amount = json["amount"].intValue
            status = json["status"].intValue
            buyer_address = json["buyer_address"].stringValue
            buyer_name = json["buyer_name"].stringValue
            buy_product = json["buy_product"].stringValue
            type = json["type"].intValue
            product_type = json["product_type"].intValue
            phone = json["phone"].stringValue
        
        }
    }
