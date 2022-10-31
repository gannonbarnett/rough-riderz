//
//  MainScreenViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/30/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseDatabase
import AVFoundation
import FacebookCore
import FacebookShare
import GoogleMobileAds

var name : String = "Username"
var soundOn : Bool = true

var points = 0
var score = 0
var gems = 0

var pointsToScoreRatio = 0.1

var sandboxPurchased : Bool = true

class MainScreenViewController: UIViewController, UITextFieldDelegate {

    var maxUserNameLength : Int = 14
    
    @IBOutlet var AdFreeButton: UIButton!
    
    @IBOutlet var ScoreLabel: UILabel!
    @IBOutlet var PointLabel: UILabel!
    
    @IBOutlet var GemLabel: UILabel!
    
    @IBOutlet var UsernameTextField: UITextField!
    
    @IBOutlet var SoundSwitch: UISwitch!
    
    @IBAction func SoundSwitchChanged(_ sender: UISwitch) {
        soundOn = SoundSwitch.isOn
        buttonPlayer.play()
        if !soundOn {
            musicPlayer.stop()
            AppEventsLogger.log("Turned sound off")
        }else {
            musicPlayer.play()
            AppEventsLogger.log("Turned sound on")
        }
        UserDefaults.standard.set(soundOn, forKey: "SoundOn")
    }
    
    @IBAction func SandboxTouched(_ sender: UIButton) {
        if sandboxPurchased {
            self.performSegue(withIdentifier: "RunSandbox", sender: nil)
        }else {
            self.performSegue(withIdentifier: "BuySandbox", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if soundOn {
            musicPlayer.volume = 0.6
            musicPlayer.play()
            musicPlayer.numberOfLoops = -1
        }
        hideKeyboardWhenTappedAround()
        UsernameTextField.delegate = self
        let defaults = UserDefaults.standard
        self.title = "MainVC"
        if defaults.bool(forKey: "Premium") == true {
            AdFreeButton.titleLabel?.text = ":)"
            AdFreeButton.isEnabled = false
            AdFreeButton.isHighlighted = true
        }
        
        let ref : DatabaseReference = Database.database().reference()
        
        let highscore = defaults.integer(forKey: "Highscore")
        let displayName = UsernameTextField.text == nil ? "Username" : UsernameTextField.text
        
        let userFile = ref.child(CurrentUserID)
        userFile.child("DisplayName").setValue(displayName!)
        userFile.child("Highscore").setValue(highscore)
        
        SoundSwitch.isOn = soundOn
        buttonPlayer.prepareToPlay()
        
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: gameRewardID)
    }
    
    
    func checkScore() {
        let ref = Database.database().reference().child(CurrentUserID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("NewScore") {
                let newScore = snapshot.childSnapshot(forPath: "NewScore").value as! Int
                UserDefaults.standard.set(newScore, forKey: "Highscore")
                score = newScore
                self.ScoreLabel.text = String(score)
                self.resetManualScore()
            }
        })
    }
    
    func resetManualScore() {
        let ref : DatabaseReference = Database.database().reference()
        let userFile = ref.child(CurrentUserID)
        userFile.child("NewScore").setValue(nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count
        return newLength <= maxUserNameLength // Bool
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         UserDefaults.standard.set(UsernameTextField.text!, forKey: "DisplayName")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let ref : DatabaseReference = Database.database().reference()
        let displayName = UsernameTextField.text == nil ? "Username" : UsernameTextField.text
        let userFile = ref.child(CurrentUserID)
        UserDefaults.standard.set(displayName!, forKey: "DisplayName")
        userFile.child("DisplayName").setValue(displayName!)
        userFile.child("Highscore").setValue(UserDefaults.standard.integer(forKey: "Highscore"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UsernameTextField.text = UserDefaults.standard.string(forKey: "DisplayName")!
        if UsernameTextField.text!.count > maxUserNameLength {
            UsernameTextField.text = String(UsernameTextField.text!.dropLast(UsernameTextField.text!.count - maxUserNameLength))
            UserDefaults.standard.set(UsernameTextField.text!, forKey: "DisplayName")
        }
        Analytics.setUserProperty(UsernameTextField.text, forName: "display_name")
        checkScore()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    @IBAction func ResetButtonTouched(_ sender: Any) {
        presentAlert_ConfirmReset()
        ScoreLabel.text = String(UserDefaults.standard.integer(forKey: "Highscore"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ScoreLabel.text = String(UserDefaults.standard.integer(forKey: "Highscore"))
        PointLabel.text = String(points)
        GemLabel.text = String(gems)
    }
    
    func presentAlert_ConfirmReset() {
        let alert = UIAlertController(title: "Are you sure?", message: "Please confirm your choice to reset your highscore.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.destructive, handler: { (alert) in
            UserDefaults.standard.set(0, forKey: "Highscore")
            let vc : MainScreenViewController = super.self() as! MainScreenViewController
            vc.ScoreLabel.text = String(UserDefaults.standard.integer(forKey: "Highscore"))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        ScoreLabel.text = String(UserDefaults.standard.integer(forKey: "Highscore"))
    }
    
    @IBAction func ButtonTouched(_ sender: Any) {
        guard soundOn else { return }
        buttonPlayer.play()
    }
    
}
