//
//  Ship.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/7/22.
//

import Foundation

class Ship : Codable {
    
    static let shipUpdatedNotification = "shipUpdatedNotification"
    
    var shipModel = ""
    var hull : Double = 0
    var cargo : Double = 0
    var engine : Double = 0
    var fuel : Double = 0 {
        didSet {
            self.shipUpdated()
        }
    }
    
    var commodities : [Commodity:Double] = [:]
    
    var equipment : [ShipEquipment] = []
    
    var hullDamage : Double = 0 {
        didSet {
            self.shipUpdated()
        }
    }
    
    class func baseShip() -> Ship {
        let ret = Ship()
        ret.shipModel = "I"
        ret.hull = 100
        ret.cargo = 100
        ret.engine = 100
        ret.fuel = 100
        
        let weap = ShipEquipment()
        weap.weight = 10
        weap.strength = 10
        weap.type = .weapon
        ret.equipment.append(weap)
        
        return ret
    }
    
    class func timeToLeaveDock() -> Double {
        return 0.25
    }
    
    func shipUpdated() {
        NotificationCenter.default.post(name: Notification.Name(Ship.shipUpdatedNotification), object: self)
    }
    
    func totalCargoWeight() -> Double {
        let commWeight = self.commodities.reduce(0.0, { partialResult, value in
            return partialResult + value.value
        })
        let equipmentWeight = self.equipment.reduce(0.0) { partialResult, value in
            return partialResult + value.weight
        }
        return commWeight + equipmentWeight
    }
    
    func baseTimeToJump(distance: Double) -> Double {
        return distance*sqrt((hull + self.totalCargoWeight())/self.engine)
    }
    
    func fuelToTravelTime(time: Double) -> Double {
        return time*self.engine/50
    }
}
