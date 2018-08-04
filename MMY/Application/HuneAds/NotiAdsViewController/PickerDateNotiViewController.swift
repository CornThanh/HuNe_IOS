//
//  PickerDateNotiViewController.swift
//  MMY
//
//  Created by Apple on 5/19/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit

class PickerDateNotiViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    private weak var calendar: FSCalendar!
    var status = ""
    
    init(status: String) {
        super.init(nibName: "PickerDateNotiViewController" , bundle: nil)
        self.status = status
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendar"
        let todayItem = UIBarButtonItem(image: UIImage(named: "ic_done_white"), style: .plain, target: self, action: #selector(todayItemClicked))
        self.navigationItem.rightBarButtonItem = todayItem
    }
    
    override func loadView() {
        
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.groupTableViewBackground
        self.view = view
        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 400 : 300
        let calendar = FSCalendar(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: self.view.bounds.width, height: height))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.backgroundColor = UIColor.white
        self.view.addSubview(calendar)
        self.calendar = calendar
        
    }
    
    func todayItemClicked() {
        self.navigationController?.popViewController(animated: true)
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let myString = formatter.string(from: date)
        ShareData.datePicker[status] = myString
    }
    
}

