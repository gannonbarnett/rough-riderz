//
//  GetPointsViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/7/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import GoogleMobileAds
import FacebookCore

let pointsLevelOne = 20000
let pointsLevelTwo = 70000
let pointsAd = 500

let gemsLevelOne = 200
let gemsLevelTwo = 750

let package = (1000, 90000)

class GetPointsViewController: UIViewController, GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        points += pointsAd
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GADRewardBasedVideoAd.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("GetMorePointsPage viewed")
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: gameRewardID)
    }
    
    @IBAction func BackButtonTouched(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func BuyPointsOneTouched(_ sender: Any) {
        purchaseProduct_PointsOne()
    }
    
    @IBAction func BuyPointsTwoTouched(_ sender: Any) {
        purchaseProduct_PointsTwo()
    }
    
    @IBAction func BuyGemsOneTouched(_ sender: Any) {
        purchaseProduct_GemsOne()
    }
    
    @IBAction func BuyGemsTwoTouched(_ sender: Any) {
        purchaseProduct_GemsTwo()
    }
    
    @IBAction func BuyPackageTouched(_ sender: Any) {
        purchaseProduct_Package()
    }
    
    @IBAction func WatchAdButtonTouched(_ sender: Any) {
        AppEventsLogger.log("WatchAd_ForPoints Touched")
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            AppEventsLogger.log("Presented video reward ad")
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        } else {
            AppEventsLogger.log("Unable to load video reward ad")
            print("Unable to load ad")
        }
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: gameRewardID)
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }

    func purchaseProduct_PointsOne() {
        SwiftyStoreKit.purchaseProduct("Barnett.RoughRiderz.PointsOne", completion: {
            result in
            if case .success(let product) = result {
                
                points += pointsLevelOne
                UserDefaults.standard.set(points, forKey: "Points")
                AppEventsLogger.log(AppEvent.purchased(amount: 0.99))
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
        })
    }
    
    func purchaseProduct_PointsTwo() {
        SwiftyStoreKit.purchaseProduct("Barnett.RoughRiderz.PointsTwo", completion: {
            result in
            if case .success(let product) = result {
                
                points += pointsLevelTwo
                AppEventsLogger.log(AppEvent.purchased(amount: 2.99))

                UserDefaults.standard.set(points, forKey: "Points")
                
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
        })
    }
    
    func purchaseProduct_GemsOne() {
        SwiftyStoreKit.purchaseProduct("Barnett.RoughRiderz.GemsOne", completion: {
            result in
            if case .success(let product) = result {
                
                gems += gemsLevelOne
                AppEventsLogger.log(AppEvent.purchased(amount: 0.99))
                
                UserDefaults.standard.set(points, forKey: "Points")
                
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
        })
    }
    
    func purchaseProduct_GemsTwo() {
        SwiftyStoreKit.purchaseProduct("Barnett.RoughRiderz.GemsTwo", completion: {
            result in
            if case .success(let product) = result {
                
                gems += gemsLevelTwo
                AppEventsLogger.log(AppEvent.purchased(amount: 2.99))
                
                UserDefaults.standard.set(gems, forKey: "Gems")
                
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
        })
    }
    
    func purchaseProduct_Package() {
        SwiftyStoreKit.purchaseProduct("Barnett.RoughRiderz.Package", completion: {
            result in
            if case .success(let product) = result {
                
                points += package.1
                gems += package.0
                AppEventsLogger.log(AppEvent.purchased(amount: 9.99))
                
                UserDefaults.standard.set(points, forKey: "Points")
                UserDefaults.standard.set(gems, forKey: "Gems")
                
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
        })
    }
    
}
