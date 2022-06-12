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
    
    class func generateNewMarket(_ starSystem : StarSystem) -> Market {
        
        let result = Market()
        Commodity.allCases.forEach { comm in
            let targ = comm.base_target(starSystem)
            result.target[comm] = targ
            
            let qtyRange = comm.expectedQuantityRange(starSystem)
            let qty = Int(floor(Double.random(in: qtyRange)*Double(targ)))
            result.stock[comm] = qty
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
