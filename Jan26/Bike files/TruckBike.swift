//
//  TruckBike.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/31/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import Foundation

class TruckBike : BikeFrame {
    
    init() {
        super.init(imageName: BikeImages.TruckBike.rawValue, size: "Large")
        self.sizeName = "Large"
        self.bikeName = "Truck Bike"
        self.weight = 300.0
        self.maxVelocity = BikeFrame.velocity(15.0)
        self.BikeRestitution = 0.0
        self.price = 3000
        self.multiplier = 2
        
        self.notes = "Earns double score. Barely a bike, this awkward mess may be suitable for some."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
}
