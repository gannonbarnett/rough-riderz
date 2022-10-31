//
//  GameViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/26/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds
import os.log
import FirebaseAnalytics
import FacebookCore
import AVFoundation

let interstitialAdID : String = "ca-app-pub-6058033124995096/7552699342"
let gameRewardID : String = "ca-app-pub-6058033124995096/3114079668"

class GameViewController: UIViewController {
    
    var loadedInterstitialAd : GADInterstitial? = nil
    
    @IBAction func ResetButtonTouched(_ sender: Any) {
        if soundOn {
            buttonPlayer.play()
        }
        gameScene!.resetGame()
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let request = GADRequest()
        let interstitial = GADInterstitial(adUnitID: interstitialAdID)
        interstitial.load(request)
        return interstitial
    }
    
    var gameScene : GameScene? {
        if let view = self.view as! SKView? {
            return view.scene! as! GameScene
        }
        return nil 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.isNavigationBarHidden = true
        
        gameSceneSetUp()
    }

    @objc func appClosed() {
        if self.isBeingPresented {
            gameScene?.isPaused = true
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let view = self.view as! SKView
        view.scene?.isPaused = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let view = self.view as! SKView
        let scene = view.scene! as! GameScene
        scene.removeAllActions()
        scene.removeAllChildren()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadedInterstitialAd = createAndLoadInterstitial()
        AppEventsLogger.log("Game played")
        AppEventsLogger.log("Used \(bikeInUse.bikeName)")
    }
    
    func gameSceneSetUp(score: Int = 0) {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                scene.becomeFirstResponder()
                scene.manualPoints = score
                scene.gameVC = self
                
                //view.showsFPS = true
                // view.showsNodeCount = true
            }
            
            view.ignoresSiblingOrder = true
        }
    }
        
    @IBAction func MainMenuPressed(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        self.navigationController?.popViewController(animated: true)
    }

    func died() {
        guard self.navigationController?.topViewController?.restorationIdentifier != "GameOverVC" else {
            return
        }
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore")
            Analytics.setUserProperty(String(score), forName: "current_highscore")
            Analytics.setUserProperty(String(windLevel), forName: "windLevel")
            Analytics.setUserProperty(String(solarLevel), forName: "solarLevel")
        }
        self.performSegue(withIdentifier: "GameOverSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameOverSegue" {
            let gameOverVC = segue.destination as! GameOverViewController
            gameOverVC.interstitialAd = loadedInterstitialAd
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
