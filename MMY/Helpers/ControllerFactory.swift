//
//  ControllerFactory.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

enum ControllerType : String {
    case base = "BaseViewController"
    case splash = "SplashScreenViewController"
    case about = "AboutViewController"
    case popup = "PopupViewController"
    case post = "PostViewController"
    case profile = "ProfileViewController"

}

class ControllerFactory {

    private init() {
        
    }
    
    static var shared = ControllerFactory()
    
    func makeController(type: ControllerType, with data: [String : Any]? = nil) -> UIViewController {
        switch type {
        case .profile: return makeProfileViewController(with: data)
        case .post: return makePostViewController(with: data)
        case .popup: return PopupViewController()
        case .about: return AboutViewController()
        case .splash: return SplashScreenController()
        default:
            return BaseViewController()
        }
    }
    
    private func makeProfileViewController(with data: [String: Any]?) -> ProfileViewController {
        let profileVC = ProfileViewController()
        profileVC.userModel = data?["user"] as? UserModel ?? nil
        profileVC.allowsEditing = data?["allowsEditing"] as? Bool ?? false
        profileVC.canBeDismissed = data?["canBeDismissed"] as? Bool ?? true
        return profileVC
    }
    
    private func makePostViewController(with data: [String: Any]?) -> PostViewController {
        let postVC = PostViewController()
        postVC.categories = data?["categories"] as? [CategoryModel] ?? [CategoryModel]()
        postVC.postModel = data?["postModel"] as? TempPostModel ?? TempPostModel()
        return postVC
    }
}
