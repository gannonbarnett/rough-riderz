//
//  GameOverViewController.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/29/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FirebaseDatabase

import FirebaseAnalytics
import FacebookCore

import Social

var secondTry : Bool = false

class GameOverViewController: UIViewController, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate {
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        
    }
    
    @IBOutlet var ScoreLabel: UILabel!
    @IBOutlet var AdFreeLifeButton: UIButton!
    @IBOutlet var PointLabel: UILabel!
    @IBOutlet var TotalPointLabel: UILabel!
    
    @IBOutlet var ContinueScoreButton: UIButton!
    
    @IBAction func shareButtonPressed(sender : UIButton) {
        
        let post = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
        getRank {
            print(self.user_Rank)
            let newImage = self.getShareImage(rank: self.user_Rank)
            post.add(newImage)
            post.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                switch result {
                case .cancelled:
                    break
                    
                case .done:
                    points += Int(Double(score) * pointsToScoreRatio)
                    AppEventsLogger.log("SharedOnFacebook")
                    break
                }
            }
            self.present(post, animated: true)
            }
    }
    
    var interstitialAd : GADInterstitial?
    
    let randomAdRate : Int = 4
    
    var user_Rank : Int = 1
    
    func getRank(completion: @escaping () -> Void) {
        var rank : Int = 1
        let Username = UserDefaults.standard.value(forKey: "DisplayName") as! String
        let highscore = UserDefaults.standard.value(forKey: "Highscore") as! Int
        let ref = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            for childSnapshot in snapshot.children.allObjects {
                let child = childSnapshot as! DataSnapshot
                let name = child.childSnapshot(forPath: "DisplayName").value as! String
                let retrievedScore = child.childSnapshot(forPath: "Highscore").value as! Int
                if name != Username {
                    if retrievedScore > highscore {
                        rank += 1
                    }
                }
            }
            self.user_Rank = rank
            completion()
        })
    }
    
    func getShareImage(rank: Int) -> UIImage {
        let textColor = UIColor.black
        let Rank_textFont = UIFont(name: "AmericanTypewriter-Bold", size: 100)!
        var Name_textFont = UIFont(name: "AmericanTypewriter-Bold", size: 80)!
        
        let image = UIImage(named: "RR_ShareBlank.png")!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let Rank_textFontAttributes = [
            NSAttributedStringKey.font: Rank_textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        
        var Name_textFontAttributes = [
            NSAttributedStringKey.font: Name_textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        //adding rank to the image
        let textPoint_Rank = CGPoint(x: image.size.width / CGFloat(2) - CGFloat(125), y: image.size.height / CGFloat(2) - CGFloat(15))
        let rect_Rank = CGRect(origin: textPoint_Rank, size: image.size)
        
        let nameText = UserDefaults.standard.value(forKey: "DisplayName") as! String
        let totalChars = nameText.count
        var estimatedStringLength = totalChars * 40
        var padding = CGFloat(0)
        if estimatedStringLength > 320 {
            Name_textFont = UIFont(name: "AmericanTypewriter-Bold", size: 40)!
            Name_textFontAttributes = [
                NSAttributedStringKey.font: Name_textFont,
                NSAttributedStringKey.foregroundColor: textColor,
                ] as [NSAttributedStringKey : Any]
            estimatedStringLength = 450
            padding = CGFloat(20)
        }
        //adding name to the image
        let textPoint_Name = CGPoint(x: image.size.width / CGFloat(2) - CGFloat(estimatedStringLength / 2), y: image.size.height / CGFloat(2) - CGFloat(85) + padding)
        let rect_Name = CGRect(origin: textPoint_Name, size: image.size)
        
        let rankText = "#\(rank)"
        rankText.draw(in: rect_Rank, withAttributes: Rank_textFontAttributes)
        
        nameText.draw(in: rect_Name, withAttributes: Name_textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func presentAlert_NoFacebook() {
        let alert = UIAlertController(title: "Unable to Share", message: "We were unable to conenct to a Facebook account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiess", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        
        self.ScoreLabel.text = String(score)
        self.PointLabel.text = String(Int(Double(score) * pointsToScoreRatio))
        points += Int(Double(score) * pointsToScoreRatio)
        UserDefaults.standard.set(points, forKey: "Points")
        UserDefaults.standard.set(gems, forKey: "Gems")
        self.TotalPointLabel.text = String(points)
        
        ContinueScoreButton.transform.rotated(by: CGFloat(Double.pi / 4))
        
        Analytics.setScreenName("gameover_view", screenClass: "GameOverViewController")
        
        if !Premium {
            randomPresentationOfAdWithFrequency(oneIn: randomAdRate)
        }
    }
    
    @objc func appClosed() {
        if self.isBeingPresented {
            navigationController?.popToRootViewController(animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.set(gems, forKey: "Gems")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if secondTry {
            ContinueScoreButton.isHidden = true
            secondTry = false
        }else {
            ContinueScoreButton.isHidden = false
        }
        
        if !Premium {
            interstitialAd?.delegate = self
        }
        
        if Premium {
            AdFreeLifeButton.isHidden = true
        }
    }
    
    @IBAction func ContinueScoreButtonTouched(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        }else {
            presentAlert_UnableToShowAd()
        }
    }
    
    func presentAlert_UnableToShowAd() {
        var alert = UIAlertController(title: "Unable to load advertisement.", message: "Unfortunately we are having trouble loading an ad at this time.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        let gameVC = self.navigationController!.viewControllers[1] as! GameViewController
        gameVC.gameSceneSetUp(score: score / bikeInUse.multiplier)
        self.navigationController!.popViewController(animated: true)
        AppEventsLogger.log("ContinueScoreForAd Used")
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: gameRewardID)
        secondTry = true
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let request = GADRequest()
        let interstitial = GADInterstitial(adUnitID: interstitialAdID)
        interstitial.delegate = self
        interstitial.load(request)
        
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitialAd = createAndLoadInterstitial()
    }
    
    func randomNumberInRange(_ lower: Int, upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func randomPresentationOfAdWithFrequency(oneIn: Int) {
        let randomNumber = randomNumberInRange(1, upper: oneIn)
        
        print("Random number: \(randomNumber)")
        
        if randomNumber == 1 {
            if interstitialAd != nil {
                if interstitialAd!.isReady {
                    interstitialAd?.present(fromRootViewController: self)
                    print("Ad presented")
                } else {
                    print("Ad was not ready for presentation")
                }
            }
        }
        
    }

    @IBAction func MainMenuButtonPressed(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func PlayAgainPressed(_ sender: UIButton) {
        if soundOn {
            buttonPlayer.play()
        }
        let gameVC = self.navigationController!.viewControllers[1] as! GameViewController
        gameVC.gameSceneSetUp()
        self.navigationController!.popViewController(animated: true)
    }

}
