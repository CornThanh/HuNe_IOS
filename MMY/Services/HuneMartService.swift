//
//  HuneMartService.swift
//  MMY
//
//  Created by Apple on 7/25/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension ServiceManager {
    static let martService = HuneMartService.shared
    
    class HuneMartService: Service {
        
        static let shared = HuneMartService()
        
        func addPostNews(_ postNews: PostNewsModel, completion: @escaping ((SingleResult<BaseModel>) -> Void) ){
            
            var urlString = newBackendUrl + "hunemart/seller/product/add"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            var params = [String: Any]()
            params["name"] = postNews.name
            params["type"] = postNews.type
            params["product_type"] = postNews.product_type
            params["price"] = postNews.price
            params["description"] = postNews.description
            params["unit"] = postNews.price
            params["quantity"] = postNews.quantity
            params["end_date"] = postNews.end_date
            params["address"] = postNews.address
            params["transport_fee"] = postNews.transport_fee
            params["thumbnail"] = postNews.thumbnail
            params["image1"] = postNews.image1
            params["image2"] = postNews.image2
            params["image3"] = postNews.image3
            params["lat"] = postNews.lat
            params["lng"] = postNews.lng
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<BaseModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func configType(completion: @escaping ((ListResult<ConfigTypeOrProductTypeModel>) -> Void)) {
            
            var urlString = newBackendUrl + "settings/type"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = ListResult<ConfigTypeOrProductTypeModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func configProductType(completion: @escaping ((ListResult<ConfigTypeOrProductTypeModel>) -> Void)) {
            
            var urlString = newBackendUrl + "settings/product-type"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = ListResult<ConfigTypeOrProductTypeModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func configUnit(completion: @escaping ((ListResult<ConfigTypeOrProductTypeModel>) -> Void)) {
            var urlString = newBackendUrl + "settings/unit"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = ListResult<ConfigTypeOrProductTypeModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func getProduct(completion: @escaping ((ListResult<ListProductBuyerModel>) -> Void)) {
            var urlString = newBackendUrl + "hunemart/buyer"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = ListResult<ListProductBuyerModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func buyerAddToCart(_ productCart: ListProductBuyerModel, amount: Int, completion: @escaping ((SingleResult<BaseModel>) -> Void)) {
            
            var urlString = newBackendUrl + "hunemart/buyer/add-to-cart"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            var params = [String: Any]()
            params["quantity"] = amount
            params["price"] = productCart.price
            params["product_id"] = productCart.product_id
            params["seller_id"] = productCart.user_id
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<BaseModel>.handle(response: response, key: "data")
                completion(result)
                
            }
        }
        
        func getBuyerOrder(completion: @escaping ((ListResult<OrderModel>) -> Void)) {
            
            var urlString = newBackendUrl + "hunemart/buyer/order"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = ListResult<OrderModel>.handle(response: response, key: "data")
                completion(result)
                
            }
        }
        
        func getSellerProduct(completion: @escaping ((ListResult<ManageStoreModel>) -> Void)) {
            var urlString = newBackendUrl + "hunemart/seller"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = ListResult<ManageStoreModel>.handle(response: response, key: "data")
                completion(result)
                
            }
        }
        
        func editSellerProduct(productId: String ,completion: @escaping ((SingleResult<BaseModel>) -> Void)) {
            var urlString = newBackendUrl + "hunemart/seller/product/edit"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            urlString.append("&product_id=\(productId)")
        
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = SingleResult<BaseModel>.handle(response: response, key: "data")
                completion(result)
                
            }
        }
        
        func updateSellerProduct(_ postNews: ManageStoreModel, product_id: String, completion: @escaping ((SingleResult<BaseModel>) -> Void) ){
            
            var urlString = newBackendUrl + "hunemart/seller/product/update"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            ///hunemart/seller/product/update
            urlString.append("&id=\(product_id)")
            
            var params = [String: Any]()
            params["name"] = postNews.name
            params["type"] = postNews.type
            params["product_type"] = postNews.product_type
            params["price"] = postNews.price
            params["description"] = postNews.description
            params["unit"] = postNews.price
            params["quantity"] = postNews.quantity
            params["end_date"] = postNews.end_date
            params["address"] = postNews.address
            params["transport_fee"] = postNews.transport_fee
            params["thumbnail"] = postNews.thumbnail
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<BaseModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func deleteSellerProduct(_ productId: String, completion: @escaping ((SingleResult<BaseModel>) -> Void)) {
            
            var urlString = newBackendUrl + "hunemart/seller/product/delete"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            var params = [String: Any]()
            params["product_id"] = productId
            
            requestServer(urlString, method: .delete, parameters: params) { (response) in
                let result = SingleResult<BaseModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func postComment(_ orderData: OrderModel, rating: Int, comment: String, completion: @escaping ((SingleResult<BaseModel>) -> Void)) {
            
            var urlString = newBackendUrl + "hunemart/buyer/rating"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            var params = [String: Any]()
            params["user_rating"] = orderData.seller_id
            params["comments"] = comment
            params["rating"] = rating
            params["product_id"] = orderData.product_id
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<BaseModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func getSellerOrder(status: Int, fromDate: String, toDate: String, completion: @escaping ((ListResult<ManageOrderModel>) -> Void)) {
            var urlString = newBackendUrl + "hunemart/seller/order"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }

            if status > 0 {
                urlString.append("&status=\(status)")
            }
            
            if fromDate.count > 9 && toDate.count > 0 {
                urlString.append("&date_from=\(fromDate)&date_to=\(toDate)")
            }
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = ListResult<ManageOrderModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func updateStatusOrderSeller(orderId: String, completion: @escaping ((SingleResult<BaseModel>) -> Void)) {
            
            var urlString = newBackendUrl + "hunemart/seller/order/update"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            urlString.append("&order_id=\(orderId)")
            
            requestServer(urlString, method: .post, parameters: nil) { (response) in
                let result = SingleResult<BaseModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func orderBuyerProduct(_ sortType: Int, sortTypeProduct: Int, countStar: Int ,completion: @escaping ((ListResult<ListProductBuyerModel>) -> Void)) {
            
            var urlString = newBackendUrl + "hunemart/buyer"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }

            if sortType > 0 {
                 urlString.append("&type=\(sortType)")
            }
            
            if sortTypeProduct > 0 {
                urlString.append("&product_type=\(sortTypeProduct)")
                print("//////////////////////////////////////////////////////",sortTypeProduct)
            }
            
            if countStar >= 0 {
                urlString.append("&star_number=\(countStar)")
            }
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = ListResult<ListProductBuyerModel>.handle(response: response, key: "data")
                completion(result)
            }
            
        }
        
        func likeProduct (_ idProduct: String, action: String , completion: @escaping ((SingleResult<BaseModel>) -> Void)) {
            var urlString = newBackendUrl + "hunemart/buyer/like"
            // POST /hunemart/buyer/dislike/{id}
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            var params = [String: Any]()
            params["id"] = idProduct
            params["action"] = action
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<BaseModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
        
        func getComment(_ idProduct: String, completion: @escaping ((SingleResult<ProductEditModel>) -> Void)) {
            
            var urlString = newBackendUrl + "hunemart/seller/product/edit"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            urlString.append("&product_id=\(idProduct)")
            
            requestServer(urlString, method: .get, parameters: nil) { (response) in
                let result = SingleResult<ProductEditModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
    }
    
}
