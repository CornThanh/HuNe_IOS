//
//  PickerDateViewController.swift
//  MMY
//
//  Created by Apple on 5/7/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class PickerDateViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    fileprivate weak var calendar: FSCalendar!
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var arrDates = [String]()
    
    let fillSelectionColors = ["2015/10/08": UIColor.green, "2015/10/06": UIColor.purple, "2015/10/17": UIColor.gray, "2015/10/21": UIColor.cyan, "2015/11/08": UIColor.green, "2015/11/06": UIColor.purple, "2015/11/17": UIColor.gray, "2015/11/21": UIColor.cyan, "2015/12/08": UIColor.green, "2015/12/06": UIColor.purple, "2015/12/17": UIColor.gray, "2015/12/21": UIColor.cyan]
    
    
    let fillDefaultColors = ["2015/10/08": UIColor.purple, "2015/10/06": UIColor.green, "2015/10/18": UIColor.cyan, "2015/10/22": UIColor.yellow, "2015/11/08": UIColor.purple, "2015/11/06": UIColor.green, "2015/11/18": UIColor.cyan, "2015/11/22": UIColor.yellow, "2015/12/08": UIColor.purple, "2015/12/06": UIColor.green, "2015/12/18": UIColor.cyan, "2015/12/22": UIColor.magenta]
    
    let borderDefaultColors = ["2015/10/08": UIColor.brown, "2015/10/17": UIColor.magenta, "2015/10/21": UIColor.cyan, "2015/10/25": UIColor.black, "2015/11/08": UIColor.brown, "2015/11/17": UIColor.magenta, "2015/11/21": UIColor.cyan, "2015/11/25": UIColor.black, "2015/12/08": UIColor.brown, "2015/12/17": UIColor.magenta, "2015/12/21": UIColor.purple, "2015/12/25": UIColor.black]
    
    let borderSelectionColors = ["2015/10/08": UIColor.red, "2015/10/17": UIColor.purple, "2015/10/21": UIColor.cyan, "2015/10/25": UIColor.magenta, "2015/11/08": UIColor.red, "2015/11/17": UIColor.purple, "2015/11/21": UIColor.cyan, "2015/11/25": UIColor.purple, "2015/12/08": UIColor.red, "2015/12/17": UIColor.purple, "2015/12/21": UIColor.cyan, "2015/12/25": UIColor.magenta]

    override func loadView() {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        self.view = view
        
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 450 : 300
        let calendar = FSCalendar(frame: CGRect(x:0, y:64, width:self.view.bounds.size.width, height:height))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = true
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.backgroundColor = UIColor.white
        calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        self.view.addSubview(calendar)
        self.calendar = calendar
        calendar.select(self.dateFormatter1.date(from: "2015/10/03"))
        let todayItem = UIBarButtonItem(image: UIImage(named: "ic_done_white"), style: .plain, target: self, action: #selector(self.todayItemClicked(sender:)))
        self.navigationItem.rightBarButtonItem = todayItem
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        //
        self.calendar.setCurrentPage(Date(), animated: false)
    }
    
    deinit {
        print("\(#function)")
    }
    
    @objc
    func todayItemClicked(sender: AnyObject) {
        AdsLocation.dates = arrDates
        ShareData.arrDates = arrDates
        self.navigationController?.popViewController(animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        ShareData.totalDateChoose = ShareData.totalDateChoose + 1
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myString = formatter.string(from: date)
        arrDates.append(myString)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        ShareData.totalDateChoose = ShareData.totalDateChoose - 1
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myString = formatter.string(from: date)
        for index in 0..<arrDates.count {
            if arrDates[index] == myString {
                arrDates.remove(at: index)
                break
            }
        }
    }
    

}
