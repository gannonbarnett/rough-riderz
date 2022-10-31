//
//  CascinoScene.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/27/18.
//  Copyright © 2018 Barnett. All rights reserved.
//
import Foundation
import UIKit
import SpriteKit
import GameKit
import FacebookCore
import FirebaseAnalytics

let chestPrice : (Int, Int) = (50, 4999)
var cardIndex : Int = 0

enum CardResultType {
    case Gems, Points, Bike, Solar, Wind
}

enum CardImageName : String {
    case cardBack = "roughRiderzCard.png", Gems_5 = "roughRiderzCard_5-gems.png",
    Gems_10 = "roughRiderzCard_10-gems.png", Gems_20 = "roughRiderzCard_20-gems.png",
    Gems_50 = "roughRiderzCard_50-gems.png",
    Points_500 = "roughRiderzCard_500-points.png", Points_750 = "roughRiderzCard_750-points.png", Points_1000 = "roughRiderzCard_1000-points.png",
    Points_2000 = "roughRiderzCard_2000-points.png", Points_3000 = "roughRiderzCard_3000-points.png", Points_7000 = "roughRiderzCard_7000-points.png", Points_10000 = "roughRiderzCard_10000-points.png",
    Solar = "roughRiderzCard_Solar.png", Wind = "roughRiderzCard_Wind.png", BMXBike = "roughRiderzCard_BMX.png", MonopolyCar = "roughRiderzCard_MonopolyCar.png", Truck = "roughRiderzCard_Truck.png", Scooter = "roughRiderzCard_Scooter.png", Plane = "roughRiderzCard_Plane.png", Gems_100 = "roughRiderzCard_100-gems.png"
}

let Cards : [CardImageName : (CardResultType, Int)] = [.Gems_5 : (.Gems, 5),
                                                         .Gems_10 : (.Gems, 10),
                                                         .Gems_20 : (.Gems, 20),
                                                         .Gems_50 : (.Gems, 50),
                                                         .Points_500 : (.Points, 500),
                                                         .Points_750 : (.Points, 750),
                                                         .Points_1000 : (.Points, 1000),
                                                         .Points_2000 : (.Points, 2000),
                                                         .Points_3000 : (.Points, 3000),
                                                         .Points_7000 : (.Points, 7000),
                                                         .Points_10000 : (.Points, 10000),
                                                         .Solar : (.Solar, 1),
                                                         .Wind : (.Wind, 1),
                                                         .BMXBike : (.Bike, 1),
                                                         .MonopolyCar : (.Bike, 1),
                                                         .Truck : (.Bike, 1),
                                                         .Scooter : (.Bike, 1),
                                                         .Plane : (.Bike, 1)]

var lastDailyChestOpenDate : Date? = nil

class CascinoScene: SKScene {
    
    var randomCardName : CardImageName? = nil
    
    var cascinoVC : CascinoViewController? = nil
    
    let SpecialChestSequence : [CardImageName] = [.Gems_20,
                                                  .Gems_50,
                                                  .Gems_50,
                                                  .Gems_50,
                                                  .Gems_100,
                                                  .Gems_100,
                                                  .Gems_100,
                                                  .Points_2000,
                                                  .Points_2000,
                                                  .Points_2000,
                                                  .Points_7000,
                                                  .Points_7000,
                                                  .Points_7000,
                                                  .Points_7000,
                                                  .Points_7000,
                                                  .Points_10000,
                                                  .Points_10000,
                                                  .Points_10000,
                                                  .Points_10000,
                                                  .Points_10000,
                                                  .Points_10000,
                                                  .Points_10000,
                                                  .Solar,
                                                  .Wind,
                                                  .BMXBike,
                                                  .MonopolyCar,
                                                  .Truck,
                                                  .Scooter]
    
    func randomNumberInRange(_ lower: Int, upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    
    let DailyChestSequence : [CardImageName] = [.Gems_5,
                                                .Gems_5,
                                                .Gems_5,
                                                .Gems_10,
                                                .Gems_20,
                                                .Points_750,
                                                .Points_750,
                                                .Points_750,
                                                .Points_500,
                                                .Points_1000,
                                                .Points_2000]
    
    
    private var DailyChestCardNode : SKSpriteNode!
    private var SpecialChestCardNode : SKSpriteNode!
    
    private var DailyChestOpenNode : SKSpriteNode!
    private var SpecialChestBuyNode_Gems : SKSpriteNode!
    private var SpecialChestBuyNode_Points : SKSpriteNode!
    
    var canOpenDailyChest : Bool = true
    
    override func didMove(to view: SKView) {
        DailyChestCardNode = self.childNode(withName: "DailyChestCardNode") as! SKSpriteNode
        DailyChestCardNode.isHidden = true
        SpecialChestCardNode = self.childNode(withName: "SpecialChestCardNode") as! SKSpriteNode
        SpecialChestCardNode.isHidden = true
        
        DailyChestOpenNode = self.childNode(withName: "DailyChestOpenNode") as! SKSpriteNode
        SpecialChestBuyNode_Gems = self.childNode(withName: "SpecialChestBuyNode_Gems") as! SKSpriteNode
        SpecialChestBuyNode_Points = self.childNode(withName: "SpecialChestBuyNode_Points") as! SKSpriteNode
        
        let calendar = Calendar.current
        if let last = lastDailyChestOpenDate {
            if calendar.isDateInToday(last) {
                canOpenDailyChest = false
                DailyChestOpenNode.color = UIColor.gray
                DailyChestOpenNode.colorBlendFactor = 0.5
            }else {
                canOpenDailyChest = true
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        if !DailyChestCardNode.isHidden {

        }else if DailyChestOpenNode.contains(location) && canOpenDailyChest{
            //card is not showing, open button contains location
            DailyChestCardNode.isHidden = false
            DailyChestOpenNode.isHidden = true
            beginCardAnimation(card: DailyChestCardNode)
            lastDailyChestOpenDate = Date()
            UserDefaults.standard.set(lastDailyChestOpenDate!.timeIntervalSinceReferenceDate, forKey: "LastDailyChestOpenDate")
            AppEventsLogger.log("Opened Daily Chest")
        }
        
        if !SpecialChestCardNode.isHidden {
            //card is showing
            if SpecialChestCardNode.contains(location) {
                SpecialChestCardNode.isHidden = true
                SpecialChestBuyNode_Gems.isHidden = false
                SpecialChestBuyNode_Points.isHidden = false
            }
        }else if SpecialChestBuyNode_Gems.contains(location) {
            //card is not showing, gem button active
            if gems >= chestPrice.0 {
                gems -= chestPrice.0
                UserDefaults.standard.set(gems, forKey: "Gems")
                SpecialChestBuyNode_Gems.isHidden = true
                SpecialChestBuyNode_Points.isHidden = true
                SpecialChestCardNode.isHidden = false
                AppEventsLogger.log("Opened Special Chest - gems")
                AppEventsLogger.log(AppEvent.spentCredits())
                beginCardAnimation(card: SpecialChestCardNode)
            }else {
                //incomplete
            }
            
        }else if SpecialChestBuyNode_Points.contains(location) {
            //card is not showing, points button active
            if points >= chestPrice.1 {
                points -= chestPrice.1
                UserDefaults.standard.set(points, forKey: "Points")
                SpecialChestBuyNode_Gems.isHidden = true
                SpecialChestBuyNode_Points.isHidden = true
                SpecialChestCardNode.isHidden = false
                AppEventsLogger.log("Opened Special Chest - points")
                AppEventsLogger.log(AppEvent.spentCredits())
                beginCardAnimation(card: SpecialChestCardNode)
            }else {
                //incomplete
            }
        }
    }
    
    func beginCardAnimation(card : SKSpriteNode) {
        
        let cardWidth : CGFloat = 90
        let fastInterval = 0.1
        let slowInterval = 0.2
        let reallySlowInterval = 0.5
        
        let fastTurnOne = SKAction.resize(toWidth: 5, duration: fastInterval)
        let fastTurnTwo = SKAction.resize(toWidth: cardWidth, duration: fastInterval)
        let slowTurnOne = SKAction.resize(toWidth: 5, duration: slowInterval)
        let slowTurnTwo = SKAction.resize(toWidth: cardWidth, duration: slowInterval)
        let reallySlowTurnOne = SKAction.resize(toWidth: 5, duration: reallySlowInterval)
        let reallySlowTurnTwo = SKAction.resize(toWidth: cardWidth, duration: reallySlowInterval)
        fastTurnOne.timingMode = .easeIn
        fastTurnTwo.timingMode = .easeOut
        slowTurnOne.timingMode = .easeIn
        slowTurnTwo.timingMode = .easeOut
        reallySlowTurnOne.timingMode = .easeIn
        reallySlowTurnTwo.timingMode = .easeOut
        
        var texture = SKTexture()
    
        switch card.name! {
        case "DailyChestCardNode":
            let randomIndex : Int = randomNumberInRange(0, upper: DailyChestSequence.count - 1)
            randomCardName = DailyChestSequence[randomIndex]
            texture = SKTexture(imageNamed: randomCardName!.rawValue)
        case "SpecialChestCardNode":
            let randomIndex : Int = randomNumberInRange(0, upper: SpecialChestSequence.count - 1)
            randomCardName = SpecialChestSequence[randomIndex]
            texture = SKTexture(imageNamed: randomCardName!.rawValue)
        default :
            let randomIndex : Int = randomNumberInRange(0, upper: DailyChestSequence.count - 1)
            randomCardName = DailyChestSequence[randomIndex]
            texture = SKTexture(imageNamed: randomCardName!.rawValue)
        }
        
        let firstAction = SKAction.repeat(SKAction.sequence([
            fastTurnOne,
            SKAction.animate(with: [SKTexture(image: #imageLiteral(resourceName: "roughRiderzCard.png"))], timePerFrame: 0),
            fastTurnTwo,
            fastTurnOne,
            SKAction.animate(with: [texture], timePerFrame: 0),
            fastTurnTwo]), count: 2)
        
        let secondAction = SKAction.repeat(SKAction.sequence([
            slowTurnOne,
            SKAction.animate(with: [SKTexture(image: #imageLiteral(resourceName: "roughRiderzCard.png"))], timePerFrame: 0),
            slowTurnTwo,
            slowTurnOne,
            SKAction.animate(with: [texture], timePerFrame: 0),
            slowTurnTwo]), count: 1)
        
        let thirdAction = SKAction.repeat(SKAction.sequence([
            reallySlowTurnOne,
            SKAction.animate(with: [SKTexture(image: #imageLiteral(resourceName: "roughRiderzCard.png"))], timePerFrame: 0),
            reallySlowTurnTwo,
            reallySlowTurnOne,
            SKAction.animate(with: [texture], timePerFrame: 0),
            reallySlowTurnTwo]), count: 1)
        
        let cardRiseAction = SKAction.move(to: CGPoint(x: card.position.x, y: 60), duration: fastInterval * 2 + slowInterval + reallySlowInterval)
        card.run(cardRiseAction)
        card.run(SKAction.sequence([firstAction, secondAction, thirdAction]))
        
        giveReward()
    }
    
    func giveReward() {
        switch Cards[randomCardName!]!.0 {
        case .Gems:
            gems += Cards[randomCardName!]!.1
        case .Points:
            points += Cards[randomCardName!]!.1
        case .Solar:
            solarLevel += 1
        case .Wind:
            windLevel += 1
        case .Bike:
            switch randomCardName!{
            case .MonopolyCar:
                if !purchasedBikeNames.contains(MonopolyCar().bikeName) {
                    purchasedBikeNames.append(MonopolyCar().bikeName)
                }
            case .BMXBike:
                if !purchasedBikeNames.contains(BMXBike().bikeName) {
                    purchasedBikeNames.append(BMXBike().bikeName)
                }
            case .Scooter:
                if !purchasedBikeNames.contains(Scooter().bikeName) {
                    purchasedBikeNames.append(Scooter().bikeName)
                }
            case .Truck:
                if !purchasedBikeNames.contains(Truck().bikeName) {
                    purchasedBikeNames.append(Truck().bikeName)
                }
            case .Plane:
                if !purchasedBikeNames.contains(Plane().bikeName) {
                    purchasedBikeNames.append(Plane().bikeName)
                }
            default:
                return
            }
        }
        UserDefaults.standard.set(purchasedBikeNames, forKey: "PurchasedBikeNames")
        cascinoVC?.updateLabels()
    }
}
