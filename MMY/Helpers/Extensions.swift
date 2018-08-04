//
//  Extensions.swift
//  MMY
//
//  Created by Akiramonster on 2/16/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

extension UIViewController {
    func set(titleColor: UIColor, titleFont: UIFont) {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0.6)
        shadow.shadowColor = UIColor.clear
        let settings = [NSFontAttributeName : titleFont,
                        NSForegroundColorAttributeName : titleColor,
                        NSShadowAttributeName : shadow]
        navigationController?.navigationBar.titleTextAttributes = settings
    }
    
    func display(controller: UIViewController) {
        addChildViewController(controller)
        controller.view.frame = view.bounds
        view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    func hide(controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        
    }
    
    open func safePresent(_ viewControllerToPresent: UIViewController?, animated flag: Bool,usingNavigation: Bool = true, completion: (() -> Swift.Void)? = nil) {
        guard viewControllerToPresent != nil else {
            log.error("Can't present nil controller")
            return
        }
        
        let controller = usingNavigation ? UINavigationController(rootViewController: viewControllerToPresent!) : viewControllerToPresent!
        present(controller, animated: flag, completion: completion)
    }
    
}

extension UINavigationController {
    open func safePushViewController(_ viewController: UIViewController?, animated: Bool) {
        
        guard viewController != nil else {
            log.error("Can't push nil controller")
            return
        }
        
        pushViewController(viewController!, animated: animated)
    }
}


extension UIColor {

    open class var appColor: UIColor { return UIColor(red: 60/255.0, green: 186/255.0, blue: 236/255.0, alpha: 1.0) }
    open class var separatorColor: UIColor { return UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0) }
    open class var redMarkerColor: UIColor { return UIColor(red: 232.0/255, green: 60.0/255, blue: 64.0/255, alpha: 1) }
    open class var greenMarkerColor: UIColor { return UIColor(red: 64.0/255, green: 206.0/255, blue: 182.0/255, alpha: 1) }
    //open class var appColor: UIColor { return UIColor(red: 0, green: 179.0/255, blue: 62.0/255, alpha: 1) }

    open class var facebook: UIColor { return UIColor.blue }//HexColor("3b5998")! }
    open class var feedDivider: UIColor { return UIColor(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0) }
}

extension Date {
    func relative() -> String {
        
        
         let components = Set<Calendar.Component>([.day ,.month ,.year , .hour ,.minute , .weekOfYear , .weekday])
         let c1 = Calendar.current.dateComponents(components, from: self)
         let c2 = Calendar.current.dateComponents(components, from: Date())
         
         if  c1.second != nil && c2.second != nil && c1.minute == c2.minute && c1.hour == c2.hour && c1.day == c2.day && c1.month == c2.month && c1.year == c2.year{
         return "\(c2.second! - c1.second!) giây trước"
         }
         
         if  c1.minute != nil && c2.minute != nil && c1.hour == c2.hour && c1.day == c2.day && c1.month == c2.month && c1.year == c2.year{
         return "\(c2.minute! - c1.minute!) phút trước"
         }
         
         if  c1.hour != nil && c2.hour != nil && c1.day == c2.day && c1.month == c2.month && c1.year == c2.year{
         return "\(c2.hour! - c1.hour!) giờ trước"
         }
         
         if c1.year == c2.year {
         return format(format: "dd/MM HH:mm")
         }
         
         return format(format: "dd/MM/yyyy")
        
    }
    
    func format(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Array {
    public mutating func safeAppend(_ newElement: Element?) {
        if newElement != nil {
            append(newElement!)
        }
    }
}


extension JSON {
    func parseArray<C: BaseModel>() -> [C]? {
        if let items = self.array {
            var results = [C]()
            for item in items {
                results.safeAppend(C(json: item))
            }
            return results
        }
        return nil
    }
    
    func parseArrayValue<C: BaseModel>() -> [C] {
        if let items = self.array {
            var results = [C]()
            for item in items {
                results.safeAppend(C(json: item))
            }
            return results
        }
        return [C]()
    }
}

extension UIView {
    func safeAddSubview(_ view: UIView?) {
        if let view = view {
            addSubview(view)
        }
    }
}

extension UIAlertController {
    static func showSimpleAlertView(in controller: UIViewController,
                             title: String,
                             message: String? = nil,
                             buttonTitle: String? = nil,
                             action: ((UIAlertAction)->Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: buttonTitle ?? "OK".localized(), style: .default, handler: action)
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func showDiscardAlertView(in controller: UIViewController,
                                           title: String? = nil,
                                           message: String? = nil,
                                           buttonTitle: String? = nil,
                                           action: ((UIAlertAction)->Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message ?? "Discard changes?".localized(), preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: buttonTitle ?? "Discard".localized(), style: .destructive, handler: action)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
        
    }
}

extension UITableViewCell {
    func addSeparator() {
        let separator = UIView(frame: CGRect.zero)
        separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        contentView.addSubview(separator)
        separator.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(50)
            make.right.equalTo(contentView).offset(-50)
            make.bottom.equalTo(contentView).offset(-5)
            make.height.equalTo(1)
        }
    }
}

extension UITextField {
    func stringAfterAddSeparateFromLeft(){
        let str = self.text?.replacingOccurrences(of: ".", with: "")
        var ret = ""
        let length = str!.characters.count
        for i in 0 ..< length {
            ret = ret + (NSString(string: str!).substring(with: NSMakeRange(i, 1)) as String)
            if ((i + 1) % 3 == 0) && (i != (length - 1)) {
                ret = ret + "."
            }
        }
        self.text = ret
    }
}

extension UIButton {
    func shadowButton() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
