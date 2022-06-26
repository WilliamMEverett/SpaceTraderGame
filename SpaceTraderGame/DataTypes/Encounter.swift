//
//  Encounter.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/20/22.
//

import Foundation

enum EncounterType : Int, Codable, CustomStringConvertible {
    case pirate
    case merchant
    case patrol
    case other
    
    var description : String {
        switch self {
        case .pirate: return "Pirate"
        case .merchant: return "Merchant"
        case .patrol: return "System Patrol"
        case .other: return "Unknown"
        }
    }
}

class Encounter : Codable {
    
    var player : Player? = nil
    var type : EncounterType = .pirate
    
    class func checkForEncounterInCurrentSystem(player: Player, map: GalaxyMap) -> Encounter? {
        guard let currentSystem = map.getSystemForId(player.location) else {
            return nil
        }
        if currentSystem.danger == 0 {
            return nil
        }
        
        //Note: this is for a pirate encounter. Probability of this happening should depend on danger level, for now, always happens
        let playerShipThreat = player.ship.threatLevel()
        let minimumThreat = playerShipThreat < 2 ? 0 : playerShipThreat - 2
        let maxThreat = max(max(playerShipThreat + 2, currentSystem.danger), player.reputation/10)
        let enemyDanger = Int.random(in: minimumThreat...maxThreat)
        
        let enc = Encounter()
        enc.player = Player(name:"")
        enc.player!.ship = Ship.shipForThreatLevel(enemyDanger)
        enc.player!.combat = Int.random(in: (min(0,player.combat - 30))...(max(player.combat - 10,currentSystem.danger*10)))
        enc.player!.navigation = max(0,min(100,enc.player!.combat + Int.random(in: -20...20)))
        
        return enc
    }
}
