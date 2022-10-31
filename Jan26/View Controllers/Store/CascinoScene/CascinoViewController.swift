//
//  CascinoViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/27/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import SpriteKit
import FacebookCore

class CascinoViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("Cascino Page Viewed")
    }
    var storeVC : StoreViewController {
        return self.parent!.parent! as! StoreViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "CascinoScene") as? CascinoScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.cascinoVC = self
                // Present the scene
                view.presentScene(scene)
                
                //view.showsFPS = true
                // view.showsNodeCount = true
            }
            view.ignoresSiblingOrder = true
        }
    }

    func updateLabels() {
        storeVC.PointsLabel.text = String(points)
        storeVC.GemsLabel.text = String(gems)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
