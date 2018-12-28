//
//  tagListViewController2.swift
//  Cardiapp
//
//  Created by Sam Lack on 5/15/18.
//  Copyright © 2018 Riverdale Country School. All rights reserved.
//

import UIKit
import Foundation

class tagListViewController2: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tags: [PersonalTag] = []
    
    var coreDataStartDates: [Date?] = []
    var coreDataEndDates: [Date?] = []
    var coreDataActivities: [String] = []
    var coreDataStar: [Bool] = []
    
    @IBAction func saveToTagListViewController2 (segue:UIStoryboardSegue) {
        let detailTableViewController2 = segue.source as! detailTableViewController2
        
        let index = detailTableViewController2.index
        let activityString = detailTableViewController2.editedActivity
        let startTimeDate = detailTableViewController2.editedStartTime
        let endTimeDate = detailTableViewController2.editedEndTime
        let starBool = detailTableViewController2.editedStar
        
        coreDataActivities[index!] = activityString!
        coreDataStartDates[index!] = startTimeDate!
        coreDataEndDates[index!] = endTimeDate!
        coreDataStar[index!] = starBool!
        
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        getData()
        tableView.reloadData()
    }
    
    func getData() {
        do {
            tags = try context.fetch(PersonalTag.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tags.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let tag = tags[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let startDateAppear = dateFormatter.string(from: tag.startDate!)
        let endDateAppear = dateFormatter.string(from: tag.endDate!)
        
        cell.textLabel?.numberOfLines = 0
        
        var star = ""
        if tag.star == true {
            star = "🚩"
        } else {
            star = ""
        }
        
        cell.textLabel?.text = "ACTIVITY: \((tag.activity)!)\nSTART TIME: \(startDateAppear)\nEND TIME: \(endDateAppear)\n\(star)"
        return cell

    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let tag = tags[indexPath.row]
            tags.remove(at: indexPath.row)
            context.delete(tag)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                tags = try context.fetch(PersonalTag.fetchRequest())
            } catch {
                print("Fetching Failed")
            }
        }
        //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //}
    }
    
    func deleteTag(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let tag = tags[indexPath.row]
        tags.remove(at: indexPath.row)
        context.delete(tag)
        tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        do {
            tags = try context.fetch(PersonalTag.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
    }
    

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
        if segue.identifier == "edit" {
            
            for tag in tags{
                coreDataStartDates.append(tag.startDate)
                coreDataEndDates.append(tag.endDate)
                coreDataActivities.append(tag.activity!)
                coreDataStar.append(tag.star)
            }
            
            var path = tableView.indexPathForSelectedRow
            
            var detailTableViewController2 = segue.destination as! detailTableViewController2
            
            detailTableViewController2.index = path?.row
            detailTableViewController2.activityArray = coreDataActivities
            detailTableViewController2.startTimeArray = coreDataStartDates as! [Date]
            detailTableViewController2.endTimeArray = coreDataEndDates as! [Date]
            detailTableViewController2.starArray = coreDataStar
            
            deleteTag(tableView, commit: .delete, forRowAt: path!)
        }
    }
    

}
