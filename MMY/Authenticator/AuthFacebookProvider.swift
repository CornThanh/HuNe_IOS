//
//  FacebookProvider.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class AuthFacebookProvider: NSObject, AuthProvider {
    //MARK: - Properties
    private let type = LoginType.facebook
    private var loginManager = LoginManager()
    
    //MARK: - Get/Set Properties
    func getType() -> LoginType{
        return type
    }
    
    //MARK: - Setting Application Delegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool{
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    //MARK:- Authentication
    func login(in controller: UIViewController, completion: @escaping(_ result: AuthResult<[String: Any]?>) -> Void){
        loginManager.logIn(readPermissions: [.publicProfile], viewController: controller) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                log.debug(error)
                completion(AuthResult.failure(AuthError.failed))
                
            case .cancelled:
                log.debug("User cancelled login.")
                completion(AuthResult.failure(AuthError.cancelled))
            
            case .success( _, _, let accessToken):
                log.debug("Logged in!")
                completion(AuthResult.success(["facebook_token": accessToken.authenticationToken]))
            }
        }
    }
    
    func logout(){
        loginManager.logOut()
    }
}
