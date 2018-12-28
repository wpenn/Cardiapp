//
//  ViewController.swift
//  heartRateAppMockUp
//
//  Copyright © 2017 Riverdale Country School. All rights reserved.
//

import UIKit
import HealthKit
import Foundation
import CoreData
import Charts

//establishes userdefaults for the app (lets you save certain values for the user that will be used frequently throughout the app)
let defaults = UserDefaults.standard

var calendarSelectedDate = Date()

class ViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet var mainView: UIView!
    
    //Unwind Segue to the view controller
    @IBAction func unwindToViewController(sender: UIStoryboardSegue){}
    
    
    @IBOutlet weak var infoButton: UIButton!
    //https://stackoverflow.com/questions/952412/uiscrollview-scroll-to-bottom-programmatically
    @IBAction func infoButton(_ sender: Any) {
        let bottomOffset = CGPoint(x: 0, y: mainControllerScrollView.contentSize.height - mainControllerScrollView.bounds.size.height)
        mainControllerScrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    
    //function to get authorization from healthkit for certain datatypes in the application
    let healthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: @escaping (Error?) -> Void) {
        if HKHealthStore.isHealthDataAvailable(){
            print("HEALTH DATA AVAILABLE (19)")
        } else{ print("HEALTH DATA UNAVAILABLE (20)") }
        
        guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let height = HKObjectType.quantityType(forIdentifier: .height),
            let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
            let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
            else {
                print("HKObjectType INITIALIZATION ERROR (29)")
                return
        }
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth, biologicalSex, height, bodyMass, heartRate, HKObjectType.workoutType()]
        
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) -> Void in
            if success == false{
                print("AUTHORIZATION FAIL (37)")
            }
            else{
                print("AUTHORIZATION SUCCESS(41)")
                print("–––––––––––––––––––––––––––––––––––––––––")
                self.getHeartRatesAndGraph(selectedDate: calendarSelectedDate)
            }
        }
        completion(nil)
    }
    
    //get heart rate samples from a start date
    func getHeartRatesAndGraph(selectedDate: Date?){
        var selectedDate = selectedDate
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else{
            print("could not establish quantity type (46)")
            return
        }
        
        if selectedDate == nil{
            selectedDate = Date()
        }
        
        let startDate = Calendar.current.startOfDay(for: selectedDate!)
        
        let endDate = Calendar.current.date(byAdding: .second, value: -1, to: Calendar.current.date(byAdding: .day, value: 1, to: startDate)!)
        
        print("SELECTED START DATE = ", (startDate.description(with: Calendar.current.locale)), startDate)
        print("SELECTED END DATE = ", endDate?.description(with: Calendar.current.locale) ?? "", endDate!)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: sortDescriptors) {
            query, results, error in
            
            guard error == nil else {
                print("error: \(String(describing: error))")
                return
            }
            
            //saving parsed heart rate data to local variable
            //self.hrDataLoad = self.parseHKSampleArray(results: results) as! [(Int, Date, Date)]
            let arrayConvertedFromHealthStore = self.parseHKSampleArray(results: results) as! [(Int, Date, Date)]
            let arrayForGraph = self.parsedHKSampleArrayForGraphs(dataSet: arrayConvertedFromHealthStore)
            
            
            print("––––––––––––––––––––––––––––––––––")
            print("DATA: ", arrayForGraph)
            print("––––––––––––––––––––––––––––––––––")
            
            //Start Loading animation
            self.startLoadingAnimation()
            
            if arrayForGraph.0.isEmpty || arrayForGraph.1.isEmpty  || arrayForGraph.2.isEmpty{
                //Pull up viw with "No Data Available" and hide calendar View
                print("No data available")
                DispatchQueue.main.async {
                    self.noDataAvailableText.isHidden = false
                    self.settingsLinkButton.isHidden = false
                    self.mainControllerScrollView.isScrollEnabled = false
                    self.infoButton.isHidden = true
                    self.infoButton.isEnabled = false
                }
                self.stopLoadingAnimation()
            }
            else{
                print("GRAPH DATA AVAILABLE")
                DispatchQueue.main.async{
                    self.noDataAvailableText.isHidden = true
                    self.settingsLinkButton.isHidden = true
                    self.infoButton.isHidden = false
                    self.infoButton.isEnabled = true
                    self.mainControllerScrollView.isScrollEnabled = true
                }
                self.createGraph(completion: { () in //***This may not be exactly where the graph is rendered
                    self.stopLoadingAnimation()
                },
                    heartRateDataSet: arrayForGraph)
            }
        }
        healthStore.execute(heartRateQuery)
    }
    
    //Loading Animation: https://stackoverflow.com/questions/27960556/loading-an-overlay-when-running-long-tasks-in-ios
    func startLoadingAnimation(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    func stopLoadingAnimation(){
        dismiss(animated: false, completion: nil)
    }
    
    
    func parseHKSampleArray(results: [HKSample]?) -> Array<Any>{
        var finalArray = [Any]()
        for currData in results!{
            let currDataString = "\(currData)"
            let parsedCurrDataStringArray = currDataString.components(separatedBy: " count/min")
            let BPM = Int(parsedCurrDataStringArray[0])
            
            //            print("BPM: \(BPM!)")
            //            print("Start Date: \(currData.startDate)")
            //            print("End Date: \(currData.endDate)")
            //            print("UUID: \(currData.uuid)")
            //            print("Source: \(currData.sourceRevision)")
            
            finalArray.append((BPM!, currData.startDate, currData.endDate))
        }
        return finalArray
    }
    
    //Parsing for Graphs --> Jessica's section
    fileprivate func extractedFunc(_ activityTags: [PersonalTag]?, _ activityTagsFormatted: inout [(String, Date, Date, Bool)]) {
        if activityTags?.isEmpty == false{
            for tags in activityTags!{
                activityTagsFormatted.append((tags.activity!, tags.startDate!, tags.endDate!, tags.star))
            }
        }
    }
    
    func parsedHKSampleArrayForGraphs(dataSet: [(Int, Date, Date)]) -> ([String], [Double], [String?], [(String, Date, Date, Bool)]){
        
        var xArray = [String]()
        var yArray = [Double]()
        var activityBPMArray = [String?]()
        
        //handling empty or partially filled tag array
        var activityTags: [PersonalTag]? = nil
        if !dataSet.isEmpty{
            activityTags = getData(sD: (dataSet.last?.1)!, eD: dataSet[0].1) //Note: Data set is in order from later to earlier bpm samples
        } else if dataSet.count == 1{
            activityTags = getData(sD: dataSet[0].1, eD: dataSet[0].1)
        }
        
        for set in dataSet{
            let dateTime = set.1
            
            //adding the date of the bpm to the tuple data set
            xArray.append("\(dateTime)")
            
            //adding the bpm to the tuple data set
            let y = "\(set.0).0"
            let finalY = Double(y)
            yArray.append(finalY!)
            
            
            //adding corresponding activities
            var tagAppend: String? = nil
            
            for tag in activityTags!{
                if  dateTime > tag.startDate! &&  dateTime < tag.endDate! {
                    tagAppend = tag.activity
                }
            }
            activityBPMArray.append(tagAppend)
        }
        var activityTagsFormatted = [(String, Date, Date, Bool)]()
        extractedFunc(activityTags, &activityTagsFormatted)
        
        //returning a reversed array so that the array goes from oldest to newest
        return (xArray.reversed(), yArray.reversed(), activityBPMArray.reversed(), activityTagsFormatted)
    }
    
    //dealing with tags --> helper function to the "parsedHKSampleArrayForGraphs"
    func getData(sD: Date, eD: Date) -> [PersonalTag]?{
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<PersonalTag> = PersonalTag.fetchRequest()
        
        //***This does not work if the end point of the tag is EQUAL to the last bpm
        let predicate = NSPredicate(format: "%@ < startDate AND %@ > endDate OR startDate < %@ AND %@ < endDate OR startDate < %@ AND %@ < endDate", sD as CVarArg, eD as CVarArg, sD as CVarArg, sD as CVarArg, eD as CVarArg, eD as CVarArg)
        
        fetchRequest.predicate = predicate
        
        do {
            //let tags = try context.fetch(PersonalTag.fetchRequest()) as! [PersonalTag]
            let tags = try context.fetch(fetchRequest)
            return tags
        } catch {
            print("Fetching Failed")
            return nil
        }
    }
    
    //________________________________________________
    //Graph Section
    //sources: https://github.com/danielgindi/Charts, https://www.appcoda.com/ios-charts-api-tutorial/, https://medium.com/@felicity.johnson.mail/lets-make-some-charts-ios-charts-5b8e42c20bc9
    
    let data = CombinedChartData()
    
    @IBOutlet weak var chartView: CombinedChartView!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var graphInfoMax: UILabel!
    @IBOutlet weak var graphInfoMin: UILabel!
    @IBOutlet weak var graphInfoAvg: UILabel!
    @IBOutlet weak var graphInfoMedian: UILabel!
    
    func createGraph(completion: () -> Void, heartRateDataSet: (([String], [Double], [String?], [(String, Date, Date, Bool)]))){
        //self.yLabel.transform = CGAffineTransform(rotationAngle: -1*CGFloat.pi / 2)
        chartView.delegate = self
        chartView.rightAxis.enabled = false
        
        // trying out a different marker
        let marker2 = XYMarkerView(
            color: UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1),
            font: NSUIFont.systemFont(ofSize: 14.0),
            textColor: NSUIColor.white,
            insets: UIEdgeInsets(top: 2.0, left: 3.0, bottom: 2.0, right: 3.0),
            xAxisValueFormatter: DateValueFormatter(),
            heartRateData: heartRateDataSet)
        marker2.chartView = chartView
        chartView.marker = marker2
        
        // working with time
        chartView.xAxis.valueFormatter = DateValueFormatter()  //formats the labels on the x axis
        
        let startDate = heartRateDataSet.0
        let bpm = heartRateDataSet.1
        
        
        //adding stuff for combined chart
        chartView.drawOrder = [DrawOrder.bar.rawValue,
                               DrawOrder.line.rawValue]
        chartView.drawBarShadowEnabled = false
        chartView.highlightFullBarEnabled = false
        
        lineSetChart(dataPoints: bpm, coords: startDate)
        
       
        
        //bar chart data
        let maxY = bpm.max()
        var startDateActivityList = [Date]()
        var endDateActivityList = [Date]()
        var emojiTagString = [String]()
        var flagBool = [Bool]()
        
        for i in heartRateDataSet.3{
            emojiTagString.append(i.0)
            startDateActivityList.append(i.1)
            endDateActivityList.append(i.2)
            flagBool.append(i.3)
        }
        
        //        print("here is heart rate data set \(heartRateDataSet)")
        //        print("emojis here: \(emojiTagString)")
        //        print("startDate here: \(startDateActivityList)")
        
        //chartView.setVisibleXRangeMaximum(1000) //this sets max zoom on graph
        //chartView.zoom(scaleX: 1000, scaleY: 100)
        
        if startDate != [] {
            //find the first time for initial zooming
            let firstTime = startDate[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            dateFormatter.timeZone = Calendar.current.timeZone
            dateFormatter.locale = Calendar.current.locale
            let initialTime = dateFormatter.date(from: firstTime)?.timeIntervalSince1970
            
            chartView.zoom(scaleX: 4, scaleY: 1, xValue: initialTime!, yValue: maxY!, axis: .left)
        }
            
        if startDateActivityList.isEmpty == false {
            BarSetChart(start: startDateActivityList, end: endDateActivityList, maxY:maxY!, emojis: emojiTagString, flags: flagBool)
        }
        chartView.data = data
        
        //set information about graph
        graphInfo(bpm: bpm, times: startDate)
        
        DispatchQueue.main.async{
            self.chartView.notifyDataSetChanged()
        }
        completion()
    }
    
    func lineSetChart(dataPoints: [Double], coords: [String]) {
        
        //convert the time stamp into a number value
        //source: https://stackoverflow.com/questions/24777496/how-can-i-convert-string-date-to-nsdate
        var times: [Double] = []
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        //changing the time zone:
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        // dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        for i in coords {
            let t = dateFormatter.date(from: i)?.timeIntervalSince1970
            times.append(Double(t!))
        }
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {  //loop formats the data as a ChartDataEntry
            let dataEntry = ChartDataEntry(x: times[i], y: dataPoints[i], icon:UIImage(named:"heart2"))
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Your Heart Rate History")
        
        //format the data
        lineChartDataSet.lineDashLengths = [5, 2.5]
        lineChartDataSet.highlightLineDashLengths = [5, 2.5]
        lineChartDataSet.setColor(.gray)
        lineChartDataSet.setCircleColor(.white)
        lineChartDataSet.lineWidth = 2
        lineChartDataSet.circleRadius = 5
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.valueFont = .systemFont(ofSize: 9)
        lineChartDataSet.formLineDashLengths = [5, 2.5]
        lineChartDataSet.formLineWidth = 1
        lineChartDataSet.formLineWidth = 15
        lineChartDataSet.drawValuesEnabled = false //don't write y values over points
        
        lineChartDataSet.mode = (lineChartDataSet.mode == .horizontalBezier) ? .horizontalBezier : .horizontalBezier //smoothes the graph
        
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        
        data.lineData = LineChartData(dataSet: lineChartDataSet)
        
        data.barData = nil
    }
    
    
    // ******** BAR CHART DATA (BELOW) ********
    func BarSetChart(start:[Date], end:[Date], maxY:Double, emojis:[String], flags:[Bool]){
        print("BAR CHART CALLED")
        if start.isEmpty == false {
            var times1: [Double] = []
            var times2: [Double] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            // dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            dateFormatter.timeZone = Calendar.current.timeZone
            dateFormatter.locale = Calendar.current.locale
            
            for i in start {
                let t = i.timeIntervalSince1970
                times1.append(Double(t))
            }
            for i in end {
                let t = i.timeIntervalSince1970
                //let t = dateFormatter.date(from: i)?.timeIntervalSince1970
                times2.append(Double(t))
            }
            
            var dataEntries: [BarChartDataEntry] = []
            for i in 0..<times1.count { //for each start time
                
                //find half way bar - half way bar is where I'm drawing the icon
                let range = times2[i]-times1[i]
                let mid = range/2
                let mid_bar = mid/60 //since drawing a bar every 60
                print("mid_bar: \(mid_bar)")
                print("mid_bar+times1[i]: \((mid_bar*60)+times1[i])")
                
                for j in stride(from: times1[i], through: times2[i], by: 60) { //create many bars that span the region from start to end time, counting up by minutes (60 sec) so it goes faster
                    //only display the icon for the bar in the middle of start/end times
                    //get the emoji only not the text
                    let emojiIcon = emojis[i].components(separatedBy: " ")
                    let emojiIcon2 = emojiIcon[1]
                    
                    print("emojiicon \(emojiIcon2)")
                    print("j: \(j)")
                    
                    // if j < (mid_bar*60)+times1[i] + 30 && j > (mid_bar*60)+times1[i] - 30
                    
                    if (j <= (mid_bar*60)+times1[i] + 30) && (j > (mid_bar*60)+times1[i] - 30) { //if it's the middle bar
                        let dataEntry = BarChartDataEntry(x: j, y: maxY, icon: emojiIcon2.image())
                        dataEntries.append(dataEntry)
                        print("called")
                    }
                    else if (j == times1[0] && flags[i] == true) { //if it's the first bar
                        print("flags called")
                        let dataEntry = BarChartDataEntry(x: j, y: maxY, icon: "🚩".image())
                        dataEntries.append(dataEntry)
                    }
                    else{
                        //let dataEntry = BarChartDataEntry(x: j, y: maxY, icon: emojiIcon2.image())
                        let dataEntry = BarChartDataEntry(x: j, y: maxY)
                        dataEntries.append(dataEntry)
                    }
                }
            }
            
            let barDataSet = BarChartDataSet(values: dataEntries, label: "Your Tags")
            barDataSet.setColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2))
            barDataSet.valueTextColor = UIColor(red: 60/255, green: 220/255, blue: 78/255, alpha: 1)
            barDataSet.valueFont = .systemFont(ofSize: 10)
            
            //don't draw labels over the bars and no highlight, do draw icons
            barDataSet.highlightEnabled = false
            barDataSet.drawValuesEnabled = false
            barDataSet.drawIconsEnabled = true
            
            //let data = BarChartData(dataSet: barDataSet)
            let data1 = BarChartData(dataSet: barDataSet)
            data1.barWidth = 60
            //data1.barWidth = times2[0]-times1[0]
            
            data.barData = data1
        }
    }
    
    func graphInfo(bpm: [Double], times: [String]) {
        //find max, min, avg heart rate
        let maxBPM = bpm.max()!
        let minBPM = bpm.min()!
        let avgBPM = bpm.reduce(0.0,+) / Double(bpm.count)
        let roundedAvgBPM = round(avgBPM * 10) / 10
        
        var medianBPM = 0.0
        if bpm.sorted().count % 2 != 0 { //if have odd number of items
            medianBPM = bpm.sorted()[bpm.sorted().count/2] //median is the middle value of the sorted array
        } else{
            medianBPM = ( bpm.sorted()[bpm.sorted().count/2]  +   bpm.sorted()[bpm.sorted().count/2 - 1] ) / 2 //median is the average of the two middle values
        }
        print(maxBPM)
        print(minBPM)
        print(avgBPM)
        print(medianBPM)
        
        //graphInfoLabel.numberOfLines = 6;
        
        print("HEY THERE, HERES MY AGE: ", defaults.string(forKey: "Age"))
        
        DispatchQueue.main.async {
            self.graphInfoMax.text = "\(String(describing: maxBPM)) BPM"
            self.graphInfoMin.text = "\(String(describing: minBPM)) BPM"
            self.graphInfoAvg.text = "\(String(describing: roundedAvgBPM)) BPM"
            self.graphInfoMedian.text = "\(String(describing: medianBPM)) BPM"
        }
        
        
       // graphInfoText.isEditable = false
        //graphInfoText.attributedText = NSMutableAttributedString(string: "h")
//        DispatchQueue.main.async(){
////            self.graphInfoLabel.text = "Here are your BPM stats for the day!  \nMaximum: \(String(describing: maxBPM))  \nMinimum: \(String(describing: minBPM))  \nAverage: \(String(describing: roundedAvgBPM))   \nMedian: \(String(describing: medianBPM)) "
//        }
        
        
//        if medianBPM != 0.0 {
//            graphInfoText.text = "Here are your stats for the day!  \nMaximum BPM: \(String(describing: maxBPM))  \nMinimum BPM: \(String(describing: minBPM))  \nAverage BPM: \(String(describing: avgBPM))   \nMedian BPM: \(String(describing: medianBPM)) "
//        }
    }
        
        
    //________________________________________________
    
    //Main Thread Functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //run authorization
        authorizeHealthKit(){ (error) in
            if let error = error{
                print("Error (32): \(error)")
            }
        }
        
        //rotation of bpm label
        self.yLabel.transform = CGAffineTransform(rotationAngle: -1*CGFloat.pi / 2)
        
//        let heartProfileView = HeartProfileViewController()
//        heartProfileView.getBioData(
//            completion: { (error) in
//                if let error = error{
//                    print("Error (40): \(error)")
//                }
//            }
//        )
        
        getAge()
        
    }
    
    
    
    @IBOutlet weak var cardigraphDateLabel: UILabel!


    @IBOutlet weak var noDataAvailableText: UITextView!
    
    @IBOutlet weak var settingsLinkButton: UIButton!
    //https://stackoverflow.com/questions/28152526/how-do-i-open-phone-settings-when-a-button-is-clicked
    @IBAction func settingsLinkButton(_ sender: Any) {
//        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//            return
//        }
        guard let settingsUrl = URL(string: "x-apple-health://") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }
    
    
    
    @IBOutlet weak var mainControllerScrollView: UIScrollView!
    
    override func viewDidAppear(_ animated: Bool) {
        print("–––––––––––––––––––––––––––")
        print("SELECTED TIME: \(calendarSelectedDate)")
        print("–––––––––––––––––––––––––––")
        
        //loads the current day as a start
        self.getHeartRatesAndGraph(selectedDate: calendarSelectedDate)
        
        //sets text for selectedDate label on ViewController
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        cardigraphDateLabel.text = dateFormatter.string(from: calendarSelectedDate)
        
        DispatchQueue.main.async{
            self.noDataAvailableText.isHidden = true
            self.settingsLinkButton.isHidden = true
            self.mainControllerScrollView.isScrollEnabled = true
            self.infoButton.isHidden = false
            self.infoButton.isEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



//convert emoji string to UIimage for the tag //source:https://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage
extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 35, height: 35)
        //let size = CGSize(width: 50, height: 50)
        //let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.white.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


func getAge() {
    var age: Int?
    var birthComponents: DateComponents
    do {
        birthComponents = try HKHealthStore().dateOfBirthComponents()
        let calendar = Calendar.current
        
        let ageDifference = ((Date().timeIntervalSince1970 - calendar.date(from: DateComponents(year: birthComponents.year, month: birthComponents.month, day: birthComponents.day, hour: birthComponents.hour, minute: birthComponents.minute, second: birthComponents.second))!.timeIntervalSince1970) / (365 * 24 * 60 * 60))
        
        age = Int(floor(ageDifference))
        
        if let unwrappedAge = age{
            defaults.set(unwrappedAge, forKey: "Age")
            print("AGE IS \(unwrappedAge)")
        }
    } catch{
        print("CAN'T GET AGE (80)")
        defaults.set(nil, forKey: "Age")
    }
}
