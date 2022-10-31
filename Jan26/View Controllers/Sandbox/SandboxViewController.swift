//
//  SandboxViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 3/11/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import SpriteKit
import FacebookCore

class SandboxViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        gameSceneSetUp()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("Sandbox played")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func gameSceneSetUp(score: Int = 0) {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "SandboxScene") as? SandboxMode {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                scene.becomeFirstResponder()
                scene.sandboxVC = self
                //view.showsFPS = true
                // view.showsNodeCount = true
            }
            
            view.ignoresSiblingOrder = true
        }
    }
    
    @IBAction func MenuButtonTouched(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func died() {
        self.performSegue(withIdentifier: "SandboxGameOver", sender: nil)
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
