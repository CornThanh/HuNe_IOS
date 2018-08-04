//
//  SelectionItem.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/14/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

protocol SelectionItemProtocol {

    func iconURL() -> String?
    func title() -> String?
    func isChosen() -> Bool
    func setIsChosen(_ value: Bool) -> Void
    func associatedValue() -> Any?
    
}
