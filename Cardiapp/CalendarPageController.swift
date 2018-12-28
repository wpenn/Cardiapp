//
//  CalendarPageController.swift
//  Cardiapp
//
//  Created by Wesley Penn on 4/8/18.
//  Copyright © 2018 Riverdale Country School. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarPageController: UIViewController {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    var cellIsSelected = false
    
    var selectedDate = Date() //local variable for cell selected date value
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendarView()
    }
    
    func setupCalendarView(){
        //setup calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //setup month,year labels
        calendarView.visibleDates{ (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else{
            return
        }
        
        if cellState.isSelected{
            validCell.dateLabel.textColor = UIColor.white
//            validCell.dateLabel.textColor = UIColor.black
        } else{
            if cellState.dateBelongsTo == .thisMonth && Calendar.current.compare(Date(), to: cellState.date, toGranularity: .day).rawValue != -1{
                validCell.dateLabel.textColor = UIColor.black
            } else{
                validCell.dateLabel.textColor = UIColor.lightGray
            }
        }
        
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else{
            return
        }
        if cellState.isSelected{
            validCell.selectedView.isHidden = false
            cellIsSelected = true
        } else{
            validCell.selectedView.isHidden = true
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }
    
    //**This is the outlet for moving the calendar into and out of the main interface, but since it is on a different viewController, then it is unnecessary
    //@IBOutlet weak var calendarSliderView: UIView!
    
    
    @IBAction func calendarCancelButton(_ sender: Any) {
        //perform unwind segue from calendar to cardigraph/ViewController (main) page
        performSegue(withIdentifier: "unwindToViewController", sender: self)
    }
    
    
    //done button –-> user finished date selection process and now we pass the date to the main interface
    @IBAction func calendarDoneButton(_ sender: UIButton) { //*** NEEDS WORK WITH THE PROTOCOLS TO HIDE THE CALENDAR AND RETURN TO MAIN INTERFACE (I NEED THE ASSISTANCE OF WILLIAM LACK)
        
        if cellIsSelected{
            calendarSelectedDate = selectedDate //setting global date to the last selected cell date value
            performSegue(withIdentifier: "unwindToViewController", sender: self)
        }
        else{
            //Creating UIAlertController and setting title and message for the alert dialog
            let alertController = UIAlertController(title: "Error", message: "Please select the date.", preferredStyle: .alert)
            //the confirm action taking the inputs
            let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
            //adding the action to dialogbox
            alertController.addAction(okAction)
            //finally presenting the dialog box
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CalendarPageController: JTAppleCalendarViewDataSource{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        
        let currentCalendar = Calendar.current
        let dateAdjustedForTimeZoneString = "\(currentCalendar.component(.year, from: Date())) \(Calendar.current.component(.month, from: Date())) \(Calendar.current.component(.day, from: Date()))"
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: formatter.date(from: dateAdjustedForTimeZoneString)!)!
        let endDate = formatter.date(from: dateAdjustedForTimeZoneString)!
        
        calendar.scrollToDate(endDate) {
            calendar.selectDates([endDate])
        }
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
}

extension CalendarPageController: JTAppleCalendarViewDelegate{
    //required function --> Unsure of its purpose
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {}
    
    //displaying the cell in the calendar
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        cell.dateLabel.text = cellState.text
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        //handling cell coloring
        if cellState.dateBelongsTo == .thisMonth && Calendar.current.compare(Date(), to: date, toGranularity: .day).rawValue != -1 {
            handleCellSelected(view: cell, cellState: cellState)
            handleCellTextColor(view: cell, cellState: cellState)
            
            //this variable is pased to the main interface (graph/healthkit components)
            selectedDate = date
        } else{
            print("Not in this month")
            if cellState.dateBelongsTo == .followingMonthOutsideBoundary{
                print("Date outside of boundary")
                cellIsSelected = false
            } else if cellState.dateBelongsTo == .followingMonthWithinBoundary{
                calendar.scrollToDate(date) {
                    calendar.selectDates([date])
                }
            } else if cellState.dateBelongsTo == .previousMonthOutsideBoundary{
                print("Date outside of boundary")
                cellIsSelected = false
            } else if cellState.dateBelongsTo == .previousMonthWithinBoundary{
                calendar.scrollToDate(date) {
                    calendar.selectDates([date])
                }
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
        calendar.deselectAllDates()
        cellIsSelected = false
    }
    
    func calendarDidScroll(_ calendar: JTAppleCalendarView) {
        calendar.deselectAllDates()
        cellIsSelected = false
    }
    
    func scrollRight(_ calendar: JTAppleCalendarView, cellState: CellState, cell: CellState){
        calendar.scrollToDate(Calendar.current.date(byAdding: .month, value: 1, to: cell.date)!)
    }
    func scrollLeft(_ calendar: JTAppleCalendarView, cellState: CellState, cell: CellState){
        calendar.scrollToDate(Calendar.current.date(byAdding: .month, value: -1, to: cell.date)!)
    }
    func goToToday(_ calendar: JTAppleCalendarView){
        calendar.scrollToDate(Date()) {
            calendar.selectDates([Date()])
        }
    }
}
