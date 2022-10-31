//
//  SandboxMode.swift
//  Jan26
//
//  Created by Gannon Barnett on 3/7/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import Foundation
import SpriteKit

class SandboxMode: SKScene, SKPhysicsContactDelegate {
    
    weak var sandboxVC : SandboxViewController? = nil
    
    //---LABELS---
    public var bike : BikeFrame!
    
    private var AirPositionLabel : SKLabelNode!
    
    private var touchToBeginLabel : SKLabelNode!
    
    let startingPosition = CGPoint(x: -250, y: 180)
    
    var gemNodes : [SKSpriteNode] = []
    
    var gemFrequency : Int = 30
    
    var gemInterval_MIN : Int = 500
    var gemInterval_MAX : Int = 1000
    
    let gemSize : CGSize = CGSize(width: 70, height: 50)
    
    var resetGameCalled : Bool = false
    
    var explosionParticles : SKEmitterNode = SKEmitterNode(fileNamed: "ExplosionParticle.sks")!
    
    var gemCollectParticles : SKEmitterNode = SKEmitterNode(fileNamed: "GemParticles.sks")!
    
    var frameHeight : Int = 0
    var frameWidth : Int = 0
    
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
        
        //air position label set up
        AirPositionLabel = camera!.childNode(withName: "AirPositionLabel") as! SKLabelNode
        AirPositionLabel.text = ""
        AirPositionLabel.isHidden = true

        touchToBeginLabel = camera!.childNode(withName: "touchToBeginLabel") as! SKLabelNode
        
        self.bike = bikeInUse.makeNew()
        bike.removeAllChildren()
        bike.removeAllActions()
        //---set up bike---
        
        //position bike correctly
        bike.position = startingPosition
        bike.zRotation = 0.0
        bike.name = "bike"
        //*
        bike.physicsBody!.pinned = true
        bike.physicsBody!.allowsRotation = false
        
        if let _ = self.childNode(withName: "bike") {
            self.childNode(withName: "bike")?.removeFromParent()
        }
        
        self.addChild(bike)

        var lastPosition = 0
        
        for _ in 0 ... randomNumberInRange(3, upper: 5) {
            if randomNumberInRange(0, upper: 100) < gemFrequency {
                let gem = SKSpriteNode(texture: SKTexture(cgImage: #imageLiteral(resourceName: "gem.png").cgImage!), color: UIColor.clear, size: gemSize)
                gem.position.x = CGFloat(lastPosition + randomNumberInRange(gemInterval_MIN, upper: gemInterval_MAX))
                gem.position.y = CGFloat(randomNumberInRange(-300, upper: 300))
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

    func playPointSound() {
        guard soundOn else { return }
        run(coinSound)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.node?.name == "GroundNode" || contact.bodyB.node?.name == "GroundNode" {
            
            //Check to see if is rotated past acceptable value. *DEATH POINT*
            if cos(bike.zRotation) < -0.5 && self.isPaused == false {
                resetGame()
                return
            }
            bike.angularDampening = 1.0
            
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

        }
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
        guard sandboxVC != nil else {return}
        sandboxVC!.died()
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
        currentMin = CGPoint.zero
        currentMax = CGPoint.zero
    }
    
    
    //max velocity used to calc. speed points
    var maxVelocity : Double = 0.0
    
    func metersFromCG(_ points : CGFloat) -> Double {
        return Double(points / 50.0 )
    }
    //in-game distances are points / 100
    
    var distance : Int {
        return Int(metersFromCG(bike.position.x - startingPosition.x))
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

    var groundNodes : [GroundNode] = []
    
    let velocity_MIN = CGFloat(3)
    
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
        
        //add air label if needed
        if bike.position.y > (frame.height / CGFloat(2.0)) {
            AirPositionLabel.isHidden = false
            AirPositionLabel.text = "\(Int(metersFromCG(bike.position.y - CGFloat(frameHeight / 2))))m"
            AirPositionLabel.zRotation = bike.zRotation
        } else {
            AirPositionLabel.isHidden = true
        }
        
        //update velocity
        if currentSpeed > maxVelocity {
            maxVelocity = currentSpeed
        }
        
        //death guard
        if bike.position.y < -(frame.height / CGFloat(2.0)) - CGFloat(60) {
            // *DEATH*
            bike!.physicsBody!.pinned = true
            bike.physicsBody!.allowsRotation = false
            resetGame()
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
    }
}
