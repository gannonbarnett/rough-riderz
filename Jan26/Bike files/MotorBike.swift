//
//  MotorBike.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/31/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import Foundation

class MotorBike : BikeFrame {
    
    init() {
        super.init(imageName: BikeImages.MotorBike.rawValue)
        self.bikeName = "Motor Bike"
        self.weight = 40.0
        self.maxVelocity = BikeFrame.velocity(25.0)
        self.BikeRestitution = 0.0
        self.price = 500
        self.notes = "This bike drives fast and lives quick. Hold on."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
}
