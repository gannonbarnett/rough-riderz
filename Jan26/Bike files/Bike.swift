//
//  Bike.swift
//  Jan26
//
//  Created by Gannon Barnett on 1/31/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import Foundation
import UIKit

var BikeArray : [BikeFrame] = [StandardBike(), MotorBike(), Truck(), Scooter(), SmallJeep(), Humvee(), PickUpTruck(), BMXBike(), MonopolyCar(), OldRaceCar(), Sled(), MonsterTruck(),  Plane(), Truck6Wheel(), SwanBoat(), TruckWithWheel(), Truck10Wheel(), RaceCar()]

var purchasedBikeNames : [String] = [StandardBike().bikeName]

var bikeInUse : BikeFrame = StandardBike()

protocol Bike {
    var bikeName : String { get }
    var bikeSize : CGSize { get }
    var weight : Double { get }
    var angularDampening : Double { get }
    var initialSpeed : CGVector { get }
    var acceleration : Double { get }
    var motorForce : Double { get }
    var BikeRestitution : Double { get }
    func makeNew() -> BikeFrame
}
