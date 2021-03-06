//
//  GameState.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/6/22.
//

import Foundation

class GameState : Codable {
    
    static let timeUpdatedNotification = "timeUpdatedNotification"
    
    var galaxyMap : GalaxyMap!
    var player : Player!
    var gameOver = false
    var saved = false
    var time : Double  = 0 { //In days
        didSet {
            self.timeUpdated()
        }
    }
    
    required init?(player : Player, starSystems : Int) {
        self.galaxyMap = GalaxyMap(starSystems)
        self.player = player
        guard let startingPosition = self.galaxyMap.getStartingPlayerLocation() else {
            print("Failed to find starting position")
            return nil
        }
        self.player.location = startingPosition
        self.player.visitedStars.insert(startingPosition)
        let startingStar = self.galaxyMap.getSystemForId(startingPosition)!
        startingStar.connectingSystems.forEach { self.player.knownStars.insert($0) }
        startingStar.refreshStarSystemOnReentry()
        
    }
    
    func timeUpdated() {
        self.saved = false
        NotificationCenter.default.post(name: Notification.Name(GameState.timeUpdatedNotification), object: self)
    }
    
    func timeStringDescription() -> String {
        
        let yearValue = Int(floor(time/365))
        let daysValue = time - Double(365*yearValue)
        
        return String(format: "Year %d, Day %.1f", yearValue, daysValue)
    }
    
}
