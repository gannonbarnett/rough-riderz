//
//  StoreViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/4/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import FacebookCore

class StoreViewController: UIViewController {
    
    @IBOutlet var PointsLabel: UILabel!
    @IBOutlet var GemsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PointsLabel.text = String(points)
        GemsLabel.text = String(gems)
    }

    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("StorePage viewed")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackButtonPressed(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func GetMorePointsButtonTouched(_ sender: Any) {
        
    }
}
