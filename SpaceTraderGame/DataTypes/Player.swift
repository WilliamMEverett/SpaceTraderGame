//
//  Player.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/6/22.
//

import Foundation

class Player : Codable {
    
    static let playerUpdatedNotification = "playerUpdatedNotification"
    
    var name = ""
    var navigation : Int = 0
    var navigationExperience : Double = 0 {
        didSet {
            let newScore = Player.convertExperienceToScore(navigationExperience)
            if navigation != newScore {
                self.navigation = newScore
                self.playerUpdated()
            }
        }
    }
    var combat : Int = 0
    var combatExperience : Double = 0 {
        didSet {
            let newScore = Player.convertExperienceToScore(combatExperience)
            if combat != newScore {
                self.combat = newScore
                self.playerUpdated()
                
            }
        }
    }
    var negotiation : Int = 0
    var negotiationExperience : Double = 0 {
        didSet {
            let newScore = Player.convertExperienceToScore(negotiationExperience)
            if negotiation != newScore {
                self.negotiation = newScore
                self.playerUpdated()
            }
        }
    }
    
    var diplomacy : Int = 0
    var diplomacyExperience : Double = 0 {
        didSet {
            let newScore = Player.convertExperienceToScore(diplomacyExperience)
            if diplomacy != newScore {
                self.diplomacy = newScore
                self.playerUpdated()
            }
        }
    }
    var reputation : Int = 0
    var ship : Ship!
    
    var location : Int = 0
    var inStation = true
    var visitedStars : Set<Int> = Set<Int>()
    var knownStars : Set<Int> = Set<Int>()
    var allKnownStars : Set<Int> {
        visitedStars.union(knownStars)
    }
    var money : Int = 0 {
        didSet {
            self.playerUpdated()
        }
    }
    
    var distanceTraveled : Double = 0
    var jumpsMade : Int = 0
    
    required init(name: String) {
        self.name = name
        self.ship = Ship.baseShip()
        self.money = 1000
    }
    
    func playerUpdated() {
        NotificationCenter.default.post(name: Notification.Name(Player.playerUpdatedNotification), object: self)
    }
    
    func negotiationPriceAdjustment() -> Double {
        return 0.05
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
        currentStar.market = nil
        destinationStar.market = nil
        
        self.location = destinationStar.num_id
        self.visitedStars.insert(destinationStar.num_id)
        destinationStar.connectingSystems.forEach() { self.knownStars.insert($0)}
        self.ship.fuel -= fuel
        self.distanceTraveled += distance
        self.jumpsMade += 1

        self.playerUpdated()
        
        return (success:true, timeElapsed: time)
    }
    
    class func convertScoreToExperience(_ score : Int) -> Double {
        return ceil(Double(score)*Double(score)/2.0 + 10*Double(score))
    }
        
    class func convertExperienceToScore(_ exp : Double) -> Int {
        return Int(floor(-10 + sqrt(100 + 2*exp)))
    }
}
