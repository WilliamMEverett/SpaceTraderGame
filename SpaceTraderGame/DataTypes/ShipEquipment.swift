//
//  ShipEquipment.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/20/22.
//

import Foundation

enum ShipEquipmentType : Int, CustomStringConvertible, Codable {
    case none
    case weapon
    case shield
    case stealth
    case lifeSupport
    
    var description : String {
        switch self {
        case .none: return "None"
        case .weapon: return "Weapon"
        case .shield: return "Shield"
        case .stealth: return "Stealth"
        case .lifeSupport: return "Life Support"
        }
    }
    
    var expectedWeightRatio : Double {
        switch self {
        case .none: return 1
        case .weapon: return 1
        case .shield: return 0.5
        case .stealth: return 0.25
        case .lifeSupport: return 20
        }
    }
}

class ShipEquipment : Codable {

    var weight : Double = 0
    var strength : Double = 0
    var type : ShipEquipmentType = .none
    
    func valueOfEquipment() -> Double {
        switch self.type {
        case .none: return 0
        case .weapon: return self.strength*200*(self.strength/self.weight)
        case .shield: return self.strength*50*(self.strength/self.weight)
        case .stealth: return self.strength*1000*(self.strength/self.weight) + 3000
        case .lifeSupport: return 2000 + 30000/self.weight
        }
    }
    
    class func generateShipEquipmentMarketFor(_ system: StarSystem) -> [ShipEquipment] {
        var numberOfItems = 0
        switch system.stage {
        case .colonial:
            numberOfItems = Int.random(in: 2...5)
        case .emerging:
            numberOfItems = Int.random(in: 5...12)
        case .apex:
            numberOfItems = Int.random(in: 10...20)
        case .declining:
            numberOfItems = Int.random(in: 5...20)
        default:
            numberOfItems = 0
        }
        
        var result : [ShipEquipment] = []
        
        while result.count < numberOfItems {
            let typeSelector = Int.random(in: 1...10)
            
            if result.count < 2 {
                if typeSelector <= 2 {
                    result.append(self.standardExampleOfType(.lifeSupport))
                }
                else if typeSelector <= 6 {
                    result.append(self.standardExampleOfType(.weapon))
                }
                else {
                    result.append(self.standardExampleOfType(.shield))
                }
                continue
            }
            var maxPowerLevel = 1
            if (system.stage == .emerging) {
                maxPowerLevel = 3
            }
            else if (system.stage == .apex) {
                maxPowerLevel = 5
            }
            else if (system.stage == .declining) {
                maxPowerLevel = 4
            }
            if (system.economy == .industrial) {
                maxPowerLevel += 1
            }
            var selectedPowerLevel = Int.random(in: 1...maxPowerLevel)
            
            var selectedType = ShipEquipmentType.none
            switch typeSelector {
            case 1:
                selectedType = .lifeSupport
            case 2...5:
                selectedType = .weapon
            case 6...9:
                selectedType = .shield
            case 10:
                if selectedPowerLevel >= 3 {
                    selectedType = .stealth
                }
                else {
                    selectedType = .weapon
                }
            default:
                selectedType = .none
            }
            var weightModifier : Double = 1
            if selectedPowerLevel > 1 && Int.random(in: 1...5) == 1 {
                selectedPowerLevel -= 1
                weightModifier = 0.5
            }
            else if selectedPowerLevel < 5 && Int.random(in: 1...5) == 1 {
                selectedPowerLevel += 1
                weightModifier = 1.5
            }
            
            let newEquip = self.standardExampleOfType(selectedType)
            
            if newEquip.type == .lifeSupport {
                if selectedPowerLevel > 3 {
                    newEquip.weight = newEquip.type.expectedWeightRatio*newEquip.strength/2
                }
            }
            else if newEquip.type == .stealth {
                newEquip.strength = newEquip.strength*Double(selectedPowerLevel - 2)
                newEquip.weight = newEquip.type.expectedWeightRatio*newEquip.strength*weightModifier
            }
            else if newEquip.type == .shield || newEquip.type == .weapon {
                newEquip.strength = newEquip.strength*Double(selectedPowerLevel)
                newEquip.weight = newEquip.type.expectedWeightRatio*newEquip.strength*weightModifier
            }
            
            result.append(newEquip)
        }
        
        result.sort(by: {
            if $0.type == $1.type {
                return $0.valueOfEquipment() < $1.valueOfEquipment()
            } else {
                return $0.type.rawValue < $1.type.rawValue
            }
                
        })
        
        return result
        
    }
    
    class func standardExampleOfType(_ type : ShipEquipmentType) -> ShipEquipment {
        let res = ShipEquipment()
        res.type = type
        switch type {
        case .none:
            res.strength = 1
        case .weapon:
            res.strength = 10
        case .shield:
            res.strength = 20
        case .stealth:
            res.strength = 20
        case .lifeSupport:
            res.strength = 1
        }
        res.weight = res.type.expectedWeightRatio*res.strength
        return res
    }
}
