//
//  TaskModel.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 11/20/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import SwiftyJSON


enum TaskStatus: Int, CustomStringConvertible {
    case waiting = 1, working, completed, rejected

    var description: String {
        switch self {
        case .waiting:
            return "NotConfirm".localized()
        case .working:
            return "Working".localized()
        case .rejected:
            return "Rejected".localized()
        case .completed:
            return "Completed".localized()
        }
    }

    var iconName: String {
        switch self {
        case .waiting:
            return "icWaiting"
        case .working:
            return "icWorking"
        case .rejected:
            return "icWaiting"
        case .completed:
            return "icFinished"
        }
    }

    var icon: UIImage? {
        return UIImage(named: iconName)
    }
}

class TaskModel: BaseModel {

    var id =  ""
    var ownerId =  ""
    var post: PostModel?
    var cost: Int = 0
    var name = ""
    var candidate: UserModel?
    var note: String = ""

    var startDate: String?
    var startHour: String?
    var endDate: String?
    var endHour: String?
    var status: TaskStatus = .waiting
    var statusPayment: Int = 1

    required init?(json: JSON) {
        guard json.error == nil else {
            return nil
        }
        super.init(json: json)

        id = json["id"].stringValue
        cost = json["amount"].intValue
        name = json["name"].stringValue
        startDate = json["start_date"].stringValue
        startHour = json["start_hour"].stringValue
        endDate = json["end_date"].stringValue
        endHour = json["end_hour"].stringValue
        status = TaskStatus(rawValue: json["status"].intValue) ?? .waiting
        statusPayment = json["status_payment"].intValue
        note = json["description"].stringValue
        post = PostModel(json: json["post"])
        candidate = UserModel(json: json["user"])
        ownerId = json["owner_id"].stringValue
    }
}
