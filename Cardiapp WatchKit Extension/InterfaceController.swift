import Foundation
import HealthKit
import WatchKit
import UIKit

extension UIColor {
    //creating an extension of the UI Color
    
    func interpolateRGBColorTo(_ end: UIColor, fraction: CGFloat) -> UIColor? {
        //creating a function to interpolate RGBColor FROM/TO
        let f = min(max(0, fraction), 1)
        
        guard let c1 = self.cgColor.components, let c2 = end.cgColor.components else { return nil }
        
        let r: CGFloat = CGFloat(c1[0] + (c2[0] - c1[0]) * f)
        let g: CGFloat = CGFloat(c1[1] + (c2[1] - c1[1]) * f)
        let b: CGFloat = CGFloat(c1[2] + (c2[2] - c1[2]) * f)
        let a: CGFloat = CGFloat(c1[3] + (c2[3] - c1[3]) * f)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    
    @IBOutlet var ExerTimer: WKInterfaceTimer!
    @IBOutlet var exerState: WKInterfaceLabel!
    @IBOutlet private weak var label: WKInterfaceLabel!
    @IBOutlet private weak var startStopButton : WKInterfaceButton!
    
    //    @IBOutlet var workoutPerformanceBox: WKInterfaceButton!
    
    @IBOutlet var heartIndicator: WKInterfaceLabel!
    let healthStore = HKHealthStore()
    
    //State of the app - is the workout activated
    var workoutActive = false
    
    // define the activity type and location
    var session : HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    //var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    var currenQuery : HKQuery?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        guard HKHealthStore.isHealthDataAvailable() == true else {
            label.setText("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            displayNotAllowed()
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
            if success == false {
                self.displayNotAllowed()
            }
        }
    }
    
    func displayNotAllowed() {
        label.setText("not allowed")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Do nothing for now
        print("Workout error")
    }
    
    
    func workoutDidStart(_ date : Date) {
        if let query = createHeartRateStreamingQuery(date) {
            self.currenQuery = query
            healthStore.execute(query)
        }
        else {
            label.setText("cannot start")
        }
    }
    
    func workoutDidEnd(_ date : Date) {
        healthStore.stop(self.currenQuery!)
        label.setText("---")
        session = nil
        //            workoutPerformanceBox.setBackgroundColor(UIColor.yellow)
        heartIndicator.setTextColor(UIColor.lightGray)
        exerState.setText(" ")
    }
    
    
    @IBAction func startBtnTapped() {
        if (self.workoutActive) {
            //finish the current workout
            
            //           workoutPerformanceBox.setBackgroundColor(UIColor.darkGray)
            heartIndicator.setTextColor(UIColor.purple)
            startStopButton.setBackgroundColor(UIColor.darkGray)
            ExerTimer.stop()
            wkTimerReset(timer: ExerTimer,interval: 0.0)
            self.workoutActive = false
            self.startStopButton.setBackgroundColor(UIColor.green)
            self.startStopButton.setTitle("Start")
            if let workout = self.session {
                healthStore.end(workout)
            }
        }
        else {
            //start a new workout
            
            //           workoutPerformanceBox.setBackgroundColor(UIColor.green)
            //            heartIndicator.setTextColor(UIColor.purple)
            startStopButton.setBackgroundColor(UIColor.lightGray)
            
            
            self.workoutActive = true
            self.startStopButton.setTitle("Stop")
            self.startStopButton.setBackgroundColor(UIColor.red)
            startWorkout()
        }
        
    }
    
    func startWorkout() {
        
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
            session?.delegate = self
        }
        catch {
            fatalError("Unable to create the workout session!")
        }
        
        ExerTimer.stop()
        wkTimerReset(timer: ExerTimer,interval: 0.0)
        healthStore.start(self.session!)
        ExerTimer.start()
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func updateHeartRate(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else{
                return
            }
            let value = sample.quantity.doubleValue(for: self.heartRateUnit)
            let valueFormated = UInt16(value)
            self.updateWorkoutIndicator(heartRate: valueFormated)
            self.label.setText(String(valueFormated))
        }
    }
    func updateWorkoutIndicator(heartRate: UInt16){
        
        getAge()
        
        //https://www.webmd.com/fitness-exercise/features/the-truth-about-heart-rate-and-exercise#1
        //let age = 45 //pull age from HealthStore
        
        let max: Double = 208 - (Double(age!) * 0.7) //formula for maximum heartrate performance
        let ratio: Float = Float(heartRate) / Float(max)
        
        
        
        
        //min and max heart Colors
        let heartColorMax = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.000);
        let heartColorMin = UIColor(red: 0.20, green: 0.40, blue: 0.89, alpha: 1.000)
        var currentHeartColor = UIColor(red:1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        //heartrate interpolation
        if (heartRate <= Int(max)) {
            currentHeartColor = heartColorMin.interpolateRGBColorTo(heartColorMax, fraction:CGFloat(ratio))!
            print("HEART RATE IN ZONE")
            heartIndicator.setTextColor(currentHeartColor)
        }
        else {
            currentHeartColor = UIColor(red:1.000, green: 0.000, blue:0.000, alpha: 1.000)
            print ("HEART RATE OVER MAX!!!")
            heartIndicator.setTextColor(currentHeartColor)
        }
        
        if (heartRate >= Int(0.6 * max) && heartRate < Int(0.75 * max)) {
            exerState.setTextColor(UIColor.yellow)
            exerState.setText("FAT BURNING MODE")
        }
        else if (heartRate >= Int(0.75 * max) && heartRate <= Int(0.85 * max)){
            exerState.setTextColor(UIColor.green)
            exerState.setText("CARDIO MODE")
        }
        else if (heartRate > Int(0.85 * max) && heartRate < Int(max)){
            WKInterfaceDevice.current().play(.notification)
            exerState.setTextColor(UIColor.red)
            exerState.setText("LOWER HEART RATE")
        }
        else {
            exerState.setText("")
        }
        
    }
    
    //basic wkTimer
    func wkTimerReset(timer:WKInterfaceTimer,interval:TimeInterval){
        timer.stop()
        let time  = NSDate(timeIntervalSinceNow: interval)
        timer.setDate(time as Date)
    }
    
    
    var age: Int?
    func getAge() {
        var birthComponents: DateComponents
        do {
            birthComponents = try HKHealthStore().dateOfBirthComponents()
            let calendar = Calendar.current
            
            let ageDifference = ((Date().timeIntervalSince1970 - calendar.date(from: DateComponents(year: birthComponents.year, month: birthComponents.month, day: birthComponents.day, hour: birthComponents.hour, minute: birthComponents.minute, second: birthComponents.second))!.timeIntervalSince1970) / (365 * 24 * 60 * 60))
            
            age = Int(floor(ageDifference))
            
            if let unwrappedAge = age{
                //defaults.set(unwrappedAge, forKey: "Age")
                age = unwrappedAge
                print("AGE IS \(unwrappedAge)")
            }
        } catch{
            print("CAN'T GET AGE (80)")
            age = 20
            //defaults.set(nil, forKey: "Age")
        }
    }
    
}








