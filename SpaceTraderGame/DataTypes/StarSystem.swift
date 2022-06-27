//
//  StarSystem.swift
//  SpaceTraderGame
//
//  Created by William Everett on 5/31/22.
//

import Foundation

enum StarSystemEconomy : Int, CustomStringConvertible, Codable {
    case none
    case mining
    case agriculture_luxury
    case agriculture_basic
    case industrial
    case post_industrial
    case resort
    
    var description : String {
        switch self {
        case .none: return "None"
        case .mining: return "Mining"
        case .agriculture_luxury: return "Agriculture (Luxury)"
        case .agriculture_basic: return "Agriculture (Basic)"
        case .industrial: return "Industrial"
        case .post_industrial: return "Post-Industrial"
        case .resort: return "Resort"
        }
    }
    
}

enum StarSystemStage : Int, CustomStringConvertible, Codable {
    case empty
    case colonial
    case emerging
    case apex
    case declining
    
    var description : String {
        switch self {
        case .empty: return "Empty"
        case .colonial: return "Colonial"
        case .emerging: return "Emerging"
        case .apex: return "Apex"
        case .declining: return "Declining"
        }
    }
    
}

struct Coord : Codable, CustomStringConvertible {
    var x : Double = 0
    var y : Double = 0
    var z : Double = 0
    
    func distance(_ otherCoord : Coord) -> Double {
        let xDist = self.x - otherCoord.x
        let yDist = self.y - otherCoord.y
        let zDist = self.z - otherCoord.z
        return sqrt(xDist*xDist + yDist*yDist + zDist*zDist)
    }
    
    func distance2D(_ otherCoord : NSPoint) -> Double {
        let xDist = self.x - otherCoord.x
        let yDist = self.y - otherCoord.y
        return sqrt(xDist*xDist + yDist*yDist)
    }
    
    var description : String {
        let xString = String(format: "%.1f", self.x)
        let yString = String(format: "%.1f", self.y)
        let zString = String(format: "%.1f", self.z)
        return "(\(xString),\(yString),\(zString))"
    }
}

class StarSystem : Codable, CustomStringConvertible {
    
    static let starSystemUpdatedNotification = "starSystemUpdatedNotification"
    
    var num_id = 0
    var name = ""
    var position = Coord()
    var economy = StarSystemEconomy.none
    var stage = StarSystemStage.empty
    var population = 0
    var danger = 0
    var faction = 0
    var connectingSystems : [Int] = []
    var market : Market? = nil
    
    var populationDescription : String {
        if self.population < 1000000 {
            return "\(String(format: "%.1f", (Double(self.population)/1000)))k"
        }
        else if self.population < 1000000000 {
            return "\(String(format: "%.1f", (Double(self.population)/1000000)))M"
        }
        else {
            return "\(String(format: "%.1f", (Double(self.population)/1000000000)))B"
        }
    }
    
    var description : String {
        return "\(self.num_id).  \(self.name)    \(self.position)\n\(self.stage)  \(self.economy)\nPop: \(self.populationDescription)   Danger: \(self.danger)   Faction:\(self.faction)\nConnecting Systems: \(self.connectingSystems))\n"
    }
    
    func getFuelCost() -> Double {
        return 3
    }
    
    func getRepairCost() -> Double {
        return 50
    }
    
    func starSystemUpdated() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: StarSystem.starSystemUpdatedNotification), object: self)
    }
    
    class func generateRandomSystem() -> StarSystem {
        let returnValue = StarSystem()
        
        returnValue.stage = self.getRandomStage()
        
        returnValue.economy = self.getRandomEconomy(returnValue)
        
        switch returnValue.stage {
        case .empty:
            returnValue.population = 0
            returnValue.danger = Int.random(in: 5...10)
        case .colonial:
            returnValue.population = Int.random(in: 10..<1000)*1000
            returnValue.danger = Int.random(in: 3...9)
        case .emerging:
            returnValue.population = Int.random(in: 1..<1000)*1000000
            returnValue.danger = Int.random(in: 1...5)
        case .apex:
            returnValue.population = Int.random(in: 1..<500)*1000000000
            returnValue.danger = Int.random(in: 0...3)
        case .declining:
            returnValue.population = Int.random(in: 1..<10000)*1000000
            returnValue.danger = Int.random(in: 4...9)
        }
        
        return returnValue
    }
    
    private class func getRandomStage() -> StarSystemStage {
        let randoStage = Int.random(in: 1...100)
        switch randoStage {
        case 1...5:
            return .empty
        case 6...30:
            return .colonial
        case 31...60:
            return .emerging
        case 61...80:
            return .apex
        default:
            return .declining
        }
    }
    
    private class func getRandomEconomy(_ system : StarSystem) -> StarSystemEconomy {
        let randoEconomy = Int.random(in: 1...100)
        switch system.stage {
        case .empty:
            return .none
        case .colonial:
            switch randoEconomy {
            case 1...40:
                return .mining
            case 41...80:
                return .agriculture_basic
            default:
                return .agriculture_luxury
            }
        case .emerging:
            switch randoEconomy {
            case 1...30:
                return .mining
            case 31...50:
                return .agriculture_basic
            case 51...70:
                return .agriculture_luxury
            case 71...95:
                return .industrial
            default:
                return .resort
            }
        case .apex:
            switch randoEconomy {
            case 1...5:
                return .mining
            case 6...15:
                return .agriculture_basic
            case 16...30:
                return .agriculture_luxury
            case 31...65:
                return .industrial
            case 66...95:
                return .post_industrial
            default:
                return .resort
            }
        case .declining:
            switch randoEconomy {
            case 1...10:
                return .mining
            case 11...15:
                return .agriculture_basic
            case 16...20:
                return .agriculture_luxury
            case 21...50:
                return .industrial
            case 51...95:
                return .post_industrial
            default:
                return .resort
            }
        }
    }
    
}

