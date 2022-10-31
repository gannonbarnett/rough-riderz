//
//  GameScene.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/26/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import CoreGraphics
import AVFoundation

var solarLevel : Int = 1
var windLevel : Int = 1

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC : GameViewController? = nil
    
    //---LABELS---
     public var bike : BikeFrame!
    
    private var meterLabel : SKLabelNode!
    private var distanceLabel : SKLabelNode!
    
    private var V_IntroLabel : SKLabelNode!
    private var V_Label : SKLabelNode!
    
    private var HighscoreValueLabel : SKLabelNode!
    private var CurrentScoreValueLabel : SKLabelNode!
    private var AirTimeValueLabel : SKLabelNode!
    
    private var AirPositionLabel : SKLabelNode!
    
    private var trickLabel : SKLabelNode!
    
    private var velocityMeter : SKSpriteNode!
    
    private var dirtMeter : SKSpriteNode!
    
    private var dirtMetersLabel : SKLabelNode!
    
    private var lowDirtWarningLabel : SKLabelNode!
    
    private var windHeadNode : SKSpriteNode!
    
    private var solarNode : SKSpriteNode!
    
    private var solarLevelLabel : SKLabelNode!
    
    private var windLevelLabel : SKLabelNode!
    
    private var sideMenu : SKSpriteNode!
    
    private var scoreMenu : SKSpriteNode!
    
    private var touchToBeginLabel : SKLabelNode!
    
    let startingPosition = CGPoint(x: -250, y: 180)
    
    var gemNodes : [SKSpriteNode] = []
    
    var gemFrequency : Int = 30
    
    var gemInterval_MIN : Int = 500
    var gemInterval_MAX : Int = 1000
    
    let gemSize : CGSize = CGSize(width: 70, height: 50)
    
    var velocity_MIN : CGFloat = CGFloat(2)
    
    var resetGameCalled : Bool = false
    
    var explosionParticles : SKEmitterNode = SKEmitterNode(fileNamed: "ExplosionParticle.sks")!
    
    var gemCollectParticles : SKEmitterNode = SKEmitterNode(fileNamed: "GemParticles.sks")!
    
    var frameHeight : Int = 0
    var frameWidth : Int = 0
    
    var menu_Margin : CGFloat = 0
    
    var sideMenuPosition : CGFloat {
        let frameWidthAdjust = -CGFloat(frameWidth / 2) + 10
        let menuWidthAdjust = sideMenu.size.width / CGFloat(2)
        let marginAdjust = menu_Margin
        return  frameWidthAdjust + menuWidthAdjust + marginAdjust
    }
    
    var scoreMenuPosition : CGFloat {
        let frameWidthAdjust = -CGFloat(frameWidth / 2) + 10
        let menuWidthAdjust = scoreMenu.size.width / CGFloat(2)
        let marginAdjust = menu_Margin
        print("scoreMenu:")
        print(menuWidthAdjust)
        return  frameWidthAdjust + menuWidthAdjust + marginAdjust
    }
    
    let windHead_Margin = CGFloat(21)
    
    var started : Bool = false
    
    override func didMove(to view: SKView) {
        resetGameCalled = false
        frameHeight = Int(self.size.height)
        frameWidth = Int(self.size.width)
        
        //Physics world
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 0.999
        physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        
        //---attach labels---
        self.camera = self.childNode(withName: "SceneCamera") as? SKCameraNode
        self.touchToBeginLabel = camera!.childNode(withName: "TouchToBeginLabel") as! SKLabelNode
        self.sideMenu = camera!.childNode(withName: "SideMenu") as! SKSpriteNode
        self.scoreMenu = camera!.childNode(withName: "ScoreMenu") as! SKSpriteNode
        
        self.sideMenu.position.x = sideMenuPosition
        self.scoreMenu.position.x = scoreMenuPosition
        
        //score labels
        meterLabel = scoreMenu.childNode(withName: "MeterLabel") as! SKLabelNode
        distanceLabel = scoreMenu.childNode(withName: "DistanceLabel") as! SKLabelNode
        HighscoreValueLabel = scoreMenu.childNode(withName: "HighscoreValueLabel") as! SKLabelNode
        CurrentScoreValueLabel = scoreMenu.childNode(withName: "CurrentScoreValueLabel") as! SKLabelNode
        AirTimeValueLabel = scoreMenu.childNode(withName: "AirTimeValueLabel") as! SKLabelNode
        V_IntroLabel = scoreMenu.childNode(withName: "V_Intro") as! SKLabelNode
        V_Label = scoreMenu.childNode(withName: "V_Mag") as! SKLabelNode
        trickLabel = scoreMenu.childNode(withName: "TrickPointsValueLabel") as! SKLabelNode
        
        //update labels
        HighscoreValueLabel.text = String(UserDefaults.standard.integer(forKey: "Highscore"))
        
        //air position label set up
        AirPositionLabel = camera!.childNode(withName: "AirPositionLabel") as! SKLabelNode
        AirPositionLabel.text = ""
        AirPositionLabel.isHidden = true
        
        //sidemenu
        velocityMeter = camera!.childNode(withName: "VelocityMeter") as! SKSpriteNode
        
        velocityMeter.position.x = sideMenu.position.x + windHead_Margin
        
        velocityMeter.zPosition = 5
        
        dirtMeter = sideMenu.childNode(withName: "DirtMeter") as! SKSpriteNode
        dirtMeterTotalHeight = Double(dirtMeter.size.height)
        dirtMetersLabel = sideMenu.childNode(withName: "DirtMetersLabel") as! SKLabelNode
        
        solarLevelLabel = sideMenu.childNode(withName: "SolarLevelLabel") as! SKLabelNode
        windLevelLabel = sideMenu.childNode(withName: "WindLevelLabel") as! SKLabelNode
        windHeadNode = camera!.childNode(withName: "WindHead") as! SKSpriteNode
        
        windHeadNode.position.x = sideMenu.position.x + windHead_Margin
        
        solarNode = sideMenu.childNode(withName: "SunNode") as! SKSpriteNode

        //dirt warning
        lowDirtWarningLabel = camera!.childNode(withName: "LowDirtWarning") as! SKLabelNode
        lowDirtWarningLabel.isHidden = true
    
        
        self.bike = bikeInUse.makeNew()
        bike.removeAllChildren()
        bike.removeAllActions()
        //---set up bike---
        
        //position bike correctly
        bike.position = startingPosition
        bike.zRotation = 0.0
        bike.name = "bike"
        //*
       // bike.physicsBody?.pinned = false
        bike.physicsBody!.pinned = true
        bike.physicsBody!.allowsRotation = false
        if let _ = self.childNode(withName: "bike") {
            self.childNode(withName: "bike")?.removeFromParent()
        }
        
        self.addChild(bike)
        
        addDirtGates()
        addPointGates()
        
        if windLevel == 0{
            windHeadNode.colorBlendFactor = 1.0
            windHeadNode.color = UIColor.gray
            windHeadNode.alpha = 0.7
            windLevelLabel.text! = ""
        }
        
        windLevelLabel.text = String(windLevel)
        
        if solarLevel == 0{
            solarNode.colorBlendFactor = 1.0
            solarNode.color = UIColor.gray
            solarNode.alpha = 0.7
            solarLevelLabel.text! = ""
        }
        
        solarLevelLabel.text = String(solarLevel)
        
        
        let base = randomNumberInRange(gemInterval_MIN, upper: gemInterval_MAX)
        let multiplier = 1.5
        let range = 200
        
        var lastPosition = base
        
        for _ in 0 ... 20 {
            if randomNumberInRange(0, upper: 100) < gemFrequency {
            let gem = SKSpriteNode(texture: SKTexture(cgImage: #imageLiteral(resourceName: "gem.png").cgImage!), color: UIColor.clear, size: gemSize)
            gem.position.x = CGFloat(Double(lastPosition) * multiplier + Double(randomNumberInRange(-range, upper: range)))
            gem.position.y = CGFloat(randomNumberInRange(-frameHeight / 2 + 20, upper: frameHeight / 2 - 20))
            gem.zPosition = 9
            addChild(gem)
            gemNodes.append(gem)
            lastPosition = Int(gem.position.x)
            }else {
                 lastPosition += randomNumberInRange(gemInterval_MIN, upper: gemInterval_MAX)
            }
        }
    }
    
    let coinSound = SKAction.playSoundFileNamed("coin2.flac", waitForCompletion: false)
    let dirtSound = SKAction.playSoundFileNamed("pingOne.wav", waitForCompletion: false)
    
    func playPointSound() {
        guard soundOn else { return }
        run(coinSound)
    }

    func playDirtSound() {
        guard soundOn else { return }
        run(dirtSound)
    }
    
    //---AIR SESSION CALCULATIONS---
    //Essentially set up so that each time contact begins, last air session ends.
    //airSession must be at least one second to get points
    private var totalAirTime : Double = 0.0
    private var dateOfLastContact : Date = Date()
    
    private var isInAir : Bool = false
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.node?.name == "GroundNode" || contact.bodyB.node?.name == "GroundNode" {
            isInAir = false
            
            windHeadNode.removeAllActions()
            
            //Check to see if is rotated past acceptable value. *DEATH POINT*
            if cos(bike.zRotation) < -0.5 && self.isPaused == false {
                resetGame()
                return
            }
            
            if potentialFlip && bike.zRotation < 0.6{
                trickPoints += flipPoints
                trickLabel.text! = String(trickPoints)
                addFlipLabel()
                potentialFlip = false
            }
            
            let airSession = (Date().timeIntervalSince(dateOfLastContact))
            
            if airSession > 0.4 {
                totalAirTime += airSession
                AirTimeValueLabel!.text = String(airPoints)
            }
            
            bike.angularDampening = 1.0
            
            dateOfLastContact = Date()
        }
    }

    //---ATTEMPT TO MAKE JUMPS EASIER TO LAND---
    //If contact ends, give the bike a slight push in the direction opposite to its
    //current angular velocity in hopes of increasing the change of landing upright.
    
    var angularCorrection : CGFloat {
        return 0.1 * (bike.physicsBody!.angularVelocity)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "GroundNode" || contact.bodyB.node?.name == "GroundNode" {
           // bike.run((SKAction.applyAngularImpulse(angularCorrection, duration: 0.5)))
            
            isInAir = true
            if windLevel > 0 {
                let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: 30, duration: 20))
                windHeadNode.run(rotateAction)
            }
        }
    }
    
    func addFlipLabel() {
        let flipLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        flipLabel.text = "Nice flip! +\(flipPoints)"
        flipLabel.name = "FlipLabelNode"
        flipLabel.fontSize = 20
        flipLabel.fontColor = SKColor.black
        camera!.addChild(flipLabel)
        flipLabel.position = CGPoint(x: 0, y: frameHeight / 2 - 80)
        
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        
        flipLabel.run(SKAction.sequence([fadeOut, remove]))
    }
    
    //---HANDLING DEATH/ RESETING THE GAME---
    //resetGame() gives the user some time before the game resets.
    
    var resetGameTimer : Timer = Timer()
    var touchAllowed : Bool = true
    func resetGame() {
        guard !resetGameCalled else { return }
        resetGameCalled = true
        touchAllowed = false
        addExplosionEffect()
        resetGameTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(reset), userInfo: nil, repeats: false)
    }
    
    func addExplosionEffect() {
        explosionParticles.zPosition = 8
        explosionParticles.position = CGPoint(x: 0, y: -bike.size.height / CGFloat(2) + 30)
        explosionParticles.particlePositionRange = CGVector(dx: bike.size.width / CGFloat(2) - 20, dy: CGFloat(10))
        explosionParticles.targetNode = self
        bike.addChild(explosionParticles)
    }
    
    @objc func reset() {
        self.isPaused = true
        self.bike.removeFromParent()
        score = getScore()
        guard gameVC != nil else {return}
        gameVC!.died()
        resetGameTimer.invalidate()
    }
    
    //---DRAWING THE PATHS---
    var currentPosition : CGPoint = CGPoint.zero
    //current position is used to keep track of the current touch position.
    
    var x_location_relativeto_bike : CGFloat = CGFloat(0)
    //x_location_relativeto_bike is used to keep the path drawing even if touch hasn't moved.
    //path is updated each frame. (if touch hasn't moved, but hasn't ended, use location relative to
    //bike to discern where to add the next point to path.
    
    var linePoints : [CGPoint] = []
    //linePoints are the points of the current line.
    
    //current max/min are used to prevent addition of new paths over old paths; prevent ground
    //from being place atop another.
    var currentMax : CGPoint = CGPoint(x: -5000, y: -5000)
    //currentMax is the current line's max point on the X axis
    
    var currentMin : CGPoint = CGPoint(x: -5000, y: -5000)
    //currentMin is the current line's min point on the X axis
    
    var lineMin : CGFloat = CGFloat(-5000)
    
    @objc func addPointToPath() {
        guard currentDirt > 0 else {
            return
        }
        
        guard touchAllowed else { return }
        let newPoint : CGPoint = CGPoint(x: bike.position.x + x_location_relativeto_bike, y: currentPosition.y)
        
        if newPoint.x <= currentMax.x  { return }
        //don't let user draw behind current ground
        
        currentMax = newPoint
        
        linePoints.append(newPoint)
    }
    
    func pathToDraw() -> CGMutablePath? {
        
        let path = CGMutablePath()
        
        guard linePoints.count > 0 else { return nil }
        
        let leftFrameEdge = camera!.position.x - CGFloat(frameWidth / 2) - CGFloat(400)
        linePoints = linePoints.filter({$0.x > leftFrameEdge})
        
        guard linePoints.count > 0 else { return nil }
        
        lineMin = linePoints.map({$0.x}).min()!
        currentMax.x  = linePoints.map({$0.x}).max()!
        
        path.move(to: CGPoint(x: lineMin, y: -500))
        for i in 0 ... linePoints.count - 1 {
            let p = linePoints[i]
            path.addLine(to: p)
        }
        
        //make path appear to be connected to ground.
        path.addLine(to: CGPoint(x: currentMax.x, y: -500))
        path.addLine(to: CGPoint(x: lineMin, y: -500))
        
        return path
    }
    
    var touchIsActive : Bool = false
    //used in update() to tell whether or not to add point to path.
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        if !started {
            bike.physicsBody!.pinned = false
            bike.physicsBody!.allowsRotation = true
            touchToBeginLabel.removeFromParent()
            started = true
            return
        }
        //guard location.x > currentMax.x else { return }
        //make sure newline is after old line.
        
        touchIsActive = true
        
        linePoints.append(location)
        currentMin = location
        lineMin = location.x
        currentMax = location
        
        x_location_relativeto_bike = location.x - bike.position.x
        //recalculate relative position.
        
        currentPosition = location
        
        groundNodes.append(GroundNode(path: pathToDraw()!))
    }
 
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
    
        currentPosition = location
        x_location_relativeto_bike = location.x - bike.position.x
        //recalculate relative position.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchIsActive = false
        //make current path oldPath.
        
        linePoints.removeAll()
        //clear current line points
        dirtOfOldPaths += metersFromCG(currentMax.x - currentMin.x)
        currentMin = CGPoint.zero
        currentMax = CGPoint.zero
    }
    
    //---DIRT CALCULATIONS---
    //dirt is just the x distance of the track. (no surface area, no height considerations)
    
    var totalDirt : Double = 300
    //starting dirt count
    
    var dirtPerGate : Double = 40
    //dirt earned per dirtGate passed
    
    var currentDirt : Double = 150
    //keep track of current dirt
    
    var earnedDirt : Double = 0
    //keep track of dirt earned (by passing gates)
    
    var dirtOfOldPaths : Double = 0
    
    func updateDirt() {
        currentDirt = totalDirt - metersFromCG(currentMax.x - currentMin.x) - dirtOfOldPaths + earnedDirt
    }
    
    var dirtMeterTotalHeight : Double = 320.0
    
    //Total height of the dirt meter on screen.
    
    //---SCORING---
    //Scoring method:
    //distance / 5
    //  +
    //airTime * 10
    //  +
    //max Speed * 2
    //  +
    // dirt Points
    // +
    //any earned points
    
    //trick points
    var trickPoints : Int = 0
    
    let flipPoints : Int = 100
    
    //manual points store earned points.
    var manualPoints : Int = 0

    //max velocity used to calc. speed points
    var maxVelocity : Double = 0.0
    
    func metersFromCG(_ points : CGFloat) -> Double {
        return Double(points / 50.0 )
    }
    //in-game distances are points / 100
    
    var distance : Int {
        return Int(metersFromCG(bike.position.x - startingPosition.x))
    }
    
    //add all elements of the score together, multiply by bike multiplier
    public func getScore() -> Int {
       return (distancePoints + airPoints + speedPoints + manualPoints + trickPoints) * bike.multiplier
    }

    
    //distance points = real distance divided by 5
    var distancePoints : Int {
        return distance / 5
    }
    
    //air points = airTime calculated above multiplied by 10
    //subtract 13 for ?
    var airPoints : Int {
        let points = Int(totalAirTime * 20) - 13
        return points > 0 ? points : 0
    }
    
    //speedPoints
    var speedPoints : Int {
        return Int(maxVelocity * 2)
    }
    
    var currentSpeed : Double {
        let xPortion = bike.physicsBody!.velocity.dx * bike.physicsBody!.velocity.dx
        let yPortion = bike.physicsBody!.velocity.dy * bike.physicsBody!.velocity.dy
        let speed = (Double(xPortion + yPortion).squareRoot() / 100).rounded()
        //divide by 100 to get speed in terms of in-game meters
        return speed
    }

    func randomNumberInRange(_ lower: Int, upper: Int) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    //---GATES---
    //If the bike passes through a gate, it will recieve a reward of some sort.
    //dirtgate = more dirt
    //pointgate = more points
    //each gate has a warning label that informs the user the meters till next gate
    
    var dirtWarningLabel : SKLabelNode? = nil
    
    var dirtGateArray : [SKSpriteNode] = []
    var pointGateArray : [SKSpriteNode] = []
    
    var gateSize : CGSize = CGSize(width: 25, height: 80)
    
    var dirtGate : SKSpriteNode {
        return dirtGateArray.first!
    }
    
    func addDirtGates() {
        var gateInterval = CGFloat(3000)
        
        var lastXPos : CGFloat = CGFloat(0)
        
        for _ in 0 ..< 70 {
            let yPos = CGFloat(randomNumberInRange(-(frameHeight / 2) + 30, upper: frameHeight / 2 - 30))
            let gate = SKSpriteNode(texture: SKTexture(cgImage: #imageLiteral(resourceName: "dirtGateNode.png").cgImage!), color: UIColor.white, size: gateSize)
            gate.zPosition = 3
            gate.name = "DirtGate"
            gate.position = CGPoint(x: lastXPos + gateInterval, y: yPos)
            dirtGateArray.append(gate)
            self.addChild(gate)
            
            lastXPos += gateInterval
            gateInterval += CGFloat(randomNumberInRange(250, upper: 450))
        }
        
        dirtWarningLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        dirtWarningLabel!.text = ""
        dirtWarningLabel!.fontSize = 25
        dirtWarningLabel!.fontColor = SKColor.brown
        dirtWarningLabel!.position = CGPoint(x: CGFloat(frameWidth / 2 - 50), y: CGFloat(150.0))
        dirtWarningLabel!.name = "WarningLabel"
        dirtWarningLabel!.zPosition = 3
        
        if dirtWarningLabel!.parent == nil {
            camera!.addChild(dirtWarningLabel!)
        }
    }
    
    var pointGate : SKSpriteNode {
        return pointGateArray.first!
    }
    
    var pointWarningLabel : SKLabelNode? = nil
    
    func addPointGates() {
        var gateInterval = CGFloat(5000)
        
        var lastXPos : CGFloat = CGFloat(0)
        
        for _ in 0 ..< 50 {
            let yPos = CGFloat(randomNumberInRange(-(frameHeight / 2) + 30, upper: frameHeight / 2 - 30))
            let gate = SKSpriteNode(texture: SKTexture(cgImage: #imageLiteral(resourceName: "pointsNode.png").cgImage!), color: UIColor.white, size: gateSize)
            gate.zPosition = 3
            gate.name = "PointGate"
            gate.position = CGPoint(x: lastXPos + gateInterval, y: yPos)
            pointGateArray.append(gate)
            self.addChild(gate)
            
            lastXPos += gateInterval
            gateInterval += CGFloat(randomNumberInRange(-100, upper: 200))
        }
        
        pointWarningLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        pointWarningLabel!.text = ""
        pointWarningLabel!.fontSize = 25
        pointWarningLabel!.fontColor = SKColor.green
        pointWarningLabel!.position = CGPoint(x: CGFloat(frameWidth / 2 - 50), y: CGFloat(150.0))
        pointWarningLabel!.name = "PointsWarningLabel"
        pointWarningLabel!.zPosition = 3
        
        if pointWarningLabel!.parent == nil {
            camera!.addChild(pointWarningLabel!)
        }
    }
    
    var potentialFlip : Bool = false
    
    //in progress : path
    var groundNodes : [GroundNode] = []
    
    func addGemCollectEffect() {
        gemCollectParticles.zPosition = 8
        gemCollectParticles.position = gemNodes.first!.position
        gemCollectParticles.targetNode = self
        gemCollectParticles.name = "GemParticles"
        if self.childNode(withName: "GemParticles") == nil {
            self.addChild(gemCollectParticles)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        guard camera != nil else { return }
        
        //move camera
        camera!.position.x = bike.position.x
        
        //increase the speed of the bike with its native acceleration
        bike.increaseSpeed()
        
        if distance > 3 && abs(bike.physicsBody!.velocity.dx) < velocity_MIN {
            bike!.physicsBody!.pinned = true
            bike!.physicsBody!.allowsRotation = false
            resetGame()
            return
        }
        
        if solarLevel > 0 {
            var solarDirt = Double(solarLevel) * 0.01
            if currentDirt + solarDirt > totalDirt {
                solarDirt = totalDirt - currentDirt
            }
            earnedDirt += solarDirt
        }
        
        if windLevel > 0 {
            if isInAir {
                var windDirt = Double(windLevel) * 0.03
                if currentDirt + windDirt > totalDirt {
                    windDirt += totalDirt - currentDirt
                }
                earnedDirt += windDirt
            }
        }
        
        if gemNodes.first != nil {
            if bike.contains(gemNodes.first!.position) {
                playPointSound()
                gems += 1
                addGemCollectEffect()
                gemNodes.first!.removeFromParent()
                gemNodes.removeFirst()
            }else if gemNodes.first!.position.x < bike.position.x {
                gemNodes.removeFirst()
            }
        }
        
        if abs(Double(bike.zRotation) - Double.pi) < 0.20 {
            potentialFlip = true
        }
        
        //---updating ground---
        if linePoints.count > 0 {
            
            if touchIsActive {
                addPointToPath()
                
            }
            
            guard pathToDraw() != nil else { return }
            groundNodes.popLast()!.removeFromParent()
            groundNodes.append(GroundNode(path: pathToDraw()!))
            self.addChild(groundNodes.last!)
           
        }
        
        //---dirt---
        //update dirt value
        updateDirt()
        
        //update dirt meter
        dirtMeter.size.height = CGFloat(Double(currentDirt) / Double(totalDirt) * dirtMeterTotalHeight)
        dirtMetersLabel.text = String(Int(currentDirt))
        
        //if dirtmeter < 50, throw warning to user.
        if currentDirt < 50 {
            lowDirtWarningLabel.isHidden = false
        } else {
            lowDirtWarningLabel.isHidden = true
        }
        
        //---update warninglabels of gates---
        if let _ = camera!.childNode(withName: "WarningLabel") {
            camera!.childNode(withName: "WarningLabel")!.position.y = dirtGate.position.y
            (camera!.childNode(withName: "WarningLabel") as! SKLabelNode).text = String(Int(metersFromCG((dirtGate.position.x - camera!.position.x)))) + "m >"
        }
        
        if let _ = camera!.childNode(withName: "PointsWarningLabel") {
            camera!.childNode(withName: "PointsWarningLabel")!.position.y = pointGate.position.y
            (camera!.childNode(withName: "PointsWarningLabel") as! SKLabelNode).text = String(Int(metersFromCG((pointGate.position.x - camera!.position.x)))) + "m >"
        }
        
        //update labels
        distanceLabel!.text = String(distancePoints)
        V_Label!.text = String(speedPoints)
        CurrentScoreValueLabel!.text = String(getScore())
        
        //add air label if needed
        if bike.position.y > (frame.height / CGFloat(2.0) + 5) {
            AirPositionLabel.isHidden = false
            AirPositionLabel.text = "\(Int(metersFromCG(bike.position.y - CGFloat(frameHeight / 2))))m"
            AirPositionLabel.zRotation = bike.zRotation
        } else {
            AirPositionLabel.isHidden = true
            if bike.position.y < -(frame.height / CGFloat(2.0)) - CGFloat(60) {
                // *DEATH*
                bike!.physicsBody!.pinned = true
                bike!.physicsBody!.allowsRotation = false
                resetGame()
            }
        }
        
        //update velocity
        if currentSpeed > maxVelocity {
            maxVelocity = currentSpeed
        }
        
        //dirt gates
        if dirtGate.contains(bike.position) {
            if currentDirt + dirtPerGate > totalDirt {
                //don't give more dirt then bike can store
                earnedDirt += totalDirt - currentDirt
            }else {
                earnedDirt += dirtPerGate
            }
            dirtGateArray.removeFirst()
            updateDirt()
            playDirtSound()
        }else if bike.position.x > dirtGate.position.x {
            dirtGateArray.removeFirst()
        }
        
        //point gates
        if pointGate.contains(bike.position) {
            manualPoints += 100
            pointGateArray.removeFirst()
            playPointSound()
        }else if bike.position.x > pointGate.position.x {
            pointGateArray.removeFirst()
        }
        
        //velocity meter
        velocityMeter.zRotation = CGFloat(Double.pi * 2 - (currentSpeed / 35.0) * Double.pi)

    }
}
