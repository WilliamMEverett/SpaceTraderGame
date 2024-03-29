//
//  GameState.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/6/22.
//

import Foundation

class GameState : Codable {
    
    struct LogEntry : Codable {
        var realTime : Double
        var gameTime : Double
        var message : String
    }
    
    static let timeUpdatedNotification = "timeUpdatedNotification"
    static let logEntryPostedNotification = "logEntryPostedNotification"
    
    var galaxyMap : GalaxyMap!
    var player : Player!
    var gameOver = false
    var saved = false
    var time : Double  = 0 { //In days
        didSet {
            self.timeUpdated()
        }
    }
    var log : [LogEntry] = []
    
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
        self.addLogEntry("Game started at \(startingStar.name)")
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(GameState.logEntryPostedNotification), object: nil, queue: nil) { notification in
            weakSelf?.logEntryPosted(notification)
        }
        
    }
    
    func timeUpdated() {
        self.saved = false
        self.player.checkMissions(time: self.time)
        NotificationCenter.default.post(name: Notification.Name(GameState.timeUpdatedNotification), object: self)
    }
    
    class func timeStringDescription(_ timeIn : Double) -> String {
        let yearValue = Int(floor(timeIn/365))
        let daysValue = timeIn - Double(365*yearValue)
        
        return String(format: "Year %d, Day %.1f", yearValue, daysValue)
    }
    
    class func shortTimeStringDescription(_ timeIn : Double) -> String {
        let yearValue = Int(floor(timeIn/365))
        let daysValue = timeIn - Double(365*yearValue)
        
        return String(format: "%d-%.1f", yearValue, daysValue)
    }
    
    func timeStringDescription() -> String {
        
        return GameState.timeStringDescription(self.time)
    }
    
    func performJump(from : Int, to: Int, galaxyMap: GalaxyMap, player: Player) -> Bool {
        guard let currentStar = galaxyMap.getSystemForId(from) else {
            return false
        }
        if !currentStar.connectingSystems.contains(to) {
            return false
        }
        guard let destinationStar = galaxyMap.getSystemForId(to) else {
            return false
        }
        
        let distance = currentStar.position.distance(destinationStar.position)
        
        let time = player.timeToJump(distance: distance)
        let fuel = player.fuelToTravelTime(time: time)
        
        if fuel > player.ship.fuel {
            return false
        }
        
        if !player.visitedStars.contains(destinationStar.num_id) {
            player.navigationExperience += distance*2.0
        }
        else {
            player.navigationExperience += distance*0.5
        }
        
        player.priorLocation = player.location
        player.location = destinationStar.num_id
        player.visitedStars.insert(destinationStar.num_id)
        destinationStar.connectingSystems.forEach() { player.knownStars.insert($0)}
        player.ship.fuel -= fuel
        player.distanceTraveled += distance
        player.jumpsMade += 1

        player.playerUpdated()
        
        self.addLogEntry("Jumped from \(currentStar.name) to \(destinationStar.name)")
        
        self.time += time
        
        destinationStar.refreshStarSystemOnReentry()
        destinationStar.missionBoard = Mission.generateMissionBoardFor(starSystem: destinationStar, galaxyMap: self.galaxyMap, player: self.player, time: self.time)
        
        
        return true
    }
    
    func addLogEntry(_ message : String) {
        self.log.append(LogEntry(realTime: Date.timeIntervalSinceReferenceDate, gameTime: self.time, message: message))
        NotificationCenter.default.post(name: Notification.Name(GameState.timeUpdatedNotification), object: self)
    }
    
    //MARK: - Notification
    
    private func logEntryPosted(_ notification : Notification) {
        guard let message = notification.userInfo?["message"] as? String else {
            print("Log notification lacking message")
            return
        }
        self.addLogEntry(message)
    }
    
}
