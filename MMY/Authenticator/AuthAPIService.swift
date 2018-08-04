//
//  AuthenAPIService.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase

class AuthAPIService: AuthService {
    //MARK: - Authenication

    func signIn(_ type: LoginType, params: [String: Any], completion:@escaping(_ result: AuthResult<AuthSession>) -> Void){
        if type == LoginType.facebook {
            ServiceManager.auth.signInWithFacebook(params: params) { (result) in
                switch result{
                case .success(let signInModel):
                    print(signInModel.accessToken)
                    guard let userId = signInModel.user?.userId,
                        let accessToken = signInModel.accessToken
                        else {
                            completion(AuthResult.failure(AuthError.responseEmpty))
                            return
                    }
                    
                    let user = AuthUser(id: userId, display: signInModel.user?.phone, verified: signInModel.verified)
                    
                    let session = AuthSession(sessionId: accessToken,
                                              user: user,
                                              expired: 0)
                    
                    completion(AuthResult.success(session))
                    
                case .failure(let error):
                    completion(AuthResult.failure(AuthError.handle(
                        error)))
                }
            }
        }
        else {
            ServiceManager.auth.signIn(params: params) { (result) in
                switch result{
                case .success(let signInModel):
                    guard let userId = signInModel.user?.userId,
                        let accessToken = signInModel.accessToken
                        else {
                            completion(AuthResult.failure(AuthError.responseEmpty))
                            return
                    }
                    
                    let user = AuthUser(id: userId, display: signInModel.user?.phone, verified: signInModel.verified)
                    
                    let session = AuthSession(sessionId: accessToken,
                                              user: user,
                                              expired: 0)
                    
                    completion(AuthResult.success(session))
                    
                case .failure(let error):
                    completion(AuthResult.failure(AuthError.handle(error)))
                }
            }
        }
        
    }
    
    func signUp(params: [String: Any], completion:@escaping(_ result: AuthResult<Bool>) -> Void){
        ServiceManager.auth.signUp(params: params) { (result) in
            switch result{
            case .success(_):
                completion(AuthResult.success(true))
                
            case .failure(let error):
                completion(AuthResult.failure(AuthError.handle(error)))
            }
        }
    }
    
//    func signOut(sessionId: String, completion: @escaping(_ result: AuthResult<Bool>) -> Void){
//        ServiceManager.pushNotification.remove(token: InstanceID.instanceID().token()) { (result) in
//            switch result{
//            case .success:
//                log.debug("Remove fcm token successfully")
//            case .failure(let error):
//                log.debug("Remove fcm token error: \(error)")
//            }
//            
//            ServiceManager.auth.signOut(sessionId: sessionId) { (result) in
//                switch result{
//                case .success(_):
//                    completion(AuthResult.success(true))
//                    
//                case .failure(let error):
//                    completion(AuthResult.failure(AuthError.handle(error)))
//                }
//            }
//        }
//        completion(AuthResult.success(true))
//    }

    func forgetPass(params: [String: Any], completion: @escaping(_ result: AuthResult<Bool>) -> Void){
//		ServiceManager.auth.ve
//        completion(AuthResult.success(true))
    }
    
    func validate(sessionId: String, renew: Bool, completion: @escaping(_ result: AuthResult<AuthSession>) ->Void){
        ServiceManager.auth.validate(sessionId: sessionId) { (result) in
            switch result{
            case .success(let signInModel):
                guard let userId = signInModel.user?.userId,
                    let accessToken = signInModel.accessToken else {
                        completion(AuthResult.failure(AuthError.responseEmpty))
                        return
                }
                
                let user = AuthUser(id: userId, display: signInModel.user?.phone, verified: signInModel.verified)

                let session = AuthSession(sessionId: accessToken,
                                          user: user,
                                          expired: 0)
                
                completion(AuthResult.success(session))
                
            case .failure(let error):
                completion(AuthResult.failure(AuthError.handle(error)))
            }
        }
    }
}
