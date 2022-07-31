//
//  BasicMenuViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/7/22.
//

import Cocoa

enum BasicMenuActionType : Int, CustomStringConvertible {
    case dock
    case undock
    case starmap
    case jump
    case refuel
    case market
    case equipment
    case shipyard
    case jobs
    
    var description : String {
        switch self {
        case .dock: return "Dock"
        case .undock: return "Un-Dock"
        case .starmap: return "Star Map"
        case .jump: return "Jump"
        case .refuel: return "Refuel and Repair"
        case .market: return "Market"
        case .equipment: return "Equipment Market"
        case .shipyard: return "Shipyard"
        case .jobs: return "Jobs"
        }
    }
    
}

class BasicMenuViewController: GameViewPanelViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var currentSystemLabel: NSTextField!
    @IBOutlet weak var inStationLabel: NSTextField!
    @IBOutlet weak var actionTableView : NSTableView!
    
    private var actionList : [BasicMenuActionType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.refreshView()
    }
    
    private func refreshView() {
        let currentSystem = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location)
        self.currentSystemLabel.stringValue = (currentSystem?.name) ?? "Error"
        self.inStationLabel.stringValue = self.gameState.player.inStation ? "Docked" : "Outer System"
        
        self.actionList.removeAll()
        if !self.gameState.gameOver {
            if self.gameState.player.inStation {
                self.actionList.append(.undock)
                self.actionList.append(.market)
                self.actionList.append(.equipment)
                if currentSystem?.stage != .empty && currentSystem?.stage != .colonial {
                    self.actionList.append(.shipyard)
                }
                self.actionList.append(.jobs)
            }
            if !self.gameState.player.inStation && currentSystem?.stage != .empty {
                self.actionList.append(.dock)
            }
            if !self.gameState.player.inStation {
                self.actionList.append(.jump)
            }
            if self.gameState.player.inStation && (self.gameState.player.ship.fuel < self.gameState.player.ship.engine || self.gameState.player.ship.hullDamage > 0) {
                self.actionList.append(.refuel)
            }
        }
     
        self.actionList.append(.starmap)
        
        self.actionTableView.reloadData()
    }
    
    //MARK: - Actions
    func performDock() {
        if self.gameState.player.inStation {
            self.refreshView()
            return
        }
        let fuelRequired = self.gameState.player.ship.fuelToTravelTime(time: Ship.timeToLeaveDock())
        if self.gameState.player.ship.fuel >= fuelRequired {
            self.gameState.player.ship.fuel -= fuelRequired
            self.gameState.player.inStation = true
            self.gameState.time += Ship.timeToLeaveDock()
        }
        self.refreshView()
    }
    
    func performUnDock() {
        if !self.gameState.player.inStation {
            self.refreshView()
            return
        }
        let fuelRequired = self.gameState.player.ship.fuelToTravelTime(time: Ship.timeToLeaveDock())
        if self.gameState.player.ship.fuel >= fuelRequired {
            self.gameState.player.ship.fuel -= fuelRequired
            self.gameState.player.inStation = false
            self.gameState.time += Ship.timeToLeaveDock()
        }
        self.refreshView()
    }
    
    func displayJumpController() {
        let jumpController = JumpSelectPanelViewController()
        self.delegate?.presentGameViewPanel(sender: self, newPanel: jumpController)
        
    }
    
    func displayStarMap() {
        let newStarMapController = StarMapViewController()
        newStarMapController.gameState = self.gameState
        newStarMapController.centerOnStarSystem(self.gameState.player.location)
        self.delegate?.presentGameViewPanel(sender: self, newPanel: newStarMapController)
    }
    
    func displayMarket() {
        let newMarketController = MarketPanelViewController()
        self.delegate?.presentGameViewPanel(sender: self, newPanel: newMarketController)
    }
    
    func performRefuel() {
        let newRefuelController = RefuelPanelViewController()
        self.delegate?.presentGameViewPanel(sender: self, newPanel: newRefuelController)
    }
    
    func performEquipmentMarket() {
        let newEquipMarket = EquipmentMarketPanelViewController()
        self.delegate?.presentGameViewPanel(sender: self, newPanel: newEquipMarket)
    }
    
    func performShipyard() {
        let newShipyard = ShipMarketPanelViewController()
        self.delegate?.presentGameViewPanel(sender: self, newPanel: newShipyard)
    }
    
    func performJobs() {
        let newJobs = MissionBoardPanelViewController()
        self.delegate?.presentGameViewPanel(sender: self, newPanel: newJobs)
    }
    
    //MARK: - NSTableView
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return actionList.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row < actionList.count {
            return "\(actionList[row])"
        }
        else {
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = self.actionTableView.selectedRow
        if row == -1 {
            return
        }
        self.actionTableView.deselectAll(nil)
        
        if row < 0 || row >= self.actionList.count {
            return
        }
        let action = self.actionList[row]
        switch action {
        case .dock:
            self.performDock()
        case .undock:
            self.performUnDock()
        case .jump:
            self.displayJumpController()
        case .starmap:
            self.displayStarMap()
        case .refuel:
            self.performRefuel()
        case .market:
            self.displayMarket()
        case .equipment:
            self.performEquipmentMarket()
        case .shipyard:
            self.performShipyard()
        case .jobs:
            self.performJobs()
        }
    }
    
}
