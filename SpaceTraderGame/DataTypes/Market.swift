//
//  Market.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/11/22.
//

import Foundation

class Market : Codable {
    
    var stock : [Commodity:Int] = [:]
    var target : [Commodity:Int] = [:]
    var timestamp : Double = 0
    var needsRefresh = false
    
    class func generateNewMarket(starSystem : StarSystem, time: Double) -> Market {
        
        let result = Market()
        Commodity.allCases.forEach { comm in
            let targ = comm.base_target(starSystem)
            result.target[comm] = targ
            
        }
        result.stock = result.generateNewCommodityQuantities(starSystem: starSystem)
        result.timestamp = time
        return result
    }
    
    func recalculateMarketQuantities(starSystem : StarSystem, time: Double) {
        let resetTime : Double = 90
        let newQtyMap = self.generateNewCommodityQuantities(starSystem: starSystem)
        
        if time - self.timestamp > resetTime {
            self.stock = newQtyMap
            self.timestamp = time
            return
        }
        let timeDiff = time - self.timestamp
        newQtyMap.keys.forEach { comm in
            let existing = self.stock[comm] ?? 0
            let new = newQtyMap[comm] ?? 0
            let qtyDiff = Double(new - existing)
            let adjustedQtyDiff = qtyDiff*timeDiff/resetTime
            self.stock[comm] = existing + Int(round(adjustedQtyDiff))
        }
        self.timestamp = time
        self.needsRefresh = false
    }
    
    private func generateNewCommodityQuantities(starSystem : StarSystem) -> [Commodity:Int] {
        var result : [Commodity:Int] = [:]
        Commodity.allCases.forEach { comm in
            
            let targ = self.target[comm] ?? 0
            
            let qtyRange = comm.expectedQuantityRange(starSystem)
            let qty = Int(floor(Double.random(in: qtyRange)*Double(targ)))
            result[comm] = qty
        }
        return result
    }
    
    func priceForCommodity(_ comm : Commodity) -> Double? {
        guard let currentQty = self.stock[comm] else {
            return nil
        }
        return self.priceForCommodityAtQty(comm: comm, qty: currentQty)
    }
    
    func priceForCommodityAtQty(comm : Commodity, qty: Int) -> Double? {
        let targetQty = self.target[comm] ?? 0
        if targetQty == 0 {
            return nil
        }
        return comm.base_price * pow(2, Double(targetQty - qty)/Double(targetQty))
    }
}
