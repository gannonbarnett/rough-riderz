//
//  LeaderboardViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/6/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import FacebookCore

class LeaderboardViewController: UIViewController {

    @IBAction func BackButtonTouched(_ sender: Any) {
        if soundOn {
            buttonPlayer.play()
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("LeaderboardsPage viewed")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
