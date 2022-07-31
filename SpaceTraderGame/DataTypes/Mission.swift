//
//  Mission.swift
//  SpaceTraderGame
//
//  Created by William Everett on 7/26/22.
//

import Foundation

class Mission : Codable {

    enum MissionType : Int, Codable, CustomStringConvertible {
        case courier
        case survey
        case delivery
        case customCargo
        
        var description : String {
            switch self {
            case .courier: return "Courier"
            case .survey: return "Survey"
            case .delivery: return "Delivery"
            case .customCargo: return "Custom Cargo"
            }
        }
    }
    
    var type : MissionType = .courier
    var target : Int = 0
    var minimumReputation : Int = 0
    var maximumReputation : Int = 0
    var reputationReward : Int = 0
    var moneyReward : Int = 0
    var danger : Int = 0
    var expiration : Double = 0
    var expired : Bool = false
    var completed : Bool = false
    var missionText = ""
    var missionQty : Int = 0
    var missionCommodity : Commodity = .agriculture_basic
    var returnDestination : Int = 0
    var requiresLifeSupport : Bool = false
    
    func playerCanTakeMission(_ player : Player) -> (res: Bool, reason: String) {
        if player.reputation < self.minimumReputation {
            return (res:false,reason:"You do not have a high enough reputation")
        }
        return (res:true,reason:"")
    }
    
    class func generateMissionBoardFor(starSystem : StarSystem, galaxyMap : GalaxyMap, player : Player, time : Double) -> [Mission] {
        if starSystem.stage == .empty {
            return []
        }
        
        let numberOfMissions = Int.random(in: 0...7)
    
        var knownStars = galaxyMap.systemsWithinJumpsFrom(start: starSystem.num_id, jumps: max(4,player.reputation/10 + 1), limitedTo: player.visitedStars).filter { element in
            if element.value.jumps == 0 {
                return false
            }
            if element.value.jumps > player.reputation/10 + 2 {
                return false
            }
            if element.value.jumps < player.reputation/10 - 1 {
                return false
            }
            return true
        }
        var unknownStars = galaxyMap.systemsWithinJumpsFrom(start: starSystem.num_id, jumps: 10, limitedTo: nil).filter { element in
            element.key != starSystem.num_id && !player.allKnownStars.contains(element.key)
        }
        
        
        var result = [Mission]()
        
        for _ in 0..<numberOfMissions {
            let typeOfMission = Int.random(in: 1...10)
            switch typeOfMission {
            case 1...3:
                if let courierMission = self.generateCourierMission(starSystem: starSystem, galaxyMap: galaxyMap, stars: knownStars, player: player, time: time) {
                    result.append(courierMission)
                    knownStars.removeValue(forKey: courierMission.target)
                }
            case 4...5:
                if let surveyMission = self.generateSurveyMission(starSystem: starSystem, galaxyMap: galaxyMap, stars: unknownStars, player: player, time: time) {
                    result.append(surveyMission)
                    unknownStars.removeValue(forKey: surveyMission.target)
                }
            default:
                break
            }
        }
        
        result.sort { miss1, miss2 in
            if miss1.minimumReputation < miss2.minimumReputation {
                return true
            }
            else {
                return miss1.moneyReward < miss2.moneyReward
            }
        }
        
        return result
    }
    
    private class func generateCourierMission(starSystem : StarSystem,  galaxyMap : GalaxyMap, stars: [Int:(jumps:Int,distance:Double)], player : Player, time : Double) -> Mission? {
        
        guard let randomStar = stars.randomElement(), let destinationStar = galaxyMap.getSystemForId(randomStar.key)  else {
            return nil
        }
        if destinationStar.stage == .empty {
            return nil
        }
        let newMission = Mission()
        newMission.type = .courier
        newMission.target = destinationStar.num_id
        newMission.missionText = "Carry a package to \(destinationStar.name)"
        newMission.danger = destinationStar.danger
        newMission.minimumReputation = max(randomStar.value.jumps/2 + newMission.danger - 10,0)
        newMission.maximumReputation = min(30,randomStar.value.jumps/2 + newMission.danger*3)
        newMission.reputationReward = max(1,((randomStar.value.jumps/2 + newMission.danger)/5))
        newMission.moneyReward = Int(round(randomStar.value.distance*20)) + 30*newMission.danger
        let timeRequired = 1.5*randomStar.value.distance + 4
        newMission.expiration = time + timeRequired
        
        return newMission
    }
    
    private class func generateSurveyMission(starSystem : StarSystem,  galaxyMap : GalaxyMap, stars: [Int:(jumps:Int,distance:Double)], player : Player, time : Double) -> Mission? {
        
        guard let randomStar = stars.randomElement(), let destinationStar = galaxyMap.getSystemForId(randomStar.key)  else {
            return nil
        }
        let newMission = Mission()
        newMission.type = .survey
        newMission.target = destinationStar.num_id
        newMission.returnDestination = starSystem.num_id
        newMission.missionText = "Find and survey \(destinationStar.name) and then return to \(starSystem.name)"
        newMission.danger = 0
        newMission.minimumReputation = 0
        newMission.maximumReputation = min(30,randomStar.value.jumps)
        newMission.reputationReward = max(1,randomStar.value.jumps/4)
        newMission.moneyReward = Int(round(randomStar.value.distance*20))
        let timeRequired = 4*randomStar.value.distance
        newMission.expiration = time + timeRequired
        
        return newMission
    }
    
}
