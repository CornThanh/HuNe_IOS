         //
//  ServiceManager.swift
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
import CoreLocation


class ServiceManager {
    
    //MARK: - Static variable to use, add more here if needed
    static let newBackendUrl = "https://hunegroup.com/api/v1/"
    
    static let auth = AuthService()
    static let category = CategoryService()
//    static let pushNotification = PushNotificationService()
    static let post = PostService()
    static let postService = PostService()
    static let media = MediaService()
    static let notificationService = NotificationService()
    static let voteService = VoteService()
    static let favoriteService = FavoriteService()
    static let shareService = ShareService()
    static let walletService = WalletService()
    
    //MARK: - Service
    class Service {
        
        var accessToken: String? {
            return Authenticator.shareInstance.getAuthSession()?.sessionId
        }
        
        let manager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
            
            return SessionManager(configuration: configuration)
        }()
        
        public func request(
            _ url: URLConvertible,
            method: HTTPMethod = .get,
            parameters: Parameters? = nil,
            handler: @escaping (DataResponse<Any>) -> Void
            )
        {
            let request = manager.request(url, method: method, parameters: parameters)
            log.debug(request.debugDescription)
            request.responseJSON { (response) in
                log.debug(response.debugDescription)
                handler(response)
            }
        }
        
        public func requestServer(
            _ url: URLConvertible,
            method: HTTPMethod = .get,
            parameters: Parameters? = nil,
            handler: @escaping (DataResponse<Any>) -> Void
            )
        {
            let lang = Localize.currentLanguage()
            let headers: [String: String] = ["Accept-Language" : lang]

            Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                log.debug(response.debugDescription)
                print(response)
                handler(response)
            }
        }

        func json(forResource name: String?, withExtension ext: String?) -> JSON?{
            guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
                return nil
            }
            
            do {
                let data = try Data(contentsOf: url)
                return try! JSON(data: data)
            } catch {
                return nil
            }
        }
        
//        public func makeURL(with entity: String) -> String {
//            return backendUrl + entity + "?access_token=" + (accessToken ?? "")
//        }
    }
    
    //MARK: - Authentication
    class AuthService: Service {
        func signIn(params: [String: Any], handler: @escaping (SingleResult<SignInModel>) -> Void){
            let urlString = newBackendUrl + "user/login-account"
            requestServer(urlString, method: .post, parameters: params) { (response) in
                handler(SingleResult<SignInModel>.handle(response: response, key: "data"))
            }
        }
        
        func signInWithFacebook(params: [String: Any], handler: @escaping (SingleResult<SignInModel>) -> Void){
            let urlString = newBackendUrl + "user/login-facebook"
            requestServer(urlString, method: .post, parameters: params) { (response) in
                handler(SingleResult<SignInModel>.handle(response: response, key: "data"))
            }
        }
        
        func signUp(params: [String: Any], handler: @escaping(SingleResult<UserModel>) -> Void){
            let urlString = newBackendUrl + "user/register"
            requestServer(urlString, method: .post, parameters: params) { (response) in
                handler(SingleResult<UserModel>.handle(response: response, key: "data"))
            }
        }
        
//        func signOut(sessionId: String, handler: @escaping(EmptyResult) -> Void){
//            let urlString = backendUrl + "accessTokens/" + sessionId
//            
//            let params = ["access_token": sessionId]
//            request(urlString, method: .delete, parameters: params) { (response) in
//                handler(EmptyResult.handle(response: response))
//            }
//        }

        func validate(sessionId: String, handler: @escaping(SingleResult<SignInModel>) -> Void){
//            let urlString = backendUrl + "accessTokens/" + sessionId
//            
//            var params = [String: Any]()
//            params["include"] = "user"
//            params["access_token"] = sessionId
//            
//            request(urlString, method: .get, parameters: params) { (response) in
//                handler(SingleResult<SignInModel>.handle(response: response, key: "data"))
//            }

            let urlString = newBackendUrl + "user/profile?user_id=" + ""
            var params = [String:Any]()
            params["token"] = sessionId
            request(urlString, method: .get, parameters: params) { (response) in
//                handler(SingleResult.handle(response: response, key: "data"))
                handler(SingleResult<SignInModel>.handle(response: response, key: "data"))
            }
        }
    }
    
    //MARK: - Category
    class CategoryService: Service {
        func getCategory(handler: @escaping(ListResult<CategoryModel>) -> Void) {
            let urlString = newBackendUrl + "category?parent_id=0"

            requestServer(urlString, method: .get, parameters: nil) { (response) in
                handler(ListResult<CategoryModel>.handle(response: response, key: "data"))
            }
        }
    }
    
    //MARK: - Push Notification
//    class PushNotificationService: Service {
//        let fcmCatchKey = "vn.asquare.os.fcm"
//        
//        func push(token: String, isLogin: Bool = false, handler: @escaping(EmptyResult) -> Void) {
//            guard validate(isLogin, token: token) else {
//                let error = ErrorModel(errorCode: .failed)
//                handler(EmptyResult.failure(error))
//                return
//            }
//            
//            let urlString = backendUrl + "pushes" + "?access_token=" + (accessToken ?? "")
//            let tokenDic = ["token": token]
//            var params = [String: Any]()
//            params["data"] = tokenDic
//            
//            request(urlString, method: .post, parameters: params) { (response) in
//                let result = EmptyResult.handle(response: response)
//                switch result{
//                case .success:
//                    UserDefaults.standard.set(token, forKey: self.fcmCatchKey)
//                    UserDefaults.standard.synchronize()
//                default:
//                    break
//                }
//                handler(result)
//            }
//        }
//        
//        func remove(token: String?, handler: @escaping(EmptyResult) -> Void){
//            guard let token = token else{
//                handler(EmptyResult.success)
//                return
//            }
//            
//            let urlString = backendUrl + "pushes/" + token
//            
//            var params: [String: Any] = [:]
//            params["pushId"] = token
//            params["access_token"] = accessToken
//            
//            request(urlString, method: .delete, parameters: params) { (response) in
//                let result = EmptyResult.handle(response: response)
//                switch result{
//                case .success:
//                    UserDefaults.standard.removeObject(forKey: self.fcmCatchKey)
//                    UserDefaults.standard.synchronize()
//                default:
//                    break
//                }
//                
//                handler(result)
//            }
//        }
//        
//        private func validate(_ isLogin: Bool, token: String) -> Bool{
//            guard let fcmToken = UserDefaults.standard.object(forKey: fcmCatchKey) as? String else{
//                return true
//            }
//            
//            return fcmToken != token || isLogin
//        }
//    }

    
    //MARK: - Post
    class PostService: Service {
        func getPosts(filterModel: FilterModel, pagingModel: PagingModel? = nil, handler: @escaping(ListResult<PostModel>, PagingModel?) -> Void) {
            let urlString = newBackendUrl + "post"
            var params = [String: Any]()
            for param in filterModel.makeParams() {
                params[param.key] = param.value
            }
            
            params["token"] = accessToken
            
            Alamofire.request(urlString, method: .get, parameters: params).responseJSON { (response) in
                log.debug(response.debugDescription)
                guard let value = response.result.value else {
                    handler(ListResult.failure(ErrorModel(errorCode: .unknownException)), nil)
                    return
                }
                let json = JSON(value)
                let error = ErrorModel(json: json)
                var results : [PostModel]?
                if let items = json["data"].array {
                    results = [PostModel]()
                    for item in items {
                        results?.safeAppend(PostModel(json: item))
                    }
                }

                guard let posts = results,
                        error.errorCode == .success else {
                    handler(ListResult.failure(error), nil)
                    return
                }
                handler(ListResult.success(posts, nil), pagingModel)
            }
        }
        
        func getRelatePosts(location: CLLocation?, type: String, radius: CGFloat, completion: @escaping([PostModel]?) -> Void) {
            let urlString = newBackendUrl + "post/relate"
            var params = [String: Any]()
            
            params["token"] = accessToken
            params["type"] = type
            params["latitude"] = location?.coordinate.latitude
            params["longitude"] = location?.coordinate.longitude
            params["radius"] = radius
            
            Alamofire.request(urlString, method: .get, parameters: params).responseJSON { (response) in
                log.debug(response.debugDescription)
                
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    var results = [PostModel]()
                    if let items = json["data"].array {
                        results = [PostModel]()
                        for item in items {
                            results.safeAppend(PostModel(json: item))
                        }
                    }
                    completion(results)
    
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
        }
        
        func post(_ newPost: TempPostModel, handler: @escaping(SingleResult<CategoryModel>) -> Void) {
            guard let token = accessToken else {
                return
            }
            var urlString = newBackendUrl + "post"
            urlString.append("?token=\(token)")
            var params = [String:Any]()
            params = newPost.makeParams()
            
            let maxWidth: CGFloat = 500
            let thumnailWidth: CGFloat = 120
            
            let group = DispatchGroup()
        
            if let avatar = newPost.avatar {
                group.enter()
                let imageSize = avatar.size
                if imageSize.width > thumnailWidth {
                    let newSize = CGSize(width: thumnailWidth, height: imageSize.height/imageSize.width*thumnailWidth)
                    let newImage = avatar.imageScaled(to: newSize)
                    self.uploadFile(dataFile: UIImageJPEGRepresentation(newImage!, 1.0)!, name: "avatar.jpg", completion: { (url) in
                        if let url = url, url.count > 0 {
                            params["thumbnail"] = url
                        }
                        group.leave()
                    })
                }
                else {
                    self.uploadFile(dataFile: UIImageJPEGRepresentation(avatar, 1.0)!, name: "avatar.jpg", completion: { (url) in
                        if let url = url, url.count > 0 {
                            params["thumbnail"] = url
                        }
                        group.leave()
                    })
                }
            }
            
            if newPost.images.count > 0 {
                for i in 0 ... newPost.images.count - 1 {
                    group.enter()
                    let image = newPost.images[i]
                    let imageSize = image.size
                    if imageSize.width > maxWidth {
                        let newSize = CGSize(width: maxWidth, height: imageSize.height/imageSize.width*maxWidth)
                        let newImage = image.imageScaled(to: newSize)
                        self.uploadFile(dataFile: UIImageJPEGRepresentation(newImage!, 1.0)!, name: "image\(i + 1).jpg", completion: { (url) in
                            if let url = url, url.count > 0 {
                                params[ "image\(i + 1)"] = url
                            }
                            group.leave()
                        })
                    }
                    else {
                        self.uploadFile(dataFile: UIImageJPEGRepresentation(image, 1.0)!,name: "image\(i + 1).jpg", completion: { (url) in
                            if let url = url, url.count > 0 {
                                params[ "image\(i + 1)"] = url
                            }
                            group.leave()
                        })
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.global(qos: .background)) {
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    for (key, value) in params {
                        print(key, value)
                        multipartFormData.append(String(describing: value).data(using: .utf8)!, withName: key)
                    }
                    print(multipartFormData)
                }, to: urlString)
                { (multipartResult) in
                    switch multipartResult {
                    case let .success(upload, _, _):
                        log.debug(upload.debugDescription)
                        upload.responseJSON(completionHandler: { (response) in
                            handler(SingleResult.handle(response: response, key: "data"))
                            log.debug(response.debugDescription)
                        })
                    case .failure(let error):
                        log.debug(error.localizedDescription)
                    }
                }
            }
            
        }
        
        func uploadFile(dataFile: Data, name: String, completion: @escaping (_ url: String?) -> Void) {
            var urlString = newBackendUrl + "file/upload"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(dataFile, withName: "file", fileName: name, mimeType: "image/jpg") //png
            }, to: urlString)
            { (multipartResult) in
                switch multipartResult {
                case let .success(upload, _, _):
                    log.debug(upload.debugDescription)
                    upload.responseJSON(completionHandler: { (response) in
                        guard let value = response.result.value else {
                            completion("")
                            return
                        }
                        let json = JSON(value)
                        let url = json["data"]["url"].stringValue
                        print("upload file \(name) done : \(url)")
                        completion(url)
                    })
                case .failure(let error):
                    log.debug(error.localizedDescription)
                    completion(nil)
                }
            }
            
        }
        
        func get(postId: String, handler: @escaping(SingleResult<PostModel>) -> Void) {
            let urlString = newBackendUrl + "post" + "/" + postId
            request(urlString, method: .get, parameters: nil) { (response) in
                handler(SingleResult<PostModel>.handle(response: response, key: "data"))
            }
        }
        
        func getMyPost(type: String, completion: @escaping (_ posts: [PostModel]?, _ error: Error?) -> Void) {
            let urlString = newBackendUrl + "post/my-post"
            let params = ["token" : accessToken ?? "",
                          "type" : type]
            
            Alamofire.request(urlString, method: .get, parameters: params).responseJSON { (response) in
                log.debug(response.debugDescription)
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    var posts = [PostModel]()
                    for subJson: JSON in json["data"].arrayValue {
                        if let post = PostModel(json: subJson) {
                            posts.append(post)
                        }
                    }
                    completion(posts, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
        
        func deletePost(postId: String, completion: @escaping ( _ resultCode: Int) -> Void) {
            var urlString = newBackendUrl + "post/\(postId)"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "DELETE"
                        
            Alamofire.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    print(json)
                    let resultCode = json["code"].intValue
                    completion(resultCode)
                case .failure(let error):
                    print(error)
                    completion(500)
                }
            }
        }
        
        func editPost(_ newPost: TempPostModel, postID :String, completion: @escaping ( _ resultCode: Int) -> Void) {
            var urlString = newBackendUrl + "post/\(postID)"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            var params = [String:Any]()
            params = newPost.makeParams()
            
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "PUT"
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
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
        
        
        func editPostWithImage(_ newPost: TempPostModel, postID :String, completion: @escaping ( _ resultCode: Int) -> Void) {
            var urlString = newBackendUrl + "post/\(postID)"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            var params = [String:Any]()
            params = newPost.makeParams()
            
            let maxWidth: CGFloat = 500
            
            let group = DispatchGroup()
            
            if let avatar = newPost.avatar {
                group.enter()
                let imageSize = avatar.size
                if imageSize.width > maxWidth {
                    let newSize = CGSize(width: maxWidth, height: imageSize.height/imageSize.width*maxWidth)
                    let newImage = avatar.imageScaled(to: newSize)
                    self.uploadFile(dataFile: UIImageJPEGRepresentation(newImage!, 1.0)!, name: "avatar.jpg", completion: { (url) in
                        if let url = url, url.count > 0 {
                            params["thumbnail"] = url
                        }
                        group.leave()
                    })
                }
                else {
                    self.uploadFile(dataFile: UIImageJPEGRepresentation(avatar, 1.0)!, name: "avatar.jpg", completion: { (url) in
                        if let url = url, url.count > 0 {
                            params["thumbnail"] = url
                        }
                        group.leave()
                    })
                }
            }
            
            if newPost.images.count > 0 {
                for i in 0 ... newPost.images.count - 1 {
                    group.enter()
                    let image = newPost.images[i]
                    let imageSize = image.size
                    if imageSize.width > maxWidth {
                        let newSize = CGSize(width: maxWidth, height: imageSize.height/imageSize.width*maxWidth)
                        let newImage = image.imageScaled(to: newSize)
                        self.uploadFile(dataFile: UIImageJPEGRepresentation(newImage!, 1.0)!, name: "image\(i + 1).jpg", completion: { (url) in
                            if let url = url, url.count > 0 {
                                params[ "image\(i + 1)"] = url
                            }
                            group.leave()
                        })
                    }
                    else {
                        self.uploadFile(dataFile: UIImageJPEGRepresentation(image, 1.0)!,name: "image\(i + 1).jpg", completion: { (url) in
                            if let url = url, url.count > 0 {
                                params[ "image\(i + 1)"] = url
                            }
                            group.leave()
                        })
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.global(qos: .background)) {
                var urlRequest = URLRequest(url: URL(string: urlString)!)
                urlRequest.httpMethod = "PUT"
                
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
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
            
        }
        
        func changePostStatus(post: PostModel, completion: @escaping ( _ resultCode: Int) -> Void) {
            var urlString = newBackendUrl + "post/\(post.postID!)"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            var params = [String:Any]()
            if post.status == "1" {
                params["status"] = "2"
            }
            else {
                params["status"] = "1"
            }
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "PUT"
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
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
    }
    
//    //MARK: - Media
    class MediaService: Service {
        func upload(image: UIImage, handler: @escaping(SingleResult<AvatarModel>) -> Void) {
            guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                let error = ErrorModel(errorCode: .invalidData)
                handler(SingleResult.failure(error))
                return
            }
            let entity = "media/upload"
//            let url = makeURL(with: entity)
//            Alamofire.upload(multipartFormData: { (multipartFormData) in
//                multipartFormData.append(imageData, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
//            }, to: url)
//            { (multipartResult) in
//                switch multipartResult {
//                case let .success(upload, _, _):
//                    log.debug(upload.debugDescription)
//                    upload.responseJSON(completionHandler: { (response) in
//                        handler(SingleResult.handle(response: response, key: "data"))
//                        log.debug(response.debugDescription)
//                    })
//                case .failure(let error):
//                    log.debug(error.localizedDescription)
//                }
//            }
        }
    }

    //MARK: - Notification
    class NotificationService: Service {
        func getAllNotification(completion: @escaping (_ notifications: [NotificationModel]?, _ error: Error?) -> Void) {
            let urlString = newBackendUrl + "notification?token=\(accessToken!)"
            Alamofire.request(urlString , method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    var notifications = [NotificationModel]()
                    for subJson: JSON in json["data"].arrayValue {
                        if let notification = NotificationModel(json: subJson) {
                            notifications.append(notification)
                        }
                    }
                    completion(notifications, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
        
        func getNumberNotification() {
            
        }
        
        func markReadAllNotification(completion: @escaping ( _ resultCode: Int) -> Void) {
            let urlString = newBackendUrl + "notification/mark-read?token=\(accessToken!)"
            Alamofire.request(urlString , method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
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
    }
    
    //MARK: - Vote
    class VoteService: Service {
        func getVote(soureID: String, type: String, completion: @escaping (_ votes: [VoteModel]?, _ error: Error?) -> Void) {
            let urlString = newBackendUrl + "vote?token=\(accessToken!)&source_id=\(soureID)&type=\(type)"
            Alamofire.request(urlString , method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    var votes = [VoteModel]()
                    for subJson: JSON in json["data"].arrayValue {
                        if let vote = VoteModel(json: subJson) {
                            votes.append(vote)
                        }
                    }
                    completion(votes, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
        }
        
        func addVote(source_id: String, rate: String, comment: String, type: String, completion: @escaping ( _ resultCode: Int) -> Void) {
            var urlString = newBackendUrl + "vote"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            let parameters: Parameters = [
                "source_id": source_id,
                "rate" : rate,
                "comment": comment,
                "type" : type
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
                    completion(resultCode)
                case .failure(let error):
                    print(error)
                    completion(500)
                }
            }
            
        }
    }
    
    //MARK: - Favorite
    class FavoriteService: Service {
        func addFavorite(type: String, source_id: String, completion: @escaping ( _ resultCode: Int) -> Void) {
            var urlString = newBackendUrl + "favourite"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            let parameters: Parameters = [
                "source_id": source_id,
                "type": type    // 1: user, 2: post
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
                    print(json)
                    let resultCode = json["code"].intValue
                    completion(resultCode)
                case .failure(let error):
                    print(error)
                    completion(500)
                }
            }
        }
        
        
        func deleteFavorite(type: String, source_id: String, completion: @escaping ( _ resultCode: Int) -> Void) {
            var urlString = newBackendUrl + "favourite"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            let parameters: Parameters = [
                "source_id": source_id,
                "type": type    // 1: user, 2: post
            ]
            
            
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "DELETE"
            
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
                    print(json)
                    let resultCode = json["code"].intValue
                    completion(resultCode)
                case .failure(let error):
                    print(error)
                    completion(500)
                }
            }
        }
        
        
        func getFavorite(type: String, completion: @escaping ( _ favorites: [UserModel]?, _ error: Error?) -> Void) {
            var urlString = newBackendUrl + "favourite"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            urlString.append("&type=\(type)")
            
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "GET"
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            Alamofire.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    print(json)
                    var favoriteUsers = [UserModel]()
                    if let favoritesJson = json["data"].array {
                        for subJson in favoritesJson {
                            if let favoriteUser = UserModel(json: subJson["user"]) {
                                favoriteUser.is_favourite = true
                                favoriteUsers.append(favoriteUser)
                            }
                        }
                    }
                    completion(favoriteUsers, nil)
                case .failure(let error):
                    print(error)
                    completion(nil, error)
                }
            }
        }
        
        
        // type_post: 1 is Enrollment, 2 is search job
        func getFavoritePost(type_post: String, completion: @escaping ( _ favorites: [PostModel]?, _ error: Error?) -> Void) {
            var urlString = newBackendUrl + "favourite"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            urlString.append("&type=2&type_post=\(type_post)")
            
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "GET"
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            Alamofire.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    print(json)
                    var favoritePosts = [PostModel]()
                    if let favoritesJson = json["data"].array {
                        for subJson in favoritesJson {
                            if let favoritePost = PostModel(json: subJson["post"]) {
//                                favoriteUser.is_favourite = true
                                favoritePosts.append(favoritePost)
                            }
                        }
                    }
                    completion(favoritePosts, nil)
                case .failure(let error):
                    print(error)
                    completion(nil, error)
                }
            }
        }
        
    }
    
    
    //MARK: - Share
    class ShareService: Service {
        func getShare(type: String, post_id: String?, completion: @escaping (_ shareModel: ShareModel?) -> Void) { // type: value: post | app
            
            var urlString = newBackendUrl + "share/\(type)/"
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            if let post_id = post_id {
                urlString.append("&post_id=\(post_id)")
            }
            
            var urlRequest = URLRequest(url: URL(string: urlString)!)
            urlRequest.httpMethod = "GET"
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            Alamofire.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = try! JSON(data: response.data!)
                    let shareModel = ShareModel(json: json["data"])
                    completion(shareModel)
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
        }
    }
    
    class WalletService: Service {
        func changeCoin(_ code: String, completion: @escaping (SingleResult<ChangeCoinModel>) -> Void) {
            var urlString = newBackendUrl + "wallet/deposit/coin"
            
            if let token = accessToken {
                urlString.append("?token=\(token)")
            }
            
            let params: Parameters = [
                "code": code
            ]
            
            requestServer(urlString, method: .post, parameters: params) { (response) in
                let result = SingleResult<ChangeCoinModel>.handle(response: response, key: "data")
                completion(result)
            }
        }
    }
}
