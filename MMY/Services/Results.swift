//
//  Results.swift
//  MMY
//
//  Created by Akiramonster on 2/16/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import XCGLogger
import Localize_Swift

enum SingleResult<C: BaseModel> {
    var value: C? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }
    var error: ErrorModel? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
    case success(C)
    case failure(ErrorModel)
    
    static func handle(response: DataResponse<Any>, key: String) -> SingleResult {
        guard let value = response.result.value else {
            return SingleResult.failure(ErrorModel(errorCode: .unknownException))
        }
        
        let json = JSON(value)
        let error = ErrorModel(json: json)
        let result = C(json: json[key])
        
        guard error.errorCode == .success && result != nil else {
            return SingleResult.failure(error)
        }
        
        return SingleResult.success(result!)
    }
    
    static func handle(json: JSON, key: String) -> SingleResult {
        let error = ErrorModel(json: json["error"])
        let result = C(json: json[key])
        
        guard error.errorCode == .success && result != nil else {
            return SingleResult.failure(error)
        }
        
        return SingleResult.success(result!)
    }
}

enum ListResult<C: BaseModel> {
    var value: [C]? {
        switch self {
        case .success(let value, _):
            return value
        default:
            return nil
        }
    }

    var error: ErrorModel? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
    
    case success([C], String?)
    case failure(ErrorModel)
    
    static func handle(response: DataResponse<Any>, key: String) -> ListResult {
        guard let value = response.result.value else {
            return ListResult.failure(ErrorModel(errorCode: .unknownException))
        }
        
        let json = JSON(value)
        let error = ErrorModel(json: json)
        var results : [C]?
        if let items = json[key].array {
            results = [C]()
            for item in items {
                results?.safeAppend(C(json: item))
            }
        }
        
        guard error.errorCode == .success && results != nil else {
            return ListResult.failure(error)
        }
        
        return ListResult.success(results!, nil)
    }
    
    static func handle(json: JSON, key: String) -> ListResult {
        let error = ErrorModel(json: json["error"])
        var results : [C]?
        
        if let items = json[key].array {
            results = [C]()
            for item in items {
                results?.safeAppend(C(json: item))
            }
        }
        
        guard error.errorCode == .success && results != nil else {
            return ListResult.failure(error)
        }
        
        return ListResult.success(results!, nil)
    }
    
}

enum EmptyResult {
    case success
    case failure(ErrorModel)
    
    static func handle(response: DataResponse<Any>) -> EmptyResult {
        guard let value = response.result.value else {
            return EmptyResult.failure(ErrorModel(errorCode: .unknownException))
        }
        
        let json = JSON(value)
        let error = ErrorModel(json: json["error"])
        
        guard error.errorCode == .success else {
            return EmptyResult.failure(error)
        }
        
        return EmptyResult.success
    }
}
