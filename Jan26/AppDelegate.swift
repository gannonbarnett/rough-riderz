//
//  AppDelegate.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/26/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import Firebase
import SwiftyStoreKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FacebookCore
import AVFoundation

/**
 remove menu buttons that are hidden
 **/
var Premium : Bool = false
var CurrentUserID : String = ""

let myNotificationKey = "com.bobthedeveloper.notificationKey"

var buttonPlayer : AVAudioPlayer = AVAudioPlayer()

var musicPlayer : AVAudioPlayer = AVAudioPlayer()

var bikeNameDictionary : [String : BikeFrame] = [:]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate{
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    var window: UIWindow?
    
    func makeRandomString(_ length : Int = 4) -> String {
        var charArray : [Character] = []
        for char in "qwertyuiopasdfghjklzxcvbnm" {
            charArray.append(char)
        }
        
        var randomString = ""
        for _ in 0 ..< length {
            let index = Int(arc4random_uniform(UInt32(charArray.count)))
            randomString.append(charArray[index])
        }
        return randomString
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
                
                if error == nil {
                    print("Successful Authorization")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        application.registerForRemoteNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
        
        //Premium
        if UserDefaults.standard.string(forKey: "Premium") == nil  {
            UserDefaults.standard.set(false, forKey: "Premium")
        } else {
            Premium = UserDefaults.standard.bool(forKey: "Premium")
        }
        Premium = UserDefaults.standard.bool(forKey: "Premium")
        
        //Highscore
        if UserDefaults.standard.integer(forKey: "Highscore") == nil  {
            UserDefaults.standard.set(0.0, forKey: "Highscore")
        }
        
        //PurchasedBikes
        if UserDefaults.standard.stringArray(forKey: "PurchasedBikeNames") == nil {
            UserDefaults.standard.set([StandardBike().bikeName], forKey: "PurchasedBikeNames")
        }
        purchasedBikeNames = UserDefaults.standard.stringArray(forKey: "PurchasedBikeNames")!
        
        //solar level
        if UserDefaults.standard.integer(forKey: "SolarLevel") == nil {
            UserDefaults.standard.set(0, forKey: "SolarLevel")
        }
        
        solarLevel = UserDefaults.standard.integer(forKey: "SolarLevel")
        
        //wind level
        if UserDefaults.standard.integer(forKey: "WindLevel") == nil {
            UserDefaults.standard.set(0, forKey: "WindLevel")
        }
        windLevel = UserDefaults.standard.integer(forKey: "WindLevel")

        //Points
        if UserDefaults.standard.integer(forKey: "Points") == nil {
            UserDefaults.standard.set(0, forKey: "Points")
        }
        points = UserDefaults.standard.integer(forKey: "Points")
        
        //Gems
        if UserDefaults.standard.integer(forKey: "Gems") == nil {
            UserDefaults.standard.set(0, forKey: "Gems")
        }
        gems = UserDefaults.standard.integer(forKey: "Gems")

        //save bike in use
        for bike in BikeArray {
            bikeNameDictionary[bike.bikeName] = bike
        }

        if UserDefaults.standard.double(forKey: "LastDailyChestOpenDate") != nil {
            lastDailyChestOpenDate = Date(timeIntervalSinceReferenceDate: UserDefaults.standard.double(forKey: "LastDailyChestOpenDate"))
        }
        
        if UserDefaults.standard.bool(forKey: "Sandbox") == nil {
            UserDefaults.standard.set(false, forKey: "Sandbox")
        }
        sandboxPurchased =  UserDefaults.standard.bool(forKey: "Sandbox")
        
        if UserDefaults.standard.string(forKey: "BikeInUse") == nil {
            UserDefaults.standard.set(StandardBike().bikeName, forKey: "BikeInUse")
        }
        bikeInUse = bikeNameDictionary[UserDefaults.standard.string(forKey: "BikeInUse")!]!
        
        if UserDefaults.standard.bool(forKey: "SoundOn") == nil {
            UserDefaults.standard.set(true, forKey: "SoundOn")
        }
        soundOn = UserDefaults.standard.bool(forKey: "SoundOn")
        FirebaseApp.configure()
        Analytics.setScreenName("game_view", screenClass: "GameViewController")
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: "ca-app-pub-6058033124995096~9018658406")
        
        //In-app purchases
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        Premium = true
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    Premium = true
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        if UserDefaults.standard.string(forKey: "CurrentUserID") == nil {
            let ref = Database.database().reference()
            let UserID = makeRandomString(20)
            UserDefaults.standard.set(UserID, forKey: "CurrentUserID")
            ref.child(UserID).setValue(UserID)
        }
        
        if UserDefaults.standard.string(forKey: "DisplayName") == nil {
            UserDefaults.standard.set("Username", forKey: "DisplayName")
        }
        CurrentUserID = UserDefaults.standard.string(forKey: "CurrentUserID")!
        
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: gameRewardID)
        
        do {
            buttonPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "ButtonTick1", ofType: "wav")!))
        }
        catch {
            print(error)
        }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "BackgroundMusic", ofType: "mp3")!))
        }
        catch {
            print(error)
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        if let nav = UIApplication.shared.keyWindow!.rootViewController as? UINavigationController {
            if let gameVC = nav.viewControllers.last! as? GameViewController {
                score = gameVC.gameScene!.getScore()
                gameVC.died()
            }
        }
        
        let df : DateFormatter = DateFormatter()
        df.timeStyle = .medium
        df.dateStyle = .medium
        
        let ref : DatabaseReference = Database.database().reference()
        let userFile = ref.child(CurrentUserID)
        userFile.child("Last-login").setValue(df.string(from: Date()))
        
    }
    
    @objc func doThisWhenNotify() {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //firebase anayltics
        FBHandler()
        
        //facebook
        AppEventsLogger.activate(application)
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @objc func refreshToken(notification: NSNotification) {
        let refreshToken = InstanceID.instanceID().token()!
        print("*** \(refreshToken) ***")
        
        FBHandler()
    }
    
    func FBHandler() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    
}

