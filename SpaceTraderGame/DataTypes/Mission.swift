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
    var missionText = ""
    var missionQty : Int = 0
    var missionCommodity : Commodity = .agriculture_basic
    var returnDestination : Int = 0
    var requiresLifeSupport : Bool = false
    
}
