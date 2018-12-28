//
//  heartHealthyAdviceController.swift
//  Cardiapp
//
//  Created by Wesley Penn on 5/17/18.
//  Copyright © 2018 Riverdale Country School. All rights reserved.
//

import UIKit
import CoreData

var webPageViewControllerURL = String()

class heartHealthyAdviceController: UIViewController {

    var URLArray = [String]()
    
    @IBAction func unwindToHHA(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        var coreDataTags = [PersonalTag]()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<PersonalTag> = PersonalTag.fetchRequest()
        do {
            coreDataTags = try context.fetch(fetchRequest)
        } catch {
            print("Fetching Failed")
        }
        
        var parsedCoreData = [(String?, Date?, Date?, Bool)]()
        for val in coreDataTags{
            parsedCoreData.append((val.activity?.stringByRemovingEmoji(), val.startDate, val.endDate, val.star))
        }
        getArticles(tags: parsedCoreData)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getArticles(tags: [(String?, Date?, Date?, Bool)]){
        var activityArray = [String?]()
        for tag in tags{
            activityArray.append(tag.0)
        }
        
        let countedActivities = activityArray.reduce(into: [:], {counts, words in counts[words!, default: 0] += 1})
        let organizedCountActivites = countedActivities.sorted(by: {
            return $0.value > $1.value
        })
        var finalOrganizedActivityArray = [String?]()
        for val in organizedCountActivites{
            finalOrganizedActivityArray.append(val.key)
        }
        if organizedCountActivites.count > 3{
            var tempArray = [String?]()
            for i in 0..<3{
                tempArray.append(finalOrganizedActivityArray[i])
            }
            activityArray = tempArray
        } else{
            activityArray = finalOrganizedActivityArray
        }
        
       /* if activityArray.count == 0{
            print("No Activities")
        } else if activityArray.count == 1{
            importActivityUI(activity: activityArray[0]!, position: 0)
        } else{
            for index in 0...activityArray.count - 1{
                importActivityUI(activity: activityArray[index]!, position: index)
            }
        }*/
        importActivityUI(activities: activityArray)
        
    }
    
    
    //source: http://mrgott.com/swift-programing/33-rest-api-in-swift-4-using-urlsession-and-jsondecode
    //source: https://codewithchris.com/iphone-app-connect-to-mysql-database/
    /*func importActivityUI(activity: String, position: Int){
        let urlString = "http://www.cardiapp.io/SQL/service.php?activity=\(activity)".trimmingCharacters(in: .whitespaces)
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                print("FETCH ERROR 94")
            }

            guard let data = data else {
                print("FETCH ERROR 98")
                return
            }
            var parsedJSONData = [Activity]()
            do{
                parsedJSONData = try JSONDecoder().decode([Activity].self, from: data)
            } catch let jsonError {
                print(jsonError)
            }

            print(parsedJSONData)

            }.resume()
    }*/
    //*** Fix later --> change workflow to optimize for larger database
    
    
    @IBOutlet weak var activity1IndicatorLabel: UILabel!
    @IBOutlet weak var activity2IndicatorLabel: UILabel!
    @IBOutlet weak var activity3IndicatorLabel: UILabel!
    
    @IBOutlet weak var activity1Label1: UILabel!
    @IBOutlet weak var activity1Label2: UILabel!
    @IBOutlet weak var activity2Label: UILabel!
    @IBOutlet weak var activity3Label: UILabel!
    
    var activity_1 = [Activity]()
    var activity_2 = [Activity]()
    var activity_3 = [Activity]()
    
    var activityURLs = [String]()
    
    func importActivityUI(activities: [String?]){
        let urlString = "http://www.cardiapp.io/SQL/service.php"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                print("FETCH ERROR 94")
            }
            
            guard let data = data else {
                print("FETCH ERROR 98")
                return
            }
            var parsedJSONData = [Activity]()
            do{
                parsedJSONData = try JSONDecoder().decode([Activity].self, from: data)
            } catch let jsonError {
                print(jsonError)
            }
            self.activity_1 = [Activity]()
            self.activity_2 = [Activity]()
            self.activity_3 = [Activity]()
            if activities.count == 0{
                print("No Activities")
                for val in parsedJSONData{
                    if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == "Running" && self.activity_1.count < 2{
                        self.activity_1.append(val)
                    }
                   else if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == "Sleeping" && self.activity_2.count < 1{
                        self.activity_2.append(val)
                    }
                    else if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == "Biking" && self.activity_3.count < 1{
                        self.activity_3.append(val)
                    }
                }
            } else if activities.count == 1{
                for val in parsedJSONData{
                    if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == activities[0]?.trimmingCharacters(in: .whitespacesAndNewlines) && self.activity_1.count < 2{
                        self.activity_1.append(val)
                    }
                    else if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == "Sleeping" && self.activity_2.count < 1{
                        self.activity_2.append(val)
                    }
                    else if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == "Biking" && self.activity_3.count < 1{
                        self.activity_3.append(val)
                    }
                }
            }else if activities.count == 2{
                for val in parsedJSONData{
                    if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == activities[0]?.trimmingCharacters(in: .whitespacesAndNewlines) && self.activity_1.count < 2{
                        self.activity_1.append(val)
                    }
                    else if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == activities[1]?.trimmingCharacters(in: .whitespacesAndNewlines) && self.activity_2.count < 2{
                        self.activity_2.append(val)
                    }
                    else if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == "Biking" && self.activity_3.count < 1{
                        self.activity_3.append(val)
                    }
                }
            } else{
                for val in parsedJSONData{
                    
                    if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == activities[0]!.trimmingCharacters(in: .whitespacesAndNewlines){
                        self.activity_1.append(val)
                        self.activityURLs.append(val.ArticleURL.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    else if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == activities[1]!.trimmingCharacters(in: .whitespacesAndNewlines) && self.activity_2.count < 1{
                        self.activity_2.append(val)
                        self.activityURLs.append(val.ArticleURL.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    else if val.Activity.trimmingCharacters(in: .whitespacesAndNewlines) == activities[2]!.trimmingCharacters(in: .whitespacesAndNewlines) && self.activity_3.count < 1{
                        self.activity_3.append(val)
                        self.activityURLs.append(val.ArticleURL.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
            print("Activities: ", activities)
            print("***Activity 1, 2, 3: ", self.activity_1, self.activity_2, self.activity_3)
            
            DispatchQueue.main.async {
                self.activity1Label1.text = self.activity_1[0].ArticleTitle
                self.activity1Label2.text = self.activity_1[1].ArticleTitle
                self.activity2Label.text = self.activity_2[0].ArticleTitle
                self.activity3Label.text = self.activity_3[0].ArticleTitle
                
                self.activity1IndicatorLabel.text = "Sugguested articles for \(self.activity_1[0].Activity): "
                self.activity2IndicatorLabel.text = "Sugguested articles for \(self.activity_2[0].Activity): "
                self.activity3IndicatorLabel.text = "Sugguested articles for \(self.activity_3[0].Activity): "
            }
            
            }.resume()
    }
    
    @IBAction func activity1Button1(_ sender: Any) {
        webPageViewControllerURL = self.activity_1[0].ArticleURL
    }
    @IBAction func activity1Button2(_ sender: Any) {
        webPageViewControllerURL = self.activity_1[1].ArticleURL
    }
    @IBAction func activity2Button(_ sender: Any) {
        webPageViewControllerURL = self.activity_2[0].ArticleURL
    }
    @IBAction func activity3Button(_ sender: Any) {
        webPageViewControllerURL = self.activity_3[0].ArticleURL
    }
    
    
/*
    
    func cartegorizeTags(tags:[(String?, Date?, Date?, Bool)] ){
        
//        let sepTags = tags[0].0!.components(separatedBy: " ")
//        var activityText = sepTags[0]
//
        var tagList: [String] = []
        for i in 0..<tags.count{
            tagList.append(tags[i].0!)
        }
        
        
        print("Tags: \(tags)")
        //different types of activity categories
        var active = 0
        var sedentary = 0
        var music = 0
        var vices = 0
        var eating = 0
        
        print("tagList \(tagList)")
    
        for i in tagList{
            
            let j = String(i)
            
            print("j \(j)")
//            var categories: [String:Int] = ["active":active,"sedentary":sedentary,"music":music,"vices":vices,"eating":eating]
            
            if (j == "Soccer ⚽️") || (j == "Running 🏃") || (j=="Basketball 🏀") || (j=="Football 🏈") || (j=="Baseball ⚾️") || (j=="Walking 🚶") || (j=="Lifting Weights 🏋️‍♀️") || (j=="Dancing 💃") || (j=="Tennis 🎾") || (j=="Volleyball 🏐") || (j=="Ping Pong 🏓") || (j=="Ice Hockey 🏒") || (j=="Field Hockey 🏑") || (j=="Archery 🏹") || (j=="Fishing 🎣") || (j=="Boxing 🥊") || (j=="Martial Arts 🥋") || (j=="Skiing ⛷") || (j=="Snowboarding 🏂") || (j=="Ice Skating ⛸") || (j=="Wrestling 🤼‍♀️") || (j=="Gymnastics 🤸‍♀️") || (j=="Golf 🏌️") || (j=="Surfing 🏄") || (j=="Water Polo 🤽‍♀️") || (j=="Swimming 🏊‍♀️") || (j=="Rowing 🚣‍♀️") || (j=="Horseback Riding 🏇") || (j=="Biking 🚴") || (j=="Mountain Biking 🚵‍♀️") || (j=="Juggling 🤹‍♂️") || (j=="Rugby 🏉") || (j=="Pool 🎱") || (j=="Badminton 🏸") || (j=="Cricket 🏏") || (j=="Bowling 🎳") || (j=="Darts 🎯") || (j=="Fencing 🤺") || (j=="Dodgeball 🤾‍♂️") {
                active = active + 1
            }
            else if (j == "Eating 🍔"){
                eating = eating + 1
            }
            else if (j == "Sleeping 💤") || (j=="Watching TV 📺") || (j=="Video Games 🎮"){
                sedentary = sedentary + 1
            }
            else if (j=="Drinking 🍸") || (j=="Smoking 🚬"){
                vices = vices + 1
            }
            else if (j=="Trumpet 🎺") || (j=="Piano 🎹") || (j=="Drums 🥁") || (j=="Saxophone 🎷") || (j=="Guitar 🎸") || (j=="Violin 🎻") || (j=="Singing 🎤"){
                music = music + 1
            }
            
        }
        
        let categories = [
            "active" : active,
            "sedentary" : sedentary,
            "music" : music,
            "vices" : vices,
            "eating" :  eating
        ]
        
        print("active \(active); sedentary \(sedentary); music \(music); vices \(vices); eating \(eating)")
    
        let sortedCategories = Array(categories).sorted{$0.1 > $1.1} //sort dictionary by value from greatest to least
        print("sortedCategories: \(sortedCategories)")
        
    }
    
    func pickArticles(list: [Int]){
        print("pickedArticles")
    } */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

//source: https://stackoverflow.com/questions/36919125/swift-replacing-emojis-in-a-string-with-whitespace?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
extension String {
    func stringByRemovingEmoji() -> String {
        return String(self.filter { !$0.isEmoji() })
    }
}
extension Character {
    fileprivate func isEmoji() -> Bool {
        return Character(UnicodeScalar(UInt32(0x1d000))!) <= self && self <= Character(UnicodeScalar(UInt32(0x1f77f))!)
            || Character(UnicodeScalar(UInt32(0x2100))!) <= self && self <= Character(UnicodeScalar(UInt32(0x26ff))!)
    }
}
