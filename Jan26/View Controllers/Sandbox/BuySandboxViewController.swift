//
//  BuySandboxViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 3/11/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import FacebookCore

class BuySandboxViewController: UIViewController {

    func purchaseProduct_Sandbox() {
        SwiftyStoreKit.purchaseProduct("Barnett.RoughRiderz.Sandbox", completion: {
            result in
            if case .success(let product) = result {
                
                AppEventsLogger.log(AppEvent.purchased(amount: 0.99))
                UserDefaults.standard.set(true, forKey: "Sandbox")
                self.navigationController!.popToRootViewController(animated: true)
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("BuySandboxPage Viewed")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BuySandboxButtonTouched(sender: Any) {
        purchaseProduct_Sandbox()
    }
    
    @IBAction func BackButtonTouched(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
