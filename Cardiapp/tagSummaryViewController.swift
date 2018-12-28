import UIKit
import Foundation
import CoreData

class tagSummaryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var startTimeText: UITextField!
    @IBOutlet weak var endTimeText: UITextField!
    @IBOutlet weak var activityText: UITextField!
    @IBOutlet weak var startSwitch: UISwitch!
    
    @IBAction func starSwitchClicked(_ sender: Any) {
        if startSwitch.isOn {
            selectedStar = true
        }
        else {
            selectedStar = false
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        showMessageDialog()
    }
    
    var StartTimePicker = UIDatePicker()
    var StartTimeToolBar = UIToolbar()
    var selectedStartDate: Date = Date(timeIntervalSinceReferenceDate: 118800)
    var selectedStartDateString: String = ""
    var EndTimePicker = UIDatePicker()
    var EndTimeToolBar = UIToolbar()
    var selectedEndDate: Date = Date(timeIntervalSinceReferenceDate: 118800)
    var selectedEndDateString: String = ""
    var activityToolBar = UIToolbar()
    var activityPickerData = ["Soccer ⚽️","Running 🏃","Sleeping 💤","Eating 🍔","Drinking 🍸","Smoking 🚬","Watching TV 📺","Basketball 🏀","Football 🏈","Baseball ⚾️","Walking 🚶","Lifting Weights 🏋️‍♀️","Dancing 💃","Tennis 🎾","Volleyball 🏐","Ping Pong 🏓","Ice Hockey 🏒","Field Hockey 🏑","Archery 🏹","Fishing 🎣","Boxing 🥊","Martial Arts 🥋","Skiing ⛷","Snowboarding 🏂","Ice Skating ⛸","Wrestling 🤼‍♀️","Gymnastics 🤸‍♀️","Golf 🏌️","Surfing 🏄","Water Polo 🤽‍♀️","Swimming 🏊‍♀️","Rowing 🚣‍♀️","Horseback Riding 🏇","Biking 🚴","Mountain Biking 🚵‍♀️","Juggling 🤹‍♂️","Rugby 🏉","Pool 🎱","Badminton 🏸","Cricket 🏏","Bowling 🎳","Video Games 🎮","Darts 🎯","Fencing 🤺","Trumpet 🎺","Piano 🎹","Drums 🥁","Saxophone 🎷","Guitar 🎸","Violin 🎻","Dodgeball 🤾‍♂️","Singing 🎤"]
    var selectedActivity: String = ""
    var selectedStar: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        activityPickerData.sort()
        createStartTimeDatePicker()
        createStartTimeToolBar()
        addStartTimeText()
        
        createEndTimeDatePicker()
        createEndTimeToolBar()
        addEndTimeText()
        
        let activityPicker = UIPickerView()
        createActivityToolBar()
        view.addSubview(activityText)
        activityPicker.delegate = self
        activityText.placeholder = "Activity"
        activityText.inputView = activityPicker
        activityText.inputAccessoryView = activityToolBar
    }
    
    @IBAction func saveBttnPressed(_ sender: Any) {
        //Core Data Save
        if selectedActivity == "" {
            showMessageDialog4()
        } else {
            if selectedStartDate < selectedEndDate {
                saveToCoreData(data: (selectedActivity, selectedStartDate, selectedEndDate, selectedStar))
                loadFromCoreData()
                
                activityText.text = ""
                startTimeText.text = ""
                endTimeText.text = ""
                
                performSegue(withIdentifier: "unwindSegueToViewController", sender: self)
            } else if selectedEndDate == Date(timeIntervalSinceReferenceDate: 118800) || selectedStartDate == Date(timeIntervalSinceReferenceDate: 118800) {
                showMessageDialog3()
            } else if selectedStartDate == selectedEndDate {
                showMessageDialog3()
            } else if selectedStartDate > selectedEndDate {
                showMessageDialog2()
            }
        }
    }
    
    //START TIME PICKER
    func addStartTimeText() {
        view.addSubview(startTimeText)
        startTimeText.placeholder = "Start Time"
        startTimeText.borderStyle = .roundedRect
        startTimeText.inputView = StartTimePicker
        startTimeText.inputAccessoryView = StartTimeToolBar
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
        startTimeText.resignFirstResponder()
    }
    @objc func startDatePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        selectedStartDateString = dateFormatter.string(from: datePicker.date)
        startTimeText.text = selectedStartDateString
        selectedStartDate = dateFormatter.date(from: selectedStartDateString)!
    }
    //END TIME PICKER
    func addEndTimeText() {
        view.addSubview(endTimeText)
        endTimeText.placeholder = "End Time"
        endTimeText.borderStyle = .roundedRect
        endTimeText.inputView = EndTimePicker
        endTimeText.inputAccessoryView = EndTimeToolBar
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
        endTimeText.resignFirstResponder()
    }
    @objc func endDatePickerValueChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        selectedEndDateString = dateFormatter.string(from: datePicker.date)
        endTimeText.text = selectedEndDateString
        selectedEndDate = dateFormatter.date(from: selectedEndDateString)!
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
        activityText.text = activityPickerData[row]
        selectedActivity = activityText.text!
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
        activityText.resignFirstResponder()
    }
    //POP UP MESSAGE
    func showMessageDialog() {
        //Creating UIAlertController and setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Cancel", message: "You will lose all information about the current tag", preferredStyle: .alert)
        //the confirm action taking the inputs
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.performSegue(withIdentifier: "unwindSegueToViewController", sender: self)
        }
        
        //the cancel action doing nothing
        let noAction = UIAlertAction(title: "No", style: .cancel) { (_) in }
        //adding the action to dialogbox
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
