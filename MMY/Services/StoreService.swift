//
//  StoreService.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/31/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import Alamofire

extension ServiceManager {
    static let storeService = StoreService.shared

    class StoreService: Service {

        static let shared = StoreService()

//        func create(post_id: String, amount: String, startHour: String, startDate: String, endHour: String, endDate: String, note: String? = nil, completion: @escaping (SingleResult<TaskModel>) -> Void) {
//            // type: value: post | app
//            var urlString = newBackendUrl + "task"
//
//            if let token = accessToken {
//                urlString.append("?token=\(token)")
//            }
//
//            var params = [String: Any]()
//
//            params["post_id"] = post_id
//            params["amount"] = amount
//            params["start_hour"] = startHour
//            params["start_date"] = startDate
//            params["end_hour"] = endHour
//            params["end_date"] = endDate
//            if let note = note {
//                params["description"] = note
//            }
//
//            requestServer(urlString, method: .post, parameters: params) { (response) in
//                let result = SingleResult<TaskModel>.handle(response: response, key: "data")
//                completion(result)
//            }
//        }

        func getCoupons(completion: @escaping (ListResult<CouponModel>) -> Void) {
            var urlString = newBackendUrl + "coupon"

            if let token = accessToken {
                urlString.append("?token=\(token)")
            }

            requestServer(urlString) { (response) in
                let result = ListResult<CouponModel>.handle(response: response, key: "data")
                completion(result)
            }
        }

        func getMyCoupons(completion: @escaping (ListResult<MyCouponModel>) -> Void) {
            var urlString = newBackendUrl + "coupon/my"

            if let token = accessToken {
                urlString.append("?token=\(token)")
            }

            requestServer(urlString) { (response) in
                let result = ListResult<MyCouponModel>.handle(response: response, key: "data")
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




        func getDetail(_ id: String!, completion: @escaping (SingleResult<DetailCouponModel>) -> Void) {
            var urlString = newBackendUrl + "coupon/group/" + id

            if let token = accessToken {
                urlString.append("?token=\(token)")
            }

            requestServer(urlString) { (response) in
                let result = SingleResult<DetailCouponModel>.handle(response: response, key: "data")
                completion(result)
            }
        }

//        func updateStatus(_ id: String!, status: Int, completion: @escaping (EmptyResult) -> Void) {
//            var urlString = newBackendUrl + "coupon/" + id
//            if let token = accessToken {
//                urlString.append("?token=\(token)")
//            }
//            var params = [String: Any]()
//
//            params["status"] = status
//
//            requestServer(urlString, method: .put, parameters: params) { (response) in
//                let result = EmptyResult.handle(response: response)
//                completion(result)
//            }
//        }


        func pay(id: String, amount: String, method: Int, completion: @escaping (SingleResult<TaskModel>) -> Void) {
            // type: value: post | app
            var urlString = newBackendUrl + "task/" + id + "/pay"

            if let token = accessToken {
                urlString.append("?token=\(token)")
            }

            var params = [String: Any]()

            //            params["amount"] = amount
            params["payment_type"] = method

            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<TaskModel>.handle(response: response, key: "data")
                completion(result)
            }
        }

        func remove(_ id: String, completion: @escaping (EmptyResult) -> Void) {
            // type: value: post | app
            var urlString = newBackendUrl + "task/" + id

            if let token = accessToken {
                urlString.append("?token=\(token)")
            }

            requestServer(urlString, method: .delete) { (response) in
                let result = EmptyResult.handle(response: response)
                completion(result)
            }
        }

    }
}
