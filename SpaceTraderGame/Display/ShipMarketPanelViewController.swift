//
//  ShipMarketPanelViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 7/6/22.
//

import Cocoa

class ShipMarketPanelViewController: GameViewPanelViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var buyTableView: NSTableView!
    @IBOutlet weak var tradeInPriceLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshView()
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    private func refreshView() {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        currentStar.shipMarket.sort {
            return getBuyPriceForShip(ship: $0, player: self.gameState.player, system: currentStar) < getBuyPriceForShip(ship: $1, player: self.gameState.player, system: currentStar)
        }
        self.tradeInPriceLabel.stringValue = "\(self.getSellPriceForShip(ship: self.gameState.player.ship, player: self.gameState.player, system: currentStar))"
        self.buyTableView.reloadData()
    }
    
    private func getBuyPriceForShip(ship: Ship, player: Player, system: StarSystem) -> Int {
        return Int(ceil(ship.baseValueOfShip())*(1 + 0.3*(1 - Double(player.negotiation)/100)))
    }
    
    private func getSellPriceForShip(ship: Ship, player: Player, system: StarSystem) -> Int {
        let startPrice = ship.baseValueOfShip()*(0.8 - 0.3*(1 - Double(player.negotiation)/100))
        let damageAdjust = startPrice - system.getRepairCost()*ship.hullDamage - system.getFuelCost()*(ship.engine - ship.fuel)
        return Int(floor(damageAdjust))
    }
    
    private func attemptToBuyShip(_ ship : Ship) {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        let price = getBuyPriceForShip(ship: ship, player: self.gameState.player, system: currentStar)
        let tradein = getSellPriceForShip(ship: self.gameState.player.ship, player: self.gameState.player, system: currentStar)
        if (price - tradein) > self.gameState.player.money {
            let al = NSAlert()
            al.alertStyle = .informational
            al.messageText = "Too Expensive"
            al.informativeText = "This ship costs \(price - tradein) credits. You do not have that much."
            al.beginSheetModal(for: self.view.window!)
            return
        }
        
        if self.gameState.player.ship.totalCargoWeight() > ship.cargo {
            let al = NSAlert()
            al.alertStyle = .informational
            al.messageText = "Insufficient Cargo Space"
            al.informativeText = "You currently have \(Int(self.gameState.player.ship.totalCargoWeight())) tonnes of cargo. There is insufficent space in the ship you wish to buy."
            al.beginSheetModal(for: self.view.window!)
            return
        }
        
        let al = NSAlert()
        al.alertStyle = .informational
        al.messageText = "Purchase ship - engine: \(Int(ship.engine))  hull: \(Int(ship.hull))  cargo: \(Int(ship.cargo))"
        al.informativeText = "This ship costs \(price - tradein) credits (after trade-in)"
        al.addButton(withTitle: "OK")
        al.addButton(withTitle: "Cancel")
        weak var weakSelf = self
        al.beginSheetModal(for: self.view.window!) { response in
            if response == .alertFirstButtonReturn {
                weakSelf?.completePurchase(ship)
            }
        }
    }
    
    private func completePurchase(_ ship : Ship) {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        guard let index = currentStar.shipMarket.firstIndex(where: { $0 === ship }) else {
            return
        }
        
        let price = getBuyPriceForShip(ship: ship, player: self.gameState.player, system: currentStar) - getSellPriceForShip(ship: self.gameState.player.ship, player: self.gameState.player, system: currentStar)
        self.gameState.player.money -= price
        let oldShip = self.gameState.player.ship
        self.gameState.player.ship = ship
        self.gameState.player.ship.equipment = oldShip!.equipment
        self.gameState.player.ship.fuel = self.gameState.player.ship.engine
        currentStar.shipMarket.remove(at: index)
        oldShip!.equipment.removeAll()
        oldShip!.hullDamage = 0
        currentStar.shipMarket.append(oldShip!)
        
        self.gameState.player.negotiationExperience += (Double(abs(price))/300.0)
        self.gameState.player.playerUpdated()
        self.refreshView()
    }
    
    
    //MARK: - Table View
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return 0
        }
        return currentStar.shipMarket.count

    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return nil
        }
        let ship = currentStar.shipMarket[row]
        
        if (tableView.tableColumns[0] == tableColumn) {
            return "\(Int(ship.engine))"
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            return "\(Int(ship.hull))"
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            return "\(Int(ship.cargo))"
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            return "\(self.getBuyPriceForShip(ship: ship, player: self.gameState.player, system: currentStar))"
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectionRow = self.buyTableView.selectedRow
        self.buyTableView.deselectAll(nil)
        
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        if selectionRow >= 0 && selectionRow < currentStar.shipMarket.count {
            self.attemptToBuyShip(currentStar.shipMarket[selectionRow])
        }
        
    }
    
}
