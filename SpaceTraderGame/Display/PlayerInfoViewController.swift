//
//  PlayerInfoViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/10/22.
//

import Cocoa

class PlayerInfoViewController: GameViewPanelViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var playerNameLabel: NSTextField!
    @IBOutlet weak var reputationScoreLabel: NSTextField!
    @IBOutlet weak var navigationScoreLabel: NSTextField!
    @IBOutlet weak var combatScoreLabel: NSTextField!
    @IBOutlet weak var negotiationScoreLabel: NSTextField!
    @IBOutlet weak var diplomacyScoreLabel: NSTextField!
    @IBOutlet weak var creditsScoreLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    @IBOutlet weak var hullLabel: NSTextField!
    @IBOutlet weak var engineLabel: NSTextField!
    @IBOutlet weak var fuelLabel: NSTextField!
    @IBOutlet weak var cargoLabel: NSTextField!
    @IBOutlet weak var cargoListTableView : NSTableView!
    
    @IBOutlet weak var heightLayoutConstraint : NSLayoutConstraint!
    @IBOutlet weak var widthLayoutConstaint: NSLayoutConstraint!
    
    private var cargoList : [Commodity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshView()
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Player.playerUpdatedNotification), object: nil, queue: nil) { notification in
            weakSelf?.playerWasUpdated(notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Ship.shipUpdatedNotification), object: nil, queue: nil) { notification in
            weakSelf?.playerWasUpdated(notification)
        }
    }
    
    private func refreshView() {
        self.playerNameLabel.stringValue = self.gameState.player.name
        self.reputationScoreLabel.stringValue = "\(self.gameState.player.reputation)"
        self.navigationScoreLabel.stringValue = "\(self.gameState.player.navigation)"
        self.combatScoreLabel.stringValue = "\(self.gameState.player.combat)"
        self.negotiationScoreLabel.stringValue = "\(self.gameState.player.negotiation)"
        self.diplomacyScoreLabel.stringValue = "\(self.gameState.player.diplomacy)"
        self.creditsScoreLabel.stringValue = "\(self.gameState.player.money)"
        
        let system = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location)
        let systemName = system?.name ?? "Error"
        self.locationLabel.stringValue = systemName
        
        self.hullLabel.stringValue = String(format: "%0.0f/%0.0f", (self.gameState.player.ship.hull - self.gameState.player.ship.hullDamage),(self.gameState.player.ship.hull))
        self.engineLabel.stringValue = String(format: "%0.0f", self.gameState.player.ship.engine)
        self.fuelLabel.stringValue = String(format: "%0.1f/%0.0f", (self.gameState.player.ship.fuel),(self.gameState.player.ship.engine))
        self.cargoLabel.stringValue = String(format: "%0.0f/%0.0f", self.gameState.player.ship.totalCargoWeight(), self.gameState.player.ship.cargo)
        
        self.cargoList = []
        self.gameState.player.ship.commodities.forEach { (key: Commodity, value: Double) in
            if value > 0 {
                self.cargoList.append(key)
            }
        }
        self.cargoListTableView.reloadData()
        
    }
    
    //MARK: - Notification
    
    func playerWasUpdated(_ notification: Notification) {
        self.gameState.saved = false
        self.refreshView()
    }
    
    //MARK: - NSTableView delegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.gameState.player.ship.equipment.count + self.cargoList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let result = self.cargoListTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("Column1"), owner: self) as? TwoLabelTableCellView
        
        if row < self.gameState.player.ship.equipment.count {
            let equip = self.gameState.player.ship.equipment[row]
            result?.textField?.stringValue = String(format: "%@(%0.0f)", equip.type.description, equip.strength)
            result?.rightSideTextField.stringValue = String(format:"%0.0f", equip.weight)
        }
        else {
            let commIndex = row - self.gameState.player.ship.equipment.count
            let comm = self.cargoList[commIndex]
            let qty = Int(self.gameState.player.ship.commodities[comm]!)
            
            result?.textField?.stringValue = "\(comm.shortDescription)"
            result?.rightSideTextField.stringValue = "\(qty)"
        }
        
        return result
    }
}
