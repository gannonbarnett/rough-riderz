//
//  GateLabelNode.swift
//  Jan26
//
//  Created by Gannon Barnett on 2/2/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import SpriteKit

class GateLabelNode: SKLabelNode {

    required override init() {
        super.init(fontNamed: "AmericanTypewriter")
        self.fontSize = 17
        self.fontColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
