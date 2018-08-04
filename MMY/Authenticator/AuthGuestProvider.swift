//
//  GuestProvider.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class AuthGuestProvider: AuthProvider {
    //MARK: - Properties
    let key = "vn.asquare.Authenticator.guestUUID"
    let type = LoginType.guest
    
    //MARK: - Get/Set Properties
    func getType() -> LoginType {
        return type
    }
    
    //MARK: - Authentication Features
    func login(in controller: UIViewController, completion: @escaping(_ result: AuthResult<[String: Any]?>) -> Void){
        var uuid = UserDefaults.standard.object(forKey: key) as? String
        if uuid == nil {
            uuid = UUID.init().uuidString
            UserDefaults.standard.set(uuid, forKey: key)
            UserDefaults.standard.synchronize()
        }
        
        completion(AuthResult.success(["deviceToken": uuid ?? ""]))
    }
}
