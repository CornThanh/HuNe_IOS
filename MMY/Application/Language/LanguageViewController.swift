//
//  LanuageViewController.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 9/25/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit
import Eureka
import Localize_Swift

class LanguageViewController: FormViewController {

    var currentLanguage: Language?
    var newLanguage: Language?
    let btnConfirm = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose language".localized()

        let section = SelectableSection<ListCheckRow<String>>("Current language".localized(), selectionType: .singleSelection(enableDeselection: false))
        let languages = Language.allTitles()
        let strCurrent = getCurrentLanguage()

        for lang in languages {
            let row = ListCheckRow<String>(lang)
            row.title = lang
            row.selectableValue = strCurrent
            if strCurrent == lang {
                row.value = strCurrent
            }
            else {
                row.value = nil
            }
            row.onChange({ (row) in
                if  let _ = row.value, let index = row.indexPath?.row {
                    self.newLanguage = Language.allValues[index]
                    UserDefaults.standard.set(self.newLanguage!.shortTitle(), forKey: "LCLCurrentLanguageKey")
                    UserDefaults.standard.synchronize()

                    let section = self.form.allSections.first
                    var header = section?.header
                    header?.title = "Current language".localized()
                    section?.header = header
                    section?.reload()
                    self.title = "Choose language".localized()
                    self.btnConfirm.setTitle("OK".localized().uppercased(), for: .normal)
                }
            })
            section.append(row)
        }
        form.append(section)

        addLeftBarButton()

        if let countVCs = navigationController?.viewControllers.count, countVCs == 1 {
            let backGroundColor = UIColor(hexString: "#33CCFF") ?? .appColor
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.barTintColor = backGroundColor
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        }

        let buttonWidth: CGFloat = 190
        let tablePaddingCell: CGFloat = 20
        let buttonHeight: CGFloat = 44
        let cornerRadius: CGFloat = CGFloat(20).fixHeight()

        // verify
        btnConfirm.backgroundColor = UIColor(hexString: "#0099cc")
        btnConfirm.layer.cornerRadius = cornerRadius
        btnConfirm.setTitle("OK".localized().uppercased(), for: UIControlState.normal)
        btnConfirm.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        btnConfirm.titleLabel?.textColor = UIColor.white
        btnConfirm.addTarget(self, action: #selector(LanguageViewController.btnConfirmTouched), for: .touchUpInside)
        view.addSubview(btnConfirm)

        btnConfirm.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.width.equalTo(buttonWidth.fixWidth())
            make.height.equalTo(buttonHeight.fixHeight())
            make.bottom.equalTo(view.snp.bottom).offset(0 - tablePaddingCell.fixWidth())
        }
    }

    override func addLeftBarButton() {
        if let num = navigationController?.viewControllers.count, num == 1 {
            let leftButton = UIButton.init(type: .custom)
            leftButton.setImage(UIImage(named: "ic_close_blue")?.withRenderingMode(.alwaysTemplate), for: .normal)
            leftButton.addTarget(self, action:#selector(dissmiss), for: UIControlEvents.touchUpInside)
            leftButton.frame = CGRect.init(x: 0, y: 0, width: 10, height: 20)
            leftButton.tintColor = .white
            leftButton.backgroundColor = .clear
            let leftBarButton = UIBarButtonItem.init(customView: leftButton)
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
        else {
            super.addLeftBarButton()
        }
    }
    
    func dissmiss() {
        if let currentLanguage = currentLanguage {
            // revert lang
            UserDefaults.standard.set(currentLanguage.shortTitle(), forKey: "LCLCurrentLanguageKey")
            UserDefaults.standard.synchronize()
        }
        dismiss(animated: true, completion: nil)
    }

    func btnConfirmTouched() {
        if let _ = newLanguage {
            // confirm lang
            NotificationCenter.default.post(name: Notification.Name(rawValue: LCLLanguageChangeNotification), object: nil)
        }
        //newLanguage?.hashValue  0: English, 1: Viet nam
        if newLanguage?.hashValue == 0 {
            ShareData.changePhoneVerify = true
        } else {
            ShareData.changePhoneVerify = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getCurrentLanguage() -> String {
        if let strCurrent = currentLanguage?.title() {
            return strCurrent
        }
        let currentLanguageShort = Localize.currentLanguage()
        if let index = Language.allShortTitles.index(of: currentLanguageShort) {
            currentLanguage = Language.allValues[index]
            return currentLanguage!.title()
        }
        return "Vietnamese".localized()
    }
}
