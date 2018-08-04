//
//  AuthenService.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

protocol AuthService {
    //MARK: - Authentication Feature
    func signIn(_ type: LoginType, params: [String: Any], completion:@escaping(_ result: AuthResult<AuthSession>) -> Void)
    
    func signUp(params: [String: Any], completion:@escaping(_ result: AuthResult<Bool>) -> Void)
    
//    func signOut(sessionId: String, completion: @escaping(_ result: AuthResult<Bool>) -> Void)

    func forgetPass(params: [String: Any], completion: @escaping(_ result: AuthResult<Bool>) -> Void)
    
    func validate(sessionId: String, renew: Bool, completion: @escaping(_ result: AuthResult<AuthSession>) ->Void)
}
