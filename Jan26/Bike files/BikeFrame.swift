//
//  BikeFrame.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/31/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import Foundation
import SpriteKit

class BikeFrame : SKSpriteNode, Bike {
    var bikeName: String = "Standard Bike"
    
    var bikeSize: CGSize = CGSize(width: 200, height: 100)
    
    var weight: Double = 50.0 {
        didSet {
            self.physicsBody!.mass = CGFloat(weight)
        }
    }
    
    var angularDampening: Double = 0
    
    var initialSpeed: CGVector = CGVector(dx: 20, dy: 100)
    
    var acceleration : Double = 6.0
    
    var motorForce: Double {
        return weight * acceleration
    }
    
    var BikeRestitution: Double = 0.1
    
    var accelerationAction : SKAction {
        return SKAction.applyForce(CGVector(dx: motorForce, dy: 0), duration: 1.0)
    }

    var imageName : String = ""
    
    var notes : String = "testing"
    
    var price : Int = 0
    
    var multiplier : Int = 1
    
    var maxVelocity : CGFloat? = BikeFrame.velocity(20.0)
    
    var sizeName : String = ""
    
    init(imageName : String, size : CGSize) {
        self.bikeSize = size
        self.imageName = imageName
        super.init(texture: SKTexture(imageNamed: imageName), color: UIColor.black, size: bikeSize)
        self.zPosition = 2
        self.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: imageName), size: bikeSize)
        self.physicsBody!.friction = 0
        self.physicsBody!.isDynamic = true
        self.physicsBody!.affectedByGravity = true
        self.physicsBody!.mass = CGFloat(weight)
        self.physicsBody!.restitution = CGFloat(BikeRestitution)
        self.physicsBody!.fieldBitMask = 1
        self.physicsBody!.categoryBitMask = 1
        self.physicsBody!.collisionBitMask = 1
        self.physicsBody!.contactTestBitMask = 1
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func velocity(_ value : Double) -> CGFloat {
        return CGFloat(value * 100)
    }
    
    func makeNew() -> BikeFrame {
        return BikeFrame(imageName: "", size: CGSize(width: 10, height: 10))
    }
}

extension BikeFrame {
    
    func getCurrentSpeed() -> Double {
        let xPortion = self.physicsBody!.velocity.dx * self.physicsBody!.velocity.dx
        let yPortion = self.physicsBody!.velocity.dy * self.physicsBody!.velocity.dy
        let speed = (Double(xPortion + yPortion).squareRoot() / 100).rounded(.toNearestOrEven)
        return speed
    }
    
    func increaseSpeed() {
        self.run(accelerationAction)
        if let velocity = maxVelocity {
            if self.physicsBody!.velocity.dx >= velocity {
                self.physicsBody!.velocity.dx = velocity
            }
        }
    }
    
    func increaseSpeed(by speed : Double) {
        self.physicsBody!.velocity.dx += CGFloat(speed * 100)
    }
}
