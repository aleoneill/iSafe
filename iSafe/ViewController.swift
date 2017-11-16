//
//  ViewController.swift
//  iSafe
//
//  Created by Andy Kor on 11/3/17.
//  Copyright © 2017 Andy Kor. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBOutlet weak var showMap: UIButton!
    @IBOutlet weak var showMission: UIButton!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    @IBAction func showMap(sender: UIButton) {
        self.performSegue(withIdentifier: "map", sender: self)
    }
    
    @IBAction func showMission(sender: UIButton) {
        self.performSegue(withIdentifier: "mission", sender: self)
    }
}


