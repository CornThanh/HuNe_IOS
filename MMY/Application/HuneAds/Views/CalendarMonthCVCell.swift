//
//  CalendarMonthCVCell.swift
//  MMY
//
//  Created by Nguyen Minh Phuong on 3/22/18.
//  Copyright © 2018 Blue R&D. All rights reserved.
//

import UIKit


class CalendarMonthCVCell: UICollectionViewCell {
    
    @IBOutlet var calendarView: JTAppleCalendarView! {
        didSet {
            let nib = UINib(nibName: "CalendarDateCVCell", bundle: nil)
            calendarView.register(nib, forCellWithReuseIdentifier: "cell")
        }
    }
    @IBOutlet var theView: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    let formatter = DateFormatter()
    var dict : [JTAppleCell: [CellState]] = [JTAppleCell: [CellState]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.allowsMultipleSelection = true
        
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
        
        func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
            guard let startDate = visibleDates.monthDates.first?.date else {
                return
            }
            
            let month = Calendar.current.dateComponents([.month], from: startDate).month!
            let monthName = DateFormatter().monthSymbols[(month-1) % 12]
            // 0 indexed array
            let year = Calendar.current.component(.year, from: startDate)
            //        monthLabel.text = monthName + " " + String(year)
        }
        
        func configureCell(view: JTAppleCell?, cellState: CellState) {
            guard let myCustomCell = view as? CalendarDateCVCell  else { return }
            handleCellTextColor(view: myCustomCell, cellState: cellState)
            handleCellSelection(view: myCustomCell, cellState: cellState)
        }
        
        func handleCellSelection(view: CalendarDateCVCell, cellState: CellState) {
            if calendarView.allowsMultipleSelection {
                switch cellState.selectedPosition() {
                case .full: view.backgroundColor = .green
                case .left: view.backgroundColor = .yellow
                case .right: view.backgroundColor = .red
                case .middle: view.backgroundColor = .blue
                case .none: view.backgroundColor = nil
                }
            } else {
                if cellState.isSelected {
                    view.backgroundColor = UIColor.red
                } else {
                    view.backgroundColor = UIColor.white
                }
            }
            
        }
        
        func handleCellTextColor(view: CalendarDateCVCell, cellState: CellState) {
            if cellState.dateBelongsTo == .thisMonth {
                view.dayLabel.textColor = UIColor.black
            } else {
                view.dayLabel.textColor = UIColor.gray
            }
        }
    }

extension CalendarMonthCVCell: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarDateCVCell
        configureCell(view: cell, cellState: cellState)
        if cellState.text == "1" {
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            print(date)
            print(month)
            cell.dayLabel .text = "\(month) \(cellState.text)"
        } else {
            cell.dayLabel .text = cellState.text
        }
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2030 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
        dict[cell!]?.append(cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
        if let dataCellState = dict[cell!] {
            if dataCellState.count > 0 {
                for index in 0..<dataCellState.count {
                    if dataCellState[index].date == cellState.date {
                        dict[cell!]?.remove(at: index)
                        break
                    }
                }
            } else {
                dict.removeValue(forKey: cell! )
            }
        }
    }
}
