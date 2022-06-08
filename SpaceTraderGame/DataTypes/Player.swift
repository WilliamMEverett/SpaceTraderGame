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
    
    required init(name: String) {
        self.name = name
        self.ship = Ship.baseShip()
        self.money = 1000
    }
}
