//
//  PauseViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/29/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class PauseViewController: UIViewController {

    @IBOutlet var AdFreeLifeBUtton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.setScreenName("pause_view", screenClass: "PauseViewController")
        
        if Premium {
            AdFreeLifeBUtton.isHidden = true
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ContinuePressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        let gameVC = navigationController?.topViewController as! GameViewController
    }
    
    @IBAction func RestartSimulation_Pressed(_ sender: UIButton) {
        let gameVC = self.navigationController!.viewControllers[1] as! GameViewController
        gameVC.gameSceneSetUp()
        self.navigationController?.popViewController(animated: true)
    }

}
