//
//  webPageViewController.swift
//  Cardiapp
//
//  Created by Sam Lack on 4/17/18.
//  Copyright © 2018 Riverdale Country School. All rights reserved.
//

import UIKit
import Foundation

class webPageViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var cardiappWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardiappWebView.delegate = self
        cardiappWebView.loadRequest(URLRequest(url: URL(string: "http://cardiapp.io/")!))
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
