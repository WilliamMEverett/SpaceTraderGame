//
//  Player.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/6/22.
//

import Foundation

class Player : Codable {
    
    var name = ""
    var navigation : Int = 0
    var combat : Int = 0
    var negotiation : Int = 0
    var diplomacy : Int = 0
    var reputation : Int = 0
    var ship : Ship!
    
    var location : Int = 0
    var inStation = true
    var visitedStars : Set<Int> = Set<Int>()
    var knownStars : Set<Int> = Set<Int>()
    var allKnownStars : Set<Int> {
        visitedStars.union(knownStars)
    }
    var money : Int = 0
    
    var distanceTraveled : Double = 0
    var jumpsMade : Int = 0
    
    required init(name: String) {
        self.name = name
        self.ship = Ship.baseShip()
        self.money = 1000
    }
    
    func timeToJump(distance: Double) -> Double {
        return self.ship.baseTimeToJump(distance: distance)
    }
    
    func fuelToTravelTime(time: Double) -> Double {
        return self.ship.fuelToTravelTime(time: time)
    }
    
    func performJump(from : Int, to: Int, galaxyMap: GalaxyMap) -> (success: Bool, timeElapsed: Double) {
        guard let currentStar = galaxyMap.getSystemForId(from) else {
            return (success:false, timeElapsed: 0)
        }
        if !currentStar.connectingSystems.contains(to) {
            return (success:false, timeElapsed: 0)
        }
        guard let destinationStar = galaxyMap.getSystemForId(to) else {
            return (success:false, timeElapsed: 0)
        }
        
        let distance = currentStar.position.distance(destinationStar.position)
        
        let time = self.timeToJump(distance: distance)
        let fuel = self.fuelToTravelTime(time: time)
        
        if fuel > self.ship.fuel {
            return (success:false, timeElapsed: 0)
        }
        
        self.location = destinationStar.num_id
        self.visitedStars.insert(destinationStar.num_id)
        destinationStar.connectingSystems.forEach() { self.knownStars.insert($0)}
        self.ship.fuel -= fuel
        self.distanceTraveled += distance
        self.jumpsMade += 1

        return (success:true, timeElapsed: time)
    }
}
