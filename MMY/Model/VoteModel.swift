
import UIKit
import SwiftyJSON

class VoteModel: BaseModel {
    var voteID: String?
    var comment: String?
    var rate: CGFloat?
    var type: String?
    var nameUserVote: String?
    
    required init?(json: JSON) {
        super.init(json: json)
        voteID = json["id"].stringValue
        comment = json["comment"].stringValue
        type = json["type"].stringValue
        rate = CGFloat(json["rate"].floatValue)
        nameUserVote = json["user"]["full_name"].stringValue
    }
}

