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
    
    var remainingHull : Double {
        return self.hull - self.hullDamage
    }
    
    var isDestroyed : Bool {
        return self.hullDamage >= self.hull
    }
    var shieldValue : Double = 0
    
    convenience init(model : String, hull : Double, cargo : Double, engine : Double) {
        self.init()
        self.shipModel = model
        self.hull = hull
        self.cargo = cargo
        self.engine = engine
    }
    
    func shipUpdated() {
        NotificationCenter.default.post(name: Notification.Name(Ship.shipUpdatedNotification), object: self)
    }
    
    func carryingDisposableCargo() -> Bool {
        let commWeight = self.commodities.reduce(0.0, { partialResult, value in
            return partialResult + value.value
        })
        return commWeight > 0
    }
    
    func dumpCargo() {
        self.commodities.removeAll()
        self.shipUpdated()
    }
    
    func baseCargoValue() -> Double {
        let commValue = self.commodities.reduce(0.0, { partialResult, value in
            return partialResult + value.value*value.key.base_price
        })
        return commValue
    }
    
    func totalCommoditiesWeight() -> Double {
        let commWeight = self.commodities.reduce(0.0, { partialResult, value in
            return partialResult + value.value
        })
        return commWeight
    }
    
    func totalCargoWeight() -> Double {
        
        let commWeight = self.totalCommoditiesWeight()
        let equipmentWeight = self.equipment.reduce(0.0) { partialResult, value in
            return partialResult + value.weight
        }
        return commWeight + equipmentWeight
    }
    
    func availableCargoSpace() -> Double {
        return self.cargo - self.totalCargoWeight()
    }
    
    func speedDamageAdjustment() -> Double {
        return sqrt((self.hull - self.hullDamage)/self.hull)
    }
    
    func totalShipWeight() -> Double {
        return hull + self.totalCargoWeight()
    }
    
    func baseTimeToJump(distance: Double) -> Double {
        return distance*sqrt((self.totalShipWeight())/self.engine)/self.speedDamageAdjustment()
    }
    
    func baseTimeToJumpWithoutCommodities(distance: Double) -> Double {
        return distance*sqrt((self.totalShipWeight() - self.totalCommoditiesWeight())/self.engine)/self.speedDamageAdjustment()
    }
    
    func fuelToTravelTime(time: Double) -> Double {
        return time*self.speedDamageAdjustment()*self.engine/50
    }
    
    func totalWeaponStrength() -> Double {
        return self.equipment.reduce(0.0) { partialResult, value in
            return value.type == .weapon ? partialResult + value.strength : partialResult
        }
    }
    
    func totalShieldStrength() -> Double {
        return self.equipment.reduce(0.0) { partialResult, value in
            return value.type == .shield ? partialResult + value.strength : partialResult
        }
    }
    
    func threatLevel() -> Int {
        
        let defensiveTotal = (self.hull + self.totalShieldStrength())/10.0
        let offensiveTotal = self.totalWeaponStrength()
        if offensiveTotal == 0 {
            return 0
        }
        let maneuverTotal = self.engine*10/self.totalShipWeight()
        
        return Int(floor(offensiveTotal/10) + floor((defensiveTotal + maneuverTotal)/20))
    }
    
    func baseValueOfShip() -> Double {
        return self.engine*100 + 30*self.hull + 10*self.cargo
    }
    
    //MARK: - class function
    
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
        
        let shield = ShipEquipment()
        shield.weight = 20
        shield.strength = 20
        shield.type = .shield
        ret.equipment.append(shield)
        
        return ret
    }
    
    class func shipForThreatLevel(_ level : Int) -> Ship {
        let ret = Ship()
        ret.hull = 50
        ret.cargo = 50
        ret.engine = 50
        ret.fuel = 50
        
        let weap = ShipEquipment()
        weap.weight = 10
        weap.strength = 10
        weap.type = .weapon
        ret.equipment.append(weap)
        
        if level <= 1 {
            return ret
        }
        var currentThreatLevel = ret.threatLevel()
        
        while currentThreatLevel < level {
            if ret.engine/ret.totalShipWeight() < 0.5 {
                ret.engine += 50
                currentThreatLevel = ret.threatLevel()
                continue
            }
            
            let option = Int.random(in: 0...5)
            switch option {
            case 0:
                ret.engine += 50
            case 1:
                let weap = ShipEquipment()
                weap.weight = 10
                weap.strength = 10
                weap.type = .weapon
                ret.equipment.append(weap)
            case 2,3:
                let existingWeapon = ret.equipment.filter({$0.type == .weapon}).randomElement()
                existingWeapon?.strength += 10
                existingWeapon?.weight += 10
            case 4:
                if let existingShield = ret.equipment.filter({$0.type == .shield}).randomElement() {
                    existingShield.strength += 50
                    existingShield.weight += 10
                }
                else {
                    let newShield = ShipEquipment()
                    newShield.weight = 10
                    newShield.strength = 50
                    newShield.type = .shield
                    ret.equipment.append(newShield)
                }
            default:
                ret.hull += 50
            }
            if ret.totalCargoWeight() > ret.cargo {
                ret.cargo = ret.totalCargoWeight()
            }
        
            currentThreatLevel = ret.threatLevel()
        }
        return ret
    }
    
    class func timeToLeaveDock() -> Double {
        return 0.25
    }
    
    class func listOfPossibleShipsForSale() -> [Ship] {
        
        var result : [Ship] = []
        
        result.append(Ship(model: "", hull: 50, cargo: 50, engine: 50))
        result.append(Ship(model: "", hull: 100, cargo: 100, engine: 50))
        result.append(Ship(model: "", hull: 100, cargo: 100, engine: 100))
        result.append(Ship(model: "", hull: 100, cargo: 150, engine: 100))
        result.append(Ship(model: "", hull: 150, cargo: 200, engine: 150))
        result.append(Ship(model: "", hull: 100, cargo: 50, engine: 200))
        result.append(Ship(model: "", hull: 100, cargo: 100, engine: 200))
        result.append(Ship(model: "", hull: 200, cargo: 200, engine: 200))
        result.append(Ship(model: "", hull: 250, cargo: 200, engine: 250))
        
        return result
    }
    
    class func generateShipMarketFor(_ system : StarSystem) -> [Ship] {
        if system.stage == .empty || system.stage == .colonial {
            return []
        }
        var baseList = self.listOfPossibleShipsForSale()
        
        var maxRange = baseList.count - 1
        if system.stage == .emerging {
            maxRange = baseList.count/2
        }
        else if system.stage == .declining {
            maxRange = (baseList.count*3)/4 - 1
        }
        else if system.stage == .apex && system.economy != .industrial {
            maxRange = baseList.count - 2
        }
        else {
            maxRange = baseList.count - 1
        }
        
        var result : [Ship] = []
        
        let maxNumber = maxRange/2 + 1
        
        for i in 0..<maxNumber {
            if baseList.count == 0 {
                break
            }
            let selection = Int.random(in:0...(max(maxRange - i,0)))
            
            result.append(baseList.remove(at: selection))
            
        }
        
        return result
        
    }
}
