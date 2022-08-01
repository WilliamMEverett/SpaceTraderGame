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
    var reputation : Int = 0 {
        didSet {
            if reputation < 0 || reputation > 100 {
                reputation = min(max(100,reputation),0)
            }
            self.playerUpdated()
        }
    }
    var ship : Ship!
    
    var location : Int = 0
    var priorLocation : Int = 0
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
    var missions : [Mission] = []
    var cancelledMissions : [Mission] = []
    var completedMissions : [Mission] = []
    
    var distanceTraveled : Double = 0
    var jumpsMade : Int = 0
    
    required init(name: String, navigation: Int, combat: Int, negotiation : Int, diplomacy : Int) {
        self.name = name
        self.ship = Ship.baseShip()
        self.money = 1000
        self.navigationExperience = Player.convertScoreToExperience(navigation)
        self.navigation = navigation
        self.combatExperience = Player.convertScoreToExperience(combat)
        self.combat = combat
        self.negotiationExperience = Player.convertScoreToExperience(negotiation)
        self.negotiation = negotiation
        self.diplomacyExperience = Player.convertScoreToExperience(diplomacy)
        self.diplomacy = diplomacy
    }
    
    func playerUpdated() {
        NotificationCenter.default.post(name: Notification.Name(Player.playerUpdatedNotification), object: self)
    }
    
    func negotiationPriceAdjustment() -> Double {
        return 0.05*(120.0 - Double(self.negotiation))/120.0
    }
    
    func timeToJump(distance: Double) -> Double {
        return self.ship.baseTimeToJump(distance: distance)*(300.0 - Double(self.navigation))/300.0
    }
    
    func timeToJumpWithoutCommodities(distance: Double) -> Double {
        return self.ship.baseTimeToJumpWithoutCommodities(distance: distance)*(300.0 - Double(self.navigation))/300.0
    }
    
    func fuelToTravelTime(time: Double) -> Double {
        return self.ship.fuelToTravelTime(time: time)
    }
    
    func fuelToTravelDistance(distance: Double) -> Double {
        return self.fuelToTravelTime(time: self.timeToJump(distance: distance))
    }
    
    func checkMissions(time : Double) {
        
        for m in self.missions {
            if m.expired || m.completed {
                continue
            }
            if time >= m.expiration {
                m.expired = true
                self.reputation -= m.reputationReward
                continue
            }
            if m.type == .courier {
                if self.location == m.target && self.inStation == true {
                    m.completed = true
                    m.completedTime = time
                    self.addMissionRewardToPlayer(m)
                }
            }
            else if m.type == .survey {
                if self.location == m.returnDestination && self.inStation == true && self.visitedStars.contains(m.target) {
                    m.completed = true
                    m.completedTime = time
                    self.addMissionRewardToPlayer(m)
                }
            }
        }
        
        self.completedMissions.append(contentsOf: self.missions.filter({$0.completed}))
        self.completedMissions.sort(by: {$0.completedTime > $1.completedTime})
        self.missions = self.missions.filter({!$0.completed})
    }
    
    private func addMissionRewardToPlayer(_ m : Mission) {
        self.money += m.moneyReward
        if self.reputation < m.maximumReputation {
            if self.reputation + m.reputationReward > m.maximumReputation {
                self.reputation = m.maximumReputation
            }
            else {
                self.reputation += m.reputationReward
            }
        }
    }
    
    class func convertScoreToExperience(_ score : Int) -> Double {
        return ceil(Double(score)*Double(score)/2.0 + 10*Double(score))
    }
        
    class func convertExperienceToScore(_ exp : Double) -> Int {
        let res = Int(floor(-10 + sqrt(100 + 2*exp)))
        return res > 100 ? 100 : res
    }
}
