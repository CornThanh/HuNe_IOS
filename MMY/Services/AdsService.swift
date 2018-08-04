//
//  AdsService.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/8/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

extension ServiceManager {
    static let adsService = AdsService.shared
    
    class AdsService: Service {
        
        static let shared = AdsService()
        
        
        func getPromoCoupons(completion: @escaping (ListResult<CouponModel>) -> Void) {
            var urlString = newBackendUrl + "ads/location"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString) { (response) in
                let result = ListResult<CouponModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func buyCoupon(_ id: Int, completion: @escaping (SingleResult<CouponModel>) -> Void) {
            // type: value: post | app
            var urlString = newBackendUrl + "coupon"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            var params = [String: Any]()
            
            params["id"] = id
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<CouponModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func getDetail(_ id: String!, completion: @escaping (SingleResult<CouponModel>) -> Void) {
            var urlString = newBackendUrl + "coupon/" + id
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString) { (response) in
                let result = SingleResult<CouponModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func getCoupons(location: CLLocation, completion: @escaping (SingleResult<CouponModel>) -> Void) {
            var urlString = newBackendUrl + "ads/location"
            var params: [String: Any] = [:]
            params["latitude"] = location.coordinate.latitude
            params["longitude"] = location.coordinate.longitude
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, parameters: params) { (response) in
                let result = SingleResult<CouponModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func buyAsPlace(location: CLLocation,
                        name: String,
                        description: String,
                        branchs: [String],
                        logo: String,
                        targetGenders:[Int],
                        dates: [String],
                        completion: @escaping (SingleResult<CouponModel>) -> Void) {
            var urlString = newBackendUrl + "ads/location"
            var params: [String: Any] = [:]
            params["lat"] = String(location.coordinate.latitude)
            params["long"] = String(location.coordinate.longitude)
            params["name"] = name
            params["description"] = description
            params["branch"] = String(describing: branchs)
            params["targetGenders"] = String(describing: targetGenders)
            params["dates"] = String(describing: dates)
            params["gender"] = String(describing: targetGenders)
            params["logo"] = logo
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<CouponModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func getBanners(_ position: String , completion: @escaping (ListResult<BannerPromotionModel>) -> Void) {
            var urlString = newBackendUrl + "ads/banner"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            urlString = urlString + "&position=\(position)"
            
            requestServer(urlString) { (response) in
                let result = ListResult<BannerPromotionModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func buyBanner(viewId: Int, actionUrl: String, cover: String , dates: [String], completion: @escaping (SingleResult<CouponModel>) -> Void) {
            var urlString = newBackendUrl + "ads/banner"
            var params: [String: Any] = [:]
            params["position"] = String(viewId)
            params["cover"] = cover
            params["dates"] = String(describing: dates)
            params["url"] = actionUrl
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<CouponModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func payment(id: String, coupon: String, completetion: @escaping (EmptyResult) -> Void) {
            var urlString = newBackendUrl + "ads/pay/\(id)"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, method: .post, parameters: nil) { (response) in
                let result = EmptyResult.handle(response: response)
                completetion(result)
            }
        }
        
        func buyPromotion(completion: @escaping (SingleResult<CouponModel>) -> Void) {
            var urlString = newBackendUrl + "ads/promotion"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            var parameters: [String: Any] = [:]
            parameters["name"] = AdsNotifi.name
            parameters["description"] = AdsNotifi.description
            parameters["branch"] = String(describing: AdsNotifi.branch)
            parameters["start_hour"] = AdsNotifi.start_hour
            parameters["end_hour"] = AdsNotifi.end_hour
            parameters["start_date"] = AdsNotifi.start_date
            parameters["end_date"] = AdsNotifi.end_date
            parameters["total_coupon"] = AdsNotifi.total_coupon
            parameters["discount"] = AdsNotifi.discount
            parameters["price"] = AdsNotifi.price
            parameters["logo"] = AdsNotifi.logo
            parameters["lat"] = String(AdsNotifi.locationMap.coordinate.latitude)
            parameters["long"] = String(AdsNotifi.locationMap.coordinate.longitude)
            parameters["gender"] = String(describing: AdsNotifi.gender)
            parameters["location"] = String(describing: AdsNotifi.location)
            
            request(urlString, method: .post, parameters: parameters) { (response) in
                let result = SingleResult<CouponModel>.handle(response: response, key: "data")
                completion(result)
            }
            
            
        }
        
        func  getAds(completion: @escaping ([AdsManageModel]?) -> Void) {
            var urlString = newBackendUrl + "ads"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            Alamofire.request(urlString, method: .get, parameters: nil).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    var result = [AdsManageModel]()
                    if let items = json["data"].array {
                        for item in items {
                            result.safeAppend(AdsManageModel(json: item))
                        }
                    }
                    completion(result)
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
            
        }
        
        func getPromotion(completion: @escaping ([CouponModel]?) -> Void) {
            
            var urlString = newBackendUrl + "ads/location"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            Alamofire.request(urlString, method: .get, parameters: nil).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    var result = [CouponModel]()
                    if let items = json["data"].array {
                        for item in items {
                            result.safeAppend(CouponModel(json: item))
                        }
                    }
                    completion(result)
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
            
        }
        
    }
}
