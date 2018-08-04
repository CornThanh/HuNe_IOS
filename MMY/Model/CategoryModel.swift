//
//  BottomMenuItem.swift
//  MMY
//
//  Created by Blue R&D on 2/16/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON

class CategoryModel: BaseModel {
    var categoryId: String?
    var icon: String?
    var name: String?
    var name_vi: String?
    var parentId: String?
    var children: [CategoryModel]?
    var maxSelectedChildren = 1
    var maxSelectedCategory = 1
    private var _isChosen: Bool = false
    var isChosen: Bool {
        get {
            return _isChosen
        }
        set {
            _isChosen = newValue
            if !newValue, let children = children {
                for child in children {
                    child._isChosen = false
                }
            }
        }
    }
    
    required init?(json: JSON) {
        super.init(json: json)
        print(json)
        categoryId  = json["id"].stringValue
        icon        = json["icon"].string
        name        = json["name"].string
        parentId    = json["parent_id"].string
        name_vi     = json["category"]["name_vi"].string
        if let array = json["childs"].array {
            children = [CategoryModel]()
            for item in array {
                children?.safeAppend(CategoryModel(json: item))
            }
        }
    }
    
    func getSelectedChildren() -> [CategoryModel] {
        var result = [CategoryModel]()
        guard let children = children else {
            return result
        }
        for child in children {
            if child.isChosen {
                result.append(child)
            }
        }
        return result
    }
    
    func copy() -> CategoryModel? {
        let clone           = CategoryModel(json: JSON(true))
        clone?.categoryId   = categoryId
        clone?.icon         = icon
        clone?.name         = name
        clone?.parentId     = parentId
        clone?.isChosen     = isChosen
        if let children = children {
            var cloneChildren = [CategoryModel]()
            for child in children {
                cloneChildren.safeAppend(child.copy())
            }
            clone?.children = cloneChildren
        }
        return clone
    }
    
    static func makeString(from categories: [CategoryModel]?) -> String {
        var result = ""
        guard let categories = categories else {
            return result
        }
        for index in 0..<categories.count {
            result += categories[index].name ?? ""
            result += index == categories.count - 1 ? "" : " | "
        }
        return result
    }
    
    static func clearSelection(of categories: [CategoryModel]?) -> [CategoryModel]? {
        guard let categories = categories else {
            return nil
        }
        for category in categories {
            category.isChosen = false
        }
        return categories
    }
    
    static func getSelectedCategory(in categories: [CategoryModel]?) -> [CategoryModel]? {
        guard let categories = categories else {
            return nil
        }
        var result = [CategoryModel]()
        for category in categories {
            if category.isChosen {
                result.safeAppend(category)
            }
            result.append(contentsOf: category.getSelectedChildren())
        }
        return result.count == 0 ? nil : result
    }
    
    static func copy(from categories: [CategoryModel]?) -> [CategoryModel]? {
        guard let categories = categories,
            let categoriesList = (categories.map() { $0.copy() }) as? [CategoryModel] else {
                return nil
        }
        return categoriesList
    }
}
