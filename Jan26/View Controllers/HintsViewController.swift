//
//  HintsViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/16/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import FacebookCore

class HintsViewController: UIViewController {

    @IBAction func BackButtonTouched(_ sender: Any) {
        if soundOn {
            buttonPlayer.play()
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("Hints Page viewed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
