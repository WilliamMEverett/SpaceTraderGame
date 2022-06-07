//
//  GalaxyMap.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/2/22.
//

import Foundation

class GalaxyMap: Codable {
    private var systemsMap = [Int:StarSystem]()
    
    required init(_ maxSystems : Int) {
        generateSystems(maxSystems)
    }
    
    func getSystemForId(_ ident: Int) -> StarSystem? {
        return systemsMap[ident]
    }
    
    func getAllSystemIdentifiers() -> [Int] {
        return Array(systemsMap.keys)
    }
    
    func getStartingPlayerLocation() -> Int? {
        
        let starIds = systemsMap.keys.sorted()
        
        var res : Int? = nil
        for testId in starIds {
            let testSystem = getSystemForId(testId)!
            if testSystem.danger > 3 {
                continue
            }
            if testSystem.stage == .empty || testSystem.stage == .colonial {
                continue
            }
            let nonEmptyConnectingSystems = testSystem.connectingSystems.reduce(0) { (partialResult: Int, nextValue : Int) -> Int in
                if getSystemForId(nextValue)!.stage != .empty {
                    return partialResult + 1
                }
                else {
                    return partialResult
                }
            }
            if nonEmptyConnectingSystems < 3 {
                continue
            }
            res = testId
            break
        }
        
        return res
    }
    
    func closestSystemToCoordinates(_ twoDCoord : NSPoint) -> StarSystem? {
        let res = self.systemsMap.reduce(nil) { (partialResult : (distance: Double, value: StarSystem)?, nextValue : (key: Int, value: StarSystem)) -> (distance:Double, value: StarSystem)? in
            let nextDistance = nextValue.value.position.distance2D(twoDCoord)
            let nextResult = (distance: nextDistance, value: nextValue.value)
            if partialResult == nil || partialResult!.distance > nextResult.distance {
                return nextResult
            }
            else {
                return partialResult
            }
        }
        return res?.value
    }
    
    private func generateSystems(_ maxSystems : Int) {
        var resultMap = [Int:StarSystem]()
        var arrayOfSystems = [StarSystem]()
        
        if resultMap.count >= maxSystems {
            self.systemsMap = resultMap
            return
        }
        
        var names = self.getMapOfNames()
        
        let newStar = StarSystem.generateRandomSystem()
        newStar.num_id = resultMap.count + 1
        if let newName = names.randomElement()?.key {
            newStar.name = newName
            names.removeValue(forKey: newName)
        }
        else {
            newStar.name = "\(newStar.num_id)"
        }
        resultMap[newStar.num_id] = newStar
        arrayOfSystems.append(newStar)
        
        var tries = 0
        while resultMap.count < maxSystems {
            let startingSystem = arrayOfSystems.count <= 200 ? arrayOfSystems.randomElement()! : arrayOfSystems[(arrayOfSystems.count - 200)...(arrayOfSystems.count - 1)].randomElement()!
            if startingSystem.connectingSystems.count >= 3 && tries < 10 {
                tries += 1
                continue
            }
            tries = 0
            let newSystem = addNewStarTo(baseSystem: startingSystem, systemMap: resultMap)
            if newSystem != nil {
                if let newName = names.randomElement()?.key {
                    newSystem!.name = newName
                    names.removeValue(forKey: newName)
                }
                
                resultMap[newSystem!.num_id] = newSystem!
                arrayOfSystems.append(newSystem!)
            }
        }
        
        self.systemsMap = resultMap
        return
    }
    
    private func addNewStarTo(baseSystem : StarSystem, systemMap : [Int:StarSystem]) -> StarSystem? {
        
        let distanceFromCore = sqrt(baseSystem.position.x*baseSystem.position.x + baseSystem.position.y*baseSystem.position.y)
        var angle = Double.random(in: 0...(2*Double.pi))
        if distanceFromCore > 1 && distanceFromCore < 150 {
            let currentAngle = atan2(baseSystem.position.y, baseSystem.position.x)
            angle = currentAngle - Double.pi/2 + Double.random(in:0...Double.pi)
        }
        
        let distance = Double.random(in: 3...10)
        
        let xValue = cos(angle)*distance + baseSystem.position.x
        let yValue = sin(angle)*distance + baseSystem.position.y
        let zRatio = Double.random(in: 0...1)
        let zMag = 10*zRatio*zRatio
        let zValue = Bool.random() ? zMag : -1*zMag
        let newCoord = Coord(x:xValue,y:yValue,z:zValue)
        
        var densityScore : Double = 0
        var connectedSystems = [(ident:Int,distance:Double)]()
        systemMap.forEach { (key: Int, value: StarSystem) in
            if densityScore > 15 || connectedSystems.count > 4 {
                return
            }
            let dist = newCoord.distance(value.position)
            if dist < 2 {
                densityScore = 100
                return
            }
            if dist < 12 {
                densityScore += 12 - dist
                if value.connectingSystems.count >= 4 {
                    densityScore = 100
                    return
                }
                connectedSystems.append((ident:key,distance:dist))
            }
        }
        
        if densityScore > 15 || connectedSystems.count > 4 || connectedSystems.count < 1 {
            return nil
        }
        
        let sortedConnectingSystems = Array(connectedSystems.sorted { (obj1, obj2 ) -> Bool in
            return obj1.distance < obj2.distance
        }.map { $0.ident })
        
        var newConnectingSystems = [Int]()
        sortedConnectingSystems.forEach { key in
            
            let otherSystem = systemMap[key]!
            if Set(newConnectingSystems).intersection(otherSystem.connectingSystems).isEmpty {
                newConnectingSystems.append(key)
            }
        }
        
        let newSystem = StarSystem.generateRandomSystem()
        newSystem.num_id = systemMap.count + 1
        newSystem.name = "\(newSystem.num_id)"
        newSystem.connectingSystems = newConnectingSystems
        newSystem.position = newCoord
    
        newConnectingSystems.forEach { key in
            let otherSystem = systemMap[key]!
            otherSystem.connectingSystems.append(newSystem.num_id)
        }
        
        return newSystem
    }
    
    private func getMapOfNames() -> [String:Bool] {
        var result = [String:Bool]()
        var fileContents : String? = nil
        if let fileURL = Bundle.main.url(forResource: "city_list", withExtension: "txt") {
            fileContents = try? String(contentsOf: fileURL)
        }
        
        if fileContents == nil {
            print("Could not open name list file")
            return result
        }
        
        let lines = fileContents!.split(separator: "\n")
        lines.forEach { ln in
            let trimmed = ln.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if !trimmed.isEmpty {
                result[trimmed] = true
            }
        }
        
        return result
    }
}
