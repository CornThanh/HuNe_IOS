//
//  Enums.swift
//  MMY
//
//  Created by Akiramonster on 2/16/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import Foundation
import XCGLogger

let log = XCGLogger(identifier: "vn.asquare.mmy")
let kPresentPostNotification = NSNotification.Name(rawValue: "kPresentPostNotification")

enum ErrorCode: Int {
//    case success                = 0
//    case badRequest             = 1
//    case unauthorized           = 2
//    case forbidden              = 3
//    case notFound               = 4
    case failed                 = 5
//    case serviceOffline         = 6
//    case internalServerError    = 7

    case success                = 200
    case accessDenied           = 403
    case notFound               = 404
    case exists                 = 409
    case error                  = 500
    
    //app specific errors
    case unknownException       = 1000
    case invalidData            = 1001
    case userCanceled           = 1002
}

enum PostType: Int {
    case findPeople = 1
    case findJob = 2
    
    static let allValues = [findPeople, findJob]
    static func allTitles() -> [String] {
        return ["Find jobs".localized(), "Find people".localized()]
    }
    
    func title() -> String {
        switch self {
        case .findPeople: return "Find people".localized()
        case .findJob: return "Find jobs".localized()
        }
    }
    
    func typeString() -> String {
        switch self {
        case .findPeople: return "1"
        case .findJob: return "2"
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .findJob:
            return UIColor(hexString: "#CC3333")
        case .findPeople:
            return UIColor(hexString: "#33CCFF")
        }
    }
}

enum Language: String {
    case english = "English"
    case vietnamese = "Vietnamese"
    
    static let allValues = [english, vietnamese]
    static let allShortTitles = ["en", "vi"]
    static func allTitles() -> [String] {
        return ["English".localized(), "Vietnamese".localized()]
    }
    
    func title() -> String {
        switch self {
        case .english: return "English".localized()
        case .vietnamese: return "Vietnamese".localized()
        }
    }
    
    func shortTitle() -> String {
        switch self {
        case .english: return "en"
        case .vietnamese: return "vi"
        }
    }
}
