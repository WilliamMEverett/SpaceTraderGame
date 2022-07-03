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
    var type : EncounterType = .other
    var bounty : Int = 0
    
    class func checkForEncounterInCurrentSystem(player: Player, map: GalaxyMap) -> Encounter? {
        
        let pirateEncounter = getPirateEncounterForCurrentSystem(player: player, map: map)
        if pirateEncounter != nil {
            return pirateEncounter
        }
        let otherEncounter = getUnknownHostileEncounterForCurrentSystem(player: player, map: map)
        if otherEncounter != nil {
            return otherEncounter
        }
        
        return nil
    }
    
    class func getPirateEncounterForCurrentSystem(player: Player, map: GalaxyMap) -> Encounter? {
        guard let currentSystem = map.getSystemForId(player.location) else {
            return nil
        }
        if currentSystem.danger == 0 {
            return nil
        }
        let cargoValue = player.ship.baseCargoValue()
        if cargoValue == 0 {
            return nil
        }
        let baseChanceOfEncounter = cargoValue < 1000 ? (cargoValue/1000)*0.06 : 0.06
        let chanceOfEncounter = baseChanceOfEncounter*Double(currentSystem.danger)
        let rando = Double.random(in: 0...1)
        if rando > chanceOfEncounter {
            return nil
        }
        
        let playerShipThreat = player.ship.threatLevel()
        let minimumThreat = playerShipThreat < 2 ? 0 : playerShipThreat - 2
        let maxThreat = max(playerShipThreat, max(player.reputation/10, currentSystem.danger/2))
        let enemyDanger = Int.random(in: minimumThreat...maxThreat)
        
        let enc = Encounter()
        enc.type = .pirate
        enc.player = Player(name:"")
        enc.player!.ship = Ship.shipForThreatLevel(enemyDanger)
        enc.player!.combat = Int.random(in: (min(0,player.combat - 30))...(max(player.combat - 10,currentSystem.danger*10)))
        enc.player!.navigation = max(0,min(100,enc.player!.combat + Int.random(in: -20...20)))
        
        let shipThreatLevel = enc.player!.ship.threatLevel()
        enc.bounty = shipThreatLevel*shipThreatLevel*100 + shipThreatLevel*enc.player!.combat + enc.player!.navigation
        
        return enc
    }
    
    class func getUnknownHostileEncounterForCurrentSystem(player: Player, map: GalaxyMap) -> Encounter? {
        guard let currentSystem = map.getSystemForId(player.location) else {
            return nil
        }
        if currentSystem.danger == 0 {
            return nil
        }
        
        let baseChanceOfEncounter = player.money < 20000 ? (0.02 + 0.04*Double(player.money)/20000) : 0.06
        let chanceOfEncounter = baseChanceOfEncounter*Double(currentSystem.danger)
        if Double.random(in: 0...1) > chanceOfEncounter {
            return nil
        }
    
        let playerShipThreat = player.ship.threatLevel()
        let minimumThreat = playerShipThreat < 2 ? 0 : playerShipThreat - 2
        let maxThreat = max(player.reputation/10, (currentSystem.danger/2))
        let enemyDanger = Int.random(in: minimumThreat...maxThreat)
    
        let enc = Encounter()
        enc.type = .other
        enc.player = Player(name:"")
        enc.player!.ship = Ship.shipForThreatLevel(enemyDanger)
        enc.player!.combat = Int.random(in: (min(0,player.combat - 20))...(max(player.combat - 10,currentSystem.danger*10)))
        enc.player!.navigation = max(0,min(100,enc.player!.combat + Int.random(in: -30...30)))
        
        let shipThreatLevel = enc.player!.ship.threatLevel()
        let maxBounty = shipThreatLevel*shipThreatLevel*100 + shipThreatLevel*enc.player!.combat + enc.player!.navigation
        let minBounty = 0
        enc.bounty = Int.random(in: minBounty...maxBounty)
        
        return enc
    }
}
