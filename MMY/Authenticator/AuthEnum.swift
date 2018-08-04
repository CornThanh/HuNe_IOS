//
//  AuthenEnum.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

enum LoginType: String{
    case facebook       = "facebook"
    case google         = "google"
    case guest          = "guest"
    case local          = "local"
}

enum AuthResult<T> {
    case success(T)
    case failure(AuthError)
}

enum SignInStyle: String{
    case hasSocial      = "hasSocial"
    case noSocial       = "noSocial"
    case onlySocial     = "onlySocial"
}

//MARK: - Error Enum
enum AuthError: Error{
    case failed
    case cancelled
    case missingService
    case missingProvider
    case missingParams
    case missingSession
    case responseEmpty
    case noInternet
    
    static func handle(_ error: ErrorModel) -> AuthError{
        if error.errorCode == .unknownException{
            return .noInternet
        }else {
            return .failed
        }
    }
}
