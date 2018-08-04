
import UIKit
import SwiftyJSON

class NotificationModel: BaseModel {
    var notificationID: String?
    var title: String?
    var content: String?
    var chanel: String?
    var isRead: Bool?
    var type: String?
    var created_at: String?
	var postOwner: String?
	var postID: String?
    
    required init?(json: JSON) {
        super.init(json: json)
        notificationID      = json["id"].stringValue
        title               = json["title"].stringValue
        content             = json["content"].stringValue
        chanel              = json["chanel"].stringValue
        isRead              = false
        type                = json["type"].stringValue
        created_at          = json["created_at"].stringValue
		postOwner          = json["owner_post"].stringValue
		postID          	= json["post_id"].stringValue
    }
    
}
