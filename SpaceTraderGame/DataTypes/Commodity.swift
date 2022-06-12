//
//  Commodity.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/11/22.
//

import Foundation


enum Commodity : Int, CustomStringConvertible, Codable, CaseIterable  {
    case agriculture_basic
    case agriculture_luxury
    case live_biologicals
    case metals_precious
    case metals_industrial
    case metals_fissile
    case machinery_industrial
    case machinery_computer
    case luxuries_manufactured
    
    var description : String {
        switch self {
        case .agriculture_basic: return "Agriculture (basic)"
        case .agriculture_luxury: return "Agriculture (luxury)"
        case .live_biologicals: return "Live Biologicals"
        case .metals_precious: return "Metals (precious)"
        case .metals_industrial: return "Metals (industrial)"
        case .metals_fissile: return "Metals (fissile)"
        case .machinery_industrial: return "Machinery (industrial)"
        case .machinery_computer: return "Machinery (computer)"
        case .luxuries_manufactured: return "Luxuries (manufactured)"
        }
    }
    
    var shortDescription : String {
        switch self {
        case .agriculture_basic: return "Ag (basic)"
        case .agriculture_luxury: return "Ag (lux)"
        case .live_biologicals: return "Bio"
        case .metals_precious: return "Met (prec)"
        case .metals_industrial: return "Met (ind)"
        case .metals_fissile: return "Met(fis)"
        case .machinery_industrial: return "Mach (ind)"
        case .machinery_computer: return "Mach (comp)"
        case .luxuries_manufactured: return "Lux"
        }
    }
    
    var base_price : Double {
        switch self {
        case .agriculture_basic: return 20
        case .agriculture_luxury: return 50
        case .live_biologicals: return 100
        case .metals_precious: return 1000
        case .metals_industrial: return 100
        case .metals_fissile: return 300
        case .machinery_industrial: return 500
        case .machinery_computer: return 700
        case .luxuries_manufactured: return 700
        }
    }
    
    private func base_target_normalized(_ starSystem : StarSystem) -> Int {
        
        switch self {
        case .agriculture_basic:
            switch starSystem.economy {
            case .agriculture_basic: return 300
            case .agriculture_luxury: return 80
            default: return 200
            }
        case .agriculture_luxury:
            switch (starSystem.economy, starSystem.stage) {
            case (.agriculture_basic, _): return 80
            case (.agriculture_luxury, _): return 200
            case (.resort, _): return 250
            case (_, .colonial): return 25
            case (_, .emerging): return 150
            case (_, .apex): return 200
            case (_, .declining): return 180
            default:
                return 0
            }
        case .live_biologicals:
            switch (starSystem.economy, starSystem.stage) {
            case (.agriculture_basic, _): return 80
            case (.agriculture_luxury, _): return 80
            case (_, .colonial): return 20
            case (_, .emerging): return 80
            case (_, .apex): return 150
            case (_, .declining): return 100
            default:
                return 0
            }
        case .metals_precious:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 20
            case (.resort, _): return 10
            case (_, .colonial): return 0
            case (_, .emerging): return 5
            case (_, .apex): return 15
            case (_, .declining): return 10
            default:
                return 0
            }
        case .metals_industrial:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 80
            case (.industrial, _): return 80
            case (.post_industrial, _): return 10
            case (.resort, _): return 0
            case (_, .colonial): return 0
            case (_, .emerging): return 10
            case (_, .apex): return 4
            case (_, .declining): return 4
            default:
                return 0
            }
        case .metals_fissile:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 40
            case (.industrial, _): return 40
            case (.post_industrial, _): return 10
            case (.resort, _): return 0
            case (_, .colonial): return 0
            case (_, .emerging): return 10
            case (_, .apex): return 4
            case (_, .declining): return 4
            default:
                return 0
            }
        case .machinery_industrial:
            switch (starSystem.economy, starSystem.stage) {
                case (.mining, _): return 60
                case (.industrial, _): return 60
                case (.post_industrial, _): return 20
                case (.resort, _): return 10
                case (_, .colonial): return 40
                case (_, .emerging): return 30
                case (_, .apex): return 20
                case (_, .declining): return 10
                default:
                    return 0
            }
        case .machinery_computer:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 30
            case (.industrial, _): return 60
            case (.post_industrial, _): return 30
            case (.resort, _): return 20
            case (_, .colonial): return 20
            case (_, .emerging): return 30
            case (_, .apex): return 20
            case (_, .declining): return 20
            default:
                return 0
            }
        case .luxuries_manufactured:
            switch (starSystem.economy, starSystem.stage) {
            case (.industrial, _): return 30
            case (.resort, _): return 30
            case (_, .colonial): return 3
            case (_, .emerging): return 15
            case (_, .apex): return 30
            case (_, .declining): return 20
            default:
                return 0
            }
        }
    }
    
    func base_target(_ starSystem : StarSystem) -> Int {
    
        let normalized = self.base_target_normalized(starSystem)
        
        let power = log10(Double(starSystem.population)) - 3
        return Int(floor(Double(normalized)*power))
    }
    
    func expectedQuantityRange(_ starSystem : StarSystem) -> ClosedRange<Double> {
        
        switch self {
        case .agriculture_basic:
            switch starSystem.economy {
            case .agriculture_basic: return 0.9...1.5
            case .agriculture_luxury: return 0.8...1.2
            default: return 0.4...1.1
            }
        case .agriculture_luxury:
            switch (starSystem.economy, starSystem.stage) {
            case (.agriculture_basic, _): return 0.8...1.2
            case (.agriculture_luxury, _): return 0.9...1.4
            case (.resort, _): return 0.4...1.0
            default:
                return 0.6...1.1
            }
        case .live_biologicals:
            switch (starSystem.economy, starSystem.stage) {
            case (.agriculture_basic, _): return 0.8...1.3
            case (.agriculture_luxury, _): return 0.9...1.2
            default:
                return 0.5...1.0
            }
        case .metals_precious:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 0.6...2.0
            case (.resort, _): return 0.4...1.0
            default:
                return 0.4...1.4
            }
        case .metals_industrial:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 0.9...2.0
            case (.industrial, _): return 0.2...1.3
            case (.post_industrial, _): return 0.8...1.0
            default:
                return 0.9...1.1
            }
        case .metals_fissile:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 0.3...2.5
            case (.industrial, _): return 0.2...1.2
            case (.post_industrial, _): return 0.5...1.1
            default:
                return 0.9...1.1
            }
        case .machinery_industrial:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 0.3...1.1
            case (.industrial, _): return 0.9...1.8
            case (.post_industrial, _): return 0.6...1.0
                default:
                return 0.7...1.0
            }
        case .machinery_computer:
            switch (starSystem.economy, starSystem.stage) {
            case (.mining, _): return 0.5...1.0
            case (.industrial, _): return 0.9...1.6
            default:
                return 0.7...1.0
            }
        case .luxuries_manufactured:
            switch (starSystem.economy, starSystem.stage) {
            case (.industrial, _): return 0.5...2.0
            case (.resort, _): return 0.5...1.0
            default:
                return 0.5...1.1
            }
        }
        
    }
}
