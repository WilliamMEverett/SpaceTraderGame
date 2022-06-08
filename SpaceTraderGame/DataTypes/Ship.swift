//
//  Ship.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/7/22.
//

import Foundation

class Ship : Codable {
    
    var shipModel = ""
    var hull : Double = 0
    var cargo : Double = 0
    var engine : Double = 0
    var fuel : Double = 0
    
    var hullDamage : Double = 0
    
    class func baseShip() -> Ship {
        let ret = Ship()
        ret.shipModel = "I"
        ret.hull = 100
        ret.cargo = 100
        ret.engine = 100
        ret.fuel = 100
        return ret
    }
    
    class func timeToLeaveDock() -> Double {
        return 0.25
    }
    
    func totalCargoWeight() -> Double {
        return 0
    }
    
    func baseTimeToJump(distance: Double) -> Double {
        return distance*sqrt((hull + self.totalCargoWeight())/self.engine)
    }
    
    func fuelToTravelTime(time: Double) -> Double {
        return time*self.engine/50
    }
}
