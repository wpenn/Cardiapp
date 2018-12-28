//
//  HHAWebPageViewController.swift
//  Cardiapp
//
//  Created by Sam Lack on 5/23/18.
//  Copyright © 2018 Riverdale Country School. All rights reserved.
//

import UIKit
import Foundation

class HHAWebPageViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var HHAdviceWebView: UIWebView!
    
    @IBAction func backToHHAPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToHHA", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HHAdviceWebView.delegate = self
//        HHAdviceWebView.loadRequest(URLRequest(url: URL(string: "https://www.heartfoundation.org.au/healthy-eating/food-and-nutrition/protein-foods/eggs")!))
        HHAdviceWebView.loadRequest(URLRequest(url: URL(string: webPageViewControllerURL)!))
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
