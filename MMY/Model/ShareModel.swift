
import UIKit
import SwiftyJSON

class ShareModel: BaseModel {
    var url: String?
    required init?(json: JSON) {
        super.init(json: json)
        url = json["url"].stringValue
    }
}
