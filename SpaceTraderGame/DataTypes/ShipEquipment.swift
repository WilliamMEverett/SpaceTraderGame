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
    
}
