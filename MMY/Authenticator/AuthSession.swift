//
//  AuthenSession.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class AuthSession: NSObject {
    //MARK: - Properties
    var sessionId: String = ""
    var user: AuthUser?
    var expired: Int = 0
    
    init(sessionId: String, user: AuthUser, expired: Int){
        super.init()
        self.sessionId = sessionId
        self.user = user
        self.expired = expired

    }
}
