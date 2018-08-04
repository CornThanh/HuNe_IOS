//
//  AuthenProvider.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

protocol AuthProvider {
    //MARK: - Get/Set Properties
    func getType() -> LoginType
    
    //MARK: - Setting Application Delegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool
    
    
    //MARK: - Authentication Feature
    func login(in controller: UIViewController, completion: @escaping(_ result: AuthResult<[String: Any]?>) -> Void)
    
    func logout()
}

//MARK: - Making Option Protocol
extension AuthProvider {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool{
        return false
    }
    
    func logout(){}
}
