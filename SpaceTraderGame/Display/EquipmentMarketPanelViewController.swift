//
//  EquipmentMarketPanelViewController.swift
//  SpaceTraderGame
//
//  Created by William Everett on 6/30/22.
//

import Cocoa

class EquipmentMarketPanelViewController: GameViewPanelViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var buyTableView: NSTableView!
    @IBOutlet weak var sellTableView: NSTableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buyTableView.reloadData()
        self.sellTableView.reloadData()
    }
    
    @IBAction func cancelButtonPressed(_ sender: NSButton) {
        self.delegate?.cancelButtonPressed(sender: self)
    }
    
    private func getBuyPriceForEquipment(equip: ShipEquipment, player: Player, system: StarSystem) -> Int {
        return Int(ceil(equip.valueOfEquipment()*(1 + 0.3*(1 - Double(player.negotiation)/100))))
    }
    
    private func getSellPriceForEquipment(equip: ShipEquipment, player: Player, system: StarSystem) -> Int {
        return Int(floor(equip.valueOfEquipment()*(0.8 - 0.3*(1 - Double(player.negotiation)/100))))
    }
    
    private func attemptToBuyEquip(_ equip : ShipEquipment) {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        let price = getBuyPriceForEquipment(equip: equip, player: self.gameState.player, system: currentStar)
        if price > self.gameState.player.money {
            let al = NSAlert()
            al.alertStyle = .informational
            al.messageText = "Too Expensive"
            al.informativeText = "This item costs \(price) credits. You do not have that much."
            al.beginSheetModal(for: self.view.window!)
            return
        }
        
        if equip.weight > self.gameState.player.ship.availableCargoSpace() {
            let al = NSAlert()
            al.alertStyle = .informational
            al.messageText = "Too Heavy"
            al.informativeText = "This item weighs \(Int(round(equip.weight))). You only have available space for \(Int(round(self.gameState.player.ship.availableCargoSpace())))."
            al.beginSheetModal(for: self.view.window!)
            return
        }
        
        let al = NSAlert()
        al.alertStyle = .informational
        al.messageText = "Purchase \(equip.type) \(Int(round(equip.strength)))"
        al.informativeText = "This item costs \(price) credits and weighs \(Int(round(equip.weight)))"
        al.addButton(withTitle: "OK")
        al.addButton(withTitle: "Cancel")
        weak var weakSelf = self
        al.beginSheetModal(for: self.view.window!) { response in
            if response == .alertFirstButtonReturn {
                weakSelf?.completePurchase(equip)
            }
        }
    }
    
    private func completePurchase(_ equip : ShipEquipment) {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        guard let index = currentStar.shipEquipmentMarket.firstIndex(where: { $0 === equip }) else {
            return
        }
        
        let price = getBuyPriceForEquipment(equip: equip, player: self.gameState.player, system: currentStar)
        self.gameState.player.money -= price
        self.gameState.player.ship.equipment.append(equip)
        currentStar.shipEquipmentMarket.remove(at: index)
        self.buyTableView.reloadData()
        
        self.gameState.player.negotiationExperience += (Double(abs(price))/400.0)
        self.gameState.player.playerUpdated()
        self.sellTableView.reloadData()
    }
    
    private func attemptToSellEquip(_ equip : ShipEquipment) {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        let price = getSellPriceForEquipment(equip: equip, player: self.gameState.player, system: currentStar)
        
        let al = NSAlert()
        al.alertStyle = .informational
        al.messageText = "Sell \(equip.type) \(Int(round(equip.strength)))"
        al.informativeText = "This item is worth \(price) credits and weighs \(Int(round(equip.weight)))"
        al.addButton(withTitle: "OK")
        al.addButton(withTitle: "Cancel")
        weak var weakSelf = self
        al.beginSheetModal(for: self.view.window!) { response in
            if response == .alertFirstButtonReturn {
                weakSelf?.completeSale(equip)
            }
        }
    }
    
    private func completeSale(_ equip : ShipEquipment) {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return
        }
        guard let index = self.gameState.player.ship.equipment.firstIndex(where: { $0 === equip }) else {
            return
        }
        let price = getSellPriceForEquipment(equip: equip, player: self.gameState.player, system: currentStar)
        self.gameState.player.money += price
        self.gameState.player.ship.equipment.remove(at: index)
        currentStar.shipEquipmentMarket.append(equip)
        self.buyTableView.reloadData()
        
        self.gameState.player.negotiationExperience += (Double(abs(price))/400.0)
        self.gameState.player.playerUpdated()
        self.sellTableView.reloadData()
    }
    
    //MARK: - Table View
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if tableView == self.sellTableView {
            return self.gameState.player.ship.equipment.count
        }
        else if tableView == self.buyTableView {
            guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
                return 0
            }
            return currentStar.shipEquipmentMarket.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
            return nil
        }
        var equip : ShipEquipment? = nil
        if tableView == self.sellTableView {
            equip = self.gameState.player.ship.equipment[row]
        }
        else if tableView == self.buyTableView {
            
            equip = currentStar.shipEquipmentMarket[row]
        }
        
        if (tableView.tableColumns[0] == tableColumn) {
            return "\(equip!.type)"
        }
        else if (tableView.tableColumns[1] == tableColumn) {
            return "\(Int(equip!.strength))"
        }
        else if (tableView.tableColumns[2] == tableColumn) {
            return "\(Int(equip!.weight))"
        }
        else if (tableView.tableColumns[3] == tableColumn) {
            if tableView == self.sellTableView {
                return "\(self.getSellPriceForEquipment(equip:equip!, player:self.gameState.player, system:currentStar))"
            }
            else if tableView == self.buyTableView {
                return "\(self.getBuyPriceForEquipment(equip:equip!, player:self.gameState.player, system:currentStar))"
            }
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if notification.object as? NSTableView == self.buyTableView {
            let selectionRow = self.buyTableView.selectedRow
            self.buyTableView.deselectAll(nil)
            
            guard let currentStar = self.gameState.galaxyMap.getSystemForId(self.gameState.player.location) else {
                return
            }
            if selectionRow >= 0 && selectionRow < currentStar.shipEquipmentMarket.count {
                self.attemptToBuyEquip(currentStar.shipEquipmentMarket[selectionRow])
            }
        }
        else if notification.object as? NSTableView == self.sellTableView {
            let selectionRow = self.sellTableView.selectedRow
            self.sellTableView.deselectAll(nil)
            if selectionRow >= 0 && selectionRow < self.gameState.player.ship.equipment.count {
                self.attemptToSellEquip(self.gameState.player.ship.equipment[selectionRow])
            }
        }
    }
    
}
