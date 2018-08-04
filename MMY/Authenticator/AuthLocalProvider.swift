//
//  EmailProvider.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class AuthLocalProvider: AuthProvider {
    //MARK: - Properties
    let type = LoginType.local
    let service: AuthService
    
    var completion : ((AuthResult<[String: Any]?>) -> Void)?
    
    //MARK: - Init
    init(with service: AuthService){
        self.service = service
    }
    
    //MARK: - Get/Set Properties
    func getType() -> LoginType{
        return type
    }
    
    //MARK: - Authentication
    func login(in controller: UIViewController, completion: @escaping(_ result: AuthResult<[String: Any]?>) -> Void){
        self.completion = completion
        
        let localSignInController = AuthSignInViewController(style: .noSocial)
        localSignInController.delegate = self
        localSignInController.service = service

        DispatchQueue.main.async {
            controller.present(localSignInController, animated: false, completion: nil)
        }
    }
}

//MARK: - AuthSignInDelegate
extension AuthLocalProvider: AuthSignInDelegate{
    func authSignInViewController(_ authSignInViewController: AuthSignInViewController, didFinishSignInWith result: AuthResult<AuthSession>) {
        switch result {
        case .success(let session):
            completion?(AuthResult.success(["session": session]))
        default:
            completion?(AuthResult.failure(AuthError.failed))
        }
    }
}
