//
//  AuthenUser.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class AuthUser: NSObject {
    //MARK: - Properties
    var id: String = ""
    var display: String? = ""
    var verified: Bool = false
    
    init(id: String, display: String?, verified: Bool){
        self.id = id
        self.display = display
        self.verified = verified
    }
}
