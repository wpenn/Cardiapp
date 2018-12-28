//
//  detailTableViewController2.swift
//  Cardiapp
//
//  Created by Sam Lack on 5/15/18.
//  Copyright © 2018 Riverdale Country School. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class detailTableViewController2: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var editActivityTextField: UITextField!
    @IBOutlet weak var editStartTimeTextField: UITextField!
    @IBOutlet weak var editEndTimeTextField: UITextField!
    @IBOutlet weak var editStarSwitch: UISwitch!
    
    var index:Int?
    var activityArray:[String]!
    var editedActivity:String?
    
    var activityToolBar = UIToolbar()
    var activityPickerData = ["Soccer ⚽️","Running 🏃","Sleeping 💤","Eating 🍔","Drinking 🍸","Smoking 🚬","Watching TV 📺","Basketball 🏀","Football 🏈","Baseball ⚾️","Walking 🚶","Lifting Weights 🏋️‍♀️","Dancing 💃","Tennis 🎾","Volleyball 🏐","Ping Pong 🏓","Ice Hockey 🏒","Field Hockey 🏑","Archery 🏹","Fishing 🎣","Boxing 🥊","Martial Arts 🥋","Skiing ⛷","Snowboarding 🏂","Ice Skating ⛸","Wrestling 🤼‍♀️","Gymnastics 🤸‍♀️","Golf 🏌️","Surfing 🏄","Water Polo 🤽‍♀️","Swimming 🏊‍♀️","Rowing 🚣‍♀️","Horseback Riding 🏇","Biking 🚴","Mountain Biking 🚵‍♀️","Juggling 🤹‍♂️","Rugby 🏉","Pool 🎱","Badminton 🏸","Cricket 🏏","Bowling 🎳","Video Games 🎮","Darts 🎯","Fencing 🤺","Trumpet 🎺","Piano 🎹","Drums 🥁","Saxophone 🎷","Guitar 🎸","Violin 🎻","Dodgeball 🤾‍♂️","Singing 🎤"]
    
    var startTimeArray:[Date]!
    var editedStartTime:Date?
    var endTimeArray:[Date]!
    var editedEndTime:Date?
    var starArray:[Bool]!
    var editedStar:Bool?
    
    var StartTimePicker = UIDatePicker()
    var StartTimeToolBar = UIToolbar()
    var selectedStartDateString: String = ""
    var EndTimePicker = UIDatePicker()
    var EndTimeToolBar = UIToolbar()
    var selectedEndDateString: String = ""
    
    @IBAction func editStarSwitchClicked(_ sender: Any) {
        if editStarSwitch.isOn {
            editedStar = true
        }
        else {
            editedStar = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityPickerData.sort()
        let activityPicker = UIPickerView()
        createActivityToolBar()
        activityPicker.delegate = self
        editActivityTextField.inputView = activityPicker
        editActivityTextField.inputAccessoryView = activityToolBar
        
        editActivityTextField.text = activityArray[index!]
        
        createStartTimeDatePicker()
        createStartTimeToolBar()
        addStartTimeText()
        createEndTimeDatePicker()
        createEndTimeToolBar()
        addEndTimeText()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let startDateAppear = dateFormatter.string(from: startTimeArray[index!])
        let endDateAppear = dateFormatter.string(from: endTimeArray[index!])
        
        editStartTimeTextField.text = startDateAppear
        editEndTimeTextField.text = endDateAppear
        
        if starArray[index!] == true {
            editStarSwitch.isOn = true
        } else if starArray[index!] == false {
            editStarSwitch.isOn = false
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    //ACTIVITY PICKER
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activityPickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activityPickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editActivityTextField.text = activityPickerData[row]
        editedActivity = editActivityTextField.text!
    }
    func createActivityToolBar() {
        activityToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(activityDoneButtonPressed(sender:)))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        label.text = "Activity"
        let labelButton = UIBarButtonItem(customView:label)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        activityToolBar.setItems([flexibleSpace,labelButton,flexibleSpace,doneButton], animated: true)
    }
    @objc func activityDoneButtonPressed(sender: UIBarButtonItem) {
        editActivityTextField.resignFirstResponder()
    }
    
    //START TIME PICKER
    func addStartTimeText() {
        editStartTimeTextField.inputView = StartTimePicker
        editStartTimeTextField.inputAccessoryView = StartTimeToolBar
    }
    func createStartTimeDatePicker() {
        StartTimePicker.datePickerMode = .dateAndTime
        StartTimePicker.minuteInterval = 5
        StartTimePicker.addTarget(self, action: #selector(self.startDatePickerValueChanged(datePicker:)), for: .valueChanged)
    }
    func createStartTimeToolBar() {
        StartTimeToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(startDoneButtonPressed(sender:)))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        label.text = "Start Time"
        let labelButton = UIBarButtonItem(customView:label)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        StartTimeToolBar.setItems([flexibleSpace,labelButton,flexibleSpace,doneButton], animated: true)
    }
    @objc func startDoneButtonPressed(sender: UIBarButtonItem) {
        editStartTimeTextField.resignFirstResponder()
    }
    @objc func startDatePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        selectedStartDateString = dateFormatter.string(from: datePicker.date)
        editStartTimeTextField.text = selectedStartDateString
    }
    
    //END TIME PICKER
    func addEndTimeText() {
        editEndTimeTextField.inputView = EndTimePicker
        editEndTimeTextField.inputAccessoryView = EndTimeToolBar
    }
    func createEndTimeDatePicker() {
        EndTimePicker.datePickerMode = .dateAndTime
        EndTimePicker.minuteInterval = 5
        EndTimePicker.addTarget(self, action: #selector(self.endDatePickerValueChanged(datePicker:)), for: .valueChanged)
    }
    func createEndTimeToolBar() {
        EndTimeToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endDoneButtonPressed(sender:)))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        label.text = "End Time"
        let labelButton = UIBarButtonItem(customView:label)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        EndTimeToolBar.setItems([flexibleSpace,labelButton,flexibleSpace,doneButton], animated: true)
    }
    @objc func endDoneButtonPressed(sender: UIBarButtonItem) {
        editEndTimeTextField.resignFirstResponder()
    }
    @objc func endDatePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        selectedEndDateString = dateFormatter.string(from: datePicker.date)
        editEndTimeTextField.text = selectedEndDateString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*override*/ func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            editActivityTextField.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            editStartTimeTextField.becomeFirstResponder()
        } else if indexPath.section == 2 && indexPath.row == 0 {
            editEndTimeTextField.becomeFirstResponder()
        } else if indexPath.section == 3 && indexPath.row == 0 {
            editStarSwitch.becomeFirstResponder()
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    */
    
    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "save" {
            
            editedActivity = editActivityTextField.text
            let startDateArr = editStartTimeTextField.text?.components(separatedBy: " at ")
            let startDateFixed = "\(startDateArr![0]), \(startDateArr![1])"
            let endDateArr = editEndTimeTextField.text?.components(separatedBy: " at ")
            let endDateFixed = "\(endDateArr![0]), \(endDateArr![1])"
            
            //Date Formatting
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy, h:mm a" //Your date format
            editedStartTime = dateFormatter.date(from: startDateFixed) //according to date format your date string
            editedEndTime = dateFormatter.date(from: endDateFixed)
            editedStar = editStarSwitch.isOn
            
            //saveToCoreData(data: (editedActivity, editedStartTime, editedEndTime, editedStar) as! (String, Date, Date, Bool))
            if editActivityTextField.text == "" {
                showMessageDialog4()
            } else {
                if editedStartTime! < editedEndTime! {
                    saveToCoreData(data: (editedActivity, editedStartTime, editedEndTime, editedStar) as! (String, Date, Date, Bool))
                    loadFromCoreData()
                } else if editedEndTime! == Date(timeIntervalSinceReferenceDate: 118800) || editedStartTime! == Date(timeIntervalSinceReferenceDate: 118800) {
                    showMessageDialog3()
                } else if editedStartTime! == editedEndTime! {
                    showMessageDialog3()
                } else if editedStartTime! > editedEndTime! {
                    showMessageDialog2()
                }
            }
        }
    }
    
    func showMessageDialog2() {
        //Creating UIAlertController and setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Error", message: "The end time of your activity is before the start time of your activity", preferredStyle: .alert)
        //the confirm action taking the inputs
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
        //adding the action to dialogbox
        alertController.addAction(okAction)
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    func showMessageDialog3() {
        //Creating UIAlertController and setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Error", message: "Please input a distinct start time and end time", preferredStyle: .alert)
        //the confirm action taking the inputs
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
        //adding the action to dialogbox
        alertController.addAction(okAction)
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    func showMessageDialog4() {
        //Creating UIAlertController and setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Error", message: "Please input an activity", preferredStyle: .alert)
        //the confirm action taking the inputs
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
        //adding the action to dialogbox
        alertController.addAction(okAction)
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    //CORE DATA
    //Local variable: core data array
    var tagDataPoints: [PersonalTag] = []
    
    //Save data point/tag to core data
    func saveToCoreData(data: (String, Date, Date, Bool)?) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("FAILED TO INITIALIZE APPP DELEGATE (182)")
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let newTag = PersonalTag(context: managedContext)
            
            newTag.activity = data?.0
            newTag.startDate = data?.1
            newTag.endDate = data?.2
            newTag.star = (data?.3)!
            
            do {
                try managedContext.save()
                self.tagDataPoints.append(newTag)
            } catch let error as NSError{
                print("COULD NOT SAVE. \(error), \(error.userInfo)")
            }
        }
    }
    
    //Load data points/tags from core data into local variable ("tagDataPoints")
    func loadFromCoreData(){
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("COULD NOT INITIALIZE APP DELEGATE (213)")
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            do {
                self.tagDataPoints = try managedContext.fetch(PersonalTag.fetchRequest())
                //                print("––––––––––––––––––––––––––––––––")
                //                print("CORE DATA: ")
                //                for dataPoint in self.tagDataPoints {
                //                    print("\((dataPoint.activity)!) || \((dataPoint.startDate)!) || \((dataPoint.endDate)!) || \(dataPoint.star)")
                //                }
                //                print("––––––––––––––––––––––––––––––––")
            } catch {
                print("FETCH FAILED (220)")
            }
        }
    }
    

}
