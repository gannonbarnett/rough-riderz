//
//  BikeUpgradesViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/19/18.
//  Copyright © 2018 Barnett. All rights reserved.
//
import Darwin
import UIKit
import FacebookCore

let WindPointBase : Double = 4000
let WindGemBase : Double = 10

let SolarPointBase : Double = 5000
let SolarGemBase : Double = 10

let pointFactor = 1.5

class BikeUpgradesViewController: UIViewController {

    @IBOutlet var SolarEnergyLevelLabel: UILabel!
    @IBOutlet var SolarPointsButton: UIButton!
    @IBOutlet var SolarGemsButton: UIButton!

    @IBOutlet var WindEnergyLevelLabel: UILabel!
    @IBOutlet var WindPointsButton: UIButton!
    @IBOutlet var WindGemsButton: UIButton!
    
    @IBOutlet var Solar_NotEnoughPointsLabel: UILabel!
    @IBOutlet var Wind_NotEnoughPointsLabel: UILabel!
    
    var storeVC : StoreViewController {
        return self.parent!.parent! as! StoreViewController
    }
    
    var nextSolarLevelPointPrice : Int {
        return Int(SolarPointBase * pow(pointFactor, Double(solarLevel)))
    }
    
    var nextSolarLevelGemPrice : Int {
        return Int(SolarGemBase * pow(pointFactor, Double(solarLevel)))
    }
    
    var nextWindLevelPointPrice : Int {
        return Int(WindPointBase * pow(pointFactor, Double(windLevel)))
    }
    
    var nextWindLevelGemPrice : Int {
        return Int(WindGemBase * pow(pointFactor, Double(windLevel)))
    }
    
    @IBAction func SolarPointsTouched(_ sender: UIButton) {
        if points >= nextSolarLevelPointPrice {
            points -= nextSolarLevelPointPrice
            solarLevel += 1
            UserDefaults.standard.set(points, forKey: "Points")
            UserDefaults.standard.set(points, forKey: "SolarLevel")
            storeVC.PointsLabel.text = String(points)
            loadData()
        }else {
            fadeInOut(label: Solar_NotEnoughPointsLabel)
        }
    }
    
    override func viewDidLoad() {
        loadData()
        Solar_NotEnoughPointsLabel.isHidden = true
        Wind_NotEnoughPointsLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("Cascino Page Viewed")
        AppEventsLogger.log(AppEvent.spentCredits())
    }
    
    @IBAction func SolarGemsTouched(_ sender: UIButton) {
        if gems >= nextSolarLevelGemPrice {
            gems -= nextSolarLevelGemPrice
            solarLevel += 1
            UserDefaults.standard.set(gems, forKey: "Gems")
            UserDefaults.standard.set(solarLevel, forKey: "SolarLevel")
            AppEventsLogger.log("Upgraded Solar Level")
            AppEventsLogger.log(AppEvent.spentCredits())
            storeVC.GemsLabel.text = String(gems)
            loadData()
        }else {
            fadeInOut(label: Wind_NotEnoughPointsLabel)
        }
    }
    
    @IBAction func WindPointsTouched(_ sender: UIButton) {
        if points >= nextWindLevelPointPrice {
            points -= nextWindLevelPointPrice
            windLevel += 1
            UserDefaults.standard.set(points, forKey: "Points")
            UserDefaults.standard.set(windLevel, forKey: "WindLevel")
            AppEventsLogger.log(AppEvent.spentCredits())
            
            storeVC.PointsLabel.text = String(points)
            loadData()
        }else {
            fadeInOut(label: Wind_NotEnoughPointsLabel)
        }
    }
    
    @IBAction func WindGemsTouched(_ sender: UIButton) {
        if gems >= nextWindLevelGemPrice {
            gems -= nextWindLevelGemPrice
            windLevel += 1
            UserDefaults.standard.set(gems, forKey: "Gems")
            UserDefaults.standard.set(windLevel, forKey: "WindLevel")
            AppEventsLogger.log("Upgraded Wind Level")
            AppEventsLogger.log(AppEvent.spentCredits())
            storeVC.GemsLabel.text = String(gems)
            loadData()
        }else {
            fadeInOut(label: Wind_NotEnoughPointsLabel)
        }
    }
    
    func loadData() {
        WindEnergyLevelLabel.text = "Level \(windLevel)"
        SolarEnergyLevelLabel.text = "Level \(solarLevel)"
        
        WindPointsButton.setTitle(String(nextWindLevelPointPrice), for: .normal)
        WindGemsButton.setTitle(String(nextWindLevelGemPrice), for: .normal)
        
        SolarPointsButton.setTitle(String(nextSolarLevelPointPrice), for: .normal)
        SolarGemsButton.setTitle(String(nextSolarLevelGemPrice), for: .normal)
    }
    
    func fadeInOut(label : UILabel) {
        
        let animationDuration = 1.0
        
        // Fade in the view
        UILabel.animate(withDuration: animationDuration, animations: { () -> Void in
            label.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UILabel.animate(withDuration: animationDuration, delay: 2.0, options: [.curveEaseIn], animations: { () -> Void in
                label.alpha = 0
            }, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
