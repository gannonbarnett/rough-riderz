//
//  StandardBike.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/31/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import Foundation
import SpriteKit


class StandardBike : BikeFrame {
    required init() {
        super.init(imageName: "bikeTWO_nounproject.png", size: CGSize(width: 95, height: 37))
        self.imageName = "bikeTWO_nounproject.png"
        self.weight = 75.0
        price = 0
        notes = "This sturdy standard bike won't let you down, but it won't get you very far."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override   func makeNew() -> BikeFrame {
        return StandardBike()
    }
}

class MotorBike : BikeFrame {
    
    init() {
        super.init(imageName: "motorBike_AtifArshad.png", size: CGSize(width: 95, height: 37))
        self.imageName = "motorBike_AtifArshad.png"
        self.bikeName = "Motor Bike"
        self.weight = 50.0
        self.maxVelocity = BikeFrame.velocity(25.0)
        self.BikeRestitution = 0.0
        self.price = 500
        self.multiplier = 2
        self.notes = "This bike drives fast and lives quick. Hold on."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return MotorBike()
    }
}


class Truck : BikeFrame {
    
    init() {
        super.init(imageName: "Truck_YuLuck.png", size: CGSize(width: 130, height: 57))
        self.imageName = "Truck_YuLuck.png"
        self.acceleration = 5.5
        self.sizeName = "Large"
        self.bikeName = "Truck"
        self.weight = 300.0
        self.maxVelocity = BikeFrame.velocity(15.0)
        self.BikeRestitution = 0.0
        self.price = 1000
        self.multiplier = 2
        
        self.notes = "This thing is pretty big and strong. <3"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return Truck()
    }
}

class Scooter : BikeFrame {
    required init() {
        super.init(imageName: "Scooter_GanKhoonLay.png", size: CGSize(width: 71.1, height: 99))
        self.imageName = "Scooter_GanKhoonLay.png"
        self.sizeName = "Small"
        self.bikeName = "Scooter"
        self.weight = 23.6
        self.maxVelocity = BikeFrame.velocity(15.0)
        self.price = 3000
        self.multiplier = 2
        notes = "Sometimes you just have to break out the scooter and fool around."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return Scooter()
    }
}
class SmallJeep : BikeFrame {
    required init() {
        super.init(imageName: "jeep.png", size : CGSize(width: 142.2, height: 56))
        self.imageName = "jeep.png"
        self.sizeName = "Small"
        self.weight = 49.9
        self.bikeName = "Small Jeep"
        self.maxVelocity = BikeFrame.velocity(23.0)
        self.acceleration = 6.5
        self.price = 7000
        self.multiplier = 3
        notes = "This is actually a really big barbie jeep."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return SmallJeep()
    }
}

class Humvee : BikeFrame {
    required init() {
        super.init(imageName: "Humvee_NadayBarkan.png", size: CGSize(width: 142, height: 42))
        self.imageName = "Humvee_NadayBarkan.png"
        self.weight = 101.0
        self.bikeName = "Humvee"
        self.maxVelocity = BikeFrame.velocity(30.0)
        self.price = 10000
        self.acceleration = 6.5
        self.multiplier = 3
        notes = "Hardy, stable, and wide. Claims to have the smoothest ride."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return Humvee()
    }
}

class PickUpTruck : BikeFrame {
    required init() {
        super.init(imageName: "PickUpTruck_misirlou.png", size: CGSize(width: 189, height: 63))
        self.imageName = "PickUpTruck_misirlou.png"
        self.weight = 69.0
        self.bikeName = "Pick-up Truck"
        self.maxVelocity = BikeFrame.velocity(20.0)
        self.price = 10000
        self.multiplier = 4
        notes = "Perfect for the country boys."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return PickUpTruck()
    }
}

class BMXBike : BikeFrame {
    required init() {
        super.init(imageName: "BMXBike_JasonSmith.png", size: CGSize(width: 88.2, height: 55))
        self.imageName = "BMXBike_JasonSmith.png"
        self.weight = 40
        self.bikeName = "BMX Bike"
        self.maxVelocity = BikeFrame.velocity(20.0)
        self.price = 13000
        self.multiplier = 5
        notes = "Class BMX Bike. Pull a few tricks, get mad flips."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return BMXBike()
    }
}

class MonopolyCar : BikeFrame {
    required init() {
        super.init(imageName: "MonopolyCar.png", size: CGSize(width: 151, height: 63))
        self.imageName = "MonopolyCar.png"
        self.weight = 151.7
        self.bikeName = "Monopoly Car"
        self.maxVelocity = BikeFrame.velocity(30.0)
        self.price = 15000
        self.acceleration = 6.5
        self.multiplier = 5
        notes = "This one is for the scholars."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return MonopolyCar()
    }
}

class OldRaceCar : BikeFrame {
    required init() {
        super.init(imageName: "OldRaceCar_DrewEllis.png", size: CGSize(width: 179, height: 47))
        self.imageName = "OldRaceCar_DrewEllis.png"
        self.weight = 120.3
        self.bikeName = "Retro Racer"
        self.maxVelocity = BikeFrame.velocity(29.0)
        self.price = 20000
        self.multiplier = 5
        self.acceleration = 7.2
        notes = "Racers gotta race."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override func makeNew() -> BikeFrame {
        return OldRaceCar()
    }
}

class Sled : BikeFrame {
    required init() {
        super.init(imageName: "Sled_RalfSchmitzer.png", size: CGSize(width: 74, height: 47))
        self.imageName = "Sled_RalfSchmitzer.png"
        self.weight = 30.0
        self.bikeName = "Sled"
        self.maxVelocity = BikeFrame.velocity(20.0)
        self.price = 30000
        self.multiplier = 6
        notes = "Even Santa rides rough occasionally."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return Sled()
    }
}

class MonsterTruck : BikeFrame {
    required init() {
        super.init(imageName: "MonsterTruck_SimonChild.png", size: CGSize(width: 227, height: 105))
        self.imageName = "MonsterTruck_SimonChild.png"
        self.weight = 213.3
        self.bikeName = "Monster Truck"
        self.maxVelocity = BikeFrame.velocity(33.0)
        self.price = 30000
        self.multiplier = 6
        self.acceleration = 7.2
        notes = "Monster trucks love to ride rough."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return MonsterTruck()
    }
}

class Plane : BikeFrame {
    required init() {
        super.init(imageName: "Plane_BerkahStudio.png", size: CGSize(width: 150, height: 70))
        self.imageName = "Plane_BerkahStudio.png"
        self.weight = 130.0
        self.bikeName = "Plane"
        self.maxVelocity = BikeFrame.velocity(25.0)
        self.price = 40000
        self.multiplier = 7
        notes = "Piloting a plane is hard, but is perhaps the most rewarding ride."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return Plane()
    }
    
    override var accelerationAction: SKAction {
        return SKAction.applyForce(CGVector(dx: motorForce, dy: Double(self.physicsBody!.mass) * 15.0), duration: 1.0)
    }
}

class Truck6Wheel : BikeFrame {
    required init() {
        super.init(imageName: "Truck6Wheel_JaimeMLaurel.png", size: CGSize(width: 186, height: 84))
        self.imageName = "Truck6Wheel_JaimeMLaurel.png"
        self.weight = 200.0
        self.bikeName = "6 Wheeler"
        self.maxVelocity = BikeFrame.velocity(30.0)
        self.price = 50000
        self.multiplier = 6
        notes = "You know what they say: more wheels, more rough riderz points."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return Truck6Wheel()
    }
}

class SwanBoat : BikeFrame {
    required init() {
        super.init(imageName: "SwanBoat_SubhashishPanigrahi.png", size: CGSize(width: 126, height: 75))
        self.imageName = "SwanBoat_SubhashishPanigrahi.png"
        self.weight = 60.0
        self.bikeName = "Swan Boat"
        self.maxVelocity = BikeFrame.velocity(18.0)
        self.price = 60000
        self.multiplier = 7
        notes = "This vehicle brings new meaning to the phrase \"Swan dive\""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return SwanBoat()
    }
}

class TruckWithWheel : BikeFrame {
    required init() {
        super.init(imageName: "TruckWithWheel_SimonChild.png", size: CGSize(width: 110, height: 50))
        self.imageName = "TruckWithWheel_SimonChild.png"
        self.weight = 108.0
        self.bikeName = "Extra Wheeler"
        self.maxVelocity = BikeFrame.velocity(23.0)
        self.price = 80000
        self.multiplier = 7
        notes = "Riding without an extra wheel would be like riding on a smooth road: horrible."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return TruckWithWheel()
    }
}

class Truck10Wheel : BikeFrame {
    required init() {
        super.init(imageName: "Truck10Wheel_JaimeMLaurel.png", size: CGSize(width: 252, height: 100))
        self.imageName = "Truck10Wheel_JaimeMLaurel.png"
        self.weight = 300.0
        self.bikeName = "10 Wheeler"
        self.maxVelocity = BikeFrame.velocity(30.0)
        self.price = 90000
        self.multiplier = 8
        notes = "I'm not saying everyone else looks small, but I definetely look bigger."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override  func makeNew() -> BikeFrame {
        return Truck10Wheel()
    }
}

class RaceCar : BikeFrame {
    required init() {
        super.init(imageName: "raceCar.png", size: CGSize(width: 179, height: 47))
        self.imageName = "raceCar.png"
        self.weight = 116.9
        self.acceleration = 8.0
        self.bikeName = "Race Car"
        self.maxVelocity = BikeFrame.velocity(34.0)
        self.price = 100000
        self.multiplier = 9
        notes = "Racers gotta race."
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(imageName: String) {
        fatalError("init(imageName:) has not been implemented")
    }
    
    override func makeNew() -> BikeFrame {
        return RaceCar()
    }
}

