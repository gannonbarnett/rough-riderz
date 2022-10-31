//
//  UpgradeViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/30/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import FirebaseAnalytics
import FacebookCore

let sharedSecret : String = "8dce6c9b96fa425eba73354cca19d4cf"
class UpgradeViewController: UIViewController {

    @IBAction func BackButtonPressed(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.setScreenName("upgrade_view", screenClass: "UpgradeViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("PremiumPage viewed")
    }

    
    //In-app purchases
    func verifyPurchase() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = "com.Barnett.SitReady.PremiumUpgrade"
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let receiptItem):
                    
                    Premium = true
                    UserDefaults.standard.set(true, forKey: "Premium")
                    self.presentAlert_RestoreSuccessful()
                    print("\(productId) is purchased: \(receiptItem)")
                    
                case .notPurchased:
                    
                    self.presentAlert_RestoreFailed_NoPurchase()
                    print("The user has never purchased \(productId)")
                }
                
            case .error(let error):
                self.presentAlert_RestoreFailed_Other(error)
                print("Receipt verification failed: \(error)")
            }
        }
        
    }
    
    func presentAlert_RestoreSuccessful() {
        let alert = UIAlertController(title: "Restore successful!", message: "Premium mode activated.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_RestoreFailed_NoPurchase() {
        let alert = UIAlertController(title: "Restore failed", message: "The product has never been purchased by this account.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_RestoreFailed_Other(_ error : Error) {
        let alert = UIAlertController(title: "Restore failed", message: "Attempted restoration failed with error \(error)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
