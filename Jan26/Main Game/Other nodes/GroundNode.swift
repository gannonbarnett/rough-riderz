//
//  GroundNode.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/29/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import SpriteKit

class GroundNode: SKShapeNode {

    convenience init(path: CGMutablePath) {
        self.init()
        
        self.path = path
        self.name = "GroundNode"
        self.strokeColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        self.lineCap = .round
        self.lineWidth = 5
        self.zPosition = 1
        self.fillColor = #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1)
        self.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        self.physicsBody?.restitution = 0.05
        self.physicsBody?.isDynamic = true
        self.physicsBody?.pinned = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.fieldBitMask = 4294967295
        self.physicsBody?.categoryBitMask = 4294967295
        self.physicsBody?.collisionBitMask = 4294967295
    }
    
}
