//
//  SettingsViewController.swift
//  Cardiapp
//
//  Created by Sam Lack on 3/1/18.
//  Copyright © 2018 Riverdale Country School. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController: UIViewController {

    
    @IBAction func HPButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToHeartProfileSegue", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
