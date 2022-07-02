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
    
}
