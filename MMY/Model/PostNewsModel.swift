//
//  PostNewsModel.swift
//  MMY
//
//  Created by Apple on 7/25/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation

class PostNewsModel {
    var name: String?
    var type: Int = 1
    var product_type: Int = 1
    var price: String?
    var description: String?
    var unit: Int?
    var quantity: Int?
    var end_date: String?
    var address: String?
    var transport_fee: String?
    var status: Int?
    var thumbnail: String?
    var image1: String?
    var image2: String?
    var image3: String?
    var dataThumbnail: UIImage?
    var arrImage = [UIImage]()
    var lat: String?
    var lng: String?
}
