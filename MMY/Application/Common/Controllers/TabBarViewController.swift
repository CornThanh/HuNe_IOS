//
//  TabBarViewController.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/13/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view
        
        let tabs: [(type: ControllerType, title: String)] = [
            
        ]
        
        
        var controllers = [UIViewController]()
        for controller in tabs {
            let newController = ControllerFactory.shared.makeController(type: .base)
            newController.title = controller.title
            newController.tabBarItem.image = UIImage()
            let navigation = UINavigationController(rootViewController: newController)
            controllers.append(navigation)
            
        }
        viewControllers = controllers
    }
}
