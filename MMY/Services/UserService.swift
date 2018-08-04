//
//  UserService.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 1/16/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension ServiceManager {

    static let userService = UserService()

    //MARK: - User
    class UserService: Service {
        func get(userId: String, handler: @escaping(SingleResult<UserModel>) -> Void) {
            let urlString = newBackendUrl + "user/profile?user_id=" + userId
            var params = [String:Any]()
            params["token"] = accessToken
            request(urlString, method: .get, parameters: params) { (response) in
                handler(SingleResult.handle(response: response, key: "data"))
            }
        }

        func updateProfile(user: UserModel, avatarIsChanged: Bool = false, completion: @escaping ( _ resultCode: Int) -> Void) {
            let urlString = newBackendUrl + "user/profile?token=\(accessToken!)"
            var parameters: Parameters = [
                "full_name": user.full_name!,
                "sex" : user.gender!,
                "birthday": user.birthday!
            ]
            if let phoneNumber = user.phone {
                parameters["phone"] = phoneNumber
            }
            if avatarIsChanged {
                parameters["avatar"] = user.avatarURL
            }

            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "PUT"

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                //             No-op
            }

            Alamofire.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    let resultCode = json["code"].intValue
                    print(resultCode)
                    completion(resultCode)
                case .failure(let error):
                    print(error)
                    completion(500)
                }
            }
        }

        func updateFcm_token(fcm_token: String, completion: @escaping ( _ resultCode: Int) -> Void) {
            guard let accessToken = accessToken else {
                completion(500)
                return
            }
            let urlString = newBackendUrl + "user/profile?token=\(accessToken)"
            let parameters: Parameters = [
                "fcm_token": fcm_token
            ]
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "PUT"

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                //             No-op
            }

            Alamofire.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    let resultCode = json["code"].intValue
                    print(resultCode)
                    completion(resultCode)
                case .failure(let error):
                    print(error)
                    completion(500)
                }
            }
        }

        func verify(akToken: String, completion: @escaping (EmptyResult) -> Void) {
            guard let accessToken = accessToken else {
                completion(EmptyResult.failure(ErrorModel(errorCode: .accessDenied)))
                return
            }
            let urlString = newBackendUrl + "user/verify?token=\(accessToken)"
            let parameters: Parameters = [
                "ack_token": akToken
            ]
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "POST"

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                //             No-op
            }

            Alamofire.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    let resultCode = json["code"].intValue
                    let code = ErrorCode(rawValue: resultCode)
                    if code == ErrorCode.success {
                        completion(EmptyResult.success)
                    }
                    else {
                        completion(EmptyResult.failure(ErrorModel(errorCode: code ?? ErrorCode.failed)))
                    }

                case .failure( _):
                    completion(EmptyResult.failure(ErrorModel(errorCode: ErrorCode.failed)))
                }
            }

        }

        func resetPassword(akToken: String, params: Parameters, completion: @escaping (EmptyResult) -> Void) {
            let urlString = newBackendUrl + "user/forget-password"
            var parameters = params
            parameters["ack_token"] = akToken

            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "POST"

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                //             No-op
            }

            Alamofire.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    let resultCode = json["code"].intValue
                    let code = ErrorCode(rawValue: resultCode)
                    if code == ErrorCode.success {
                        completion(EmptyResult.success)
                    }
                    else {
                        completion(EmptyResult.failure(ErrorModel(errorCode: code ?? ErrorCode.failed)))
                    }

                case .failure( _):
                    completion(EmptyResult.failure(ErrorModel(errorCode: ErrorCode.failed)))
                }
            }
        }

        // Wallet
        func getCash(akToken: String, completion: ((_ result: Int) -> Void)?) {
            let urlString = newBackendUrl + "wallet/"
            var parameters : [String: Any] = [:]
            parameters["ack_token"] = akToken

            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "POST"

            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                //             No-op
            }
        }
    }
    
}
