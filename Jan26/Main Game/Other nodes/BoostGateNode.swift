//
//  BoostGateNode.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/2/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import SpriteKit

class BoostGateNode: SKSpriteNode {

    var boostVelocity : Double = 1.0
    
    required init(x : Int = 0) {
        super.init(texture: SKTexture(imageNamed: "boostGateNode.png"), color: UIColor.black, size: CGSize(width: 100, height: 200))
        self.zPosition = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
