//
//  InfoViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/30/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FacebookCore

class InfoViewController: UIViewController {

    @IBAction func BackButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        guard soundOn else { return }
        buttonPlayer.play()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.setScreenName("info_view", screenClass: "InfoViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppEventsLogger.log("InfoPage viewed")
    }
}
